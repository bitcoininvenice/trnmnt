import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import 'package:trnmnt/core/database/app_database.dart';
import 'package:trnmnt/core/providers/database_provider.dart';
import '../../data/share_repository.dart';
import '../../data/sync_repository.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';

class ScanTournamentScreen extends ConsumerStatefulWidget {
  const ScanTournamentScreen({super.key});

  @override
  ConsumerState<ScanTournamentScreen> createState() => _ScanTournamentScreenState();
}

class _ScanTournamentScreenState extends ConsumerState<ScanTournamentScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;
  String? _status;

  Future<void> _handleScan(String? rawCode) async {
    if (rawCode == null || _isProcessing) return;
    
    final code = rawCode.trim();
    
    final isManageLink = code.startsWith('trnmnt://manage') || code.startsWith('trnmnt://share');
    final isWebLink = code.startsWith('http') && code.contains('/tournaments/');
    
    if (!isManageLink && !isWebLink) {
      return;
    }

    String? cloudId;
    try {
      if (isWebLink) {
          cloudId = Uri.parse(code).pathSegments.last;
      } else {
          final normalized = code
              .replaceFirst('trnmnt://manage', 'http://trnmnt')
              .replaceFirst('trnmnt://share', 'http://trnmnt');
          final uri = Uri.parse(normalized);
          cloudId = uri.queryParameters['id'];
      }
    } catch (e) {
      return;
    }

    if (cloudId == null || cloudId.isEmpty) {
      return;
    }
    
    await _controller.stop();

    setState(() {
      _isProcessing = true;
      _status = 'Recupero dati dal Cloud...';
    });

    try {
      final repo = ref.read(shareRepositoryProvider);
      final data = await repo.fetchTournamentByCloudId(cloudId);

      if (data != null) {
        final newId = await _importTournamentBundle(data, cloudId: cloudId);
        if (newId != null && mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Torneo importato e sincronizzato! 🤝🏀'), backgroundColor: Colors.green),
          );
          context.go('/tournaments/$newId');
        }
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Torneo non trovato sul Cloud o ID invalido.'), backgroundColor: Colors.orange),
          );
          setState(() => _isProcessing = false);
          _controller.start();
        }
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connessione Cloud fallita.'), backgroundColor: Colors.red),
        );
        setState(() => _isProcessing = false);
        _controller.start();
      }
    }
  }

  Future<int?> _importTournamentBundle(
    Map<String, dynamic> data, {
    required String cloudId,
  }) async {
    final db = ref.read(dbProvider);
    final tournamentData = data['tournament'] as Map<String, dynamic>?;
    final teamsData = data['teams'] as List<dynamic>?;
    final matchesData = data['matches'] as List<dynamic>?;

    if (tournamentData == null || teamsData == null || matchesData == null) {
      return null;
    }

    final existing = await (db.select(db.tournaments)..where((t) => t.cloudId.equals(cloudId))).getSingleOrNull();
    if (existing != null) {
      return existing.id;
    }

    final importName = (tournamentData['name'] ?? tournamentData['name'])?.toString() ?? 'Senza nome';
    
    // Resolve venue court if present (Cloud stores UUID, Local stores Int ID)
    int? localVenueCourtId;
    final remoteVenueId = tournamentData['venue_court_id'] ?? tournamentData['venueCourtId'];
    if (remoteVenueId != null) {
      if (remoteVenueId is int) {
        localVenueCourtId = remoteVenueId;
      } else if (remoteVenueId is String) {
        final court = await (db.select(db.courts)..where((c) => c.cloudId.equals(remoteVenueId))).getSingleOrNull();
        localVenueCourtId = court?.id;
      }
    }

    // 1. Create NEW Tournament record
    final tournamentId = await db.into(db.tournaments).insert(
      TournamentsCompanion.insert(
        name: importName,
        location: (tournamentData['location'] ?? tournamentData['location'] ?? 'Sconosciuta').toString(),
        mode: drift.Value((tournamentData['mode'] ?? tournamentData['mode'])?.toString() ?? 'group_only'),
        startDate: drift.Value(_parseDateTime(tournamentData['startDate'] ?? tournamentData['start_date'])),
        endDate: drift.Value(_parseDateTime(tournamentData['endDate'] ?? tournamentData['end_date'])),
        description: drift.Value((data['description'] ?? tournamentData['description'] ?? tournamentData['description'])?.toString()), 
        venueCourtId: drift.Value(localVenueCourtId),
        scoringSystem: drift.Value((tournamentData['scoringSystem'] ?? tournamentData['scoring_system'])?.toString() ?? 'standard'),
        winPoints: drift.Value(int.tryParse((tournamentData['winPoints'] ?? tournamentData['win_points'])?.toString() ?? '') ?? 3),
        drawPoints: drift.Value(int.tryParse((tournamentData['drawPoints'] ?? tournamentData['draw_points'])?.toString() ?? '') ?? 1),
        lossPoints: drift.Value(int.tryParse((tournamentData['lossPoints'] ?? tournamentData['loss_points'])?.toString() ?? '') ?? 0),
        includeConsolationFinals: drift.Value(tournamentData['includeConsolationFinals'] == true || tournamentData['include_consolation_finals'] == true),
        timerMinutes: drift.Value(int.tryParse((tournamentData['timerMinutes'] ?? tournamentData['timer_minutes'])?.toString() ?? '') ?? 10),
        isActive: drift.Value(tournamentData['isActive'] != false && tournamentData['is_active'] != false),
        twitchChannel: drift.Value((tournamentData['twitchChannel'] ?? tournamentData['twitch_channel'])?.toString()),
        youtubeVideoId: drift.Value((tournamentData['youtubeVideoId'] ?? tournamentData['youtube_video_id'])?.toString()),
        customTicker: drift.Value((tournamentData['customTicker'] ?? tournamentData['custom_ticker'])?.toString()),
        isReadOnly: const drift.Value(true), 
        cloudId: drift.Value(cloudId),
        isPublished: const drift.Value(true),
        webUrl: drift.Value((tournamentData['webUrl'] ?? tournamentData['web_url'])?.toString()),
        communityId: drift.Value((tournamentData['communityId'] ?? tournamentData['community_id'])?.toString()),
        communityName: drift.Value((tournamentData['communityName'] ?? tournamentData['community_name'])?.toString()),
      )
    );

    // 2. Map Teams { SenderId: ReceiverId }
    final Map<int, int> teamMapping = {};
    for (final teamJson in teamsData) {
      final oldId = int.tryParse(teamJson['id']?.toString() ?? '') ?? 0;
      final teamName = (teamJson['name'] ?? teamJson['name'])?.toString() ?? 'Squadra';
      
      final existingTeam = await (db.select(db.teams)..where((t) => t.name.equals(teamName))).getSingleOrNull();
      
      int receiverTeamId;
      if (existingTeam != null) {
        receiverTeamId = existingTeam.id;
      } else {
        receiverTeamId = await db.into(db.teams).insert(
          TeamsCompanion.insert(
            name: teamName,
            logoPath: drift.Value(teamJson['logoPath']?.toString() ?? teamJson['logo_path']?.toString()),
          )
        );
      }
      teamMapping[oldId] = receiverTeamId;
      
      // Link to tournament
      await db.into(db.tournamentTeams).insertOnConflictUpdate(
        TournamentTeamsCompanion.insert(
          tournamentId: tournamentId,
          teamId: receiverTeamId,
          groupNumber: drift.Value(int.tryParse((teamJson['groupNumber'] ?? teamJson['group_number'])?.toString() ?? '') ?? 1),
        )
      );
    }

    // 3. Map Matches
    for (final matchJson in matchesData) {
      final homeId = int.tryParse((matchJson['homeTeamId'] ?? matchJson['home_team_id'])?.toString() ?? '');
      final awayId = int.tryParse((matchJson['awayTeamId'] ?? matchJson['away_team_id'])?.toString() ?? '');
      
      await db.into(db.matches).insert(
        MatchesCompanion.insert(
          tournamentId: tournamentId,
          homeTeamId: drift.Value(homeId != null ? teamMapping[homeId] : null),
          awayTeamId: drift.Value(awayId != null ? teamMapping[awayId] : null),
          homeScore: drift.Value(int.tryParse((matchJson['homeScore'] ?? matchJson['home_score'])?.toString() ?? '')),
          awayScore: drift.Value(int.tryParse((matchJson['awayScore'] ?? matchJson['away_score'])?.toString() ?? '')),
          round: drift.Value(int.tryParse((matchJson['round'] ?? matchJson['round'])?.toString() ?? '') ?? 1),
          groupNumber: drift.Value(int.tryParse((matchJson['groupNumber'] ?? matchJson['group_number'])?.toString() ?? '') ?? 1),
          phase: drift.Value((matchJson['phase'] ?? matchJson['phase'])?.toString() ?? 'group'),
          isBye: drift.Value(matchJson['isBye'] == true || matchJson['is_bye'] == true),
          isCompleted: drift.Value(matchJson['isCompleted'] == true || matchJson['is_completed'] == true),
          scheduledAt: drift.Value(_parseDateTime(matchJson['scheduledAt'] ?? matchJson['scheduled_at'])),
        )
      );
    }

    return tournamentId;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.tryParse(value.toString());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                _handleScan(barcodes.first.rawValue);
              }
            },
          ),
          
          // Overlay UI
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.orange),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      _status ?? l10n.syncing,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            )
          else
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange, width: 4),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
