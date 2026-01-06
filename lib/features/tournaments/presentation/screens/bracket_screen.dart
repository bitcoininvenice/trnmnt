import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/tournaments_repository.dart';
import '../../data/matches_repository.dart';
import 'standings_screen.dart';

/// Bracket match data
class BracketMatch {
  final int? matchId;
  final String phase;
  final String? homeTeam;
  final String? awayTeam;
  final int? homeScore;
  final int? awayScore;
  final bool isCompleted;
  final int position;

  BracketMatch({
    this.matchId,
    required this.phase,
    this.homeTeam,
    this.awayTeam,
    this.homeScore,
    this.awayScore,
    this.isCompleted = false,
    required this.position,
  });
}

/// Provider for bracket data
final bracketProvider = FutureProvider.family<Map<String, List<BracketMatch>>, int>((ref, tournamentId) async {
  final matches = await ref.watch(tournamentMatchesProvider(tournamentId).future);
  
  final bracket = <String, List<BracketMatch>>{};
  
  for (final matchWithTeams in matches) {
    final match = matchWithTeams.match;
    if (match.phase == 'group') continue; // Skip group matches
    
    final bracketMatch = BracketMatch(
      matchId: match.id,
      phase: match.phase,
      homeTeam: matchWithTeams.homeTeam?.name,
      awayTeam: matchWithTeams.awayTeam?.name,
      homeScore: match.homeScore,
      awayScore: match.awayScore,
      isCompleted: match.isCompleted,
      position: match.round,
    );
    
    bracket.putIfAbsent(match.phase, () => []).add(bracketMatch);
  }
  
  return bracket;
});

class BracketScreen extends ConsumerWidget {
  final int tournamentId;

  const BracketScreen({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bracketAsync = ref.watch(bracketProvider(tournamentId));
    final tournamentAsync = ref.watch(tournamentByIdProvider(tournamentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eliminatoria'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_fix_high),
            tooltip: 'Genera da classifica',
            onPressed: () => _generateFromStandings(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Genera casuale',
            onPressed: () => _generateRandom(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Elimina e ricrea',
            onPressed: () => _deleteBracket(context, ref),
          ),
        ],
      ),
      body: bracketAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Errore: $error')),
        data: (bracket) {
          if (bracket.isEmpty) {
            return _buildEmptyState(context, ref, tournamentAsync);
          }

          return _buildBracketView(context, bracket);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, AsyncValue<dynamic> tournamentAsync) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_tree_outlined,
            size: 100,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Nessun bracket',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Genera il bracket per iniziare la fase eliminatoria',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _generateFromStandings(context, ref),
                icon: const Icon(Icons.auto_fix_high),
                label: const Text('Da Classifica'),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () => _generateRandom(context, ref),
                icon: const Icon(Icons.shuffle),
                label: const Text('Casuale'),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Future<void> _deleteBracket(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Bracket'),
        content: const Text('Sei sicuro di voler eliminare tutto il tabellone eliminatorio? I risultati verranno persi.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annulla')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final repo = ref.read(matchesRepositoryProvider);
    await repo.deleteMatchesByPhase(tournamentId, 'quarterfinal');
    await repo.deleteMatchesByPhase(tournamentId, 'semifinal');
    await repo.deleteMatchesByPhase(tournamentId, 'final');
    await repo.deleteMatchesByPhase(tournamentId, 'third_place');
    await repo.deleteMatchesByPhase(tournamentId, 'fifth_place');
    await repo.deleteMatchesByPhase(tournamentId, 'seventh_place');

    // ignore: unused_result
    ref.refresh(bracketProvider(tournamentId));
  }

  Future<void> _generateFromStandings(BuildContext context, WidgetRef ref) async {
    final standings = await ref.read(standingsProvider(tournamentId).future);
    if (standings.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nessuna classifica disponibile. Completa prima alcune partite del girone.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    await _generateBracket(context, ref, standings.map((s) => s.teamId).toList());
  }

  Future<void> _generateRandom(BuildContext context, WidgetRef ref) async {
    final teams = await ref.read(tournamentTeamsProvider(tournamentId).future);
    if (teams.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nessuna squadra nel torneo'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final teamIds = teams.map((t) => t.team.id).toList()..shuffle(Random());
    await _generateBracket(context, ref, teamIds);
  }

  Future<void> _generateBracket(BuildContext context, WidgetRef ref, List<int> orderedTeamIds) async {
    final tournament = await ref.read(tournamentByIdProvider(tournamentId).future);
    if (tournament == null) return;

    final repo = ref.read(matchesRepositoryProvider);
    
    // Delete existing elimination matches
    await repo.deleteMatchesByPhase(tournamentId, 'quarterfinal');
    await repo.deleteMatchesByPhase(tournamentId, 'semifinal');
    await repo.deleteMatchesByPhase(tournamentId, 'final');
    await repo.deleteMatchesByPhase(tournamentId, 'third_place');
    await repo.deleteMatchesByPhase(tournamentId, 'fifth_place');
    await repo.deleteMatchesByPhase(tournamentId, 'seventh_place');

    final numTeams = orderedTeamIds.length;
    
    // Determine bracket size (2, 4, 8, 16...)
    int bracketSize = 2;
    while (bracketSize < numTeams) {
      bracketSize *= 2;
    }

    // Generate matches based on team count
    if (numTeams >= 8) {
      // Quarterfinals
      for (var i = 0; i < 4; i++) {
        final homeIdx = i;
        final awayIdx = 7 - i;
        await repo.createMatch(
          tournamentId: tournamentId,
          homeTeamId: homeIdx < numTeams ? orderedTeamIds[homeIdx] : null,
          awayTeamId: awayIdx < numTeams ? orderedTeamIds[awayIdx] : null,
          round: i + 1,
          phase: 'quarterfinal',
          isBye: homeIdx >= numTeams || awayIdx >= numTeams,
        );
      }
    }

    if (numTeams >= 4) {
      // Semifinals (placeholders if QF exists)
      for (var i = 0; i < 2; i++) {
        final homeIdx = numTeams < 8 ? i : null;
        final awayIdx = numTeams < 8 ? 3 - i : null;
        await repo.createMatch(
          tournamentId: tournamentId,
          homeTeamId: numTeams < 8 && homeIdx != null && homeIdx < numTeams ? orderedTeamIds[homeIdx] : null,
          awayTeamId: numTeams < 8 && awayIdx != null && awayIdx < numTeams ? orderedTeamIds[awayIdx] : null,
          round: i + 1,
          phase: 'semifinal',
        );
      }
    }

    // Final
    await repo.createMatch(
      tournamentId: tournamentId,
      homeTeamId: numTeams == 2 ? orderedTeamIds[0] : null,
      awayTeamId: numTeams == 2 ? orderedTeamIds[1] : null,
      round: 1,
      phase: 'final',
    );

    // Consolation finals if enabled
    if (tournament.includeConsolationFinals) {
      // 3rd/4th place
      await repo.createMatch(
        tournamentId: tournamentId,
        round: 1,
        phase: 'third_place',
      );

      if (numTeams >= 8) {
        // Consolation Semifinals (Losers of QF)
        for (var i = 0; i < 2; i++) {
           await repo.createMatch(
            tournamentId: tournamentId,
            round: i + 1,
            phase: 'consolation_semifinal',
          );
        }

        // 5th/6th place
        await repo.createMatch(
          tournamentId: tournamentId,
          round: 1,
          phase: 'fifth_place',
        );

        // 7th/8th place
        await repo.createMatch(
          tournamentId: tournamentId,
          round: 1,
          phase: 'seventh_place',
        );
      }
    }

    // Refresh
    // ignore: unused_result
    ref.refresh(bracketProvider(tournamentId));
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bracket generato!')),
      );
    }
  }

  Widget _buildBracketView(BuildContext context, Map<String, List<BracketMatch>> bracket) {
    final phases = ['quarterfinal', 'semifinal', 'final'];
    final consolationPhases = ['consolation_semifinal', 'third_place', 'fifth_place', 'seventh_place'];

    // Determine tournament winner
    String? tournamentWinner;
    if (bracket.containsKey('final')) {
      final finalMatch = bracket['final']!.first;
      if (finalMatch.isCompleted) {
        tournamentWinner = (finalMatch.homeScore ?? 0) > (finalMatch.awayScore ?? 0)
            ? finalMatch.homeTeam
            : finalMatch.awayTeam;
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tournament Winner Banner
          if (tournamentWinner != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade700, Colors.amber.shade500],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    '🏆 VINCITORE 🏆',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tournamentWinner,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().scale(),

          // Main bracket area
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: phases.where((p) => bracket.containsKey(p)).map((phase) {
                    return _buildPhaseColumn(context, phase, bracket[phase]!);
                  }).toList(),
                ),
                
                // Consolation finals
                if (bracket.keys.any((k) => consolationPhases.contains(k))) ...[
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Tabellone 5°-8° Posto',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: consolationPhases.where((p) => bracket.containsKey(p)).map((phase) {
                      return _buildPhaseColumn(context, phase, bracket[phase]!);
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPhaseColumn(BuildContext context, String phase, List<BracketMatch> matches) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: Column(
        children: [
          Text(
            _getPhaseLabel(phase),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...matches.map((match) => _buildMatchCard(context, null, match)),
        ],
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, String? label, BracketMatch match) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          if (match.matchId != null) {
            context.pushNamed('match-detail', pathParameters: {
              'tournamentId': tournamentId.toString(),
              'matchId': match.matchId.toString(),
            });
          }
        },
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              if (label != null) ...[
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
              ],
              _buildTeamRow(context, match.homeTeam, match.homeScore, match.isCompleted && (match.homeScore ?? 0) > (match.awayScore ?? 0)),
              const Divider(height: 16),
              _buildTeamRow(context, match.awayTeam, match.awayScore, match.isCompleted && (match.awayScore ?? 0) > (match.homeScore ?? 0)),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildTeamRow(BuildContext context, String? teamName, int? score, bool isWinner) {
    return Row(
      children: [
        Expanded(
          child: Text(
            teamName ?? 'TBD',
            style: TextStyle(
              fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
              color: teamName == null ? Colors.grey : null,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (score != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isWinner ? Colors.green.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$score',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isWinner ? Colors.green : null,
              ),
            ),
          ),
      ],
    );
  }

  String _getPhaseLabel(String phase) {
    switch (phase) {
      case 'quarterfinal':
        return 'Quarti';
      case 'semifinal':
        return 'Semifinali';
      case 'final':
        return '🏆 Finale';
      case 'consolation_semifinal':
        return 'Semi 5°-8°';
      case 'third_place':
        return '3°/4° Posto';
      case 'fifth_place':
        return '5°/6° Posto';
      case 'seventh_place':
        return '7°/8° Posto';
      default:
        return phase;
    }
  }
}
