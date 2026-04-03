import 'package:drift/drift.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/database/app_database.dart';
import '../../tournaments/data/tournaments_repository.dart';
import '../../tournaments/data/matches_repository.dart';

class ShareRepository {
  final AppDatabase _db;
  HttpServer? _server;
  String? _localIp;
  final int _port = 4554; // "TRNMNT" offset port

  ShareRepository(this._db);

  Future<String?> getLocalIp() async {
    _localIp = await NetworkInfo().getWifiIP();
    return _localIp;
  }

  Future<void> startServer() async {
    if (_server != null) return;

    final app = Router();

    // Health check
    app.get('/health', (Request request) {
      return Response.ok('TRNMNT Sharing Server Active');
    });

    // Endpoint to get a specific tournament with all data
    app.get('/tournament/<id>', (Request request, String id) async {
      final tournamentId = int.tryParse(id);
      if (tournamentId == null) return Response.notFound('Invalid ID');

      final data = await getTournamentExport(tournamentId);
      if (data == null) return Response.notFound('Tournament not found');

      return Response.ok(
        jsonEncode(data),
        headers: {'Content-Type': 'application/json'},
      );
    });

    _server = await io.serve(app, InternetAddress.anyIPv4, _port);
  }

  Future<void> stopServer() async {
    await _server?.close();
    _server = null;
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
      'isReadOnly': true,
    };
  }

  String getShareUrl(int tournamentId) {
    if (_localIp == null) return '';
    return 'trnmnt://share?ip=$_localIp&port=$_port&id=$tournamentId';
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
        // CASE: First publication. Let Supabase trigger generate the pretty slug ID.
        final response = await supabase.from('published_tournaments').insert({
          'data': export,
          'last_updated': DateTime.now().toIso8601String(),
        }).select('id').single();
        
        cloudId = response['id'].toString();
      } else {
        // CASE: Update existing row with preserved cloudId
        await supabase.from('published_tournaments').upsert({
          'id': cloudId,
          'data': export,
          'last_updated': DateTime.now().toIso8601String(),
        });
      }

      final finalUrl = '$baseUrl/tournaments/$cloudId';

      // Update local status with the confirmed cloudId and finalUrl
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
      // Error handled silently for production
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
        'last_update': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Silent error for production
    }
  }

  /// Removes the tournament from the live_matches table when match ends
  Future<void> clearLiveMatch(String cloudId) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('live_matches').delete().eq('id', cloudId);
    } catch (e) {
      // Silent error for production
    }
  }

  Future<void> saveWebUrl(int tournamentId, String url) async {
    await (_db.update(_db.tournaments)..where((t) => t.id.equals(tournamentId))).write(
      TournamentsCompanion(
        isPublished: const Value(true),
        publishedAt: Value(DateTime.now()),
        webUrl: Value(url),
      ),
    );
  }
}

final shareRepositoryProvider = Provider((ref) {
  final db = ref.watch(dbProvider);
  return ShareRepository(db);
});
