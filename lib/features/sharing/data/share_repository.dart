import 'dart:ui';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/env/env.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/database/app_database.dart';
import '../../community/data/community_repository.dart';
import '../../../core/services/analytics_service.dart';

class ShareRepository {
  final AppDatabase _db;
  final CommunityRepository _communityRepo;

  ShareRepository(this._db, this._communityRepo);

  /// Downloads tournament data from Supabase using its Cloud ID
  Future<Map<String, dynamic>?> fetchTournamentByCloudId(String cloudId) async {
    try {
      final supabase = Supabase.instance.client;
      
      // 1. Fetch tournament data
      final response = await supabase
          .from('published_tournaments')
          .select('data')
          .eq('id', cloudId)
          .single();
      
      return response['data'] as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  /// Synchronizes local tournament data with cloud data (Download from Cloud)
  Future<bool> syncFromCloud(int tournamentId) async {
    final tournament = await (_db.select(_db.tournaments)..where((t) => t.id.equals(tournamentId))).getSingleOrNull();
    if (tournament == null || tournament.cloudId == null || tournament.cloudId!.isEmpty) return false;

    final cloudData = await fetchTournamentByCloudId(tournament.cloudId!);
    if (cloudData == null) return false;

    final supabase = Supabase.instance.client;

    try {
      // 1. Update Tournament Basic Info
      final remoteTourney = cloudData['tournament'] as Map<String, dynamic>?;
      if (remoteTourney != null) {
        await (_db.update(_db.tournaments)..where((t) => t.id.equals(tournamentId))).write(
          TournamentsCompanion(
            name: Value(remoteTourney['name'] ?? tournament.name),
            location: Value(remoteTourney['location'] ?? tournament.location),
            description: Value(remoteTourney['description'] ?? tournament.description),
          ),
        );
      }

      // 2. Sync Matches
      final remoteMatches = cloudData['matches'] as List<dynamic>?;
      if (remoteMatches != null) {
        // Fetch all local matches for this tournament
        final localMatchesList = await (_db.select(_db.matches)..where((m) => m.tournamentId.equals(tournamentId))).get();
        
        // Fetch teams to resolve names for matching
        final teams = await (_db.select(_db.teams)..where((t) => t.id.isIn(localMatchesList.map((m) => [m.homeTeamId, m.awayTeamId]).expand((e) => e).whereType<int>().toList()))).get();
        final teamNames = { for (var t in teams) t.id : t.name };

        for (final rm in remoteMatches) {
          final remoteMatch = Map<String, dynamic>.from(rm);
          
          // Try to find the matching local match
          final localMatch = localMatchesList.firstWhere((lm) {
            final localHomeName = teamNames[lm.homeTeamId] ?? '';
            final localAwayName = teamNames[lm.awayTeamId] ?? '';
            
            return lm.phase == remoteMatch['phase'] &&
                   lm.round == remoteMatch['round'] &&
                   localHomeName == remoteMatch['homeTeamName'] &&
                   localAwayName == remoteMatch['awayTeamName'];
          }, orElse: () => null as dynamic);

          if (localMatch != null) {
            // Update score if remote has a score or is completed
            final bool remoteCompleted = remoteMatch['isCompleted'] == true;
            final int? remoteHomeScore = remoteMatch['homeScore'];
            final int? remoteAwayScore = remoteMatch['awayScore'];

            if (remoteCompleted || remoteHomeScore != null || remoteAwayScore != null) {
               await (_db.update(_db.matches)..where((m) => m.id.equals(localMatch.id))).write(
                MatchesCompanion(
                  homeScore: Value(remoteHomeScore),
                  awayScore: Value(remoteAwayScore),
                  isCompleted: Value(remoteCompleted),
                ),
              );
            }
          }
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchTournamentByCloudIdOld(String cloudId) async {
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

  Future<Map<String, dynamic>?> getTournamentExport(int tournamentId, {List<int>? madnessQueue}) async {
    final tournament = await (_db.select(_db.tournaments)..where((t) => t.id.equals(tournamentId))).getSingleOrNull();
    if (tournament == null) return null;

    final teamsQuery = _db.select(_db.tournamentTeams).join([
      innerJoin(_db.teams, _db.teams.id.equalsExp(_db.tournamentTeams.teamId)),
    ])..where(_db.tournamentTeams.tournamentId.equals(tournamentId))
      ..orderBy([OrderingTerm.asc(_db.tournamentTeams.seed)]);

    final teamsRows = await teamsQuery.get();
    final exportTeams = teamsRows.map((row) {
      final team = row.readTable(_db.teams);
      final tt = row.readTable(_db.tournamentTeams);
      final teamMap = team.toJson();
      teamMap['groupNumber'] = tt.groupNumber;
      return teamMap;
    }).toList();

    final matches = await (_db.select(_db.matches)..where((m) => m.tournamentId.equals(tournamentId))).get();
    
    // Map team IDs to names for stable matching across devices
    final teams = await (_db.select(_db.teams)).get();
    final Map<int, String> teamNameMap = { for (var t in teams) t.id : t.name };

    final exportMatches = [];
    for (var i = 0; i < matches.length; i++) {
      final m = matches[i];
      final matchMap = m.toJson();
      matchMap['homeTeamName'] = teamNameMap[m.homeTeamId];
      matchMap['awayTeamName'] = teamNameMap[m.awayTeamId];
      matchMap['remoteIndex'] = i; // STABLE IDENTIFIER
      exportMatches.add(matchMap);
    }

    final activeCommunity = await _communityRepo.getActiveCommunity(null);
    final tournamentMap = tournament.toJson();
    // Remove description from JSON to keep it only in the top-level column
    tournamentMap.remove('description');
    if (tournament.venueCourtId != null) {
      final court = await (_db.select(_db.courts)..where((c) => c.id.equals(tournament.venueCourtId!))).getSingleOrNull();
      if (court != null) {
        if (court.cloudId != null) {
          tournamentMap['venue_court_id'] = court.cloudId;
        } else if (court.source == 'osm' && court.sourceId != null) {
          tournamentMap['venue_court_id'] = court.sourceId;
        }
      }
    }

    if (activeCommunity != null && tournament.communityId == activeCommunity.id) {
      tournamentMap['communityName'] = activeCommunity.name;
    }

    if (tournament.mode == 'league_madness') {
      final hasMadnessMatches = matches.any((m) => m.phase == 'madness' || m.phase == 'final' || m.phase == 'semifinale_spareggio');
      tournamentMap['phase'] = hasMadnessMatches ? 'madness' : 'league';
    }

    return {
      'tournament': tournamentMap,
      'teams': exportTeams,
      'matches': exportMatches,
      'exportedAt': DateTime.now().toIso8601String(),
      if (madnessQueue != null) 'madnessQueue': madnessQueue,
    };
  }

  Future<String?> publishToSupabase(int tournamentId, {List<int>? madnessQueue}) async {
    final result = await publishToSupabaseFull(tournamentId, madnessQueue: madnessQueue);
    return result?.url;
  }

  Future<({String url, String cloudId})?> publishToSupabaseFull(int tournamentId, {List<int>? madnessQueue}) async {
    final tournament = await (_db.select(_db.tournaments)..where((t) => t.id.equals(tournamentId))).getSingle();
    final export = await getTournamentExport(tournamentId, madnessQueue: madnessQueue);
    if (export == null) return null;

    final supabase = Supabase.instance.client;
    String? cloudId = tournament.cloudId;
    final baseUrl = Env.baseUrl;
    
    // Recupera l'ID dispositivo da AnalyticsService
    final String? creatorId = await AnalyticsService.getUserId();
    
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

      if (cloudId != null && cloudId.isNotEmpty) {
        // CONFLICT PREVENTION: Before pushing, let's peek at the current cloud state
        // and merge any match results we might be missing locally.
        try {
          final remoteResponse = await supabase.from('published_tournaments').select('data').eq('id', cloudId).single();
          final remoteData = remoteResponse['data'] as Map<String, dynamic>?;
          if (remoteData != null && remoteData['matches'] != null) {
            final List<dynamic> remoteMatches = remoteData['matches'];
            final List<dynamic> localMatches = export['matches'];

            for (var i = 0; i < localMatches.length; i++) {
              final localMatch = localMatches[i];
              // STABLE MATCHING (By Phase, Round, and Team Names)
              final remoteMatch = remoteMatches.firstWhere((rm) => 
                rm['phase'] == localMatch['phase'] && 
                rm['round'] == localMatch['round'] &&
                rm['homeTeamName'] == localMatch['homeTeamName'] &&
                rm['awayTeamName'] == localMatch['awayTeamName'],
                orElse: () => null,
              );

              if (remoteMatch != null) {
                // If remote match is completed but local isn't, use remote (preserving someone else's work)
                if (remoteMatch['isCompleted'] == true && localMatch['isCompleted'] != true) {
                  localMatches[i]['homeScore'] = remoteMatch['homeScore'];
                  localMatches[i]['awayScore'] = remoteMatch['awayScore'];
                  localMatches[i]['isCompleted'] = true;
                }
              }
            }
          }
        } catch (_) {
          // If fetch fails (e.g. first pub), it's fine to just push ours
        }

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
          'venue_court_id': (export['tournament'] as Map?)?['venue_court_id'],
          'description': tournament.description,
          'last_updated': DateTime.now().toIso8601String(),
          if (creatorId != null) 'creator_id': creatorId, // INJECT CREATOR ID
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
        await supabase.from('published_tournaments').update({
          'data': export,
          'community_id': communityId,
          'community_slug': slug,
          'venue_court_id': (export['tournament'] as Map?)?['venue_court_id'],
          'description': tournament.description,
          'last_updated': DateTime.now().toIso8601String(),
          // Se per caso mancava, proviamo a settarlo (opzionale, ma sicuro)
          if (creatorId != null) 'creator_id': creatorId,
        }).eq('id', cloudId);
      }

      final String finalUrl = '$baseUrl/it/tournaments/$cloudId';

      // 1. Update local status with the NEW definitive URL (STUB)
      await (_db.update(_db.tournaments)..where((t) => t.id.equals(tournamentId))).write(
        TournamentsCompanion(
          isPublished: const Value(true),
          publishedAt: Value(DateTime.now()),
          webUrl: Value(finalUrl),
          cloudId: Value(cloudId),
        ),
      );
      
      // After publication, we keep local data to ensure a smooth transition
      // without waiting for the sync engine to refill the database.
      
      // Cleanup live_matches table for matches that are now completed
      if (cloudId != null) {
        final List<dynamic> localMatches = export['matches'] ?? [];
        for (final m in localMatches) {
          if (m['isCompleted'] == true) {
            // Match is done, remove from live scoreboard
            await clearLiveMatch(cloudId, m['id'] as int).catchError((_) => null);
          }
        }
      }
      
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
    int? period,
    String? twitchUsername,
    String? matchTitle,
    String? standaloneCustomId,
    String? venueCourtId,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      // For standalone matches, prioritized custom ID (UUID string)
      final String compositeId;
      if (standaloneCustomId != null) {
        compositeId = standaloneCustomId;
      } else if (cloudId == 'standalone') {
         compositeId = 'standalone_$matchId';
      } else {
         compositeId = '${cloudId}_$matchId';
      }
      
      await supabase.from('live_matches').upsert({
        'id': compositeId,
        'home_score': homeScore,
        'away_score': awayScore,
        'timer': timer,
        'home_team_name': homeName,
        'away_team_name': awayName,
        'is_running': isRunning,
        'period': period,
        'match_title': matchTitle,
        'twitch_username': twitchUsername,
        'last_update': DateTime.now().toUtc().toIso8601String(),
        'tournament_id': cloudId == 'standalone' ? null : cloudId,
        'venue_court_id': venueCourtId,
      });
    } catch (e) {
    }
  }

  Future<void> saveToStandaloneHistory({
    required String homeName,
    required String awayName,
    required int homeScore,
    required int awayScore,
    String? matchTitle,
    String? twitchUsername,
    int? period,
    String? timer,
    String? venueCourtId,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('published_single_matches').insert({
        'home_team_name': homeName,
        'away_team_name': awayName,
        'home_score': homeScore,
        'away_score': awayScore,
        'match_title': matchTitle,
        'twitch_username': twitchUsername,
        'period': period,
        'timer': timer,
        'last_update': DateTime.now().toUtc().toIso8601String(),
        'venue_court_id': venueCourtId,
      });
    } catch (e) {
      // Silent error
    }
  }

  Future<void> clearLiveMatch(String cloudId, int matchId, {String? customId}) async {
    try {
      final supabase = Supabase.instance.client;
      final compositeId = customId ?? '${cloudId}_$matchId';
      await supabase.from('live_matches').delete().eq('id', compositeId);
    } catch (e) {
      // Silent error
    }
  }

  Future<void> clearAllLiveMatches(String cloudId) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('live_matches').delete().eq('tournament_id', cloudId);
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
    int playerCountMin = 3,
    int playerCountMax = 5,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      
      final data = {
        'tournament_id': cloudId,
        'max_teams': maxTeams,
        'is_active': true,
        'show_lunch_options': showLunch,
        'lunch_options': lunchOptions,
        'player_count_min': playerCountMin,
        'player_count_max': playerCountMax,
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

  /// Records a view for a cloud tournament or a standalone match
  Future<void> recordTournamentHit(String? cloudId, {String origin = 'app', int? liveCount, String? sessionId, String? matchId}) async {
    final supabase = Supabase.instance.client;
    try {
      // 1. Atomic increment via RPC (Only if it's a tournament hit)
      if (cloudId != null && cloudId != 'standalone') {
        try {
          await supabase.rpc('increment_tournament_views_v2', params: {
            't_id': cloudId,
            'origin': origin,
          });
        } catch (_) {}
      }

      // 2. Granular log entry
      final language = PlatformDispatcher.instance.locale.languageCode;
      await supabase.from('tournament_analytics').insert({
        if (cloudId != null && cloudId != 'standalone') 'tournament_id': cloudId,
        if (matchId != null) 'match_id': matchId,
        'platform': origin,
        'language': language,
        'live_count': liveCount ?? 1,
        'session_id': sessionId,
      });
    } catch (e) {
    }
  }

  /// Records the end of a visit
  Future<void> endTournamentHit(String sessionId) async {
    final supabase = Supabase.instance.client;
    try {
      await supabase
          .from('tournament_analytics')
          .update({'ended_at': DateTime.now().toIso8601String()})
          .eq('session_id', sessionId);
    } catch (_) {}
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
