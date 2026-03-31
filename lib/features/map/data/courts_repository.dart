import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';

final courtsRepositoryProvider = Provider<CourtsRepository>((ref) {
  return CourtsRepository(ref.watch(dbProvider));
});

final courtsProvider = FutureProvider<List<Court>>((ref) {
  final repo = ref.watch(courtsRepositoryProvider);
  return repo.getAllCourts();
});

class CourtsRepository {
  final AppDatabase _db;

  CourtsRepository(this._db);

  Future<List<Court>> getAllCourts() async {
    return await _db.select(_db.courts).get();
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
