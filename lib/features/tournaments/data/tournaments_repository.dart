import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';

/// Provider for all tournaments
final tournamentsProvider = StreamProvider<List<Tournament>>((ref) {
  final db = ref.watch(dbProvider);
  return (db.select(db.tournaments)
    ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
    .watch();
});

/// Provider for a single tournament by ID
final tournamentByIdProvider = StreamProvider.family<Tournament?, int>((ref, id) {
  final db = ref.watch(dbProvider);
  return (db.select(db.tournaments)..where((t) => t.id.equals(id)))
      .watchSingleOrNull();
});

/// Provider for teams in a tournament
final tournamentTeamsProvider = StreamProvider.family<List<TournamentTeamWithTeam>, int>((ref, tournamentId) {
  final db = ref.watch(dbProvider);
  final query = db.select(db.tournamentTeams).join([
    innerJoin(db.teams, db.teams.id.equalsExp(db.tournamentTeams.teamId)),
  ])..where(db.tournamentTeams.tournamentId.equals(tournamentId));
  
  return query.watch().map((rows) => rows.map((row) {
    return TournamentTeamWithTeam(
      tournamentTeam: row.readTable(db.tournamentTeams),
      team: row.readTable(db.teams),
    );
  }).toList());
});

/// Combined data class for tournament team with team info
class TournamentTeamWithTeam {
  final TournamentTeam tournamentTeam;
  final Team team;

  TournamentTeamWithTeam({required this.tournamentTeam, required this.team});
}

/// Tournaments repository for CRUD operations
class TournamentsRepository {
  final AppDatabase _db;

  TournamentsRepository(this._db);

  Future<int> createTournament({
    required String name,
    required String location,
    required String mode,
    required String scoringSystem,
    int winPoints = 2,
    int drawPoints = 0,
    int lossPoints = 1,
    bool includeConsolationFinals = false,
    int timerMinutes = 10,
  }) async {
    return await _db.into(_db.tournaments).insert(
      TournamentsCompanion.insert(
        name: name,
        location: location,
        mode: Value(mode),
        scoringSystem: Value(scoringSystem),
        winPoints: Value(winPoints),
        drawPoints: Value(drawPoints),
        lossPoints: Value(lossPoints),
        includeConsolationFinals: Value(includeConsolationFinals),
        timerMinutes: Value(timerMinutes),
      ),
    );
  }

  Future<bool> updateTournament({
    required int id,
    String? name,
    String? location,
    String? mode,
    String? scoringSystem,
    int? winPoints,
    int? drawPoints,
    int? lossPoints,
    bool? includeConsolationFinals,
    int? timerMinutes,
    bool? isActive,
  }) async {
    return await (_db.update(_db.tournaments)..where((t) => t.id.equals(id))).write(
      TournamentsCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        location: location != null ? Value(location) : const Value.absent(),
        mode: mode != null ? Value(mode) : const Value.absent(),
        scoringSystem: scoringSystem != null ? Value(scoringSystem) : const Value.absent(),
        winPoints: winPoints != null ? Value(winPoints) : const Value.absent(),
        drawPoints: drawPoints != null ? Value(drawPoints) : const Value.absent(),
        lossPoints: lossPoints != null ? Value(lossPoints) : const Value.absent(),
        includeConsolationFinals: includeConsolationFinals != null ? Value(includeConsolationFinals) : const Value.absent(),
        timerMinutes: timerMinutes != null ? Value(timerMinutes) : const Value.absent(),
        isActive: isActive != null ? Value(isActive) : const Value.absent(),
      ),
    ) > 0;
  }

  Future<int> deleteTournament(int id) async {
    // Delete tournament teams first
    await (_db.delete(_db.tournamentTeams)..where((tt) => tt.tournamentId.equals(id))).go();
    // Delete matches
    await (_db.delete(_db.matches)..where((m) => m.tournamentId.equals(id))).go();
    // Delete tournament
    return await (_db.delete(_db.tournaments)..where((t) => t.id.equals(id))).go();
  }

  Future<void> addTeamToTournament(int tournamentId, int teamId, {int groupNumber = 1, int seed = 0}) async {
    await _db.into(_db.tournamentTeams).insert(
      TournamentTeamsCompanion.insert(
        tournamentId: tournamentId,
        teamId: teamId,
        groupNumber: Value(groupNumber),
        seed: Value(seed),
      ),
    );
  }

  Future<void> removeTeamFromTournament(int tournamentId, int teamId) async {
    await (_db.delete(_db.tournamentTeams)
      ..where((tt) => tt.tournamentId.equals(tournamentId) & tt.teamId.equals(teamId)))
      .go();
  }

  Future<void> setTournamentTeams(int tournamentId, List<int> teamIds) async {
    // Remove all existing teams
    await (_db.delete(_db.tournamentTeams)..where((tt) => tt.tournamentId.equals(tournamentId))).go();
    // Add new teams
    for (var i = 0; i < teamIds.length; i++) {
      await addTeamToTournament(tournamentId, teamIds[i], seed: i);
    }
  }
}

/// Provider for tournaments repository
final tournamentsRepositoryProvider = Provider<TournamentsRepository>((ref) {
  final db = ref.watch(dbProvider);
  return TournamentsRepository(db);
});
