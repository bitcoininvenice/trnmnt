import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trnmnt/features/stats/data/stats_repository.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';

class StatsOverviewWidget extends StatelessWidget {
  final AppStats stats;

  const StatsOverviewWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   AppLocalizations.of(context)!.appStatistics,
          //   style: Theme.of(context).textTheme.titleLarge?.copyWith(
          //         fontWeight: FontWeight.bold,
          //       ),
          // ),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1.3,
            children: [
              _buildStatCard(
                context,
                AppLocalizations.of(context)!.tournamentsCreated,
                stats.totalTournaments.toString(),
                Icons.emoji_events,
                Colors.purple,
              ).animate().scale(delay: 100.ms, duration: 400.ms, curve: Curves.easeOutBack),
              _buildStatCard(
                context,
                AppLocalizations.of(context)!.inProgress,
                stats.activeTournaments.toString(),
                Icons.sports,
                Colors.red,
              ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
              _buildStatCard(
                context,
                AppLocalizations.of(context)!.matchesPlayed,
                stats.totalMatches.toString(),
                Icons.sports_basketball,
                Colors.green,
              ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
              _buildStatCard(
                context,
                AppLocalizations.of(context)!.pointsScored,
                stats.totalPoints.toString(),
                Icons.bar_chart,
                Colors.orange,
              ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
              _buildStatCard(
                context,
                AppLocalizations.of(context)!.totalTeams,
                stats.totalTeams.toString(),
                Icons.people,
                Colors.blue,
              ).animate().scale(delay: 500.ms, duration: 400.ms, curve: Curves.easeOutBack),
              _buildStatCard(
                context,
                AppLocalizations.of(context)!.courts,
                stats.totalCourts.toString(),
                Icons.map,
                Colors.teal,
              ).animate().scale(delay: 600.ms, duration: 400.ms, curve: Curves.easeOutBack),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9.5,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
