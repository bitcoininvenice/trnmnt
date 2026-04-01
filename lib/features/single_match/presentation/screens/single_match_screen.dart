import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/vintage_score_column.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import '../../data/single_match_provider.dart';

class SingleMatchScreen extends ConsumerStatefulWidget {
  final String homeTeamName;
  final String awayTeamName;

  const SingleMatchScreen({
    super.key,
    required this.homeTeamName,
    required this.awayTeamName,
  });

  @override
  ConsumerState<SingleMatchScreen> createState() => _SingleMatchScreenState();
}

class _SingleMatchScreenState extends ConsumerState<SingleMatchScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(singleMatchProvider.notifier).setup(widget.homeTeamName, widget.awayTeamName);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playBuzzer() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/buzzer.mp3'));
      HapticFeedback.heavyImpact();
    } catch (e) {
      HapticFeedback.heavyImpact();
    }
  }

  String _formatTime(int remainingSeconds) {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color _getTimerColor(SingleMatchState state) {
    if (state.isFinished) return Colors.red;
    if (!state.isRunning) return Colors.blue;
    final percentage = state.remainingSeconds / (state.totalSeconds > 0 ? state.totalSeconds : 1);
    if (percentage > 0.25) return Colors.green;
    if (percentage > 0.1) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final matchState = ref.watch(singleMatchProvider);
    final notifier = ref.read(singleMatchProvider.notifier);

    ref.listen(singleMatchProvider.select((s) => s.isFinished), (prev, next) {
      if (next && !(prev ?? false)) {
        _playBuzzer();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(AppLocalizations.of(context)!.matchInProgress, style: const TextStyle(fontFamily: 'monospace')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: AppLocalizations.of(context)!.resetMatch,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(AppLocalizations.of(context)!.resetMatch),
                  content: Text(AppLocalizations.of(context)!.confirmResetMatch),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                    TextButton(
                      onPressed: () {
                        notifier.resetMatch();
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: Text(AppLocalizations.of(context)!.delete),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: VintageScoreColumn(
                      teamName: matchState.homeTeamName,
                      score: matchState.homeScore,
                      onScoreChanged: (val) => notifier.updateHomeScore(val),
                    ),
                  ),
                  _buildPeriodColumn(matchState, notifier),
                  Expanded(
                    child: VintageScoreColumn(
                      teamName: matchState.awayTeamName,
                      score: matchState.awayScore,
                      onScoreChanged: (val) => notifier.updateAwayScore(val),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 16, thickness: 2),
            _buildDurationSelector(matchState, notifier),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade900, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: _getTimerColor(matchState).withValues(alpha: 0.2),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          _formatTime(matchState.remainingSeconds),
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: _getTimerColor(matchState),
                            shadows: [
                              Shadow(color: _getTimerColor(matchState), blurRadius: 15),
                            ],
                          ),
                        ),
                      ).animate(target: matchState.isFinished ? 1 : 0).shake(duration: 500.ms).then().shimmer(duration: 1000.ms, color: Colors.red),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildControlButton(
                            icon: Icons.replay,
                            onPressed: () => notifier.resetTimer(),
                            color: Colors.grey,
                            size: 48,
                          ),
                          const SizedBox(width: 24),
                          _buildControlButton(
                            icon: matchState.isRunning ? Icons.pause : Icons.play_arrow,
                            onPressed: () => notifier.toggleTimer(),
                            color: matchState.isRunning ? Colors.orange : Colors.green,
                            size: 64,
                            isPrimary: true,
                          ),
                          const SizedBox(width: 24),
                          _buildControlButton(
                            icon: Icons.stop,
                            onPressed: () => notifier.stopTimerManually(),
                            color: Colors.red,
                            size: 48,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodColumn(SingleMatchState state, SingleMatchNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.periodLabel,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.grey.shade900, width: 2),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(color: Colors.green.withValues(alpha: 0.15), blurRadius: 5),
              ]
            ),
            child: Text(
              state.period.toString(),
              style: const TextStyle(
                fontSize: 32, 
                fontWeight: FontWeight.bold, 
                fontFamily: 'monospace',
                color: Colors.green,
                shadows: [Shadow(color: Colors.green, blurRadius: 8)],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.arrow_drop_down, size: 24, color: Colors.white54),
                onPressed: () => notifier.updatePeriod(state.period - 1),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.arrow_drop_up, size: 24, color: Colors.white54),
                onPressed: () => notifier.updatePeriod(state.period + 1),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDurationSelector(SingleMatchState state, SingleMatchNotifier notifier) {
    final durations = [1, 2, 3, 5, 8, 10, 12, 15, 20];
    final currentMinutes = state.totalSeconds ~/ 60;
    return Column(
      children: [
        Text(AppLocalizations.of(context)!.durationMinutes, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 8),
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
                  onSelected: state.isRunning ? null : (_) => notifier.setDuration(minutes),
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
            ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2)]
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
            child: Icon(icon, size: size * 0.5, color: color),
          ),
        ),
      ),
    ).animate().scale(begin: const Offset(0.8, 0.8), duration: 200.ms);
  }
}
