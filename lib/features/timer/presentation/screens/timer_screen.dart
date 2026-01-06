import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';

/// Timer state
class TimerState {
  final int totalSeconds;
  final int remainingSeconds;
  final bool isRunning;
  final bool isFinished;

  TimerState({
    this.totalSeconds = 600, // 10 minutes default
    this.remainingSeconds = 600,
    this.isRunning = false,
    this.isFinished = false,
  });

  TimerState copyWith({
    int? totalSeconds,
    int? remainingSeconds,
    bool? isRunning,
    bool? isFinished,
  }) {
    return TimerState(
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      isFinished: isFinished ?? this.isFinished,
    );
  }

  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progress => totalSeconds > 0 ? remainingSeconds / totalSeconds : 0;
}

/// Timer notifier
class TimerNotifier extends StateNotifier<TimerState> {
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  TimerNotifier() : super(TimerState());

  void setDuration(int minutes) {
    final seconds = minutes * 60;
    state = state.copyWith(
      totalSeconds: seconds,
      remainingSeconds: seconds,
      isFinished: false,
    );
  }

  void start() {
    if (state.remainingSeconds <= 0) return;
    
    state = state.copyWith(isRunning: true, isFinished: false);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        stop();
        _playBuzzer();
        state = state.copyWith(isFinished: true);
      }
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    stop();
    state = state.copyWith(
      remainingSeconds: state.totalSeconds,
      isFinished: false,
    );
  }

  void toggle() {
    if (state.isRunning) {
      stop();
    } else {
      start();
    }
  }

  Future<void> _playBuzzer() async {
    try {
      // Play buzzer sound
      await _audioPlayer.play(AssetSource('sounds/buzzer.mp3'));
      // Also trigger haptic feedback
      HapticFeedback.heavyImpact();
    } catch (e) {
      // Fallback: just vibrate if sound fails
      HapticFeedback.heavyImpact();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier();
});

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  bool _isFullscreen = false;

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final timerNotifier = ref.read(timerProvider.notifier);

    final timerColor = _getTimerColor(timerState);

    return Scaffold(
      backgroundColor: _isFullscreen ? Colors.black : null,
      appBar: _isFullscreen
          ? null
          : AppBar(
              title: const Text('Timer'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  onPressed: () => setState(() => _isFullscreen = true),
                ),
              ],
            ),
      body: GestureDetector(
        onTap: _isFullscreen ? () => setState(() => _isFullscreen = false) : null,
        child: SafeArea(
          child: Column(
            children: [
              if (!_isFullscreen) ...[
                const SizedBox(height: 24),
                _buildDurationSelector(timerNotifier, timerState),
                const SizedBox(height: 24),
              ],
              
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Timer display
                      Container(
                        padding: EdgeInsets.all(_isFullscreen ? 48 : 32),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              timerColor.withValues(alpha: 0.3),
                              timerColor.withValues(alpha: 0.1),
                            ],
                          ),
                          border: Border.all(
                            color: timerColor,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: timerColor.withValues(alpha: 0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Text(
                          timerState.formattedTime,
                          style: TextStyle(
                            fontSize: _isFullscreen ? 120 : 72,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: timerColor,
                          ),
                        ),
                      )
                          .animate(
                            target: timerState.isFinished ? 1 : 0,
                          )
                          .shake(duration: 500.ms)
                          .then()
                          .shimmer(duration: 1000.ms, color: Colors.red),

                      const SizedBox(height: 48),

                      // Progress bar
                      if (!_isFullscreen)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: timerState.progress,
                              minHeight: 8,
                              backgroundColor: Colors.grey.withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                            ),
                          ),
                        ),

                      SizedBox(height: _isFullscreen ? 64 : 48),

                      // Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Reset button
                          _buildControlButton(
                            icon: Icons.replay,
                            onPressed: timerNotifier.reset,
                            color: Colors.grey,
                            size: _isFullscreen ? 80 : 60,
                          ),

                          SizedBox(width: _isFullscreen ? 48 : 32),

                          // Play/Pause button
                          _buildControlButton(
                            icon: timerState.isRunning ? Icons.pause : Icons.play_arrow,
                            onPressed: timerNotifier.toggle,
                            color: timerState.isRunning ? Colors.orange : Colors.green,
                            size: _isFullscreen ? 100 : 80,
                            isPrimary: true,
                          ),

                          SizedBox(width: _isFullscreen ? 48 : 32),

                          // Stop button
                          _buildControlButton(
                            icon: Icons.stop,
                            onPressed: timerNotifier.stop,
                            color: Colors.red,
                            size: _isFullscreen ? 80 : 60,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              if (_isFullscreen)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Tocca per uscire dal fullscreen',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationSelector(TimerNotifier notifier, TimerState state) {
    final durations = [1, 2, 3, 5, 8, 10, 12, 15, 20];
    final currentMinutes = state.totalSeconds ~/ 60;

    return Column(
      children: [
        Text(
          'Durata (minuti)',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: durations.map((minutes) {
              final isSelected = minutes == currentMinutes;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text('$minutes'),
                  selected: isSelected,
                  onSelected: state.isRunning
                      ? null
                      : (_) => notifier.setDuration(minutes),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    required double size,
    bool isPrimary = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Material(
        color: color.withValues(alpha: 0.2),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
            ),
            child: Icon(
              icon,
              size: size * 0.5,
              color: color,
            ),
          ),
        ),
      ),
    ).animate().scale(begin: const Offset(0.8, 0.8), duration: 200.ms);
  }

  Color _getTimerColor(TimerState state) {
    if (state.isFinished) return Colors.red;
    if (!state.isRunning) return Colors.blue;
    
    final percentage = state.remainingSeconds / state.totalSeconds;
    if (percentage > 0.25) return Colors.green;
    if (percentage > 0.1) return Colors.orange;
    return Colors.red;
  }
}
