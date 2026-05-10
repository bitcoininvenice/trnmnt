import 'dart:async';
import 'package:flutter/material.dart';

class ScrollingTicker extends StatefulWidget {
  final String text;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final double speed;
  final IconData separatorIcon;

  const ScrollingTicker({
    super.key,
    required this.text,
    this.height = 21,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.fontSize = 9,
    this.speed = 0.5,
    this.separatorIcon = Icons.star,
  });

  @override
  State<ScrollingTicker> createState() => _ScrollingTickerState();
}

class _ScrollingTickerState extends State<ScrollingTicker> {
  late ScrollController _scrollController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() {
    if (!mounted) return;
    
    final tickDuration = const Duration(milliseconds: 16); // ~60fps
    
    _timer = Timer.periodic(tickDuration, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_scrollController.hasClients) {
        final currentOffset = _scrollController.offset;
        // Continuous smooth scroll
        _scrollController.jumpTo(currentOffset + widget.speed);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? Theme.of(context).colorScheme.primary;

    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.orange.withOpacity(0.1), width: 0.5),
        ),
      ),
      child: IgnorePointer(
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return Row(
              children: [
                const SizedBox(width: 40),
                Text(
                  widget.text.toUpperCase(),
                  style: TextStyle(
                    color: widget.textColor?.withOpacity(0.9),
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 40),
                Icon(
                  widget.separatorIcon, 
                  size: widget.fontSize - 1, 
                  color: Colors.orange.withOpacity(0.5)
                ),
                const SizedBox(width: 40),
                Container(
                  width: 1, 
                  height: widget.height * 0.6, 
                  color: Colors.white.withOpacity(0.1)
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
