import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import 'package:trnmnt/core/database/app_database.dart';
import 'package:trnmnt/core/providers/database_provider.dart';

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
    if (!code.startsWith('trnmnt://share')) return;

    final uri = Uri.parse(code.replaceFirst('trnmnt://share', 'http://trnmnt'));
    final ip = uri.queryParameters['ip'];
    final port = uri.queryParameters['port'];
    final id = uri.queryParameters['id'];

    if (ip == null || port == null || id == null) return;

    setState(() {
      _isProcessing = true;
      _status = 'Connecting to transmitter at $ip...';
    });

    try {
      final response = await http.get(Uri.parse('http://$ip:$port/tournament/$id')).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final success = await _importTournamentBundle(data);
        if (success && mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tournament imported successfully!'), backgroundColor: Colors.green),
          );
          context.go('/');
        }
      } else {
        setState(() {
          _status = 'Error downloading data: ${response.statusCode}';
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = 'Connection failed. Ensure both devices are on the same WiFi.\n$e';
          _isProcessing = false;
        });
      }
    }
  }

  Future<bool> _importTournamentBundle(Map<String, dynamic> data) async {
    final db = ref.read(dbProvider);
    final tournamentData = data['tournament'] as Map<String, dynamic>;
    final teamsData = data['teams'] as List<dynamic>;
    final matchesData = data['matches'] as List<dynamic>;

    // 1. Create NEW Tournament record (Copy of receiver's version)
    // We remove the ID to let it auto-increment
    final tournamentId = await db.into(db.tournaments).insert(
      TournamentsCompanion.insert(
        name: tournamentData['name'] + ' (Import)',
        location: tournamentData['location'],
        mode: drift.Value(tournamentData['mode']),
        scoringSystem: drift.Value(tournamentData['scoringSystem']),
        winPoints: drift.Value(tournamentData['winPoints']),
        drawPoints: drift.Value(tournamentData['drawPoints']),
        lossPoints: drift.Value(tournamentData['lossPoints']),
        includeConsolationFinals: drift.Value(tournamentData['includeConsolationFinals']),
        timerMinutes: drift.Value(tournamentData['timerMinutes']),
        isActive: drift.Value(tournamentData['isActive']),
        isReadOnly: const drift.Value(true), // Set it to read-only
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
          homeScore: drift.Value(matchJson['homeScore']),
          awayScore: drift.Value(matchJson['awayScore']),
          round: matchJson['round'],
          phase: matchJson['phase'],
          isCompleted: drift.Value(matchJson['isCompleted']),
        )
      );
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
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
                      _status ?? 'Syncing...',
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
