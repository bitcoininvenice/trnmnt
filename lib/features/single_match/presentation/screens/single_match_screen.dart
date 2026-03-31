import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/widgets/vintage_score_column.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';

class SingleMatchScreen extends StatefulWidget {
  final String homeTeamName;
  final String awayTeamName;

  const SingleMatchScreen({
    super.key,
    required this.homeTeamName,
    required this.awayTeamName,
  });

  @override
  State<SingleMatchScreen> createState() => _SingleMatchScreenState();
}

class _SingleMatchScreenState extends State<SingleMatchScreen> {
  // Scoreboard State
  int _homeScore = 0;
  int _awayScore = 0;
  int _period = 1;

  // Timer State
  int _totalSeconds = 600; // 10 minutes default
  int _remainingSeconds = 600;
  bool _isRunning = false;
  bool _isFinished = false;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _setDuration(int minutes) {
    if (_isRunning) return;
    setState(() {
      _totalSeconds = minutes * 60;
      _remainingSeconds = _totalSeconds;
      _isFinished = false;
    });
  }

  void _startTimer() {
    if (_remainingSeconds <= 0) return;
    setState(() {
      _isRunning = true;
      _isFinished = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _stopTimer();
          _isFinished = true;
          _playBuzzer();
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _remainingSeconds = _totalSeconds;
      _isFinished = false;
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  Future<void> _playBuzzer() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/buzzer.mp3'));
      HapticFeedback.heavyImpact();
    } catch (e) {
      HapticFeedback.heavyImpact();
    }
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color get _timerColor {
    if (_isFinished) return Colors.red;
    if (!_isRunning) return Colors.blue;
    final percentage = _remainingSeconds / (_totalSeconds > 0 ? _totalSeconds : 1);
    if (percentage > 0.25) return Colors.green;
    if (percentage > 0.1) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Vintage dark background
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
                        setState(() {
                          _homeScore = 0;
                          _awayScore = 0;
                          _period = 1;
                        });
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: Text(AppLocalizations.of(context)!.delete), // Using delete as 'Azzera' here
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
            // SCOREBOARD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  // HOME TEAM
                  Expanded(
                    child: VintageScoreColumn(
                      teamName: widget.homeTeamName,
                      score: _homeScore,
                      onScoreChanged: (val) {
                        setState(() {
                          if (val >= 0) _homeScore = val;
                        });
                      },
                    ),
                  ),
                  
                  // PERIOD
                  _buildPeriodColumn(),
                  
                  // AWAY TEAM
                  Expanded(
                    child: VintageScoreColumn(
                      teamName: widget.awayTeamName,
                      score: _awayScore,
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
            const Divider(height: 16, thickness: 2),

            // DURATION SELECTOR
            _buildDurationSelector(),
            const SizedBox(height: 12),

            // TIMER DISPLAY
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
                            color: _timerColor.withValues(alpha: 0.2),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Text(
                        _formattedTime,
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color: _timerColor,
                          shadows: [
                            Shadow(color: _timerColor, blurRadius: 15),
                          ],
                        ),
                      ),
                    ).animate(target: _isFinished ? 1 : 0).shake(duration: 500.ms).then().shimmer(duration: 1000.ms, color: Colors.red),

                    const SizedBox(height: 24),

                    // CONTROLS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildControlButton(
                          icon: Icons.replay,
                          onPressed: _resetTimer,
                          color: Colors.grey,
                          size: 48,
                        ),
                        const SizedBox(width: 24),
                        _buildControlButton(
                          icon: _isRunning ? Icons.pause : Icons.play_arrow,
                          onPressed: _toggleTimer,
                          color: _isRunning ? Colors.orange : Colors.green,
                          size: 64,
                          isPrimary: true,
                        ),
                        const SizedBox(width: 24),
                        _buildControlButton(
                          icon: Icons.stop,
                          onPressed: _stopTimer,
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

 

  Widget _buildPeriodColumn() {
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
              _period.toString(),
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
                onPressed: () => setState(() { if (_period > 1) _period--; }),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.arrow_drop_up, size: 24, color: Colors.white54),
                onPressed: () => setState(() { _period++; }),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDurationSelector() {
    final durations = [1, 2, 3, 5, 8, 10, 12, 15, 20];
    final currentMinutes = _totalSeconds ~/ 60;

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
                  onSelected: _isRunning ? null : (_) => _setDuration(minutes),
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
