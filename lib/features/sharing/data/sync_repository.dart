import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trnmnt/core/database/app_database.dart';
import 'package:trnmnt/core/providers/database_provider.dart';

class SyncRepository {
  final AppDatabase _db;
  RealtimeChannel? _subscription;

  SyncRepository(this._db);

  /// Subscribes to realtime updates for a specific tournament on Supabase
  void subscribeToTournament(String cloudId, int tournamentId) {
    _subscription?.unsubscribe();
    
    final supabase = Supabase.instance.client;
    
    _subscription = supabase
        .channel('tournament_sync_$cloudId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'published_tournaments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: cloudId,
          ),
          callback: (payload) {
            final data = payload.newRecord['data'] as Map<String, dynamic>?;
            if (data != null) {
              _handleCloudUpdate(tournamentId, data);
            }
          },
        )
        .subscribe();
  }

  void unsubscribe() {
    _subscription?.unsubscribe();
    _subscription = null;
  }

  Future<void> _handleCloudUpdate(int tournamentId, Map<String, dynamic> data) async {
    final tournamentData = data['tournament'] as Map<String, dynamic>?;
    final teamsData = data['teams'] as List<dynamic>?;
    final matchesData = data['matches'] as List<dynamic>?;
    
    if (tournamentData == null || teamsData == null || matchesData == null) return;

    // 1. Update general tournament info
    await (_db.update(_db.tournaments)..where((t) => t.id.equals(tournamentId))).write(
      TournamentsCompanion(
        name: Value(tournamentData['name']),
        location: Value(tournamentData['location']),
        mode: Value(tournamentData['mode']),
        isActive: Value(tournamentData['isActive'] ?? true),
        groupCount: Value(tournamentData['groupCount'] ?? 1),
      ),
    );

    // 2. Map Teams by NAME (safer than IDs which diverge between devices)
    final Map<int, int> teamMapping = {}; // { RemoteId : LocalId }
    
    // Fetch current local teams
    final localTeams = await (
      _db.select(_db.tournamentTeams).join([
        innerJoin(_db.teams, _db.teams.id.equalsExp(_db.tournamentTeams.teamId)),
      ])..where(_db.tournamentTeams.tournamentId.equals(tournamentId))
    ).get();

    for (final teamJson in teamsData) {
      final remoteId = teamJson['id'] as int;
      final teamName = teamJson['name'] as String;
      
      // Try to find local match by name
      final localTeam = localTeams.where((row) => row.readTable(_db.teams).name == teamName).firstOrNull;
      
      if (localTeam != null) {
        teamMapping[remoteId] = localTeam.readTable(_db.teams).id;
      } else {
        // Team was added by creator but we don't have it! Let's insert it
        final newTeamId = await _db.into(_db.teams).insert(
          TeamsCompanion.insert(
            name: teamName,
            logoPath: Value(teamJson['logoPath']),
          )
        );
        await _db.into(_db.tournamentTeams).insert(
          TournamentTeamsCompanion.insert(
            tournamentId: tournamentId,
            teamId: newTeamId,
            groupNumber: Value(teamJson['groupNumber'] ?? 1),
          )
        );
        teamMapping[remoteId] = newTeamId;
      }
    }

    // 3. Smart Matches Sync (Preserving IDs to avoid UI breakage)
    // We map local matches by a stable key: "phase_round_home_away"
    final localMatches = await (_db.select(_db.matches)
      ..where((m) => m.tournamentId.equals(tournamentId))).get();
    
    final Map<String, int> localMatchesMapByTeams = {
      for (var m in localMatches) 
        if (m.homeTeamId != null && m.awayTeamId != null)
          '${m.phase}_${m.round}_${m.homeTeamId}_${m.awayTeamId}': m.id
    };

    // Store indices of matches we've already synced to avoid duplicate inserts
    final List<int> processedLocalIds = [];

    await _db.batch((batch) {
      for (final m in matchesData) {
        final homeRemoteId = m['homeTeamId'] as int?;
        final awayRemoteId = m['awayTeamId'] as int?;
        
        final localHomeId = homeRemoteId != null ? teamMapping[homeRemoteId] : null;
        final localAwayId = awayRemoteId != null ? teamMapping[awayRemoteId] : null;
        
        // 3.1 Try to find match by TEAMS first (stable across devices)
        int? existingId;
        if (localHomeId != null && localAwayId != null) {
          final String teamsKey = '${m['phase'] ?? 'group'}_${m['round'] ?? 1}_${localHomeId}_${localAwayId}';
          existingId = localMatchesMapByTeams[teamsKey];
        }

        // 3.2 If not found by teams and we are in bracket/knockout, 
        // fallback to Index-based matching if the local list size matches
        if (existingId == null) {
          final int? rIndex = m['remoteIndex'] as int?;
          if (rIndex != null && rIndex < localMatches.length) {
            existingId = localMatches[rIndex].id;
          }
        }

        if (existingId != null) {
          processedLocalIds.add(existingId);
          
          final localMatch = localMatches.firstWhere((lm) => lm.id == existingId);
          final bool remoteCompleted = m['isCompleted'] ?? false;
          final int remoteHomeScore = m['homeScore'] ?? 0;
          final int remoteAwayScore = m['awayScore'] ?? 0;

          // SMART SCORE UPDATE LOGIC:
          // 1. If remote is completed and local isn't, ALWAYS take remote (final result is king)
          // 2. If both are live, only take remote scores if local is still 0-0 (initial sync)
          //    to avoid overwriting active work on this device.
          bool shouldUpdateScores = false;
          if (remoteCompleted && !localMatch.isCompleted) {
            shouldUpdateScores = true;
          } else if (!remoteCompleted && !localMatch.isCompleted) {
            if (localMatch.homeScore == 0 && localMatch.awayScore == 0) {
              shouldUpdateScores = true;
            }
          }

          batch.update(
            _db.matches,
            MatchesCompanion(
              homeScore: shouldUpdateScores ? Value(remoteHomeScore) : const Value.absent(),
              awayScore: shouldUpdateScores ? Value(remoteAwayScore) : const Value.absent(),
              isCompleted: Value(remoteCompleted),
              isBye: Value(m['isBye'] ?? false),
              scheduledAt: Value(m['scheduledAt'] != null 
                  ? DateTime.tryParse(m['scheduledAt'].toString()) 
                  : null),
            ),
            where: (row) => row.id.equals(existingId!),
          );
        } else {
          // INSERT new match
          batch.insert(
            _db.matches,
            MatchesCompanion.insert(
              tournamentId: tournamentId,
              homeTeamId: Value(localHomeId),
              awayTeamId: Value(localAwayId),
              homeScore: Value(m['homeScore']),
              awayScore: Value(m['awayScore']),
              round: Value(m['round'] ?? 1),
              phase: Value(m['phase'] ?? 'group'),
              groupNumber: Value(m['groupNumber'] ?? 1),
              isCompleted: Value(m['isCompleted'] ?? false),
              isBye: Value(m['isBye'] ?? false),
              scheduledAt: Value(m['scheduledAt'] != null 
                  ? DateTime.tryParse(m['scheduledAt'].toString()) 
                  : null),
            ),
          );
        }
      }

      // 4. Pruning: Delete matches that are no longer in the cloud
      // We only delete IDs that WERE here locally but were not found in the cloud bundle
      final originalLocalIds = localMatches.map((lm) => lm.id).toList();
      final idsToRemove = originalLocalIds.where((id) => !processedLocalIds.contains(id)).toList();
      
      if (idsToRemove.isNotEmpty) {
        batch.deleteWhere(_db.matches, (t) => t.id.isIn(idsToRemove));
      }
    });
  }
}

final syncRepositoryProvider = Provider((ref) {
  final db = ref.watch(dbProvider);
  return SyncRepository(db);
});
