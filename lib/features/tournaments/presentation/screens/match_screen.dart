import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/matches_repository.dart';
import '../../../../core/widgets/vintage_score_column.dart';
import '../../data/tournaments_repository.dart';
import '../../../sharing/data/share_repository.dart';
import '../../../game/providers/game_provider.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';

/// Provider for a single match by ID (only for tournament matches)
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
  final int? matchId;

  const MatchScreen({super.key, this.matchId});

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen> {
  int? _homeScore;
  int? _awayScore;
  bool _isLoading = false;
  bool _initialized = false;

  Future<void> _saveScore() async {
    if (widget.matchId == null) return;
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
        widget.matchId!,
        _homeScore!,
        _awayScore!,
      );

      final matchData = await ref.read(matchByIdProvider(widget.matchId!).future);
      final tournamentId = matchData?.match.tournamentId;
      
      if (tournamentId != null) {
        final tournament = await ref.read(tournamentByIdProvider(tournamentId).future);
        final isPublished = tournament?.isPublished ?? false;

        if (mounted) {
          Navigator.pop(context);
          if (isPublished) {
            shareRepo.publishToSupabase(tournamentId).catchError((_) => null);
          }
        }
      } else if (mounted) {
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
    final activeGame = ref.watch(activeGameProvider);
    final activeGameNotifier = ref.read(activeGameProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    // Is this specific match currently active?
    final bool isThisMatchActive = (widget.matchId == null) 
        ? (activeGame.matchId == null) // If we came here as standalone, we are active if the current game is standalone
        : (activeGame.matchId == widget.matchId);

    if (isThisMatchActive && (activeGame.matchData != null || widget.matchId == null)) {
      return _buildLiveMatchScreen(context, activeGame, activeGameNotifier);
    }

    // If no matchId, it shouldn't even reach here without being "active" or "setup"
    if (widget.matchId == null) {
      return const Scaffold(body: Center(child: Text('Errore: Partita non inizializzata')));
    }

    final matchAsync = ref.watch(matchByIdProvider(widget.matchId!));

    return matchAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: Text(l10n.error)),
        body: Center(child: Text('${l10n.error}: $error')),
      ),
      data: (matchWithTeams) {
        if (matchWithTeams == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Non trovata')),
            body: const Center(child: Text('Partita non trovata')),
          );
        }

        final match = matchWithTeams.match;
        final tournamentAsync = ref.watch(tournamentByIdProvider(match.tournamentId));
        final tournament = tournamentAsync.valueOrNull;
        final isReadOnly = tournament?.isReadOnly ?? false;
        final timerDuration = tournament?.timerMinutes ?? 10;

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
            title: Text(l10n.matchDetail, style: const TextStyle(fontFamily: 'monospace')),
          ),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: VintageScoreColumn(
                          teamName: matchWithTeams.homeTeam?.name ?? 'Home',
                          score: _homeScore ?? 0,
                          onScoreChanged: isReadOnly ? null : (val) => setState(() => _homeScore = val),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('VS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white54, fontFamily: 'monospace')),
                      ),
                      Expanded(
                        child: VintageScoreColumn(
                          teamName: matchWithTeams.awayTeam?.name ?? 'Away',
                          score: _awayScore ?? 0,
                          onScoreChanged: isReadOnly ? null : (val) => setState(() => _awayScore = val),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (!isReadOnly)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.flash_on),
                            label: const Text('GIOCA PARTITA LIVE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontFamily: 'monospace')),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade900, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                            onPressed: () => activeGameNotifier.startGame(matchWithTeams, timerDuration),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade900, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade800, width: 2))),
                            onPressed: _isLoading ? null : _saveScore,
                            child: _isLoading ? const CircularProgressIndicator() : const Text('SALVA SOLO RISULTATO', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'monospace')),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLiveMatchScreen(BuildContext context, GameState activeGame, GameNotifier notifier) {
    final timerColor = activeGame.isFinished ? Colors.red : (activeGame.isRunning ? Colors.green : Colors.blue);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(l10n.matchInProgress, style: const TextStyle(fontFamily: 'monospace')),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        actions: [
           TextButton(
            onPressed: () {
               notifier.quitGame();
               Navigator.pop(context);
            },
            child: Text(l10n.quit.toUpperCase(), style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Expanded(child: VintageScoreColumn(teamName: activeGame.homeTeamName, score: activeGame.homeScore, onScoreChanged: (val) => notifier.updateHomeScore(val))),
                  _buildPeriodColumn(activeGame, notifier),
                  Expanded(child: VintageScoreColumn(teamName: activeGame.awayTeamName, score: activeGame.awayScore, onScoreChanged: (val) => notifier.updateAwayScore(val))),
                ],
              ),
            ),
            const Divider(height: 16, thickness: 1, color: Colors.white10),
            
            // Duration selector (only for standalone or before starting)
            if (!activeGame.isRunning && activeGame.matchId == null)
              _buildDurationSelector(activeGame, notifier),

            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: timerColor.withValues(alpha: 0.5), width: 2),
                      ),
                      child: Text(
                        activeGame.formattedTime,
                        style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: timerColor),
                      ),
                    ).animate(target: activeGame.isFinished ? 1 : 0).shake().shimmer(),
                    const SizedBox(height: 48),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildControlButton(icon: Icons.replay, onPressed: notifier.resetTimer, color: Colors.grey, size: 56),
                        const SizedBox(width: 32),
                        FloatingActionButton.large(
                          backgroundColor: activeGame.isRunning ? Colors.orange : Colors.green,
                          onPressed: notifier.toggleTimer,
                          child: Icon(activeGame.isRunning ? Icons.pause : Icons.play_arrow, size: 48),
                        ),
                        const SizedBox(width: 32),
                        _buildControlButton(
                          icon: Icons.check, 
                          onPressed: () async {
                            await notifier.finishGame();
                            if (mounted) Navigator.pop(context);
                          }, 
                          color: Colors.blue, 
                          size: 56
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodColumn(GameState state, GameNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          const Text('PERIODO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white70)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.black, border: Border.all(color: Colors.grey.shade900, width: 2), borderRadius: BorderRadius.circular(8)),
            child: Text(state.period.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.green)),
          ),
          Row(
            children: [
              IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.arrow_drop_down, size: 20, color: Colors.white54), onPressed: () => notifier.updatePeriod(state.period - 1)),
              IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.arrow_drop_up, size: 20, color: Colors.white54), onPressed: () => notifier.updatePeriod(state.period + 1)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDurationSelector(GameState state, GameNotifier notifier) {
    final durations = [1, 5, 8, 10, 12, 15, 20];
    final currentMinutes = state.totalSeconds ~/ 60;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: durations.map((m) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(label: Text('$m min'), selected: m == currentMinutes, onSelected: (_) => notifier.setDuration(m)),
        )).toList(),
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required VoidCallback onPressed, required Color color, required double size}) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
      child: IconButton(icon: Icon(icon, color: color, size: size * 0.5), onPressed: onPressed),
    );
  }
}
