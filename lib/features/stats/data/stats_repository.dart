import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
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
    final teamsCount = await _db.customSelect('SELECT COUNT(*) AS c FROM teams').getSingle();
    final totalTeams = teamsCount.read<int?>('c') ?? 0;

    // 2. Total Tournaments
    final tourneysCount = await _db.customSelect('SELECT COUNT(*) AS c FROM tournaments').getSingle();
    final totalTournaments = tourneysCount.read<int?>('c') ?? 0;

    // 3. Active Tournaments
    final activeCount = await _db.customSelect('''
      SELECT COUNT(*) AS c FROM tournaments t
      WHERE t.is_active = 1
      AND t.id NOT IN (
        -- Exclude those with a completed final
        SELECT tournament_id FROM matches WHERE phase = 'final' AND is_completed = 1
      )
      AND (
        -- For group_only, must have at least one uncompleted match
        t.mode != 'group_only' 
        OR EXISTS (SELECT 1 FROM matches m WHERE m.tournament_id = t.id AND m.is_completed = 0)
        OR NOT EXISTS (SELECT 1 FROM matches m WHERE m.tournament_id = t.id)
      )
    ''').getSingle();
    final activeTournaments = activeCount.read<int?>('c') ?? 0;

    // 4. Total Points Scored
    final pointsResult = await _db.customSelect('SELECT SUM(IFNULL(home_score, 0) + IFNULL(away_score, 0)) AS c FROM matches WHERE is_completed = 1').getSingle();
    final totalPoints = pointsResult.read<int?>('c') ?? 0;

    // 5. Total Courts
    final courtsCount = await _db.customSelect('SELECT COUNT(*) AS c FROM courts').getSingle();
    final totalCourts = courtsCount.read<int?>('c') ?? 0;

    // M. Total Matches Played
    final totalMatchesCount = await _db.customSelect('SELECT COUNT(*) AS c FROM matches WHERE is_completed = 1').getSingle();
    final totalMatches = totalMatchesCount.read<int?>('c') ?? 0;

    // 6. Hall of Fame
    final tournaments = await _db.select(_db.tournaments).get();
    final List<HallOfFameEntry> hallOfFame = [];

    for (final t in tournaments) {
      final teamCountQuery = await _db.customSelect(
        'SELECT COUNT(*) as c FROM tournament_teams WHERE tournament_id = ?', 
        variables: [Variable.withInt(t.id)]
      ).getSingle();
      final teamCount = teamCountQuery.read<int?>('c') ?? 0;

      String? winnerName;
      int? winnerWins;
      int? winnerLosses;
      int? winnerPointsFor;
      int? winnerPointsAgainst;

      // Se non c'è una finale consideriamo la squadra con più punti se il torneo non è attivo.
      // Più semplice: recuperiamo la finale conclusa.
      final finalMatchRows = await _db.customSelect(
        '''
        SELECT m.home_score, m.away_score, ht.name as h_name, at.name as a_name, m.home_team_id, m.away_team_id, m.phase
        FROM matches m
        LEFT JOIN teams ht ON m.home_team_id = ht.id
        LEFT JOIN teams at ON m.away_team_id = at.id
        WHERE m.tournament_id = ? 
          AND (m.phase = 'final' OR m.phase = 'group') 
          AND m.is_completed = 1
        ORDER BY m.phase ASC, m.id DESC
        ''', 
        variables: [Variable.withInt(t.id)]
      ).get();

      final finalMatches = finalMatchRows.where((r) => r.read<String>('phase') == 'final').toList();
      int? winnerId;

      if (finalMatches.isNotEmpty) {
        final row = finalMatches.first;
          final homeScore = row.read<int?>('home_score') ?? 0;
          final awayScore = row.read<int?>('away_score') ?? 0;

          if (homeScore > awayScore) {
            winnerName = row.read<String?>('h_name');
            winnerId = row.read<int?>('home_team_id');
          } else if (awayScore > homeScore) {
            winnerName = row.read<String?>('a_name');
            winnerId = row.read<int?>('away_team_id');
          } else {
            winnerName = 'Pareggio/Sconosciuto';
          }
        } 
        
        // Se non abbiamo ancora un vincitore dalla finale, cercatelo dalla classifica (Gironi)
        if (winnerId == null) {
           // Trova il vincitore dai punti (girone)
           final bestTeamRows = await _db.customSelect('''
              SELECT team_id, SUM(pts) as classification_points FROM (
                SELECT home_team_id as team_id, 
                       CASE WHEN home_score > away_score THEN ? 
                            WHEN home_score = away_score THEN ? 
                            ELSE ? END as pts
                FROM matches WHERE tournament_id = ? AND is_completed = 1 AND home_team_id IS NOT NULL
                UNION ALL
                SELECT away_team_id as team_id, 
                       CASE WHEN away_score > home_score THEN ? 
                            WHEN home_score = away_score THEN ? 
                            ELSE ? END as pts
                FROM matches WHERE tournament_id = ? AND is_completed = 1 AND away_team_id IS NOT NULL
              )
              GROUP BY team_id ORDER BY classification_points DESC LIMIT 1
           ''', variables: [
             Variable.withInt(t.winPoints), Variable.withInt(t.drawPoints), Variable.withInt(t.lossPoints), Variable.withInt(t.id),
             Variable.withInt(t.winPoints), Variable.withInt(t.drawPoints), Variable.withInt(t.lossPoints), Variable.withInt(t.id),
           ]).get();

           if (bestTeamRows.isNotEmpty) {
             winnerId = bestTeamRows.first.read<int>('team_id');
             final teamRow = await _db.customSelect('SELECT name FROM teams WHERE id = ?', variables: [Variable.withInt(winnerId)]).getSingleOrNull();
             winnerName = teamRow?.read<String>('name') ?? 'Sconosciuta';
           } else {
             winnerName = t.isActive ? "In corso..." : "Nessun Vincitore";
           }
        }

        if (winnerId != null) {
          final statsRows = await _db.customSelect(
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
          ).get();

          if (statsRows.isNotEmpty) {
             winnerWins = statsRows.first.read<double?>('wins')?.toInt();
             winnerLosses = statsRows.first.read<double?>('losses')?.toInt();
             winnerPointsFor = statsRows.first.read<double?>('points_for')?.toInt();
             winnerPointsAgainst = statsRows.first.read<double?>('points_against')?.toInt();
          }
        }

      String modeStr;
      if (t.mode == 'group_only') modeStr = 'Girone';
      else if (t.mode == 'elimination_only') modeStr = 'Eliminazione Diretta';
      else modeStr = 'Gironi + Playoffs';

      hallOfFame.add(HallOfFameEntry(
        tournamentId: t.id,
        tournamentName: t.name,
        location: t.location,
        teamCount: teamCount,
        mode: t.mode, // Use raw mode for UI-level localization
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
}

final appStatsProvider = FutureProvider<AppStats>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  final repo = StatsRepository(db);
  return repo.getAppStats();
});
