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

  Future<Court?> getCourtById(int id) async {
    return await (_db.select(_db.courts)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  Stream<List<Court>> watchAllCourts() {
    return _db.select(_db.courts).watch();
  }

  Future<int> insertCourt(CourtsCompanion court) async {
    final id = await _db.into(_db.courts).insert(court);
    
    // Sync to Supabase (Published Courts)
    await _syncToSupabase(id, court);
    
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

  Future<List<Court>> fetchCloudCourts() async {
    try {
      final supabase = Supabase.instance.client;
      final List<dynamic> data = await supabase.from('published_courts').select();
      
      return data.map((json) => Court(
        id: -1, // Dummy ID for cloud-only courts
        name: json['name'] ?? 'Campetto',
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        description: json['description'],
        hoops: json['hoops'] ?? 2,
        hasLights: json['has_lights'] ?? true,
        netsStatus: json['nets_status'] ?? 'stoffa',
        courtStatus: json['court_status'] ?? 'giocabile',
        linesStatus: json['lines_status'] ?? 'visibili',
        stars: json['stars'] ?? 3,
        cloudId: json['id'].toString(),
        source: json['source'] ?? 'trnmnt',
        sourceId: json['source_id']?.toString(),
        createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      )).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> syncPendingCourts() async {
    final pending = await (_db.select(_db.courts)..where((c) => c.cloudId.isNull())).get();
    if (pending.isEmpty) return;
    
    for (final court in pending) {
      await _syncToSupabase(court.id, CourtsCompanion.insert(
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
        source: Value(court.source),
        sourceId: Value(court.sourceId),
      ));
    }
  }

  Future<void> _syncToSupabase(int localId, CourtsCompanion court) async {
    try {
      final supabase = Supabase.instance.client;
      
      // Get current user if any, or active community
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
        'source_id': court.sourceId.value,
      };

      // Upsert based on coordinates to avoid duplicate published records
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
    }
  }
  Future<int> ensureCloudCourtLocally(Court cloudCourt) async {
    // Check if we already have it by cloudId
    if (cloudCourt.cloudId != null) {
      final existing = await (_db.select(_db.courts)..where((c) => c.cloudId.equals(cloudCourt.cloudId!))).getSingleOrNull();
      if (existing != null) return existing.id;
    }

    // Check if we already have it by sourceId
    if (cloudCourt.sourceId != null) {
      final existing = await (_db.select(_db.courts)..where((c) => c.sourceId.equals(cloudCourt.sourceId!))).getSingleOrNull();
      if (existing != null) return existing.id;
    }

    // Not found locally, insert it via repository method to trigger sync
    return await insertCourt(CourtsCompanion.insert(
      name: cloudCourt.name,
      description: Value(cloudCourt.description),
      latitude: cloudCourt.latitude,
      longitude: cloudCourt.longitude,
      hoops: Value(cloudCourt.hoops),
      netsStatus: Value(cloudCourt.netsStatus),
      courtStatus: Value(cloudCourt.courtStatus),
      linesStatus: Value(cloudCourt.linesStatus),
      hasLights: Value(cloudCourt.hasLights),
      stars: Value(cloudCourt.stars),
      cloudId: Value(cloudCourt.cloudId),
      source: Value(cloudCourt.source),
      sourceId: Value(cloudCourt.sourceId),
    ));
  }
}

// Provider for fetching a single court by local ID
final courtByIdProvider = FutureProvider.family<Court?, int>((ref, id) async {
  return ref.watch(courtsRepositoryProvider).getCourtById(id);
});

// New provider for merged data
final cloudCourtsProvider = FutureProvider<List<Court>>((ref) {
  return ref.watch(courtsRepositoryProvider).fetchCloudCourts();
});

final mergedCourtsProvider = Provider<AsyncValue<List<Court>>>((ref) {
  final localAsync = ref.watch(courtsProvider);
  final cloudAsync = ref.watch(cloudCourtsProvider);

  return localAsync.when(
    data: (localList) {
      return cloudAsync.when(
        data: (cloudList) {
          // Merge logic
          final Map<String, Court> merged = {};

          // 1. Process cloud courts first (Source of Truth)
          for (final c in cloudList) {
            final key = "${c.latitude.toStringAsFixed(5)},${c.longitude.toStringAsFixed(5)}";
            merged[key] = c;
          }

          // 2. Add local courts that are not in cloud or don't match proximity
          for (final l in localList) {
            final key = "${l.latitude.toStringAsFixed(5)},${l.longitude.toStringAsFixed(5)}";
            
            // Check by cloudId if it exists
            bool existsInCloud = false;
            if (l.cloudId != null) {
              existsInCloud = cloudList.any((c) => c.cloudId == l.cloudId);
            } else {
              // Proximity match
              existsInCloud = merged.containsKey(key);
            }

            if (!existsInCloud) {
              merged[key] = l;
            }
          }

          return AsyncValue.data(merged.values.toList());
        },
        loading: () => AsyncValue.data(localList), // Fallback to local while loading cloud
        error: (e, st) => AsyncValue.data(localList),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});
