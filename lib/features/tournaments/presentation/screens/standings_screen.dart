import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';
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
/// Provider for standings grouped by groupNumber
final standingsProvider = FutureProvider.family<Map<int, List<StandingEntry>>, int>((ref, tournamentId) async {
  final matchesAsync = await ref.watch(groupMatchesProvider(tournamentId).future);
  final tournamentAsync = await ref.watch(tournamentByIdProvider(tournamentId).future);
  final teamsAsync = await ref.watch(tournamentTeamsProvider(tournamentId).future);

  if (tournamentAsync == null) return {};

  final tournament = tournamentAsync;
  final winPoints = tournament.winPoints;
  final drawPoints = tournament.drawPoints;
  final lossPoints = tournament.lossPoints;

  // Initialize standings for all teams, grouped by groupNumber
  final Map<int, Map<int, StandingEntry>> groupStandings = {};
  for (final tt in teamsAsync) {
    final gn = tt.tournamentTeam.groupNumber;
    groupStandings.putIfAbsent(gn, () => {});
    groupStandings[gn]![tt.team.id] = StandingEntry(
      teamId: tt.team.id,
      teamName: tt.team.name,
    );
  }

  // Calculate standings from completed matches
  for (final matchWithTeams in matchesAsync) {
    final match = matchWithTeams.match;
    if (!match.isCompleted || match.isBye) continue;

    final gn = match.groupNumber;
    if (!groupStandings.containsKey(gn)) continue;
    final standings = groupStandings[gn]!;

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

  // Sort and convert to final map
  final Map<int, List<StandingEntry>> result = {};
  for (var entry in groupStandings.entries) {
    final sorted = entry.value.values.toList()
      ..sort((a, b) {
        final pointsComp = b.classificationPoints.compareTo(a.classificationPoints);
        if (pointsComp != 0) return pointsComp;
        final diffComp = b.pointsDiff.compareTo(a.pointsDiff);
        if (diffComp != 0) return diffComp;
        return b.pointsFor.compareTo(a.pointsFor);
      });
    result[entry.key] = sorted;
  }

  return result;
});

class StandingsScreen extends ConsumerWidget {
  final int tournamentId;

  const StandingsScreen({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final standingsAsync = ref.watch(standingsProvider(tournamentId));
    final tournamentAsync = ref.watch(tournamentByIdProvider(tournamentId));

    return tournamentAsync.when(
      loading: () => Scaffold(appBar: AppBar(title: const Text('...')), body: const Center(child: CircularProgressIndicator())),
      error: (_, __) => Scaffold(appBar: AppBar(title: const Text('Error')), body: const Center(child: Text('Error'))),
      data: (tournament) {
        if (tournament == null) return const SizedBox();
        
        // Parse group names
        List<String> groupNames = [];
        try {
          if (tournament.groupNames != null) {
            groupNames = List<String>.from(jsonDecode(tournament.groupNames!));
          }
        } catch (_) {}

        return standingsAsync.when(
          loading: () => Scaffold(appBar: AppBar(title: Text(tournament.name)), body: const Center(child: CircularProgressIndicator())),
          error: (error, __) => Scaffold(appBar: AppBar(title: Text(tournament.name)), body: Center(child: Text('Errore: $error'))),
          data: (groupedStandings) {
            if (groupedStandings.isEmpty) {
              return Scaffold(appBar: AppBar(title: Text(tournament.name)), body: _buildEmptyState(context));
            }

            final groupNumbers = groupedStandings.keys.toList()..sort();
            
            if (groupNumbers.length <= 1) {
              return Scaffold(
                appBar: AppBar(title: const Text('Classifica')),
                body: _buildSingleGroupBody(context, groupedStandings[groupNumbers.first]!, tournament.qualifiersPerGroup),
              );
            }

            return DefaultTabController(
              length: groupNumbers.length,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Classifiche'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.account_tree),
                      tooltip: 'Vai al Tabellone',
                      onPressed: () => context.go('/tournaments/$tournamentId/bracket'),
                    ),
                  ],
                  bottom: TabBar(
                    isScrollable: true,
                    tabs: groupNumbers.map((gn) {
                      final name = groupNames.length >= gn ? groupNames[gn-1] : 'Girone $gn';
                      return Tab(text: name);
                    }).toList(),
                  ),
                ),
                body: TabBarView(
                  children: groupNumbers.map((gn) {
                    return _buildSingleGroupBody(context, groupedStandings[gn]!, tournament.qualifiersPerGroup);
                  }).toList(),
                ),
              ),
            );
          },
        );
      }
    );
  }

  Widget _buildSingleGroupBody(BuildContext context, List<StandingEntry> standings, int qualifiers) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStandingsTable(context, standings, qualifiers),
          const SizedBox(height: 16),
          _buildLegend(context, qualifiers),
        ],
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

  Widget _buildStandingsTable(BuildContext context, List<StandingEntry> standings, int qualifiers) {
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
            final isTop = index < qualifiers; // Playoff zone based on config
            
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

  Widget _buildLegend(BuildContext context, int qualifiers) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Legenda (Qualificati: $qualifiers)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
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
