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

    final teams = await (_db.select(_db.tournamentTeams)..where((tt) => tt.tournamentId.equals(tournamentId))).get();
    final teamIds = teams.map((tt) => tt.teamId).toList();
    
    final fullTeams = await (_db.select(_db.teams)..where((t) => t.id.isIn(teamIds))).get();

    final matches = await (_db.select(_db.matches)..where((m) => m.tournamentId.equals(tournamentId))).get();

    return {
      'tournament': tournament.toJson(),
      'teams': fullTeams.map((t) => t.toJson()).toList(),
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
    final export = await getTournamentExport(tournamentId);
    if (export == null) return null;

    final supabase = Supabase.instance.client;
    
    try {
      await supabase.from('published_tournaments').upsert({
        'id': tournamentId.toString(),
        'data': export,
        'last_updated': DateTime.now().toIso8601String(),
      });
      
      // Return the public URL
      final baseUrl = dotenv.env['VESB_BASE_URL'] ?? 'https://vesb.vercel.app';
      return '$baseUrl/tournaments/$tournamentId';
    } catch (e) {
      return null;
    }
  }
}

final shareRepositoryProvider = Provider((ref) {
  final db = ref.watch(dbProvider);
  return ShareRepository(db);
});
