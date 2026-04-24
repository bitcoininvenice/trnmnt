import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/database/app_database.dart';
import 'selected_community_provider.dart';

class CommunityRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AppDatabase _db;
  final _uuid = const Uuid();

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
    
    // Auto-Heal/Merge: if we have more than one owner community, merge legacy into real
    final allComms = await _db.select(_db.communities).get();
    if (allComms.length > 1) {
      final realOwner = allComms.where((c) => c.isOwner && !c.id.startsWith('legacy')).firstOrNull;
      final legacyOwner = allComms.where((c) => (c.id.startsWith('legacy-') || c.id == 'legacy-id') && c.isOwner).firstOrNull;
      
      if (realOwner != null && legacyOwner != null) {
        // MERGE NOW
        await (_db.update(_db.tournaments)..where((t) => t.communityId.equals(legacyOwner.id)))
            .write(TournamentsCompanion(communityId: Value(realOwner.id)));
        await (_db.update(_db.teams)..where((t) => t.communityId.equals(legacyOwner.id)))
            .write(TeamsCompanion(communityId: Value(realOwner.id)));
        await (_db.delete(_db.communities)..where((t) => t.id.equals(legacyOwner.id))).go();
        
        return realOwner;
      }
    }

    // Fallback to first if selected not found or not provided
    comm ??= await (_db.select(_db.communities)..limit(1)).getSingleOrNull();
    
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
        creatorId: Value(data['creator_id']),
        isOwner: Value(isOwner),
        inviteToken: Value(data['invite_token']),
        inviteTokenExpiresAt: data['invite_token_expires_at'] != null 
            ? Value(DateTime.parse(data['invite_token_expires_at'])) 
            : const Value.absent(),
      ),
    );
  }

  Future<String?> upsertCommunity({
    required String name, 
    required String slug, 
    String? logoUrl, 
    String? location, 
    String? instagramUrl, 
    String? tiktokUrl
  }) async {
    final ownerId = currentOwnerId;
    if (ownerId == null) return 'no-session';
    
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
        // New community: set creator_id
        data['creator_id'] = ownerId;
        final res = await _supabase.from('communities').insert(data).select().single();
        finalCommunity = res;
      }

      // Save locally as OWNER
      final String newId = finalCommunity['id'];
      
      // DATABASE MIGRATION: Check if we have a legacy community and migrate its contents
      final legacyCommunities = await (_db.select(_db.communities)..where((t) => t.id.equals('legacy-id') | t.id.like('legacy-%'))).get();
      
      for (final legacy in legacyCommunities) {
        if (legacy.id == newId) continue; 
        
        await (_db.update(_db.tournaments)..where((t) => t.communityId.equals(legacy.id)))
            .write(TournamentsCompanion(communityId: Value(newId)));
            
        await (_db.update(_db.teams)..where((t) => t.communityId.equals(legacy.id)))
            .write(TeamsCompanion(communityId: Value(newId)));
            
        await (_db.delete(_db.communities)..where((t) => t.id.equals(legacy.id))).go();
      }

      await saveCommunityLocally(finalCommunity, true);
      return null; // Success
    } on PostgrestException catch (e) {
      if (e.code == '23505') return 'slug-exists';
      return 'error';
    } catch (e) {
      return 'error';
    }
  }

  /// Generates a new secure invite token (UUID) valid for 24 hours
  Future<String?> generateInviteToken(String communityId) async {
    if (communityId.startsWith('legacy')) return null;
    
    try {
      final token = _uuid.v4();
      final expiresAt = DateTime.now().add(const Duration(hours: 24));
      
      final response = await _supabase
          .from('communities')
          .update({
            'invite_token': token,
            'invite_token_expires_at': expiresAt.toIso8601String(),
          })
          .eq('id', communityId)
          .select()
          .single();
      
      // Update local cache
      await saveCommunityLocally(response, true);
      
      return token;
    } catch (e) {
      return null;
    }
  }

  /// Join an existing community using a secure invite token
  Future<bool> joinCommunityByToken(String token) async {
    try {
      // Find the community with this token and check expiration
      final response = await _supabase
          .from('communities')
          .select()
          .eq('invite_token', token)
          .single();
      
      final expiresAtStr = response['invite_token_expires_at'];
      if (expiresAtStr != null) {
        final expiresAt = DateTime.parse(expiresAtStr);
        if (DateTime.now().isAfter(expiresAt)) {
          // Token expired
          return false;
        }
      }
      
      // Save locally as MEMBER (not owner)
      await saveCommunityLocally(response, false);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Legacy join by ID - Deprecated for security
  Future<bool> joinCommunity(String communityId) async {
    try {
      final response = await _supabase
          .from('communities')
          .select()
          .eq('id', communityId)
          .single();
      
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
  
  final community = await repo.getActiveCommunity(selectedId);
  
  // Auto-selection logic: if nothing selected but communities exist, pick the best candidate
  if (community == null && selectedId == null) {
    final all = await repo.getAllLocalCommunities();
    if (all.isNotEmpty) {
      // Sort to prioritize owned communities, then by name
      all.sort((a, b) {
        if (a.isOwner && !b.isOwner) return -1;
        if (!a.isOwner && b.isOwner) return 1;
        return a.name.compareTo(b.name);
      });
      
      final candidate = all.first;
      Future.microtask(() {
        if (ref.read(selectedCommunityIdProvider) != candidate.id) {
          ref.read(selectedCommunityIdProvider.notifier).setSelected(candidate.id);
        }
      });
      return candidate;
    }
  }
  
  return community;
});

final communityByIdProvider = FutureProvider.family<Community?, String>((ref, id) async {
  final repo = ref.watch(communityRepositoryProvider);
  return repo.getActiveCommunity(id);
});
