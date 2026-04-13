import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunityRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get currentOwnerId {
    return _supabase.auth.currentSession?.user.id;
  }

  Future<Map<String, dynamic>?> getMyCommunity() async {
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

  Future<bool> upsertCommunity({required String name, required String slug, String? logoUrl, String? location, String? instagramUrl, String? tiktokUrl}) async {
    final ownerId = currentOwnerId;
    if (ownerId == null) {
      print('SUPABASE DEBUG: ownerId is null! Auth failed or Anonymous sign-in not enabled in Supabase Dashboard.');
      return false;
    }
    
    try {
      // Check if one exists for this device
      final existing = await getMyCommunity();
      if (existing != null) {
        await _supabase.from('communities').update({
          'name': name,
          'slug': slug,
          'logo_url': logoUrl,
          'location': location,
          'instagram_url': instagramUrl,
          'tiktok_url': tiktokUrl,
        }).eq('id', existing['id']);
      } else {
        await _supabase.from('communities').insert({
          'owner_id': ownerId,
          'name': name,
          'slug': slug,
          'logo_url': logoUrl,
          'location': location,
          'instagram_url': instagramUrl,
          'tiktok_url': tiktokUrl,
        });
      }
      return true;
    } catch (e) {
      print('SUPABASE DEBUG EXCEPTION: $e');
      return false; // Could be a unique slug collision or network issue
    }
  }
}

final communityRepositoryProvider = Provider((ref) => CommunityRepository());

final myCommunityProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  return ref.watch(communityRepositoryProvider).getMyCommunity();
});
