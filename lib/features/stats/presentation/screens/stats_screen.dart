import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/stats_repository.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(appStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appStatistics),
        centerTitle: true,
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Errore: $error')),
        data: (stats) {
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(appStatsProvider),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      _buildStatCard(
                        context,
                        AppLocalizations.of(context)!.totalTeams,
                        stats.totalTeams.toString(),
                        Icons.groups,
                        Colors.blue,
                      ).animate().scale(delay: 100.ms, duration: 400.ms, curve: Curves.easeOutBack),
                      _buildStatCard(
                        context,
                        AppLocalizations.of(context)!.courts,
                        stats.totalCourts.toString(),
                        Icons.map,
                        Colors.teal,
                      ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
                      _buildStatCard(
                        context,
                        AppLocalizations.of(context)!.tournamentsCreated,
                        stats.totalTournaments.toString(),
                        Icons.emoji_events,
                        Colors.purple,
                      ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
                      _buildStatCard(
                        context,
                        AppLocalizations.of(context)!.inProgress,
                        stats.activeTournaments.toString(),
                        Icons.sports,
                        Colors.red,
                      ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
                      _buildStatCard(
                        context,
                        AppLocalizations.of(context)!.matchesPlayed,
                        stats.totalMatches.toString(),
                        Icons.sports_basketball,
                        Colors.green,
                      ).animate().scale(delay: 500.ms, duration: 400.ms, curve: Curves.easeOutBack),
                      _buildStatCard(
                        context,
                        AppLocalizations.of(context)!.pointsScored,
                        stats.totalPoints.toString(),
                        Icons.bar_chart,
                        Colors.orange,
                      ).animate().scale(delay: 600.ms, duration: 400.ms, curve: Curves.easeOutBack),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                    child: Text(
                      AppLocalizations.of(context)!.hallOfFame,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: 700.ms),
                  ),
                ),
                stats.hallOfFame.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(AppLocalizations.of(context)!.noTournamentsRecorded),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final entry = stats.hallOfFame[index];
                          final bool isDecided = entry.winningTeam != null;
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isDecided ? Colors.amber.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
                                child: Icon(
                                  Icons.emoji_events,
                                  color: isDecided ? Colors.amber : Colors.grey,
                                ),
                              ),
                              title: Text(entry.tournamentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          entry.startDate != null 
                                            ? "${entry.startDate!.day}/${entry.startDate!.month}/${entry.startDate!.year}"
                                            : "${entry.createdAt.day}/${entry.createdAt.month}/${entry.createdAt.year}",
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(AppLocalizations.of(context)!.location(entry.location)),
                                    Text(AppLocalizations.of(context)!.teamsAndMode(entry.teamCount, _getLocalizedMode(context, entry.mode))),
                                    const SizedBox(height: 8),
                                    Text(
                                      isDecided ? AppLocalizations.of(context)!.winner(entry.winningTeam!) : AppLocalizations.of(context)!.inProgressOrToBeDecided,
                                      style: TextStyle(
                                        fontWeight: isDecided ? FontWeight.bold : FontWeight.normal,
                                        color: isDecided ? Colors.green : Colors.grey,
                                      ),
                                    ),
                                    if (isDecided && entry.winnerWins != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!.teamRecord(entry.winnerWins!, entry.winnerLosses ?? 0),
                                              style: const TextStyle(fontSize: 13, color: Colors.grey),
                                            ),
                                            if (entry.winnerPointsFor != null)
                                              Text(
                                                AppLocalizations.of(context)!.points(entry.winnerPointsFor!, entry.winnerPointsAgainst ?? 0),
                                                style: const TextStyle(fontSize: 13, color: Colors.grey),
                                              ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              isThreeLine: true,
                            ),
                          ).animate().slideX(delay: (700 + index * 100).ms, duration: 400.ms);
                        },
                        childCount: stats.hallOfFame.length,
                      ),
                    ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getLocalizedMode(BuildContext context, String mode) {
    final l10n = AppLocalizations.of(context)!;
    switch (mode) {
      case 'group_only':
        return l10n.groupOnly;
      case 'elimination_only':
        return l10n.eliminationOnly;
      case 'group_and_elimination':
        return l10n.groupAndElimination;
      default:
        return mode;
    }
  }
}
