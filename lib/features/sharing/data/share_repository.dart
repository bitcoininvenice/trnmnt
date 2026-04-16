import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/database/app_database.dart';
import '../../community/data/community_repository.dart';

class ShareRepository {
  final AppDatabase _db;
  final CommunityRepository _communityRepo;

  ShareRepository(this._db, this._communityRepo);

  /// Downloads tournament data from Supabase using its Cloud ID
  Future<Map<String, dynamic>?> fetchTournamentByCloudId(String cloudId) async {
    try {
      final supabase = Supabase.instance.client;
      
      // 1. Fetch tournament data and community ID
      final response = await supabase
          .from('published_tournaments')
          .select('data, community_id')
          .eq('id', cloudId)
          .single();
      
      final Map<String, dynamic> data = Map<String, dynamic>.from(response['data'] as Map);
      final String? communityId = response['community_id'];

      // 2. If communityId is present but name is missing in JSON, fetch it from cloud communities table
      if (communityId != null) {
        final tournamentData = data['tournament'] as Map<String, dynamic>;
        if (tournamentData['communityName'] == null) {
          try {
            final commResponse = await supabase
                .from('communities')
                .select('name')
                .eq('id', communityId)
                .single();
            
            tournamentData['communityName'] = commResponse['name'];
            tournamentData['communityId'] = communityId;
          } catch (_) {
            // Community might have been deleted or not found
          }
        }
      }
      
      return data;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getTournamentExport(int tournamentId) async {
    final tournament = await (_db.select(_db.tournaments)..where((t) => t.id.equals(tournamentId))).getSingleOrNull();
    if (tournament == null) return null;

    final teamsQuery = _db.select(_db.tournamentTeams).join([
      innerJoin(_db.teams, _db.teams.id.equalsExp(_db.tournamentTeams.teamId)),
    ])..where(_db.tournamentTeams.tournamentId.equals(tournamentId));

    final teamsRows = await teamsQuery.get();
    final exportTeams = teamsRows.map((row) {
      final team = row.readTable(_db.teams);
      final tt = row.readTable(_db.tournamentTeams);
      final teamMap = team.toJson();
      teamMap['groupNumber'] = tt.groupNumber;
      return teamMap;
    }).toList();

    final matches = await (_db.select(_db.matches)..where((m) => m.tournamentId.equals(tournamentId))).get();

    final activeCommunity = await _communityRepo.getActiveCommunity(null);
    final tournamentMap = tournament.toJson();
    if (activeCommunity != null && tournament.communityId == activeCommunity.id) {
      tournamentMap['communityName'] = activeCommunity.name;
    }

    return {
      'tournament': tournamentMap,
      'teams': exportTeams,
      'matches': matches.map((m) => m.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  Future<String?> publishToSupabase(int tournamentId) async {
    final result = await publishToSupabaseFull(tournamentId);
    return result?.url;
  }

  Future<({String url, String cloudId})?> publishToSupabaseFull(int tournamentId) async {
    final tournament = await (_db.select(_db.tournaments)..where((t) => t.id.equals(tournamentId))).getSingle();
    final export = await getTournamentExport(tournamentId);
    if (export == null) return null;

    final supabase = Supabase.instance.client;
    String? cloudId = tournament.cloudId;
    final baseUrl = dotenv.env['BASE_URL'] ?? 'https://trnmnt.vercel.app';
    
    try {
      // Find the community for this tournament
      final String? tournamentCommunityId = tournament.communityId;
      final activeCommunity = await _communityRepo.getActiveCommunity(null);
      
      final String? communityId = tournamentCommunityId ?? activeCommunity?.id;
      final String slug = (tournamentCommunityId != null && activeCommunity?.id == tournamentCommunityId) 
          ? activeCommunity!.slug 
          : (activeCommunity?.slug ?? 'hub');

      final String? currentCloudId = tournament.cloudId;
      final String initialUrl = currentCloudId != null && currentCloudId.isNotEmpty 
          ? '$baseUrl/it/tournaments/$currentCloudId' 
          : '';

      if (currentCloudId != null && currentCloudId.isNotEmpty) {
        if (export['tournament'] != null) {
          (export['tournament'] as Map<String, dynamic>)['webUrl'] = initialUrl;
          (export['tournament'] as Map<String, dynamic>)['communitySlug'] = slug;
        }
      }

      if (cloudId == null || cloudId.isEmpty) {
        // CASE: First publication
        final response = await supabase.from('published_tournaments').insert({
          'data': export,
          'community_id': communityId,
          'community_slug': slug,
          'last_updated': DateTime.now().toIso8601String(),
        }).select('id').single();
        
        cloudId = response['id'].toString();
        
        // After first insert, update data with correct URLs and slugs
        final String firstTimeUrl = '$baseUrl/it/tournaments/$cloudId';
        if (export['tournament'] != null) {
          (export['tournament'] as Map<String, dynamic>)['webUrl'] = firstTimeUrl;
          (export['tournament'] as Map<String, dynamic>)['communitySlug'] = slug;
        }
        await supabase.from('published_tournaments').update({ 'data': export }).eq('id', cloudId);
      } else {
        // CASE: Update existing row
        await supabase.from('published_tournaments').upsert({
          'id': cloudId,
          'data': export,
          'community_id': communityId,
          'community_slug': slug,
          'last_updated': DateTime.now().toIso8601String(),
        });
      }

      final String finalUrl = '$baseUrl/it/tournaments/$cloudId';

      // Update local status with the NEW definitive URL
      await (_db.update(_db.tournaments)..where((t) => t.id.equals(tournamentId))).write(
        TournamentsCompanion(
          isPublished: const Value(true),
          publishedAt: Value(DateTime.now()),
          webUrl: Value(finalUrl),
          cloudId: Value(cloudId),
        ),
      );
      
      return (url: finalUrl, cloudId: cloudId!);
    } catch (e) {
      rethrow;
    }
  }

  /// Updates the ultra-fast live_matches table for real-time scoreboard
  Future<void> updateLiveMatch({
    required String cloudId,
    required int matchId,
    required int homeScore,
    required int awayScore,
    required String timer,
    required String homeName,
    required String awayName,
    required bool isRunning,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('live_matches').upsert({
        'id': cloudId,
        'home_score': homeScore,
        'away_score': awayScore,
        'timer': timer,
        'home_team_name': homeName,
        'away_team_name': awayName,
        'is_running': isRunning,
        'last_update': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Silent error for production
    }
  }

  Future<void> clearLiveMatch(String cloudId, int matchId) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('live_matches').delete().eq('id', cloudId);
    } catch (e) {
      // Silent error
    }
  }

  /// Sends a special event (bomba, buzzer beater, etc) to Supabase for web animations
  Future<void> sendMatchEvent({
    required String cloudId,
    required int matchId,
    required String type,
    String? teamSide,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('match_events').insert({
        'tournament_id': cloudId,
        'match_id': matchId.toString(),
        'type': type,
        'team_side': teamSide,
      });
    } catch (e) {
    }
  }

  /// Registration System Methods
  Future<Map<String, dynamic>?> fetchRegistrationSettings(String cloudId) async {
    try {
      final supabase = Supabase.instance.client;
      final settingsRes = await supabase
          .from('registration_settings')
          .select('*')
          .eq('tournament_id', cloudId)
          .maybeSingle();
      
      return settingsRes;
    } catch (e) {
      return null;
    }
  }

  Future<String> createRegistrationSettings({
    required String cloudId,
    required int maxTeams,
    required bool showLunch,
    required List<String> lunchOptions,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      
      final data = {
        'tournament_id': cloudId,
        'max_teams': maxTeams,
        'is_active': true,
        'show_lunch_options': showLunch,
        'lunch_options': lunchOptions,
      };

      final response = await supabase
          .from('registration_settings')
          .upsert(data, onConflict: 'tournament_id')
          .select('id')
          .single();
      
      return response['id'].toString();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchTournamentRegistrations(String cloudId) async {
    try {
      final supabase = Supabase.instance.client;
      
      // 1. Get the settings ID for this cloud tournament
      final settingsRes = await supabase
          .from('registration_settings')
          .select('id')
          .eq('tournament_id', cloudId)
          .maybeSingle();
      
      if (settingsRes == null) return [];
      
      final settingsId = settingsRes['id'];
      
      // 2. Fetch all registrations for this settings ID
      final regsRes = await supabase
          .from('registrations')
          .select('*')
          .eq('settings_id', settingsId)
          .order('created_at', ascending: true);
      
      return List<Map<String, dynamic>>.from(regsRes);
    } catch (e) {
      return [];
    }
  }

  Future<void> updateRegistrationStatus(String regId, String status) async {
    final supabase = Supabase.instance.client;
    await supabase
        .from('registrations')
        .update({'status': status})
        .eq('id', regId);
  }

  Future<void> closeRegistrations(String cloudId, int currentCount) async {
    final supabase = Supabase.instance.client;
    await supabase
        .from('registration_settings')
        .update({
          'is_active': false,
          'max_teams': currentCount,
        })
        .eq('tournament_id', cloudId);
  }

  Future<void> deleteRegistration(String registrationId) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('registrations')
          .delete()
          .eq('id', registrationId);
    } catch (e) {
      rethrow;
    }
  }
}

final shareRepositoryProvider = Provider((ref) {
  final db = ref.watch(dbProvider);
  final communityRepo = ref.watch(communityRepositoryProvider);
  return ShareRepository(db, communityRepo);
});

final registrationSettingsProvider = FutureProvider.autoDispose.family<Map<String, dynamic>?, String>((ref, cloudId) async {
  final repo = ref.watch(shareRepositoryProvider);
  return repo.fetchRegistrationSettings(cloudId);
});
