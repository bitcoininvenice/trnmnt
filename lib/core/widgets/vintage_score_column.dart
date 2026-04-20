import 'package:flutter/material.dart';

class VintageScoreColumn extends StatelessWidget {
  final String teamName;
  final int score;
  final ValueChanged<int>? onScoreChanged;

  const VintageScoreColumn({
    super.key,
    required this.teamName,
    required this.score,
    this.onScoreChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          teamName.toUpperCase(),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white70),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.grey.shade900, width: 2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.amber.withValues(alpha: 0.15), blurRadius: 10),
            ]
          ),
          child: Text(
            score.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 48, 
              fontWeight: FontWeight.bold, 
              fontFamily: 'monospace',
              color: Colors.amber,
              shadows: [Shadow(color: Colors.amber, blurRadius: 10)],
            ),
          ),
        ),
        if (onScoreChanged != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 28, color: Colors.white54),
                onPressed: score > 0 ? () => onScoreChanged!(score - 1) : null,
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 28, color: Colors.white54),
                onPressed: () => onScoreChanged!(score + 1),
              ),
            ],
          ),
        ]
      ],
    );
  }
}
