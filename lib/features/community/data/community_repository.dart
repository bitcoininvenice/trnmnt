import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/database/app_database.dart';
import 'selected_community_provider.dart';

class CommunityRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AppDatabase _db;

  CommunityRepository(this._db);

  String? get currentOwnerId {
    return _supabase.auth.currentSession?.user.id;
  }

  /// Returns the list of all communities saved on this device
  Future<List<Community>> getAllLocalCommunities() async {
    return await _db.select(_db.communities).get();
  }

  /// Returns the "active" or selected community
  Future<Community?> getActiveCommunity(String? selectedId) async {
    Community? comm;
    if (selectedId != null) {
      comm = await (_db.select(_db.communities)..where((c) => c.id.equals(selectedId))).getSingleOrNull();
    }
    
    // Fallback to first if selected not found or not provided
    comm ??= await (_db.select(_db.communities)..limit(1)).getSingleOrNull();
    
    if (comm == null) {
      // Heal check: are there tournaments or teams with no community?
      final orphanTournaments = await (_db.select(_db.tournaments)..where((t) => t.communityId.isNull())..limit(1)).getSingleOrNull();
      final orphanTeams = await (_db.select(_db.teams)..where((t) => t.communityId.isNull())..limit(1)).getSingleOrNull();
      
      if (orphanTournaments != null || orphanTeams != null) {
        // We have legacy data! Create a recovery community.
        final now = DateTime.now();
        final legacyId = 'legacy-${now.millisecondsSinceEpoch}';
        
        await _db.into(_db.communities).insert(CommunitiesCompanion.insert(
          id: legacyId,
          name: 'La mia Community',
          slug: 'my-community',
          isOwner: const Value(true),
          createdAt: Value(now),
        ));
        
        // Link everything
        await (_db.update(_db.tournaments)..where((t) => t.communityId.isNull())).write(TournamentsCompanion(communityId: Value(legacyId)));
        await (_db.update(_db.teams)..where((t) => t.communityId.isNull())).write(TeamsCompanion(communityId: Value(legacyId)));
        
        return await (_db.select(_db.communities)..limit(1)).getSingleOrNull();
      }
    }
    return comm;
  }

  Future<Map<String, dynamic>?> getMyCommunityFromCloud() async {
    final ownerId = currentOwnerId;
    if (ownerId == null) return null;
    
    try {
      final response = await _supabase
          .from('communities')
          .select()
          .eq('owner_id', ownerId)
          .maybeSingle();
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<void> saveCommunityLocally(Map<String, dynamic> data, bool isOwner) async {
    await _db.into(_db.communities).insertOnConflictUpdate(
      CommunitiesCompanion(
        id: Value(data['id']),
        name: Value(data['name']),
        slug: Value(data['slug']),
        logoUrl: Value(data['logo_url']),
        isOwner: Value(isOwner),
      ),
    );
  }

  Future<bool> upsertCommunity({
    required String name, 
    required String slug, 
    String? logoUrl, 
    String? location, 
    String? instagramUrl, 
    String? tiktokUrl
  }) async {
    final ownerId = currentOwnerId;
    if (ownerId == null) return false;
    
    try {
      final existing = await getMyCommunityFromCloud();
      final data = {
        'owner_id': ownerId,
        'name': name,
        'slug': slug,
        'logo_url': logoUrl,
        'location': location,
        'instagram_url': instagramUrl,
        'tiktok_url': tiktokUrl,
      };

      Map<String, dynamic> finalCommunity;
      if (existing != null) {
        final res = await _supabase.from('communities').update(data).eq('id', existing['id']).select().single();
        finalCommunity = res;
      } else {
        final res = await _supabase.from('communities').insert(data).select().single();
        finalCommunity = res;
      }

      // Save locally as OWNER
      await saveCommunityLocally(finalCommunity, true);
      return true;
    } catch (e) {
      print('Upsert error: $e');
      return false;
    }
  }

  /// Join an existing community (via QR scan)
  Future<bool> joinCommunity(String communityId) async {
    try {
      final response = await _supabase
          .from('communities')
          .select()
          .eq('id', communityId)
          .single();
      
      // Save locally as MEMBER (not owner)
      await saveCommunityLocally(response, false);
      return true;
    } catch (e) {
      return false;
    }
  }
}

final communityRepositoryProvider = Provider((ref) {
  final db = ref.watch(dbProvider);
  return CommunityRepository(db);
});

final myLocalCommunitiesProvider = FutureProvider<List<Community>>((ref) async {
  return ref.watch(communityRepositoryProvider).getAllLocalCommunities();
});

final currentCommunityProvider = FutureProvider<Community?>((ref) async {
  final repo = ref.watch(communityRepositoryProvider);
  final selectedId = ref.watch(selectedCommunityIdProvider);
  return repo.getActiveCommunity(selectedId);
});
