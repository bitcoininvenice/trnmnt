import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trnmnt/core/database/app_database.dart';
import '../../tournaments/data/matches_repository.dart';
import '../../tournaments/data/tournaments_repository.dart';
import '../../sharing/data/share_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

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

  @override
  void dispose() {
    _timer?.cancel();
    _syncTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void setupStandalone(String home, String away, {int minutes = 10, bool isPublic = false, String? twitchUsername, String? matchTitle}) {
    _timer?.cancel();
    _syncTimer?.cancel();
    state = GameState(
      homeTeamName: home,
      awayTeamName: away,
      totalSeconds: minutes * 60,
      remainingSeconds: minutes * 60,
      isPublic: isPublic,
      matchTitle: matchTitle,
      twitchUsername: twitchUsername,
      standaloneUuid: isPublic ? _generateUuid() : null,
    );

    if (isPublic) {
      _syncToLive(force: true);
    }
  }

  void startGame(MatchWithTeams matchData, int minutes) {
    _timer?.cancel();
    _syncTimer?.cancel();

    state = GameState(
      matchId: matchData.match.id,
      matchData: matchData,
      homeScore: matchData.match.homeScore ?? 0,
      awayScore: matchData.match.awayScore ?? 0,
      totalSeconds: minutes * 60,
      remainingSeconds: minutes * 60,
      homeTeamName: matchData.homeTeam?.name ?? 'Home',
      awayTeamName: matchData.awayTeam?.name ?? 'Away',
    );
    
    _lastSyncHomeScore = state.homeScore;
    _lastSyncAwayScore = state.awayScore;

    _syncToLive(force: true); // Initial push
  }

  void quitGame() {
    _timer?.cancel();
    
    if (state.matchId != null) {
      final tournamentId = state.matchData?.match.tournamentId;
      final matchId = state.matchId;
      if (tournamentId != null && matchId != null) {
        _ref.read(tournamentByIdProvider(tournamentId).future).then((t) {
          if (t?.cloudId != null) {
             _ref.read(shareRepositoryProvider).clearLiveMatch(t!.cloudId!, matchId);
          }
        });
      }
    } else if (state.isPublic && state.standaloneUuid != null && !state.isHistorySaved) {
       // Standalone: Save ONLY IF not already saved by finishGame
       _ref.read(shareRepositoryProvider).saveToStandaloneHistory(
         homeName: state.homeTeamName,
         awayName: state.awayTeamName,
         homeScore: state.homeScore,
         awayScore: state.awayScore,
         matchTitle: state.matchTitle,
         twitchUsername: state.twitchUsername,
         period: state.period,
         timer: state.formattedTime,
       ).catchError((_) => null);
       
       _ref.read(shareRepositoryProvider).clearLiveMatch('standalone', 0, customId: state.standaloneUuid).catchError((_) => null);
    }
    
    state = GameState();
  }

  void toggleTimer() {
    if (state.isRunning) {
      _timer?.cancel();
      state = state.copyWith(isRunning: false);
      _syncToLive(force: true);
    } else {
      if (state.remainingSeconds <= 0) return;
      state = state.copyWith(isRunning: true);
      _syncToLive(force: true); // Inform frontend to start local timer
      
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (state.remainingSeconds > 0) {
          state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
        } else {
          _timer?.cancel();
          state = state.copyWith(isRunning: false, isFinished: true);
          _playBuzzer();
          _syncToLive(force: true); // Inform frontend to stop
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
    state = state.copyWith(
      remainingSeconds: state.totalSeconds,
      isRunning: false,
      isFinished: false,
    );
    _syncToLive(force: true);
  }

  void updateHomeScore(int val) {
    if (val < 0) return;
    state = state.copyWith(homeScore: val);
    _syncToLive(force: true); // Sync on every point
  }

  void updateAwayScore(int val) {
    if (val < 0) return;
    state = state.copyWith(awayScore: val);
    _syncToLive(force: true); // Sync on every point
  }

  void updatePeriod(int val) {
    if (val < 1) return;
    state = state.copyWith(period: val);
    _syncToLive(force: true);
  }

  void setDuration(int minutes) {
    if (state.isRunning) return;
    final seconds = minutes * 60;
    state = state.copyWith(
      totalSeconds: seconds,
      remainingSeconds: seconds,
      isFinished: false,
    );
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
  Future<void> _syncToLive({bool force = false}) async {
    final bool isStandalone = state.matchId == null && state.isPublic;
    
    if (state.matchId == null && !isStandalone) return;
    
    try {
      final repo = _ref.read(shareRepositoryProvider);

      if (isStandalone) {
        // standalone sync
        await repo.updateLiveMatch(
          cloudId: 'standalone',
          matchId: 0, // Not used when we have compositeId logic
          standaloneCustomId: state.standaloneUuid, // New param
          homeScore: state.homeScore,
          awayScore: state.awayScore,
          timer: state.formattedTime,
          homeName: state.homeTeamName,
          awayName: state.awayTeamName,
          isRunning: state.isRunning,
          period: state.period,
          twitchUsername: state.twitchUsername,
          matchTitle: state.matchTitle,
        );
        return;
      }

      final tournamentId = state.matchData?.match.tournamentId;
      if (tournamentId == null) return;

      final tournament = await _ref.read(tournamentByIdProvider(tournamentId).future);
      if (tournament == null || tournament.cloudId == null || !tournament.isPublished) return;


      // Update live match on Supabase
      await repo.updateLiveMatch(
        cloudId: tournament.cloudId!,
        matchId: state.matchId!,
        homeScore: state.homeScore,
        awayScore: state.awayScore,
        timer: state.formattedTime,
        homeName: state.homeTeamName,
        awayName: state.awayTeamName,
        isRunning: state.isRunning,
        period: state.period,
        matchTitle: state.matchTitle,
      );

      _lastSyncHomeScore = state.homeScore;
      _lastSyncAwayScore = state.awayScore;
    } catch (_) {
      // Silent error for production
    }
  }

  Future<void> finishGame() async {
    _timer?.cancel();
    
    if (state.matchId != null) {
      // TOURNAMENT MATCH
      final repo = _ref.read(matchesRepositoryProvider);
      await repo.updateMatchScore(state.matchId!, state.homeScore, state.awayScore);
      
      final tournamentId = state.matchData?.match.tournamentId;
      if (tournamentId != null) {
        final tournament = await _ref.read(tournamentByIdProvider(tournamentId).future);
        if (tournament?.cloudId != null) {
          _ref.read(shareRepositoryProvider).clearLiveMatch(tournament!.cloudId!, state.matchId!).catchError((_) => null);
          _ref.read(shareRepositoryProvider).publishToSupabase(tournamentId).catchError((_) => null);
        }
      }
    } else if (state.isPublic && state.standaloneUuid != null && !state.isHistorySaved) {
      // STANDALONE PUBLIC MATCH: Save to permanent history
      _ref.read(shareRepositoryProvider).saveToStandaloneHistory(
        homeName: state.homeTeamName,
        awayName: state.awayTeamName,
        homeScore: state.homeScore,
        awayScore: state.awayScore,
        matchTitle: state.matchTitle,
        twitchUsername: state.twitchUsername,
        period: state.period,
        timer: state.formattedTime,
      ).catchError((_) => null);
      
      // Clear from live scoreboard
      _ref.read(shareRepositoryProvider).clearLiveMatch('standalone', 0, customId: state.standaloneUuid).catchError((_) => null);
      
      state = state.copyWith(isHistorySaved: true);
    }

    state = state.copyWith(isRunning: false, isFinished: true);
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

final activeGameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier(ref);
});
