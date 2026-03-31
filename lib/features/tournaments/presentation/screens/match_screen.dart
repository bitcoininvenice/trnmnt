import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/matches_repository.dart';
import '../../../../core/widgets/vintage_score_column.dart';
import '../../../sharing/data/share_repository.dart';

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
  int? _homeScore;
  int? _awayScore;
  bool _isLoading = false;
  bool _initialized = false;

  Future<void> _saveScore() async {
    if (_homeScore == null || _awayScore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci punteggi validi'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(matchesRepositoryProvider);
      final shareRepo = ref.read(shareRepositoryProvider);
      
      await repo.updateMatchScore(
        widget.matchId,
        _homeScore!,
        _awayScore!,
      );

      // 1. Get tournament ID for sync (BEFORE pop)
      final matchData = await ref.read(matchByIdProvider(widget.matchId).future);
      final tournamentId = matchData?.match.tournamentId;

      if (mounted) {
        Navigator.pop(context);
        
        // 2. Start sync in background (NOW SAFE because we don't use 'ref' inside an async block of a dead widget)
        if (tournamentId != null) {
          shareRepo.publishToSupabase(tournamentId).catchError((e) {
             return null;
          });
        }
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

        // Initialize state with existing scores
        if (!_initialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _homeScore = match.homeScore ?? 0;
                _awayScore = match.awayScore ?? 0;
                _initialized = true;
              });
            }
          });
        }

        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text('Inserisci Risultato', style: TextStyle(fontFamily: 'monospace')),
          ),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 32),
                
                // Match card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Home team
                      Expanded(
                        child: VintageScoreColumn(
                          teamName: homeTeam?.name ?? 'Casa'.toUpperCase(),
                          score: _homeScore ?? 0,
                          onScoreChanged: (val) {
                            setState(() {
                              if (val >= 0) _homeScore = val;
                            });
                          },
                        ),
                      ),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'VS',
                          style: TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.white54,
                            fontFamily: 'monospace'
                          ),
                        ),
                      ),
                      
                      // Away team
                      Expanded(
                        child: VintageScoreColumn(
                          teamName: awayTeam?.name ?? 'Ospiti'.toUpperCase(),
                          score: _awayScore ?? 0,
                          onScoreChanged: (val) {
                            setState(() {
                              if (val >= 0) _awayScore = val;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Save button
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade900,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade800, width: 2),
                        ),
                      ),
                      onPressed: _isLoading ? null : _saveScore,
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('SALVA RISULTATO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontFamily: 'monospace')),
                    ),
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
