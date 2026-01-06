import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/matches_repository.dart';

/// Provider for a single match by ID
final matchByIdProvider = FutureProvider.family<MatchWithTeams?, int>((ref, matchId) async {
  final db = ref.watch(dbProvider);
  final match = await (db.select(db.matches)..where((m) => m.id.equals(matchId))).getSingleOrNull();
  
  if (match == null) return null;
  
  Team? homeTeam;
  Team? awayTeam;
  
  if (match.homeTeamId != null) {
    homeTeam = await (db.select(db.teams)..where((t) => t.id.equals(match.homeTeamId!))).getSingleOrNull();
  }
  if (match.awayTeamId != null) {
    awayTeam = await (db.select(db.teams)..where((t) => t.id.equals(match.awayTeamId!))).getSingleOrNull();
  }
  
  return MatchWithTeams(match: match, homeTeam: homeTeam, awayTeam: awayTeam);
});

class MatchScreen extends ConsumerStatefulWidget {
  final int matchId;

  const MatchScreen({super.key, required this.matchId});

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen> {
  final _homeScoreController = TextEditingController();
  final _awayScoreController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _homeScoreController.dispose();
    _awayScoreController.dispose();
    super.dispose();
  }

  Future<void> _saveScore() async {
    final homeScore = int.tryParse(_homeScoreController.text);
    final awayScore = int.tryParse(_awayScoreController.text);

    if (homeScore == null || awayScore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci punteggi validi'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(matchesRepositoryProvider).updateMatchScore(
        widget.matchId,
        homeScore,
        awayScore,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchAsync = ref.watch(matchByIdProvider(widget.matchId));

    return matchAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Errore')),
        body: Center(child: Text('Errore: $error')),
      ),
      data: (matchWithTeams) {
        if (matchWithTeams == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Non trovata')),
            body: const Center(child: Text('Partita non trovata')),
          );
        }

        final match = matchWithTeams.match;
        final homeTeam = matchWithTeams.homeTeam;
        final awayTeam = matchWithTeams.awayTeam;

        // Initialize controllers with existing scores
        if (_homeScoreController.text.isEmpty && match.homeScore != null) {
          _homeScoreController.text = match.homeScore.toString();
        }
        if (_awayScoreController.text.isEmpty && match.awayScore != null) {
          _awayScoreController.text = match.awayScore.toString();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Inserisci Risultato'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                
                // Match card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        // Home team
                        Expanded(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.blue.withValues(alpha: 0.2),
                                child: Text(
                                  homeTeam?.name.substring(0, 1).toUpperCase() ?? '?',
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                homeTeam?.name ?? 'Casa',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  controller: _homeScoreController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                                  decoration: const InputDecoration(
                                    hintText: '0',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // VS
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              Text(
                                'VS',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                              const SizedBox(height: 60),
                            ],
                          ),
                        ),

                        // Away team
                        Expanded(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.orange.withValues(alpha: 0.2),
                                child: Text(
                                  awayTeam?.name.substring(0, 1).toUpperCase() ?? '?',
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                awayTeam?.name ?? 'Ospiti',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  controller: _awayScoreController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                                  decoration: const InputDecoration(
                                    hintText: '0',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveScore,
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Salva Risultato'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
