import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/tournaments_repository.dart';

class TournamentDetailScreen extends ConsumerWidget {
  final int tournamentId;

  const TournamentDetailScreen({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentAsync = ref.watch(tournamentByIdProvider(tournamentId));
    final teamsAsync = ref.watch(tournamentTeamsProvider(tournamentId));

    return tournamentAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Errore')),
        body: Center(child: Text('Errore: $error')),
      ),
      data: (tournament) {
        if (tournament == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Non trovato')),
            body: const Center(child: Text('Torneo non trovato')),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(tournament.name),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                          Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.emoji_events,
                        size: 80,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 20),
                          const SizedBox(width: 8),
                          Text(tournament.location),
                        ],
                      ).animate().fadeIn(),
                      
                      const SizedBox(height: 24),
                      
                      // Teams section
                      Text(
                        'Squadre Partecipanti',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      teamsAsync.when(
                        loading: () => const CircularProgressIndicator(),
                        error: (e, s) => Text('Errore: $e'),
                        data: (teams) => Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: teams.map((tt) => Chip(
                            avatar: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: Text(
                                tt.team.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                            label: Text(tt.team.name),
                          )).toList(),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Actions
                      Text(
                        'Gestione Torneo',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildActionCards(context, tournament),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionCards(BuildContext context, dynamic tournament) {
    final mode = tournament.mode;
    final actions = <Widget>[];

    // Calendar (for group modes)
    if (mode == 'group_only' || mode == 'group_and_elimination') {
      actions.add(_buildActionCard(
        context,
        icon: Icons.calendar_month,
        title: 'Calendario',
        subtitle: 'Fase a gironi',
        color: Colors.blue,
        onTap: () => context.go('/tournaments/$tournamentId/calendar'),
      ));
    }

    // Standings (for group modes)
    if (mode == 'group_only' || mode == 'group_and_elimination') {
      actions.add(_buildActionCard(
        context,
        icon: Icons.leaderboard,
        title: 'Classifica',
        subtitle: 'Punti e statistiche',
        color: Colors.green,
        onTap: () => context.go('/tournaments/$tournamentId/standings'),
      ));
    }

    // Bracket (for elimination modes)
    if (mode == 'elimination_only' || mode == 'group_and_elimination') {
      actions.add(_buildActionCard(
        context,
        icon: Icons.account_tree,
        title: 'Eliminatoria',
        subtitle: 'Bracket playoff',
        color: Colors.orange,
        onTap: () => context.go('/tournaments/$tournamentId/bracket'),
      ));
    }

    // Timer
    actions.add(_buildActionCard(
      context,
      icon: Icons.timer,
      title: 'Timer',
      subtitle: '${tournament.timerMinutes} minuti',
      color: Colors.red,
      onTap: () => context.go('/timer'),
    ));

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: actions.asMap().entries.map((entry) {
        return entry.value.animate().fadeIn(delay: Duration(milliseconds: 100 * entry.key)).scale(begin: const Offset(0.9, 0.9));
      }).toList(),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.3),
                color.withValues(alpha: 0.1),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
