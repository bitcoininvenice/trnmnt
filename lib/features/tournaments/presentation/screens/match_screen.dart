import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/database/app_database.dart';
import 'package:collection/collection.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/matches_repository.dart';
import '../../../../core/widgets/vintage_score_column.dart';
import '../../data/tournaments_repository.dart';
import '../../../sharing/data/share_repository.dart';
import '../../../game/providers/game_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  final dynamic matchId;
  final dynamic tournamentId;

  const MatchScreen({super.key, this.matchId, this.tournamentId});

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen> {
  int? _homeScore;
  int? _awayScore;
  bool _isLoading = false;
  bool _initialized = false;
  bool _isFinishing = false;

  String? _sessionId;

  late final ShareRepository _shareRepo;

  @override
  void initState() {
    super.initState();
    _shareRepo = ref.read(shareRepositoryProvider);
    _sessionId = 'match-app-${DateTime.now().millisecondsSinceEpoch}-${widget.matchId}';
    _recordVisit();
  }

  @override
  void dispose() {
    if (_sessionId != null) {
      _shareRepo.endTournamentHit(_sessionId!);
    }
    super.dispose();
  }

  Future<void> _recordVisit() async {
    final shareRepo = ref.read(shareRepositoryProvider);
    final supabase = Supabase.instance.client;
    
    // Determine the unique match ID for tracking
    String? trackingMatchId;
    String? trackingCloudId;

    if (_isGuest) {
       trackingMatchId = widget.matchId.toString(); // For guests, matchId is usually the cloud string
       trackingCloudId = widget.tournamentId.toString();
    } else if (widget.matchId != null) {
      final matchData = await ref.read(matchByIdProvider(widget.matchId!).future);
      final tId = matchData?.match.tournamentId;
      if (tId != null) {
        final t = await ref.read(tournamentByIdProvider(tId).future);
        if (t?.cloudId != null) {
          trackingCloudId = t!.cloudId;
          trackingMatchId = '${trackingCloudId}_${widget.matchId}';
        }
      }
    } else {
      // Standalone case
      final activeGame = ref.read(activeGameProvider);
      if (activeGame.isPublic && activeGame.standaloneUuid != null) {
         trackingMatchId = activeGame.standaloneUuid;
         trackingCloudId = 'standalone';
      }
    }

    if (trackingMatchId == null) return;

    // Use presence to get live count
    final channel = supabase.channel('live-tournament-global');
    channel.subscribe((status, _) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        final state = channel.presenceState();
        int live = 1;
        
        // Correct iteration for RealtimePresenceState
        for (final item in state) {
          for (final p in item.presences) {
            if (p.payload['match_id'] == trackingMatchId) {
              live++;
            }
          }
        }
        
        shareRepo.recordTournamentHit(
          trackingCloudId,
          matchId: trackingMatchId,
          sessionId: _sessionId,
          liveCount: live,
          origin: 'app',
        );
      }
    });
  }

  int? get _localTid => int.tryParse(widget.tournamentId.toString());
  bool get _isGuest => _localTid == null && _localTid! != null;

  Future<void> _saveScore() async {
    if (widget.matchId == null || _isGuest) return;
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

      if (!mounted) return;

      final matchData = await ref.read(matchByIdProvider(widget.matchId!).future);
      if (!mounted) return;
      
      final tournamentId = matchData?.match.tournamentId;
      
      if (tournamentId != null) {
        final tournament = await ref.read(tournamentByIdProvider(tournamentId).future);
        if (!mounted) return;
        
        final isPublished = tournament?.isPublished ?? false;

        Navigator.pop(context);
        if (isPublished) {
          shareRepo.publishToSupabase(tournamentId).catchError((_) => null);
        }
      } else {
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
    if (_isFinishing || _isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }
    final l10n = AppLocalizations.of(context)!;
    
    if (_isGuest) {
      return _buildGuestMatchDetail(context, ref);
    }

    // Use a stable selector to decide between Live and Static views.
    // This prevents the entire MatchScreen from rebuilding every second due to the timer.
    final bool isLive = ref.watch(activeGameProvider.select((s) {
      if (widget.matchId == null) return s.matchId == null && s.matchData == null;
      return s.matchId == widget.matchId;
    }));

    if (isLive) {
      return _LiveMatchView(
        matchId: widget.matchId,
        onFinished: () => setState(() => _isFinishing = true),
      );
    }

    // Fallback to static view if not active
    return _buildStaticMatchScreen(context, l10n);
  }

  Widget _buildStaticMatchScreen(BuildContext context, AppLocalizations l10n) {
    if (widget.matchId == null) {
      return const Scaffold(body: Center(child: Text('Errore: Partita non inizializzata')));
    }

    final activeGameNotifier = ref.read(activeGameProvider.notifier);
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            VintageScoreColumn(
                              teamName: matchWithTeams.homeTeam?.name ?? 'Home',
                              score: _homeScore ?? 0,
                              onScoreChanged: isReadOnly ? null : (val) {
                                setState(() => _homeScore = val);
                                final activeGame = ref.read(activeGameProvider);
                                if (activeGame.matchId == match.id) {
                                  ref.read(activeGameProvider.notifier).syncManualScoreWithCloud(
                                    tournamentId: match.tournamentId, 
                                    matchId: match.id, 
                                    homeScore: val, 
                                    awayScore: _awayScore ?? 0, 
                                    homeName: matchWithTeams.homeTeam?.name ?? 'Home', 
                                    awayName: matchWithTeams.awayTeam?.name ?? 'Away'
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        child: Text('VS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white54, fontFamily: 'monospace')),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            VintageScoreColumn(
                              teamName: matchWithTeams.awayTeam?.name ?? 'Away',
                              score: _awayScore ?? 0,
                              onScoreChanged: isReadOnly ? null : (val) {
                                setState(() => _awayScore = val);
                                final activeGame = ref.read(activeGameProvider);
                                if (activeGame.matchId == match.id) {
                                  ref.read(activeGameProvider.notifier).syncManualScoreWithCloud(
                                    tournamentId: match.tournamentId, 
                                    matchId: match.id, 
                                    homeScore: _homeScore ?? 0, 
                                    awayScore: val, 
                                    homeName: matchWithTeams.homeTeam?.name ?? 'Home', 
                                    awayName: matchWithTeams.awayTeam?.name ?? 'Away'
                                  );
                                }
                              },
                            ),
                          ],
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

  Widget _buildGuestMatchDetail(BuildContext context, WidgetRef ref) {
    final tid = widget.tournamentId.toString();
    final cloudDetail = ref.watch(cloudTournamentDetailProvider(tid));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Dettaglio Partita (Ospite)', style: TextStyle(fontFamily: 'monospace')),
        backgroundColor: Colors.black,
      ),
      body: cloudDetail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Errore: $err')),
        data: (data) {
          if (data == null) return const Center(child: Text('Torneo non trovato'));
          final tournamentData = data['data'] as Map<String, dynamic>?;
          if (tournamentData == null) return const Center(child: Text('Dati non disponibili'));

          final List<dynamic> matches = tournamentData['matches'] as List? ?? [];
          final matchData = matches.firstWhereOrNull(
            (m) => m['id'] == widget.matchId,
          );

          if (matchData == null) return const Center(child: Text('Partita non trovata nel cloud'));

          final match = TournamentMatch.fromJson(matchData);
          final homeName = matchData['homeTeamName'] as String? ?? 'Home';
          final awayName = matchData['awayTeamName'] as String? ?? 'Away';

          // For guest matches, we also check if they are currently LIVE in the cloud
          final liveMatches = ref.watch(cloudLiveMatchesProvider).valueOrNull ?? [];
          final liveMatch = liveMatches.firstWhereOrNull(
            (lm) => lm['id'] == '${tid}_${widget.matchId}' || lm['id'] == widget.matchId.toString(),
          );

          final int homeScore = liveMatch != null ? (liveMatch['home_score'] as int) : (match.homeScore ?? 0);
          final int awayScore = liveMatch != null ? (liveMatch['away_score'] as int) : (match.awayScore ?? 0);
          final bool isLive = liveMatch != null && liveMatch['is_running'] == true;

          return SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 48),
                if (isLive)
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.orange.withValues(alpha: 0.5))),
                    child: const Text('🔴 LIVE ORA', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: VintageScoreColumn(
                          teamName: homeName,
                          score: homeScore,
                          onScoreChanged: null, // Read-only for guests
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text('VS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white54, fontFamily: 'monospace')),
                      ),
                      Expanded(
                         child: VintageScoreColumn(
                          teamName: awayName,
                          score: awayScore,
                          onScoreChanged: null, // Read-only for guests
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (liveMatch != null)
                   Container(
                     padding: const EdgeInsets.all(24),
                     margin: const EdgeInsets.all(24),
                     decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
                     child: Column(
                       children: [
                         Text(liveMatch['timer'] ?? '00:00', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.green)),
                         const SizedBox(height: 8),
                         Text('PERIODO ${liveMatch['period'] ?? 1}', style: const TextStyle(color: Colors.white54, letterSpacing: 2)),
                       ],
                     ),
                   ),
                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Isolated widget for the Live Match experience to prevent MatchScreen from broad rebuilds.
class _LiveMatchView extends ConsumerWidget {
  final dynamic matchId;
  final VoidCallback onFinished;

  const _LiveMatchView({
    required this.matchId,
    required this.onFinished,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch ONLY granular fields that don't change every second
    final isPublic = ref.watch(activeGameProvider.select((s) => s.isPublic));
    final homeTeamName = ref.watch(activeGameProvider.select((s) => s.homeTeamName));
    final awayTeamName = ref.watch(activeGameProvider.select((s) => s.awayTeamName));
    final homeScore = ref.watch(activeGameProvider.select((s) => s.homeScore));
    final awayScore = ref.watch(activeGameProvider.select((s) => s.awayScore));
    final matchId = ref.watch(activeGameProvider.select((s) => s.matchId));
    final tournamentId = ref.watch(activeGameProvider.select((s) => s.matchData?.match.tournamentId));

    final notifier = ref.read(activeGameProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    final bool isPublished = (tournamentId != null) 
        ? (ref.watch(tournamentByIdProvider(tournamentId)).valueOrNull?.isPublished ?? false)
        : false;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(l10n.matchInProgress, style: const TextStyle(fontFamily: 'monospace')),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        actions: [
          if (isPublished || isPublic)
            // We pass a dummy state to _ShareButton or just make it watch what it needs
            Consumer(
              builder: (context, ref, _) {
                final activeGame = ref.watch(activeGameProvider);
                return _ShareButton(activeGame: activeGame, tournamentId: tournamentId);
              }
            ),
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          VintageScoreColumn(
                            teamName: homeTeamName, 
                            score: homeScore, 
                            onScoreChanged: (val) => notifier.updateHomeScore(val)
                          ),
                          if (isPublished)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: _SpecialShotsRow(
                                side: 'A', 
                                matchId: matchId,
                                tournamentId: tournamentId,
                                homeName: homeTeamName,
                                awayName: awayTeamName,
                              ),
                            ),
                        ],
                      ),
                    ),
                    _PeriodColumn(notifier: notifier),
                    Expanded(
                      child: Column(
                        children: [
                          VintageScoreColumn(
                            teamName: awayTeamName, 
                            score: awayScore, 
                            onScoreChanged: (val) => notifier.updateAwayScore(val)
                          ),
                          if (isPublished)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: _SpecialShotsRow(
                                side: 'B', 
                                matchId: matchId,
                                tournamentId: tournamentId,
                                homeName: homeTeamName,
                                awayName: awayTeamName,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 16, thickness: 1, color: Colors.white10),
              Consumer(
                builder: (context, ref, _) {
                  final isRunning = ref.watch(activeGameProvider.select((s) => s.isRunning));
                  final mid = ref.watch(activeGameProvider.select((s) => s.matchId));
                  if (!isRunning && mid == null) {
                    return _DurationSelector(notifier: notifier);
                  }
                  return const SizedBox.shrink();
                }
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _LiveMatchTimer(),
                      const SizedBox(height: 48),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ControlButton(icon: Icons.replay, onPressed: notifier.resetTimer, color: Colors.grey, size: 56),
                          const SizedBox(width: 32),
                          // Use localized selectors for the FAB to avoid rebuilds of the whole row
                          Consumer(
                            builder: (context, ref, _) {
                              final isRunning = ref.watch(activeGameProvider.select((s) => s.isRunning));
                              return FloatingActionButton.large(
                                backgroundColor: isRunning ? Colors.orange : Colors.green,
                                onPressed: () => notifier.toggleTimer(),
                                child: Icon(isRunning ? Icons.pause : Icons.play_arrow, size: 48),
                              );
                            }
                          ),
                          const SizedBox(width: 32),
                          _ControlButton(
                            icon: Icons.check, 
                            onPressed: () async {
                              onFinished();
                              Navigator.pop(context);
                              notifier.finishGame();
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
      ),
    );
  }
}

class _LiveMatchTimer extends ConsumerWidget {
  const _LiveMatchTimer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formattedTime = ref.watch(activeGameProvider.select((s) => s.formattedTime));
    final isFinished = ref.watch(activeGameProvider.select((s) => s.isFinished));
    final isRunning = ref.watch(activeGameProvider.select((s) => s.isRunning));
    
    final timerColor = isFinished ? Colors.red : (isRunning ? Colors.green : Colors.blue);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: timerColor.withValues(alpha: 0.5), width: 2),
      ),
      child: Text(
        formattedTime,
        style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: timerColor),
      ),
    ).animate(target: isFinished ? 1 : 0).shake().shimmer();
  }
}

class _ShareButton extends ConsumerWidget {
  final GameState activeGame;
  final int? tournamentId;

  const _ShareButton({required this.activeGame, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.share, color: Colors.orange),
      onPressed: () async {
        String? finalId;
        if (activeGame.matchId == null && activeGame.isPublic) {
          finalId = activeGame.standaloneUuid;
        } else if (tournamentId != null) {
          final t = await ref.read(tournamentByIdProvider(tournamentId!).future);
          if (t?.cloudId != null) {
            finalId = '${t!.cloudId}_${activeGame.matchId}';
          }
        }

        if (!context.mounted) return;
        if (finalId != null) {
          final locale = Localizations.localeOf(context).languageCode;
          final url = 'https://trnmnt.vercel.app/$locale/match/$finalId';
          await Clipboard.setData(ClipboardData(text: url));
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Text('Link copiato! Condividilo sui social 🚀', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
      },
    );
  }
}

class _PeriodColumn extends ConsumerWidget {
  final GameNotifier notifier;

  const _PeriodColumn({required this.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(activeGameProvider.select((s) => s.period));
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          const Text('PERIODO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white70)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.black, border: Border.all(color: Colors.grey.shade900, width: 2), borderRadius: BorderRadius.circular(8)),
            child: Text(period.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.green)),
          ),
          Row(
            children: [
              IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.arrow_drop_down, size: 20, color: Colors.white54), onPressed: () => notifier.updatePeriod(period - 1)),
              IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.arrow_drop_up, size: 20, color: Colors.white54), onPressed: () => notifier.updatePeriod(period + 1)),
            ],
          )
        ],
      ),
    );
  }
}

class _DurationSelector extends ConsumerWidget {
  final GameNotifier notifier;

  const _DurationSelector({required this.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalSeconds = ref.watch(activeGameProvider.select((s) => s.totalSeconds));
    final durations = [1, 5, 8, 10, 12, 15, 20];
    final currentMinutes = totalSeconds ~/ 60;
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
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  final double size;

  const _ControlButton({required this.icon, this.onPressed, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
      child: IconButton(icon: Icon(icon, color: color, size: size * 0.5), onPressed: onPressed),
    );
  }
}

class _SpecialShotsRow extends ConsumerStatefulWidget {
  final String side;
  final int? matchId;
  final int? tournamentId;
  final String? homeName;
  final String? awayName;

  const _SpecialShotsRow({
    required this.side,
    this.matchId,
    this.tournamentId,
    this.homeName,
    this.awayName,
  });

  @override
  ConsumerState<_SpecialShotsRow> createState() => _SpecialShotsRowState();
}

class _SpecialShotsRowState extends ConsumerState<_SpecialShotsRow> {
  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(activeGameProvider.notifier);
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade900,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => notifier.triggerSpecialShot(
              'three_pointer', 
              widget.side,
              manualMatchId: widget.matchId,
              manualTournamentId: widget.tournamentId!,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bolt, size: 16),
                SizedBox(width: 4),
                Text('BOMBA +3', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _iconActionBtn(
              icon: Icons.notifications_active, 
              color: Colors.red.shade800, 
              onTap: () => notifier.triggerSpecialShot(
                'buzzer_beater', 
                widget.side,
                manualMatchId: widget.matchId,
                manualTournamentId: widget.tournamentId!,
              )
            ),
            _iconActionBtn(
              icon: Icons.auto_awesome, 
              color: Colors.purple.shade800, 
              onTap: () => notifier.triggerSpecialShot(
                'circus_shot', 
                widget.side,
                manualMatchId: widget.matchId,
                manualTournamentId: widget.tournamentId!,
              )
            ),
          ],
        ),
      ],
    );
  }

  Widget _iconActionBtn({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}