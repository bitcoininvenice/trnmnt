import 'dart:math';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';

/// Provider for matches in a tournament
final tournamentMatchesProvider = StreamProvider.family<List<MatchWithTeams>, int>((ref, tournamentId) {
  final db = ref.watch(dbProvider);
  
  final query = db.select(db.matches)
    ..where((m) => m.tournamentId.equals(tournamentId))
    ..orderBy([(m) => OrderingTerm.asc(m.round), (m) => OrderingTerm.asc(m.id)]);

  return query.watch().asyncMap((matches) async {
    final result = <MatchWithTeams>[];
    for (final match in matches) {
      Team? homeTeam;
      Team? awayTeam;
      
      if (match.homeTeamId != null) {
        homeTeam = await (db.select(db.teams)..where((t) => t.id.equals(match.homeTeamId!))).getSingleOrNull();
      }
      if (match.awayTeamId != null) {
        awayTeam = await (db.select(db.teams)..where((t) => t.id.equals(match.awayTeamId!))).getSingleOrNull();
      }
      
      result.add(MatchWithTeams(match: match, homeTeam: homeTeam, awayTeam: awayTeam));
    }
    return result;
  });
});

/// Provider for group matches
final groupMatchesProvider = FutureProvider.family<List<MatchWithTeams>, int>((ref, tournamentId) async {
  final matches = await ref.watch(tournamentMatchesProvider(tournamentId).future);
  return matches.where((m) => m.match.phase == 'group').toList();
});

/// Combined match data with team info
class MatchWithTeams {
  final Matche match;
  final Team? homeTeam;
  final Team? awayTeam;

  MatchWithTeams({required this.match, this.homeTeam, this.awayTeam});
}

/// Matches repository
class MatchesRepository {
  final AppDatabase _db;

  MatchesRepository(this._db);

  /// Generate round-robin calendar for group phase
  Future<void> generateGroupCalendar(int tournamentId) async {
    // Get tournament teams
    final tournamentTeams = await (_db.select(_db.tournamentTeams)
      ..where((tt) => tt.tournamentId.equals(tournamentId)))
      .get();

    if (tournamentTeams.isEmpty) return;

    // Delete existing group matches
    await (_db.delete(_db.matches)
      ..where((m) => m.tournamentId.equals(tournamentId) & m.phase.equals('group')))
      .go();

    final teamIds = tournamentTeams.map((tt) => tt.teamId).toList();
    final numTeams = teamIds.length;
    
    // Add BYE team if odd number
    final List<int?> teams = List.from(teamIds);
    if (numTeams % 2 != 0) {
      teams.add(null); // null represents BYE
    }
    
    final n = teams.length;
    final numRounds = n - 1;
    final matchesPerRound = n ~/ 2;
    
    // Shuffle teams for random order
    teams.shuffle(Random());
    
    // Round-robin algorithm (circle method)
    for (var round = 0; round < numRounds; round++) {
      for (var match = 0; match < matchesPerRound; match++) {
        final home = match;
        final away = n - 1 - match;
        
        final homeTeam = teams[home];
        final awayTeam = teams[away];
        
        // Skip if both are null (shouldn't happen) or create BYE match
        if (homeTeam == null && awayTeam == null) continue;
        
        final isBye = homeTeam == null || awayTeam == null;
        
        await _db.into(_db.matches).insert(
          MatchesCompanion.insert(
            tournamentId: tournamentId,
            homeTeamId: Value(homeTeam),
            awayTeamId: Value(awayTeam),
            round: Value(round + 1),
            phase: const Value('group'),
            isBye: Value(isBye),
          ),
        );
      }
      
      // Rotate teams (keep first team fixed)
      if (teams.length > 1) {
        final last = teams.removeLast();
        teams.insert(1, last);
      }
    }
  }

  /// Update match score and propagate winner in bracket
  Future<bool> updateMatchScore(int matchId, int homeScore, int awayScore) async {
    final success = await (_db.update(_db.matches)..where((m) => m.id.equals(matchId))).write(
      MatchesCompanion(
        homeScore: Value(homeScore),
        awayScore: Value(awayScore),
        isCompleted: const Value(true),
      ),
    ) > 0;

    if (success) {
      await _propagateBracketWinner(matchId, homeScore, awayScore);
    }

    return success;
  }

  /// Propagate winner/loser to next round
  Future<void> _propagateBracketWinner(int matchId, int homeScore, int awayScore) async {
    // Get the completed match
    final match = await (_db.select(_db.matches)..where((m) => m.id.equals(matchId))).getSingleOrNull();
    if (match == null || match.phase == 'group') return;

    final winnerId = homeScore > awayScore ? match.homeTeamId : match.awayTeamId;
    final loserId = homeScore > awayScore ? match.awayTeamId : match.homeTeamId;

    if (winnerId == null) return; // Should likely handle draws if needed, but for now assume winner exists

    String? nextPhase;
    int? nextRound;
    bool? isHomeSlot;

    // Determine next match based on current phase and round
    if (match.phase == 'quarterfinal') {
      nextPhase = 'semifinal';
      // QF1(1) -> SF1(1) Home
      // QF2(2) -> SF1(1) Away
      // QF3(3) -> SF2(2) Home
      // QF4(4) -> SF2(2) Away
      nextRound = (match.round <= 2) ? 1 : 2;
      isHomeSlot = (match.round % 2 != 0); // 1, 3 -> Home; 2, 4 -> Away

      // Handle losers for 5th-8th bracket
      // Logic: Losers of QF go to Consolation Semifinals (if they exist)
      // Check if 'consolation_semifinal' matches exist in DB (meaning 8 team bracket with consolation)
      // We assume they exist if it's an 8-team QF.
      if (loserId != null) {
         // QF1 Loser -> CSF1(1) Home
         // QF2 Loser -> CSF1(1) Away
         // QF3 Loser -> CSF2(2) Home
         // QF4 Loser -> CSF2(2) Away
         await _updateNextMatch(
          match.tournamentId,
          'consolation_semifinal',
          nextRound,
          isHomeSlot,
          loserId,
        );
      }
    } else if (match.phase == 'semifinal') {
      nextPhase = 'final';
      nextRound = 1;
      // SF1(1) -> Final(1) Home
      // SF2(2) -> Final(1) Away
      isHomeSlot = (match.round == 1);

      // Consolation Final (3rd/4th)
      if (loserId != null) {
        await _updateNextMatch(
          match.tournamentId,
          'third_place',
          1,
          isHomeSlot,
          loserId,
        );
      }
    } else if (match.phase == 'consolation_semifinal') {
      // Winners go to 5th/6th place final
      // Losers go to 7th/8th place final
      nextPhase = 'fifth_place';
      nextRound = 1;
      // CSF1(1) -> 5th(1) Home
      // CSF2(2) -> 5th(1) Away
      isHomeSlot = (match.round == 1);

      // 7th/8th Place
      if (loserId != null) {
        await _updateNextMatch(
          match.tournamentId,
          'seventh_place',
          1,
          isHomeSlot,
          loserId,
        );
      }
    }

    if (nextPhase != null && nextRound != null && isHomeSlot != null) {
      await _updateNextMatch(
        match.tournamentId,
        nextPhase,
        nextRound,
        isHomeSlot,
        winnerId,
      );
    }
  }

  Future<void> _updateNextMatch(
    int tournamentId,
    String phase,
    int round,
    bool isHomeSlot,
    int teamId,
  ) async {
    final nextMatch = await (_db.select(_db.matches)
      ..where((m) => 
        m.tournamentId.equals(tournamentId) & 
        m.phase.equals(phase) & 
        m.round.equals(round)
      )).getSingleOrNull();

    if (nextMatch != null) {
      await (_db.update(_db.matches)..where((m) => m.id.equals(nextMatch.id))).write(
        isHomeSlot 
          ? MatchesCompanion(homeTeamId: Value(teamId))
          : MatchesCompanion(awayTeamId: Value(teamId))
      );
    }
  }

  /// Create a single match
  Future<int> createMatch({
    required int tournamentId,
    int? homeTeamId,
    int? awayTeamId,
    required int round,
    required String phase,
    bool isBye = false,
  }) async {
    return await _db.into(_db.matches).insert(
      MatchesCompanion.insert(
        tournamentId: tournamentId,
        homeTeamId: Value(homeTeamId),
        awayTeamId: Value(awayTeamId),
        round: Value(round),
        phase: Value(phase),
        isBye: Value(isBye),
      ),
    );
  }

  /// Delete all matches for a tournament phase
  Future<int> deleteMatchesByPhase(int tournamentId, String phase) async {
    return await (_db.delete(_db.matches)
      ..where((m) => m.tournamentId.equals(tournamentId) & m.phase.equals(phase)))
      .go();
  }
}

/// Provider for matches repository
final matchesRepositoryProvider = Provider<MatchesRepository>((ref) {
  final db = ref.watch(dbProvider);
  return MatchesRepository(db);
});
