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

  Future<void> _handleScan(String? code) async {
    if (code == null || _isProcessing) return;
    
    final isManageLink = code.startsWith('trnmnt://manage') || code.startsWith('trnmnt://share');
    final isWebLink = code.startsWith('http') && code.contains('/tournaments/');
    
    if (!isManageLink && !isWebLink) return;

    String? cloudId;
    if (isWebLink) {
        cloudId = Uri.parse(code).pathSegments.last;
    } else {
        final uri = Uri.parse(code.replaceFirst('trnmnt://manage', 'http://trnmnt').replaceFirst('trnmnt://share', 'http://trnmnt'));
        cloudId = uri.queryParameters['id'];
    }

    if (cloudId == null || cloudId.isEmpty) return;
    
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
    final tournamentData = data['tournament'] as Map<String, dynamic>;
    final teamsData = data['teams'] as List<dynamic>;
    final matchesData = data['matches'] as List<dynamic>;

    // Check for duplicates
    final existing = await (db.select(db.tournaments)
      ..where((t) => t.cloudId.equals(cloudId)))
      .getSingleOrNull();

    if (existing != null) {
      return existing.id;
    }

    final importName = tournamentData['name'];
    
    // 1. Create NEW Tournament record
    final tournamentId = await db.into(db.tournaments).insert(
      TournamentsCompanion.insert(
        name: importName,
        location: tournamentData['location'],
        mode: drift.Value(tournamentData['mode']),
        scoringSystem: drift.Value(tournamentData['scoringSystem']),
        winPoints: drift.Value(tournamentData['winPoints']),
        drawPoints: drift.Value(tournamentData['drawPoints']),
        lossPoints: drift.Value(tournamentData['lossPoints']),
        includeConsolationFinals: drift.Value(tournamentData['includeConsolationFinals']),
        timerMinutes: drift.Value(tournamentData['timerMinutes']),
        isActive: drift.Value(tournamentData['isActive']),
        isReadOnly: const drift.Value(false), // ALLOW EDITING for co-management
        cloudId: drift.Value(cloudId),
        isPublished: const drift.Value(true),
        webUrl: drift.Value(tournamentData['webUrl']),
        communityId: drift.Value(tournamentData['communityId'] ?? tournamentData['community_id']),
        communityName: drift.Value(tournamentData['communityName'] ?? tournamentData['community_name']),
      )
    );

    // 2. Map Teams { SenderId: ReceiverId }
    final Map<int, int> teamMapping = {};
    for (final teamJson in teamsData) {
      final oldId = teamJson['id'] as int;
      
      // Check if team with same name already exists locally
      final existingTeam = await (db.select(db.teams)..where((t) => t.name.equals(teamJson['name']))).getSingleOrNull();
      
      int receiverTeamId;
      if (existingTeam != null) {
        receiverTeamId = existingTeam.id;
      } else {
        receiverTeamId = await db.into(db.teams).insert(
          TeamsCompanion.insert(
            name: teamJson['name'],
            logoPath: drift.Value(teamJson['logoPath']),
          )
        );
      }
      teamMapping[oldId] = receiverTeamId;
      
      // Link to tournament
      await db.into(db.tournamentTeams).insert(
        TournamentTeamsCompanion.insert(
          tournamentId: tournamentId,
          teamId: receiverTeamId,
        )
      );
    }

    // 3. Map Matches
    for (final matchJson in matchesData) {
      final homeId = matchJson['homeTeamId'] as int?;
      final awayId = matchJson['awayTeamId'] as int?;
      
      await db.into(db.matches).insert(
        MatchesCompanion.insert(
          tournamentId: tournamentId,
          homeTeamId: drift.Value(homeId != null ? teamMapping[homeId] : null),
          awayTeamId: drift.Value(awayId != null ? teamMapping[awayId] : null),
          homeScore: drift.Value(matchJson['homeScore'] as int?),
          awayScore: drift.Value(matchJson['awayScore'] as int?),
          round: drift.Value(matchJson['round'] as int? ?? 1),
          groupNumber: drift.Value(matchJson['groupNumber'] as int? ?? 1),
          phase: drift.Value(matchJson['phase'] as String? ?? 'group'),
          isBye: drift.Value(matchJson['isBye'] as bool? ?? false),
          isCompleted: drift.Value(matchJson['isCompleted'] as bool? ?? false),
          scheduledAt: drift.Value(matchJson['scheduledAt'] != null ? DateTime.tryParse(matchJson['scheduledAt'].toString()) : null),
        )
      );
    }

    return tournamentId;
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
