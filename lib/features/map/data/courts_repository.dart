import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../community/data/community_repository.dart';

final courtsRepositoryProvider = Provider<CourtsRepository>((ref) {
  return CourtsRepository(
    ref.watch(dbProvider),
    ref.watch(communityRepositoryProvider),
  );
});

final courtsProvider = StreamProvider<List<Court>>((ref) {
  final repo = ref.watch(courtsRepositoryProvider);
  return repo.watchAllCourts();
});

class CourtsRepository {
  final AppDatabase _db;
  final CommunityRepository _communityRepo;

  CourtsRepository(this._db, this._communityRepo);

  Future<List<Court>> getAllCourts() async {
    return await _db.select(_db.courts).get();
  }

  Stream<List<Court>> watchAllCourts() {
    return _db.select(_db.courts).watch();
  }

  Future<int> insertCourt(CourtsCompanion court) async {
    final id = await _db.into(_db.courts).insert(court);
    
    // Background sync to Supabase (Published Courts)
    _syncToSupabase(id, court);
    
    return id;
  }

  Future<bool> updateCourt(Court court) async {
    final success = await _db.update(_db.courts).replace(court);
    if (success) {
      _syncToSupabase(court.id, CourtsCompanion.insert(
        name: court.name,
        latitude: court.latitude,
        longitude: court.longitude,
        description: Value(court.description),
        hoops: Value(court.hoops),
        hasLights: Value(court.hasLights),
        netsStatus: Value(court.netsStatus),
        courtStatus: Value(court.courtStatus),
        linesStatus: Value(court.linesStatus),
        stars: Value(court.stars),
      ));
    }
    return success;
  }

  Future<int> deleteCourt(int id) async {
    return await (_db.delete(_db.courts)..where((c) => c.id.equals(id))).go();
  }

  Future<void> _syncToSupabase(int localId, CourtsCompanion court) async {
    try {
      final supabase = Supabase.instance.client;
      final activeComm = await _communityRepo.getActiveCommunity(null);
      
      final data = {
        'name': court.name.value,
        'latitude': court.latitude.value,
        'longitude': court.longitude.value,
        'description': court.description.value,
        'hoops': court.hoops.value,
        'has_lights': court.hasLights.value,
        'nets_status': court.netsStatus.value,
        'court_status': court.courtStatus.value,
        'lines_status': court.linesStatus.value,
        'stars': court.stars.value,
        'community_id': activeComm?.id,
        'source': court.source.value,
        'osm_id': court.osmId.value,
      };

      // Upsert based on coordinates to avoid duplicates
      final response = await supabase.from('published_courts').upsert(
        data, 
        onConflict: 'latitude,longitude' 
      ).select('id').single();
      
      final cloudId = response['id'].toString();
      
      // Update local court with the cloud ID
      await (_db.update(_db.courts)..where((c) => c.id.equals(localId))).write(
        CourtsCompanion(cloudId: Value(cloudId)),
      );
    } catch (e) {
      // Silent error: we don't want to break local save if sync fails
      debugPrint('Supabase Court Sync Error: $e');
    }
  }
}
