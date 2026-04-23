import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';

final courtsRepositoryProvider = Provider<CourtsRepository>((ref) {
  return CourtsRepository(ref.watch(dbProvider));
});

final courtsProvider = StreamProvider<List<Court>>((ref) {
  final repo = ref.watch(courtsRepositoryProvider);
  return repo.watchAllCourts();
});

class CourtsRepository {
  final AppDatabase _db;

  CourtsRepository(this._db);

  Future<List<Court>> getAllCourts() async {
    return await _db.select(_db.courts).get();
  }

  Stream<List<Court>> watchAllCourts() {
    return _db.select(_db.courts).watch();
  }

  Future<int> insertCourt(CourtsCompanion court) async {
    return await _db.into(_db.courts).insert(court);
  }

  Future<bool> updateCourt(Court court) async {
    return await _db.update(_db.courts).replace(court);
  }

  Future<int> deleteCourt(int id) async {
    return await (_db.delete(_db.courts)..where((c) => c.id.equals(id))).go();
  }
}
