import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/matches_repository.dart';

class CalendarScreen extends ConsumerWidget {
  final int tournamentId;

  const CalendarScreen({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(groupMatchesProvider(tournamentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Genera casuale',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Genera calendario'),
                  content: const Text('Questo cancellerà il calendario esistente e ne creerà uno nuovo casuale. Continuare?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annulla'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Genera'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(matchesRepositoryProvider).generateGroupCalendar(tournamentId);
                // ignore: unused_result
                ref.refresh(groupMatchesProvider(tournamentId));
              }
            },
          ),
        ],
      ),
      body: matchesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Errore: $error')),
        data: (matches) {
          if (matches.isEmpty) {
            return _buildEmptyState(context, ref);
          }

          // Group by round
          final matchesByRound = <int, List<MatchWithTeams>>{};
          for (final match in matches) {
            final round = match.match.round;
            matchesByRound.putIfAbsent(round, () => []).add(match);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: matchesByRound.length,
            itemBuilder: (context, index) {
              final round = matchesByRound.keys.elementAt(index);
              final roundMatches = matchesByRound[round]!;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Giornata $round',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...roundMatches.asMap().entries.map((entry) => 
                    _buildMatchCard(context, entry.value, entry.key)
                  ),
                  const SizedBox(height: 16),
                ],
              ).animate().fadeIn(delay: Duration(milliseconds: 100 * index));
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 100,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Nessuna partita',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Genera il calendario per iniziare',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await ref.read(matchesRepositoryProvider).generateGroupCalendar(tournamentId);
              // ignore: unused_result
              ref.refresh(groupMatchesProvider(tournamentId));
            },
            icon: const Icon(Icons.shuffle),
            label: const Text('Genera Calendario'),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildMatchCard(BuildContext context, MatchWithTeams matchWithTeams, int index) {
    final match = matchWithTeams.match;
    final homeTeam = matchWithTeams.homeTeam;
    final awayTeam = matchWithTeams.awayTeam;

    final isBye = match.isBye;
    final isCompleted = match.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: isBye ? null : () => context.pushNamed('match-detail', pathParameters: {
          'tournamentId': tournamentId.toString(),
          'matchId': match.id.toString(),
        }),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Home team
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      homeTeam?.name ?? 'BYE',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: homeTeam == null ? Colors.grey : null,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              
              // Score
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isBye 
                      ? 'BYE'
                      : isCompleted 
                          ? '${match.homeScore} - ${match.awayScore}'
                          : 'vs',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isBye ? Colors.grey : null,
                  ),
                ),
              ),
              
              // Away team
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      awayTeam?.name ?? 'BYE',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: awayTeam == null ? Colors.grey : null,
                      ),
                    ),
                  ],
                ),
              ),
              
              if (!isBye)
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideX(begin: 0.1);
  }
}
