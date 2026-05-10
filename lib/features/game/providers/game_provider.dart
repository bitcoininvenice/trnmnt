import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tournaments/data/matches_repository.dart';
import '../../tournaments/data/tournaments_repository.dart';
import '../../sharing/data/share_repository.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';

class GameState {
  final int? matchId;
  final MatchWithTeams? matchData;
  final int homeScore;
  final int awayScore;
  final int remainingSeconds;
  final int totalSeconds;
  final int period;
  final bool isRunning;
  final bool isFinished;
  final String homeTeamName;
  final String awayTeamName;
  final bool isPublic;
  final String? twitchUsername;
  final String? matchTitle;
  final String? standaloneUuid;
  final bool isHistorySaved;
  final String? venueCourtId;

  GameState({
    this.matchId,
    this.matchData,
    this.homeScore = 0,
    this.awayScore = 0,
    this.remainingSeconds = 600,
    this.totalSeconds = 600,
    this.period = 1,
    this.isRunning = false,
    this.isFinished = false,
    this.homeTeamName = 'Home',
    this.awayTeamName = 'Away',
    this.isPublic = false,
    this.twitchUsername,
    this.matchTitle,
    this.standaloneUuid,
    this.isHistorySaved = false,
    this.venueCourtId,
  });

  String get formattedTime {
    final mins = remainingSeconds ~/ 60;
    final secs = remainingSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  GameState copyWith({
    int? matchId,
    MatchWithTeams? matchData,
    int? homeScore,
    int? awayScore,
    int? remainingSeconds,
    int? totalSeconds,
    int? period,
    bool? isRunning,
    bool? isFinished,
    String? homeTeamName,
    String? awayTeamName,
    bool? isPublic,
    String? twitchUsername,
    String? matchTitle,
    String? standaloneUuid,
    bool? isHistorySaved,
    String? venueCourtId,
  }) {
    return GameState(
      matchId: matchId ?? this.matchId,
      matchData: matchData ?? this.matchData,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      period: period ?? this.period,
      isRunning: isRunning ?? this.isRunning,
      isFinished: isFinished ?? this.isFinished,
      homeTeamName: homeTeamName ?? this.homeTeamName,
      awayTeamName: awayTeamName ?? this.awayTeamName,
      isPublic: isPublic ?? this.isPublic,
      twitchUsername: twitchUsername ?? this.twitchUsername,
      matchTitle: matchTitle ?? this.matchTitle,
      standaloneUuid: standaloneUuid ?? this.standaloneUuid,
      isHistorySaved: isHistorySaved ?? this.isHistorySaved,
      venueCourtId: venueCourtId ?? this.venueCourtId,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  final Ref _ref;
  Timer? _timer;
  Timer? _syncTimer;
  int _lastSyncHomeScore = 0;
  int _lastSyncAwayScore = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();

  GameNotifier(this._ref) : super(GameState());

  bool _isDisposed = false;
  bool _syncEnabled = true;
  bool _isQuitting = false;

  @override
  void dispose() {
    _stopAllSync();
    
    // Safety cleanup: if we have a match, try to clear it before disposing
    if (state.matchId != null) {
      _ref.read(tournamentByIdProvider(state.matchData?.match.tournamentId ?? 0).future).then((t) {
        if (t?.cloudId != null) {
          _ref.read(shareRepositoryProvider).clearLiveMatch(t!.cloudId!.trim(), state.matchId!);
        }
      });
    } else if (state.isPublic && state.standaloneUuid != null) {
      _ref.read(shareRepositoryProvider).clearLiveMatch('standalone', 0, customId: state.standaloneUuid);
    }

    _audioPlayer.dispose();
    super.dispose();
  }

  void _startHeartbeat() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 10), (t) {
      if (_isDisposed || !_syncEnabled) {
        t.cancel();
        return;
      }
      _syncToLive(state);
    });
  }

  void _stopAllSync() {
    _syncTimer?.cancel();
    _timer?.cancel();
    _syncEnabled = false;
  }

  void _updateState(GameState newState) {
    if (_isDisposed) return;
    
    // To avoid "defunct element" assertion errors, we check if it's safe to update the state.
    // If we are currently in the middle of a frame (build, layout, or paint), we must defer.
    // Using Future.microtask is often safer than addPostFrameCallback for this purpose
    // because it executes before the next frame, reducing the window for disposal crashes.
    final scheduler = SchedulerBinding.instance;
    if (scheduler.schedulerPhase == SchedulerPhase.idle || 
        scheduler.schedulerPhase == SchedulerPhase.postFrameCallbacks) {
      state = newState;
    } else {
      Future.microtask(() {
        if (!_isDisposed) state = newState;
      });
    }
  }

  void setupStandalone(String home, String away, {int minutes = 10, bool isPublic = false, String? twitchUsername, String? matchTitle, String? venueCourtId}) {
    _timer?.cancel();
    _syncTimer?.cancel();
    _syncEnabled = true;
    final newState = GameState(
      homeTeamName: home,
      awayTeamName: away,
      totalSeconds: minutes * 60,
      remainingSeconds: minutes * 60,
      isPublic: isPublic,
      matchTitle: matchTitle,
      twitchUsername: twitchUsername,
      standaloneUuid: isPublic ? _generateUuid() : null,
      venueCourtId: venueCourtId,
    );
    _updateState(newState);

    if (isPublic) {
      _syncToLive(newState, force: true);
      _startHeartbeat();
    }
  }

  void startGame(MatchWithTeams matchData, int minutes) {
    _stopAllSync();
    _syncEnabled = true;
    _timer?.cancel();
    _syncTimer?.cancel();

    final newState = GameState(
      matchId: matchData.match.id,
      matchData: matchData,
      homeScore: matchData.match.homeScore ?? 0,
      awayScore: matchData.match.awayScore ?? 0,
      totalSeconds: minutes * 60,
      remainingSeconds: minutes * 60,
      homeTeamName: matchData.homeTeam?.name ?? 'Home',
      awayTeamName: matchData.awayTeam?.name ?? 'Away',
    );
    _updateState(newState);
    
    _lastSyncHomeScore = newState.homeScore;
    _lastSyncAwayScore = newState.awayScore;

    _syncToLive(newState, force: true); // Initial push
    _startHeartbeat();
  }

  void quitGame() {
    _isQuitting = true;
    _stopAllSync();
    
    final currentMatchId = state.matchId;
    final tournamentId = state.matchData?.match.tournamentId;
    final isPublic = state.isPublic;
    final standaloneUuid = state.standaloneUuid;
    final isHistorySaved = state.isHistorySaved;

    // Aggiorna subito lo stato locale per la UI
    _updateState(GameState());

    // Background cleanup
    () async {
      try {
        if (currentMatchId != null && tournamentId != null) {
          final t = await _ref.read(tournamentByIdProvider(tournamentId).future);
          if (t?.cloudId != null) {
              await _ref.read(shareRepositoryProvider).clearLiveMatch(t!.cloudId!.trim(), currentMatchId);
          }
        } else if (isPublic && standaloneUuid != null && !isHistorySaved) {
            _ref.read(shareRepositoryProvider).clearLiveMatch('standalone', 0, customId: standaloneUuid);
        }
      } catch (e) {}
      _isQuitting = false;
    }();
  }

  void toggleTimer() {
    if (_isDisposed) return;
    if (state.isRunning) {
      _timer?.cancel();
      final newState = state.copyWith(isRunning: false);
      _updateState(newState);
      _syncToLive(newState, force: true);
    } else {
      if (state.remainingSeconds <= 0) return;
      final newState = state.copyWith(isRunning: true);
      _updateState(newState);
      _syncToLive(newState, force: true); // Inform frontend to start local timer
      
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_isDisposed) {
          t.cancel();
          return;
        }
        if (state.remainingSeconds > 0) {
          final newState = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
          _updateState(newState);
        } else {
          _stopAllSync();
          final newState = state.copyWith(isRunning: false, isFinished: true);
          _updateState(newState);
          _playBuzzer();
          _syncToLive(newState, force: true); // Inform frontend to stop
        }

        // Periodic sync to keep cloud status fresh even if scores don't change
        if (state.remainingSeconds % 10 == 0) {
          _syncToLive(state);
        }
      });
    }
  }

  Future<void> _playBuzzer() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/buzzer.mp3'));
      HapticFeedback.heavyImpact();
    } catch (_) {
      HapticFeedback.heavyImpact();
    }
  }

  void resetTimer() {
    _timer?.cancel();
    final newState = state.copyWith(
      remainingSeconds: state.totalSeconds,
      isRunning: false,
      isFinished: false,
    );
    _updateState(newState);
    _syncToLive(newState, force: true);
  }

  void updateHomeScore(int val) {
    if (val < 0 || _isDisposed) return;
    final newState = state.copyWith(homeScore: val);
    _updateState(newState);
    _syncToLive(newState, force: true); // Sync on every point
  }

  void updateAwayScore(int val) {
    if (val < 0 || _isDisposed) return;
    final newState = state.copyWith(awayScore: val);
    _updateState(newState);
    _syncToLive(newState, force: true); // Sync on every point
  }

  void updatePeriod(int val) {
    if (val < 1 || _isDisposed) return;
    final newState = state.copyWith(period: val);
    _updateState(newState);
    _syncToLive(newState, force: true);
  }

  void updateRemainingSeconds(int seconds) {
    if (_isDisposed) return;
    final newState = state.copyWith(
      remainingSeconds: seconds,
      isFinished: seconds <= 0,
    );
    _updateState(newState);
    _syncToLive(newState, force: true);
  }

  void setDuration(int minutes) {
    if (_isDisposed || state.isRunning) return;
    final seconds = minutes * 60;
    _updateState(state.copyWith(
      totalSeconds: seconds,
      remainingSeconds: seconds,
      isFinished: false,
    ));
  }

  void triggerSpecialShot(String type, String side, {int? manualMatchId, int? manualTournamentId}) async {
    final effectiveMatchId = manualMatchId ?? state.matchId;
    if (effectiveMatchId == null) return;
    
    // 1. Logic: Auto-increment for three_pointer
    if (type == 'three_pointer') {
      if (side == 'A') {
        if (state.matchId != null) updateHomeScore(state.homeScore + 3);
      } else {
        if (state.matchId != null) updateAwayScore(state.awayScore + 3);
      }
    }

    // 2. Broadcast EVENT to Supabase for animations
    final tId = manualTournamentId ?? state.matchData?.match.tournamentId;
    if (tId != null) {
      try {
        final t = await _ref.read(tournamentByIdProvider(tId).future);
        final cloudId = t?.cloudId;
        
        if (cloudId != null) {
          await _ref.read(shareRepositoryProvider).sendMatchEvent(
            cloudId: cloudId,
            matchId: effectiveMatchId,
            type: type,
            teamSide: side,
          );
        }
      } catch (e) {
      }
    }

    HapticFeedback.lightImpact();
  }

  /// Manually syncs score to live_matches table (useful for manual mode updates)
  Future<void> syncManualScoreWithCloud({
    required int tournamentId,
    required int matchId,
    required int homeScore,
    required int awayScore,
    required String homeName,
    required String awayName,
  }) async {
    try {
      final tournament = await _ref.read(tournamentByIdProvider(tournamentId).future);
      if (tournament == null || tournament.cloudId == null) {
        return;
      }

      await _ref.read(shareRepositoryProvider).updateLiveMatch(
        cloudId: tournament.cloudId!,
        matchId: matchId,
        homeScore: homeScore,
        awayScore: awayScore,
        timer: '--:--',
        homeName: homeName,
        awayName: awayName,
        isRunning: false,
      );
    } catch (e) {
    }
  }

  /// Pushes tiny status updates specifically to the live_matches table
  Future<void> _syncToLive(GameState syncState, {bool force = false}) async {
    if (_isDisposed || !_syncEnabled || syncState.isFinished || _isQuitting) return;
    final bool isStandalone = syncState.matchId == null && syncState.isPublic;
    
    if (syncState.matchId == null && !isStandalone) return;
    
    try {
      final repo = _ref.read(shareRepositoryProvider);

      if (isStandalone) {
        // standalone sync
        await repo.updateLiveMatch(
          cloudId: 'standalone',
          matchId: 0, 
          standaloneCustomId: syncState.standaloneUuid, 
          homeScore: syncState.homeScore,
          awayScore: syncState.awayScore,
          timer: syncState.formattedTime,
          homeName: syncState.homeTeamName,
          awayName: syncState.awayTeamName,
          isRunning: syncState.isRunning,
          period: syncState.period,
          twitchUsername: syncState.twitchUsername,
          matchTitle: syncState.matchTitle,
          venueCourtId: syncState.venueCourtId,
        );
        return;
      }

      final tournamentId = syncState.matchData?.match.tournamentId;
      if (tournamentId == null) return;

      final tournament = await _ref.read(tournamentByIdProvider(tournamentId).future);
      if (tournament == null || tournament.cloudId == null || !tournament.isPublished) return;


      // Update live match on Supabase
      await repo.updateLiveMatch(
        cloudId: tournament.cloudId!,
        matchId: syncState.matchId!,
        homeScore: syncState.homeScore,
        awayScore: syncState.awayScore,
        timer: syncState.formattedTime,
        homeName: syncState.homeTeamName,
        awayName: syncState.awayTeamName,
        isRunning: syncState.isRunning,
        period: syncState.period,
        twitchUsername: syncState.twitchUsername,
        matchTitle: syncState.matchTitle,
        venueCourtId: syncState.venueCourtId,
        phase: syncState.matchData?.match.phase,
        round: syncState.matchData?.match.round,
      );
    } catch (e) {
    }
  }

  void finishGame() {
    _isQuitting = true;
    _stopAllSync();
    
    final currentMatchId = state.matchId;
    final tournamentId = state.matchData?.match.tournamentId;
    final homeScore = state.homeScore;
    final awayScore = state.awayScore;
    final isPublic = state.isPublic;
    final standaloneUuid = state.standaloneUuid;
    final isHistorySaved = state.isHistorySaved;

    _updateState(state.copyWith(isRunning: false, isFinished: true));

    // Background processing
    () async {
      try {
        if (currentMatchId != null) {
          await _ref.read(matchesRepositoryProvider).updateMatchScore(currentMatchId, homeScore, awayScore);
          
          if (tournamentId != null) {
            final tournament = await _ref.read(tournamentByIdProvider(tournamentId).future);
            if (tournament?.cloudId != null) {
              await _ref.read(shareRepositoryProvider).clearLiveMatch(tournament!.cloudId!.trim(), currentMatchId);
            }
          }
        } else if (isPublic && standaloneUuid != null && !isHistorySaved) {
          // STANDALONE PUBLIC MATCH: Save and clear
          await _ref.read(shareRepositoryProvider).saveToStandaloneHistory(
            homeName: state.homeTeamName,
            awayName: state.awayTeamName,
            homeScore: state.homeScore,
            awayScore: state.awayScore,
            matchTitle: state.matchTitle,
            twitchUsername: state.twitchUsername,
            period: state.period,
            timer: state.formattedTime,
            venueCourtId: state.venueCourtId,
          ).catchError((_) => null);
          
          await _ref.read(shareRepositoryProvider).clearLiveMatch('standalone', 0, customId: standaloneUuid);
        }
      } catch (e) {}
      _isQuitting = false;
    }();
  }

  String _generateUuid() {
    final random = math.Random();
    const hex = '0123456789abcdef';
    String res = '';
    for (int i = 0; i < 36; i++) {
      if (i == 8 || i == 13 || i == 18 || i == 23) {
        res += '-';
      } else if (i == 14) {
        res += '4';
      } else if (i == 19) {
        res += hex[random.nextInt(4) + 8];
      } else {
        res += hex[random.nextInt(16)];
      }
    }
    return res;
  }
}

final activeGameProvider = StateNotifierProvider.autoDispose<GameNotifier, GameState>((ref) {
  return GameNotifier(ref);
});
