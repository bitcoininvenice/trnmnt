import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trnmnt/features/stats/data/stats_repository.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';

import 'package:trnmnt/features/tournaments/data/tournaments_repository.dart';

class StatsOverviewWidget extends ConsumerWidget {
  final AppStats stats;

  const StatsOverviewWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentFilters = ref.watch(cloudFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              Text(
                l10n.statsOverview.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            padding: EdgeInsets.zero, // REMOVE DEFAULT GRID PADDING
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.2,
            children: [
              _buildStatItem(context, l10n.tournamentsCreated, stats.totalTournaments.toString(), Icons.emoji_events, Colors.purple),
              _buildStatItem(context, l10n.inProgress, stats.activeTournaments.toString(), Icons.sensors, Colors.green),
              _buildStatItem(context, l10n.matchesPlayed, stats.totalMatches.toString(), Icons.sports_basketball, Colors.orange),
              _buildStatItem(context, l10n.pointsScored, stats.totalPoints.toString(), Icons.leaderboard, Colors.blue),
              _buildStatItem(context, l10n.totalTeams, stats.totalTeams.toString(), Icons.people, Colors.pink),
              _buildStatItem(context, l10n.courts, stats.totalCourts.toString(), Icons.map, Colors.teal),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                ),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.95, 0.95));
  }

  PopupMenuItem<CloudFilter> _buildPopupItem(CloudFilter value, String label, bool isSelected) {
    return PopupMenuItem<CloudFilter>(
      value: value,
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_box : Icons.check_box_outline_blank,
            color: isSelected ? Colors.orange : Colors.grey,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
