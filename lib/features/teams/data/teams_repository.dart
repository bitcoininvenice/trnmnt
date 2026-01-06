import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';

/// Provider for all teams
final teamsProvider = StreamProvider<List<Team>>((ref) {
  final db = ref.watch(dbProvider);
  return db.select(db.teams).watch();
});

/// Provider for a single team by ID
final teamByIdProvider = StreamProvider.family<Team?, int>((ref, id) {
  final db = ref.watch(dbProvider);
  return (db.select(db.teams)..where((t) => t.id.equals(id)))
      .watchSingleOrNull();
});

/// Teams repository for CRUD operations
class TeamsRepository {
  final AppDatabase _db;

  TeamsRepository(this._db);

  Future<int> createTeam({required String name, String? logoPath}) async {
    return await _db.into(_db.teams).insert(
      TeamsCompanion.insert(
        name: name,
        logoPath: Value(logoPath),
      ),
    );
  }

  Future<bool> updateTeam({
    required int id,
    required String name,
    String? logoPath,
  }) async {
    return await (_db.update(_db.teams)..where((t) => t.id.equals(id))).write(
      TeamsCompanion(
        name: Value(name),
        logoPath: Value(logoPath),
      ),
    ) > 0;
  }

  Future<int> deleteTeam(int id) async {
    return await (_db.delete(_db.teams)..where((t) => t.id.equals(id))).go();
  }

  Future<List<Team>> getAllTeams() async {
    return await _db.select(_db.teams).get();
  }
}

/// Provider for teams repository
final teamsRepositoryProvider = Provider<TeamsRepository>((ref) {
  final db = ref.watch(dbProvider);
  return TeamsRepository(db);
});
