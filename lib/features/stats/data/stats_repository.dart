import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';

class HallOfFameEntry {
  final int tournamentId;
  final String tournamentName;
  final String location;
  final int teamCount;
  final String mode;
  final String? winningTeam;
  final int? winnerWins;
  final int? winnerLosses;
  final int? winnerPointsFor;
  final int? winnerPointsAgainst;
  final DateTime? startDate;
  final DateTime createdAt;

  const HallOfFameEntry({
    required this.tournamentId,
    required this.tournamentName,
    required this.location,
    required this.teamCount,
    required this.mode,
    required this.createdAt,
    this.startDate,
    this.winningTeam,
    this.winnerWins,
    this.winnerLosses,
    this.winnerPointsFor,
    this.winnerPointsAgainst,
  });
}

class AppStats {
  final int totalTeams;
  final int totalTournaments;
  final int activeTournaments;
  final int totalPoints;
  final int totalCourts;
  final int totalMatches;
  final List<HallOfFameEntry> hallOfFame;

  const AppStats({
    required this.totalTeams,
    required this.totalTournaments,
    required this.activeTournaments,
    required this.totalPoints,
    required this.totalCourts,
    required this.totalMatches,
    required this.hallOfFame,
  });
}

class StatsRepository {
  final AppDatabase _db;

  StatsRepository(this._db);

  Future<AppStats> getAppStats() async {
    // 1. Total Teams
    final teamsRes = await _db.customSelect('SELECT COUNT(*) AS c FROM teams').getSingle();
    final totalTeams = teamsRes.read<int>('c');

    // 2. Total Tournaments
    final tourneysRes = await _db.customSelect('SELECT COUNT(*) AS c FROM tournaments').getSingle();
    final totalTournaments = tourneysRes.read<int>('c');

    // 3. Active Tournaments
    final activeRes = await _db.customSelect('''
      SELECT COUNT(*) AS c FROM tournaments t
      WHERE t.is_active = 1
      AND t.id NOT IN (
        SELECT tournament_id FROM matches WHERE phase = 'final' AND is_completed = 1
      )
    ''').getSingle();
    final activeTournaments = activeRes.read<int>('c');

    // 4. Total Points Scored
    final pointsRes = await _db.customSelect('SELECT SUM(home_score + away_score) AS c FROM matches WHERE is_completed = 1').getSingle();
    final totalPoints = pointsRes.read<int?>('c') ?? 0;

    // 5. Total Courts
    final courtsRes = await _db.customSelect('SELECT COUNT(*) AS c FROM courts').getSingle();
    final totalCourts = courtsRes.read<int>('c');

    // M. Total Matches Played
    final matchesRes = await _db.customSelect('SELECT COUNT(*) AS c FROM matches WHERE is_completed = 1').getSingle();
    final totalMatches = matchesRes.read<int>('c');

    // 6. Hall of Fame
    final tournaments = await _db.select(_db.tournaments).get();
    final List<HallOfFameEntry> hallOfFame = [];

    for (final t in tournaments) {
      final teamCountRes = await _db.customSelect(
        'SELECT COUNT(*) as c FROM tournament_teams WHERE tournament_id = ?', 
        variables: [Variable.withInt(t.id)]
      ).getSingle();
      final teamCount = teamCountRes.read<int>('c');

      String? winnerName;
      int? winnerWins;
      int? winnerLosses;
      int? winnerPointsFor;
      int? winnerPointsAgainst;
      int? winnerId;

      // Try finding final match winner
      final finalMatch = await _db.customSelect(
        "SELECT home_score, away_score, home_team_id, away_team_id FROM matches WHERE tournament_id = ? AND phase = 'final' AND is_completed = 1 LIMIT 1",
        variables: [Variable.withInt(t.id)]
      ).getSingleOrNull();

      if (finalMatch != null) {
        final hs = finalMatch.read<int>('home_score');
        final as = finalMatch.read<int>('away_score');
        winnerId = hs > as ? finalMatch.read<int>('home_team_id') : finalMatch.read<int>('away_team_id');
      } else {
        // Fallback to standings order
        final isMadness = t.mode == 'madness';
        final standingQuery = isMadness 
          ? 'SELECT team_id, SUM(score) as pts FROM (SELECT home_team_id as team_id, home_score as score FROM matches WHERE tournament_id = ? AND is_completed = 1 UNION ALL SELECT away_team_id as team_id, away_score as score FROM matches WHERE tournament_id = ? AND is_completed = 1) GROUP BY team_id ORDER BY pts DESC LIMIT 1'
          : 'SELECT team_id, SUM(pts) as pts FROM (SELECT home_team_id as team_id, CASE WHEN home_score > away_score THEN ? WHEN home_score = away_score THEN ? ELSE ? END as pts FROM matches WHERE tournament_id = ? AND is_completed = 1 UNION ALL SELECT away_team_id as team_id, CASE WHEN away_score > home_score THEN ? WHEN home_score = away_score THEN ? ELSE ? END as pts FROM matches WHERE tournament_id = ? AND is_completed = 1) GROUP BY team_id ORDER BY pts DESC LIMIT 1';
        
        final standingVars = isMadness ? [Variable.withInt(t.id), Variable.withInt(t.id)] : [
          Variable.withInt(t.winPoints), Variable.withInt(t.drawPoints), Variable.withInt(t.lossPoints), Variable.withInt(t.id),
          Variable.withInt(t.winPoints), Variable.withInt(t.drawPoints), Variable.withInt(t.lossPoints), Variable.withInt(t.id),
        ];

        final result = await _db.customSelect(standingQuery, variables: standingVars).getSingleOrNull();
        if (result != null) {
          winnerId = result.read<int>('team_id');
        }
      }

      if (winnerId != null) {
        final team = await (_db.select(_db.teams)..where((tm) => tm.id.equals(winnerId!))).getSingleOrNull();
        winnerName = team?.name ?? 'Sconosciuta';

        final sRows = await _db.customSelect(
          '''
          SELECT 
            SUM(CASE WHEN (home_team_id = ? AND home_score > away_score) OR (away_team_id = ? AND away_score > home_score) THEN 1 ELSE 0 END) AS wins,
            SUM(CASE WHEN (home_team_id = ? AND home_score < away_score) OR (away_team_id = ? AND away_score < home_score) THEN 1 ELSE 0 END) AS losses,
            SUM(CASE WHEN home_team_id = ? THEN home_score WHEN away_team_id = ? THEN away_score ELSE 0 END) AS points_for,
            SUM(CASE WHEN home_team_id = ? THEN away_score WHEN away_team_id = ? THEN home_score ELSE 0 END) AS points_against
          FROM matches 
          WHERE tournament_id = ? AND is_completed = 1 
            AND (home_team_id = ? OR away_team_id = ?)
          ''',
          variables: [
            Variable.withInt(winnerId), Variable.withInt(winnerId), 
            Variable.withInt(winnerId), Variable.withInt(winnerId), 
            Variable.withInt(winnerId), Variable.withInt(winnerId), 
            Variable.withInt(winnerId), Variable.withInt(winnerId), 
            Variable.withInt(t.id),
            Variable.withInt(winnerId), Variable.withInt(winnerId)
          ]
        ).getSingle();

        winnerWins = sRows.read<int>('wins');
        winnerLosses = sRows.read<int>('losses');
        winnerPointsFor = sRows.read<int>('points_for');
        winnerPointsAgainst = sRows.read<int>('points_against');
      } else {
        winnerName = t.isActive ? "In corso..." : "Nessun Vincitore";
      }

      hallOfFame.add(HallOfFameEntry(
        tournamentId: t.id,
        tournamentName: t.name,
        location: t.location,
        teamCount: teamCount,
        mode: t.mode,
        startDate: t.startDate,
        createdAt: t.createdAt,
        winningTeam: winnerName,
        winnerWins: winnerWins,
        winnerLosses: winnerLosses,
        winnerPointsFor: winnerPointsFor,
        winnerPointsAgainst: winnerPointsAgainst,
      ));
    }

    return AppStats(
      totalTeams: totalTeams,
      totalTournaments: totalTournaments,
      activeTournaments: activeTournaments,
      totalPoints: totalPoints,
      totalCourts: totalCourts,
      totalMatches: totalMatches,
      hallOfFame: hallOfFame,
    );
  }

  Stream<AppStats> watchAppStats() {
    return Rx.combineLatest4(
      _db.select(_db.teams).watch(),
      _db.select(_db.tournaments).watch(),
      _db.select(_db.matches).watch(),
      _db.select(_db.courts).watch(),
      (a, b, c, d) => null,
    ).asyncMap((_) => getAppStats());
  }
}

final appStatsProvider = StreamProvider<AppStats>((ref) {
  final db = ref.watch(dbProvider);
  final repo = StatsRepository(db);
  return repo.watchAppStats();
});
