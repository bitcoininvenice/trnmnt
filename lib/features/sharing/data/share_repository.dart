import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/database/app_database.dart';

class ShareRepository {
  final AppDatabase _db;

  ShareRepository(this._db);

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
    final baseUrl = dotenv.env['VESB_BASE_URL'] ?? 'https://vesb.vercel.app';
    
    try {
      if (cloudId == null || cloudId.isEmpty) {
        // CASE: First publication
        final response = await supabase.from('published_tournaments').insert({
          'data': export,
          'last_updated': DateTime.now().toIso8601String(),
        }).select('id').single();
        
        cloudId = response['id'].toString();
      } else {
        // CASE: Update existing row
        await supabase.from('published_tournaments').upsert({
          'id': cloudId,
          'data': export,
          'last_updated': DateTime.now().toIso8601String(),
        });
      }

      final finalUrl = '$baseUrl/tournaments/$cloudId';

      // Update local status
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
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Silent error for production
    }
  }

  Future<void> clearLiveMatch(String cloudId) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('live_matches').delete().eq('id', cloudId);
    } catch (e) {
      // Silent error
    }
  }
}

final shareRepositoryProvider = Provider((ref) {
  final db = ref.watch(dbProvider);
  return ShareRepository(db);
});
