import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import '../../data/stats_repository.dart';

class HallOfFameScreen extends ConsumerWidget {
  const HallOfFameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(appStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.hallOfFame),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
        ),
      ),
      body: statsAsync.when(
        data: (stats) {
          if (stats.hallOfFame.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 80,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noTournamentsRecorded,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                sliver: SliverList(
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
                          title: Text(
                            entry.tournamentName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
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
                                  color: isDecided ? Colors.amber.shade700 : Colors.grey,
                                ),
                              ),
                              if (entry.winnerPointsFor != null)
                                Text(
                                  AppLocalizations.of(context)!.points(entry.winnerPointsFor!, entry.winnerPointsAgainst ?? 0),
                                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      ).animate().slideX(delay: (100 + index * 50).ms, duration: 400.ms);
                    },
                    childCount: stats.hallOfFame.length,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
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
      case 'league_madness':
        return l10n.leagueMadness;
      case 'madness':
        return l10n.madness;
      default:
        return mode;
    }
  }
}
