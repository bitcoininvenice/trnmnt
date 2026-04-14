import 'package:drift/drift.dart';
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
      final response = await supabase
          .from('published_tournaments')
          .select('data')
          .eq('id', cloudId)
          .single();
      
      return response['data'] as Map<String, dynamic>;
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

    return {
      'tournament': tournament.toJson(),
      'teams': exportTeams,
      'matches': matches.map((m) => m.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Publishes tournament data to Supabase for global/realtime access
  Future<String?> publishToSupabase(int tournamentId) async {
    final tournament = await (_db.select(_db.tournaments)..where((t) => t.id.equals(tournamentId))).getSingle();
    final export = await getTournamentExport(tournamentId);
    if (export == null) return null;

    final supabase = Supabase.instance.client;
    String? cloudId = tournament.cloudId;
    final baseUrl = dotenv.env['BASE_URL'] ?? 'https://trnmnt.vercel.app';
    
    try {
      // Find the community for this tournament
      final String? tournamentCommunityId = tournament.communityId;
      final activeCommunity = await _communityRepo.getActiveCommunity();
      
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
      
      return finalUrl;
    } catch (e) {
      return null;
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
        'id': '${cloudId}_$matchId',
        'home_score': homeScore,
        'away_score': awayScore,
        'timer': timer,
        'home_team_name': homeName,
        'away_team_name': awayName,
        'is_running': isRunning,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Silent error for production
    }
  }

  Future<void> clearLiveMatch(String cloudId, int matchId) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('live_matches').delete().eq('id', '${cloudId}_$matchId');
    } catch (e) {
      // Silent error
    }
  }
}

final shareRepositoryProvider = Provider((ref) {
  final db = ref.watch(dbProvider);
  final communityRepo = ref.watch(communityRepositoryProvider);
  return ShareRepository(db, communityRepo);
});
