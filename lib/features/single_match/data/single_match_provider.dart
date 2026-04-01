import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SingleMatchState {
  final String homeTeamName;
  final String awayTeamName;
  final int homeScore;
  final int awayScore;
  final int period;
  final int remainingSeconds;
  final int totalSeconds;
  final bool isRunning;
  final bool isFinished;

  SingleMatchState({
    this.homeTeamName = 'Home',
    this.awayTeamName = 'Away',
    this.homeScore = 0,
    this.awayScore = 0,
    this.period = 1,
    this.remainingSeconds = 600,
    this.totalSeconds = 600,
    this.isRunning = false,
    this.isFinished = false,
  });

  SingleMatchState copyWith({
    String? homeTeamName,
    String? awayTeamName,
    int? homeScore,
    int? awayScore,
    int? period,
    int? remainingSeconds,
    int? totalSeconds,
    bool? isRunning,
    bool? isFinished,
  }) {
    return SingleMatchState(
      homeTeamName: homeTeamName ?? this.homeTeamName,
      awayTeamName: awayTeamName ?? this.awayTeamName,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      period: period ?? this.period,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      isRunning: isRunning ?? this.isRunning,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}

class SingleMatchNotifier extends Notifier<SingleMatchState> {
  Timer? _timer;

  @override
  SingleMatchState build() {
    // Note: build can't have timers usually, but we manage it in toggle
    return SingleMatchState();
  }

  void setup(String home, String away) {
    if (state.homeTeamName == home && state.awayTeamName == away) return;
    state = SingleMatchState(homeTeamName: home, awayTeamName: away);
  }

  void updateHomeScore(int val) {
    if (val < 0) return;
    state = state.copyWith(homeScore: val);
  }

  void updateAwayScore(int val) {
    if (val < 0) return;
    state = state.copyWith(awayScore: val);
  }

  void updatePeriod(int val) {
    if (val < 1) return;
    state = state.copyWith(period: val);
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

  void toggleTimer() {
    if (state.isRunning) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    if (state.remainingSeconds <= 0) return;
    state = state.copyWith(isRunning: true, isFinished: false);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _stopTimer();
        state = state.copyWith(isFinished: true);
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isRunning: false);
  }

  void stopTimerManually() {
    _stopTimer();
  }

  void resetTimer() {
    _stopTimer();
    state = state.copyWith(remainingSeconds: state.totalSeconds, isFinished: false);
  }

  void resetMatch() {
    _stopTimer();
    state = SingleMatchState(
      homeTeamName: state.homeTeamName,
      awayTeamName: state.awayTeamName,
      totalSeconds: state.totalSeconds,
      remainingSeconds: state.totalSeconds,
    );
  }
}

final singleMatchProvider = NotifierProvider<SingleMatchNotifier, SingleMatchState>(() {
  return SingleMatchNotifier();
});
