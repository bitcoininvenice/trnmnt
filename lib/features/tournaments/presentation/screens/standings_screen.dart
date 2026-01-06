import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/tournaments_repository.dart';
import '../../data/matches_repository.dart';

/// Standing entry for a team
class StandingEntry {
  final int teamId;
  final String teamName;
  int played = 0;
  int won = 0;
  int drawn = 0;
  int lost = 0;
  int pointsFor = 0;
  int pointsAgainst = 0;
  int classificationPoints = 0;

  StandingEntry({required this.teamId, required this.teamName});

  int get pointsDiff => pointsFor - pointsAgainst;
}

/// Provider for standings
final standingsProvider = FutureProvider.family<List<StandingEntry>, int>((ref, tournamentId) async {
  final matchesAsync = await ref.watch(groupMatchesProvider(tournamentId).future);
  final tournamentAsync = await ref.watch(tournamentByIdProvider(tournamentId).future);
  final teamsAsync = await ref.watch(tournamentTeamsProvider(tournamentId).future);

  if (tournamentAsync == null) return [];

  final tournament = tournamentAsync;
  final winPoints = tournament.winPoints;
  final drawPoints = tournament.drawPoints;
  final lossPoints = tournament.lossPoints;

  // Initialize standings for all teams
  final standings = <int, StandingEntry>{};
  for (final tt in teamsAsync) {
    standings[tt.team.id] = StandingEntry(
      teamId: tt.team.id,
      teamName: tt.team.name,
    );
  }

  // Calculate standings from completed matches
  for (final matchWithTeams in matchesAsync) {
    final match = matchWithTeams.match;
    if (!match.isCompleted || match.isBye) continue;

    final homeId = match.homeTeamId;
    final awayId = match.awayTeamId;
    if (homeId == null || awayId == null) continue;

    final homeScore = match.homeScore ?? 0;
    final awayScore = match.awayScore ?? 0;

    // Update home team
    if (standings.containsKey(homeId)) {
      final home = standings[homeId]!;
      home.played++;
      home.pointsFor += homeScore;
      home.pointsAgainst += awayScore;
      
      if (homeScore > awayScore) {
        home.won++;
        home.classificationPoints += winPoints;
      } else if (homeScore < awayScore) {
        home.lost++;
        home.classificationPoints += lossPoints;
      } else {
        home.drawn++;
        home.classificationPoints += drawPoints;
      }
    }

    // Update away team
    if (standings.containsKey(awayId)) {
      final away = standings[awayId]!;
      away.played++;
      away.pointsFor += awayScore;
      away.pointsAgainst += homeScore;
      
      if (awayScore > homeScore) {
        away.won++;
        away.classificationPoints += winPoints;
      } else if (awayScore < homeScore) {
        away.lost++;
        away.classificationPoints += lossPoints;
      } else {
        away.drawn++;
        away.classificationPoints += drawPoints;
      }
    }
  }

  // Sort by points, then point difference, then points for
  final sortedStandings = standings.values.toList()
    ..sort((a, b) {
      final pointsComp = b.classificationPoints.compareTo(a.classificationPoints);
      if (pointsComp != 0) return pointsComp;
      final diffComp = b.pointsDiff.compareTo(a.pointsDiff);
      if (diffComp != 0) return diffComp;
      return b.pointsFor.compareTo(a.pointsFor);
    });

  return sortedStandings;
});

class StandingsScreen extends ConsumerWidget {
  final int tournamentId;

  const StandingsScreen({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final standingsAsync = ref.watch(standingsProvider(tournamentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Classifica'),
      ),
      body: standingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Errore: $error')),
        data: (standings) {
          if (standings.isEmpty) {
            return _buildEmptyState(context);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStandingsTable(context, standings),
                const SizedBox(height: 24),
                _buildLegend(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.leaderboard_outlined,
            size: 100,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Nessun dato',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Genera il calendario e inserisci i risultati',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandingsTable(BuildContext context, List<StandingEntry> standings) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          ),
          columns: const [
            DataColumn(label: Text('#')),
            DataColumn(label: Text('Squadra')),
            DataColumn(label: Text('G'), numeric: true),
            DataColumn(label: Text('V'), numeric: true),
            DataColumn(label: Text('P'), numeric: true),
            DataColumn(label: Text('S'), numeric: true),
            DataColumn(label: Text('PF'), numeric: true),
            DataColumn(label: Text('PS'), numeric: true),
            DataColumn(label: Text('+/-'), numeric: true),
            DataColumn(label: Text('Pt'), numeric: true),
          ],
          rows: standings.asMap().entries.map((entry) {
            final index = entry.key;
            final standing = entry.value;
            final isTop = index < 4; // Playoff zone
            
            return DataRow(
              color: WidgetStateProperty.all(
                isTop ? Colors.green.withValues(alpha: 0.1) : null,
              ),
              cells: [
                DataCell(
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getPositionColor(index),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                DataCell(Text(
                  standing.teamName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                )),
                DataCell(Text('${standing.played}')),
                DataCell(Text('${standing.won}', style: const TextStyle(color: Colors.green))),
                DataCell(Text('${standing.drawn}')),
                DataCell(Text('${standing.lost}', style: const TextStyle(color: Colors.red))),
                DataCell(Text('${standing.pointsFor}')),
                DataCell(Text('${standing.pointsAgainst}')),
                DataCell(Text(
                  standing.pointsDiff >= 0 ? '+${standing.pointsDiff}' : '${standing.pointsDiff}',
                  style: TextStyle(
                    color: standing.pointsDiff >= 0 ? Colors.green : Colors.red,
                  ),
                )),
                DataCell(Text(
                  '${standing.classificationPoints}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )),
              ],
            );
          }).toList(),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Color _getPositionColor(int index) {
    if (index == 0) return Colors.amber;
    if (index == 1) return Colors.grey.shade400;
    if (index == 2) return Colors.brown.shade400;
    return Colors.grey.shade700;
  }

  Widget _buildLegend(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Legenda',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Text('G = Giocate'),
                Text('V = Vittorie'),
                Text('P = Pareggi'),
                Text('S = Sconfitte'),
                Text('PF = Punti Fatti'),
                Text('PS = Punti Subiti'),
                Text('Pt = Punti Classifica'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
