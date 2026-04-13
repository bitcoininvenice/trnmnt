import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trnmnt/core/database/app_database.dart';
import '../../tournaments/data/matches_repository.dart';
import '../../tournaments/data/tournaments_repository.dart';
import '../../sharing/data/share_repository.dart';
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

  void setupStandalone(String home, String away, {int minutes = 10}) {
    _timer?.cancel();
    _syncTimer?.cancel();
    state = GameState(
      homeTeamName: home,
      awayTeamName: away,
      totalSeconds: minutes * 60,
      remainingSeconds: minutes * 60,
    );
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
    
    // Clear live status on server
    final tournamentId = state.matchData?.match.tournamentId;
    final matchId = state.matchId;
    if (tournamentId != null && matchId != null) {
      _ref.read(tournamentByIdProvider(tournamentId).future).then((t) {
        if (t?.cloudId != null) {
           _ref.read(shareRepositoryProvider).clearLiveMatch(t!.cloudId!, matchId);
        }
      });
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

  /// Pushes tiny status updates specifically to the live_matches table
  Future<void> _syncToLive({bool force = false}) async {
    if (state.matchId == null) return;
    
    try {
      final tournamentId = state.matchData?.match.tournamentId;
      if (tournamentId == null) return;

      final tournament = await _ref.read(tournamentByIdProvider(tournamentId).future);
      if (tournament == null || tournament.cloudId == null || !tournament.isPublished) return;

      final repo = _ref.read(shareRepositoryProvider);
      
      await repo.updateLiveMatch(
        cloudId: tournament.cloudId!,
        matchId: state.matchId!,
        homeScore: state.homeScore,
        awayScore: state.awayScore,
        timer: state.formattedTime,
        homeName: state.homeTeamName,
        awayName: state.awayTeamName,
        isRunning: state.isRunning,
      );

      _lastSyncHomeScore = state.homeScore;
      _lastSyncAwayScore = state.awayScore;
    } catch (_) {}
  }

  Future<void> finishGame() async {
    _timer?.cancel();
    
    // 1. Sync final score to main DB (tournament update)
    final repo = _ref.read(matchesRepositoryProvider);
    await repo.updateMatchScore(state.matchId!, state.homeScore, state.awayScore);
    
    final tournamentId = state.matchData?.match.tournamentId;
    if (tournamentId != null && state.matchId != null) {
      final tournament = await _ref.read(tournamentByIdProvider(tournamentId).future);
      if (tournament?.cloudId != null) {
        // 2. Clear live board
        _ref.read(shareRepositoryProvider).clearLiveMatch(tournament!.cloudId!, state.matchId!).catchError((_) => null);
        
        // 3. One last full re-publish to update the tournament brackets/standings
        _ref.read(shareRepositoryProvider).publishToSupabase(tournamentId).catchError((_) => null);
      }
    }

    state = state.copyWith(isRunning: false, isFinished: true);
  }
}

final activeGameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier(ref);
});
