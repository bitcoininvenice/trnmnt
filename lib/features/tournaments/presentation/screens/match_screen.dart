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
import 'package:supabase/supabase.dart';
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

  @override
  void initState() {
    super.initState();
    _sessionId = 'match-app-${DateTime.now().millisecondsSinceEpoch}-${widget.matchId}';
    _recordVisit();
  }

  @override
  void dispose() {
    if (_sessionId != null) {
      ref.read(shareRepositoryProvider).endTournamentHit(_sessionId!);
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
        final t = await ref.read(tournamentByIdProvider(tId!).future);
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
  bool get _isGuest => _localTid == null && widget.tournamentId != null;

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

    if (_isGuest) {
      return _buildGuestMatchDetail(context, ref);
    }

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
                                ref.read(activeGameProvider.notifier).syncManualScoreWithCloud(
                                  tournamentId: match.tournamentId, 
                                  matchId: match.id, 
                                  homeScore: val, 
                                  awayScore: _awayScore ?? 0, 
                                  homeName: matchWithTeams.homeTeam?.name ?? 'Home', 
                                  awayName: matchWithTeams.awayTeam?.name ?? 'Away'
                                );
                              },
                            ),
                            // Removed Special Shots from manual mode
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
                                ref.read(activeGameProvider.notifier).syncManualScoreWithCloud(
                                  tournamentId: match.tournamentId, 
                                  matchId: match.id, 
                                  homeScore: _homeScore ?? 0, 
                                  awayScore: val, 
                                  homeName: matchWithTeams.homeTeam?.name ?? 'Home', 
                                  awayName: matchWithTeams.awayTeam?.name ?? 'Away'
                                );
                              },
                            ),
                            // Removed Special Shots from manual mode
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

  Widget _buildLiveMatchScreen(BuildContext context, GameState activeGame, GameNotifier notifier) {
    final timerColor = activeGame.isFinished ? Colors.red : (activeGame.isRunning ? Colors.green : Colors.blue);
    final l10n = AppLocalizations.of(context)!;

    final tournamentId = activeGame.matchData?.match.tournamentId;
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
          if (isPublished || activeGame.isPublic)
            IconButton(
              icon: const Icon(Icons.share, color: Colors.orange),
              onPressed: () async {
                String? finalId;
                if (activeGame.matchId == null && activeGame.isPublic) {
                  finalId = activeGame.standaloneUuid;
                } else if (tournamentId != null) {
                  final t = await ref.read(tournamentByIdProvider(tournamentId).future);
                  if (t?.cloudId != null) {
                    finalId = '${t!.cloudId}_${activeGame.matchId}';
                  }
                }

                if (finalId != null) {
                  final locale = Localizations.localeOf(context).languageCode;
                  final url = 'https://trnmnt.vercel.app/$locale/match/$finalId';
                  await Clipboard.setData(ClipboardData(text: url));
                  if (mounted) {
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
                }
              },
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
                        VintageScoreColumn(teamName: activeGame.homeTeamName, score: activeGame.homeScore, onScoreChanged: (val) => notifier.updateHomeScore(val)),
                        if (isPublished)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _buildSpecialShotsRow(
                              'A', 
                              notifier,
                              matchId: activeGame.matchId,
                              tournamentId: activeGame.matchData?.match.tournamentId,
                              homeName: activeGame.homeTeamName,
                              awayName: activeGame.awayTeamName,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildPeriodColumn(activeGame, notifier),
                  Expanded(
                    child: Column(
                      children: [
                        VintageScoreColumn(teamName: activeGame.awayTeamName, score: activeGame.awayScore, onScoreChanged: (val) => notifier.updateAwayScore(val)),
                        if (isPublished)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _buildSpecialShotsRow(
                              'B', 
                              notifier,
                              matchId: activeGame.matchId,
                              tournamentId: activeGame.matchData?.match.tournamentId,
                              homeName: activeGame.homeTeamName,
                              awayName: activeGame.awayTeamName,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 16, thickness: 1, color: Colors.white10),
            if (!activeGame.isRunning && activeGame.matchId == null)
              _buildDurationSelector(activeGame, notifier),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
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
                          onPressed: _isFinishing ? null : () async {
                            setState(() => _isFinishing = true);
                            
                            // 1. Pop the screen immediately
                            if (mounted) {
                              Navigator.pop(context);
                            }
                            
                            // 2. Finish the game in the background (no longer depends on this screen's lifecycle)
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

  Widget _buildControlButton({required IconData icon, VoidCallback? onPressed, required Color color, required double size}) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
      child: IconButton(icon: Icon(icon, color: color, size: size * 0.5), onPressed: onPressed),
    );
  }

  Widget _buildSpecialShotsRow(
    String side, 
    GameNotifier notifier, {
    bool localStateOnly = false, 
    bool isHome = true,
    int? matchId,
    int? tournamentId,
    String? homeName,
    String? awayName,
  }) {
    return Column(
      children: [
        // Three Pointer Button (BOMBA)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade900,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
               if (localStateOnly) {
                  final newScore = (isHome ? (_homeScore ?? 0) : (_awayScore ?? 0)) + 3;
                  setState(() {
                    if (isHome) _homeScore = newScore;
                    else _awayScore = newScore;
                  });
                  // Sync updated score to cloud
                  if (matchId != null && tournamentId != null) {
                    notifier.syncManualScoreWithCloud(
                      tournamentId: tournamentId,
                      matchId: matchId,
                      homeScore: _homeScore ?? 0,
                      awayScore: _awayScore ?? 0,
                      homeName: homeName ?? 'Home',
                      awayName: awayName ?? 'Away',
                    );
                  }
               }
               notifier.triggerSpecialShot(
                 'three_pointer', 
                 side,
                 manualMatchId: matchId,
                 manualTournamentId: tournamentId,
               );
            },
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
        // Secondary Special Shots
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _shortLabelButton(
              icon: Icons.notifications_active, 
              color: Colors.red.shade800, 
              onTap: () => notifier.triggerSpecialShot(
                'buzzer_beater', 
                side,
                manualMatchId: matchId,
                manualTournamentId: tournamentId,
              )
            ),
            _shortLabelButton(
              icon: Icons.auto_awesome, 
              color: Colors.purple.shade800, 
              onTap: () => notifier.triggerSpecialShot(
                'circus_shot', 
                side,
                manualMatchId: matchId,
                manualTournamentId: tournamentId,
              )
            ),
          ],
        ),
      ],
    );
  }

  Widget _shortLabelButton({required IconData icon, required Color color, required VoidCallback onTap}) {
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
