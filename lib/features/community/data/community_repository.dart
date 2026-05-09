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

    // AUTO-SYNC: If still null but we are logged in, try to fetch from cloud
    if (comm == null && currentOwnerId != null) {
      final cloudData = await getMyCommunityFromCloud();
      if (cloudData != null) {
        await saveCommunityLocally(cloudData, true);
        comm = await (_db.select(_db.communities)..limit(1)).getSingleOrNull();
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

  /// Looks up a community by its local UUID directly on the cloud.
  /// More reliable than owner_id lookup when the user has an existing local community.
  Future<Map<String, dynamic>?> getCommunityByIdFromCloud(String id) async {
    if (id.startsWith('legacy')) return null;
    try {
      return await _supabase
          .from('communities')
          .select()
          .eq('id', id)
          .maybeSingle();
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
        location: Value(data['location']),
        instagramUrl: Value(data['instagram_url']),
        tiktokUrl: Value(data['tiktok_url']),
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
      // Priority 1: look up by local community ID (avoids creating duplicates
      // when owner_id is stale or not yet set on an existing record).
      final currentLocal = await (_db.select(_db.communities)
        ..where((c) => c.isOwner.equals(true))
        ..limit(1)).getSingleOrNull();

      Map<String, dynamic>? existing;
      if (currentLocal != null) {
        existing = await getCommunityByIdFromCloud(currentLocal.id);
      }

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
      try {
        if (existing != null) {
          // Always UPDATE existing record
          final res = await _supabase
              .from('communities')
              .update(data)
              .eq('id', existing['id'])
              .select()
              .single();
          finalCommunity = res;
        } else {
          // Truly new community: creator_id is set once
          data['creator_id'] = ownerId;
          final res = await _supabase
              .from('communities')
              .insert(data)
              .select()
              .single();
          finalCommunity = res;
        }
      } on PostgrestException catch (e) {
        if (e.code == '42501') return 'rls-violation';
        if (e.code == '23505') return 'slug-exists';
        rethrow;
      }

      final String newId = finalCommunity['id'];
      
      // Migrate legacy local communities to the real ID
      final legacyCommunities = await (_db.select(_db.communities)
        ..where((t) => t.id.equals('legacy-id') | t.id.like('legacy-%'))).get();
      
      for (final legacy in legacyCommunities) {
        if (legacy.id == newId) continue; 
        await (_db.update(_db.tournaments)..where((t) => t.communityId.equals(legacy.id)))
            .write(TournamentsCompanion(communityId: Value(newId)));
        await (_db.update(_db.teams)..where((t) => t.communityId.equals(legacy.id)))
            .write(TeamsCompanion(communityId: Value(newId)));
        await (_db.delete(_db.communities)..where((t) => t.id.equals(legacy.id))).go();
      }

      await saveCommunityLocally(finalCommunity, true);
      return null;
    } on PostgrestException catch (e) {
      if (e.code == '23505') return 'slug-exists';
      return 'error';
    } catch (e) {
      return 'error';
    }
  }

  /// Removes a community from this device.
  ///
  /// - Always deletes local tournaments and teams linked to this community.
  /// - If [isOwner]: also sets owner_id = null on Supabase (community becomes
  ///   "orphaned" — visible to admin, creator_id preserved, can be reassigned).
  /// - If member: cloud is untouched.
  Future<void> leaveCommunity(String communityId, {required bool isOwner}) async {
    // 1. Owner only: disassociate on cloud FIRST
    if (isOwner && !communityId.startsWith('legacy')) {
      try {
        await _supabase
            .from('communities')
            .update({'owner_id': null})
            .eq('id', communityId);
      } catch (e) {
        // Silently fail or use a proper logging service in production
      }
    }

    // 2. Perform local deletion in correct hierarchical order using a transaction
    await _db.transaction(() async {
      // Find all tournaments for this community
      final tournamentIds = (await (_db.select(_db.tournaments)
            ..where((t) => t.communityId.equals(communityId)))
          .get())
          .map((t) => t.id)
          .toList();

      if (tournamentIds.isNotEmpty) {
        // A. Delete matches
        await (_db.delete(_db.matches)
              ..where((m) => m.tournamentId.isIn(tournamentIds)))
            .go();

        // B. Delete tournament-team links
        await (_db.delete(_db.tournamentTeams)
              ..where((tt) => tt.tournamentId.isIn(tournamentIds)))
            .go();

        // C. Delete courts
        await (_db.delete(_db.courts)
              ..where((c) => c.tournamentId.isIn(tournamentIds)))
            .go();

        // D. Delete tournaments
        await (_db.delete(_db.tournaments)
              ..where((t) => t.id.isIn(tournamentIds)))
            .go();
      }

      // 3. Delete all local teams linked to this community
      await (_db.delete(_db.teams)
            ..where((t) => t.communityId.equals(communityId)))
          .go();

      // 4. Delete the community from local DB
      await (_db.delete(_db.communities)
            ..where((c) => c.id.equals(communityId))).go();
    });
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

  /// Checks if a slug is available (not taken by another community)
  Future<bool> isSlugAvailable(String slug, {String? excludeId}) async {
    if (slug.isEmpty) return false;
    try {
      var query = _supabase
          .from('communities')
          .select('id')
          .eq('slug', slug);
      
      if (excludeId != null) {
        query = query.neq('id', excludeId);
      }
      
      final res = await query.maybeSingle();
      return res == null;
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
