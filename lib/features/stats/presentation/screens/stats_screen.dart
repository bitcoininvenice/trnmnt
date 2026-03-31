import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/stats_repository.dart';

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
        title: const Text('Statistiche App'),
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
                        'Squadre Totali',
                        stats.totalTeams.toString(),
                        Icons.groups,
                        Colors.blue,
                      ).animate().scale(delay: 100.ms, duration: 400.ms, curve: Curves.easeOutBack),
                      _buildStatCard(
                        context,
                        'Campetti',
                        stats.totalCourts.toString(),
                        Icons.map,
                        Colors.teal,
                      ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
                      _buildStatCard(
                        context,
                        'Tornei Creati',
                        stats.totalTournaments.toString(),
                        Icons.emoji_events,
                        Colors.purple,
                      ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
                      _buildStatCard(
                        context,
                        'In Corso',
                        stats.activeTournaments.toString(),
                        Icons.local_fire_department,
                        Colors.red,
                      ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
                      _buildStatCard(
                        context,
                        'Partite Giocate',
                        stats.totalMatches.toString(),
                        Icons.sports,
                        Colors.green,
                      ).animate().scale(delay: 500.ms, duration: 400.ms, curve: Curves.easeOutBack),
                      _buildStatCard(
                        context,
                        'Punti Segnati',
                        stats.totalPoints.toString(),
                        Icons.sports_basketball,
                        Colors.orange,
                      ).animate().scale(delay: 600.ms, duration: 400.ms, curve: Curves.easeOutBack),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                    child: Text(
                      'Albo d\'Oro',
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
                        child: const Text('Nessun torneo registrato al momento.'),
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
                                    Text('📍 ${entry.location}'),
                                    Text('🏀 ${entry.teamCount} squadre - ${entry.mode}'),
                                    const SizedBox(height: 8),
                                    Text(
                                      isDecided ? '🏆 Vincitore: ${entry.winningTeam}' : '⏳ In Corso / Da decidere',
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
                                              'Record squadra: ${entry.winnerWins} V - ${entry.winnerLosses} S',
                                              style: const TextStyle(fontSize: 13, color: Colors.grey),
                                            ),
                                            if (entry.winnerPointsFor != null)
                                              Text(
                                                'Punti: PF ${entry.winnerPointsFor} / PS ${entry.winnerPointsAgainst}',
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
}
