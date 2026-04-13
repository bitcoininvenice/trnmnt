import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/tournaments_repository.dart';
import '../../data/matches_repository.dart';
import '../../../../core/database/app_database.dart';
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

final playSpareggiProvider = StateProvider.family<bool, int>((ref, id) => true);

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
            onPressed: () => deleteBracket(context, ref, tournamentId),
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
    final playSpareggi = ref.watch(playSpareggiProvider(tournamentId));

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_tree_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.3),
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
                color: Colors.white.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // SPAREGGI TOGGLE
            Card(
              color: Colors.white.withOpacity(0.05),
              child: SwitchListTile(
                title: const Text('Gioca Spareggi', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('2ª vs 3ª dei gironi (Qualifica 3 per girone)'),
                value: playSpareggi,
                onChanged: (val) => ref.read(playSpareggiProvider(tournamentId).notifier).state = val,
                secondary: Icon(Icons.compare_arrows, color: playSpareggi ? Colors.amber : Colors.grey),
              ),
            ),
            
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _generateFromStandings(context, ref),
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text('Da Classifica'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _generateRandom(context, ref),
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Casuale'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _generateFromStandings(BuildContext context, WidgetRef ref) async {
    final tournament = await ref.read(tournamentByIdProvider(tournamentId).future);
    if (tournament == null) return;
    
    final playSpareggi = ref.read(playSpareggiProvider(tournamentId));
    final standingsMap = await ref.read(standingsProvider(tournamentId).future);
    
    if (standingsMap.isEmpty) {
       if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completare le partite dei gironi per generare il tabellone.')));
       return;
    }

    final Map<int, List<int>> qualifiersByGroup = {};
    final List<int> allQualifiersInterleaved = [];
    final groupNumbers = standingsMap.keys.toList()..sort();

    final qPerGroup = playSpareggi ? 3 : (tournament.qualifiersPerGroup);

    for (var gn in groupNumbers) {
      final groupStandings = standingsMap[gn]!;
      final q = groupStandings.take(qPerGroup).map((s) => s.teamId).toList();
      qualifiersByGroup[gn] = q;
    }

    int maxQ = 0;
    for (var q in qualifiersByGroup.values) {
      if (q.length > maxQ) maxQ = q.length;
    }

    for (int r = 0; r < maxQ; r++) {
      for (int gn in groupNumbers) {
        final groupTeams = qualifiersByGroup[gn]!;
        if (groupTeams.length > r) {
          allQualifiersInterleaved.add(groupTeams[r]);
        }
      }
    }

    await _generateDynamicBracket(context, ref, tournament, allQualifiersInterleaved, playSpareggi);
  }

  Future<void> _generateRandom(BuildContext context, WidgetRef ref) async {
    final teams = await ref.read(tournamentTeamsProvider(tournamentId).future);
    final tournament = await ref.read(tournamentByIdProvider(tournamentId).future);
    if (teams.isEmpty || tournament == null) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nessuna squadra nel torneo.')));
      return;
    }

    final teamIds = teams.map((t) => t.team.id).toList()..shuffle();
    await _generateDynamicBracket(context, ref, tournament, teamIds, false);
  }

  Future<void> _generateDynamicBracket(
    BuildContext context, 
    WidgetRef ref, 
    dynamic tournament, 
    List<int> allQualifiers,
    bool playSpareggi,
  ) async {
    final repo = ref.read(matchesRepositoryProvider);
    final numTeams = allQualifiers.length;
    
    if (numTeams < 2) {
       if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Numero di squadre insufficiente.')));
       return;
    }

    // Determine Bracket Size
    int bracketSize = 2;
    while (bracketSize < numTeams) {
      bracketSize *= 2;
    }

    final phaseNames = {
      2: 'final',
      4: 'semifinal',
      8: 'quarterfinal',
      16: 'round_of_16',
      32: 'round_of_32',
    };

    final bool exactPower = bracketSize == numTeams;
    
    // Clear existing matches
    await repo.deleteMatchesByPhase(tournamentId, 'play_in');
    await repo.deleteMatchesByPhase(tournamentId, 'round_of_32');
    await repo.deleteMatchesByPhase(tournamentId, 'round_of_16');
    await repo.deleteMatchesByPhase(tournamentId, 'quarterfinal');
    await repo.deleteMatchesByPhase(tournamentId, 'semifinal');
    await repo.deleteMatchesByPhase(tournamentId, 'final');
    await repo.deleteMatchesByPhase(tournamentId, 'third_place');

    if (exactPower && !playSpareggi) {
      // STANDARD BRACKET
      int currentSize = bracketSize;
      while (currentSize >= 2) {
        final phase = phaseNames[currentSize]!;
        final numMatches = currentSize ~/ 2;
        for (int i = 1; i <= numMatches; i++) {
          int? home, away;
          if (currentSize == bracketSize) {
             home = allQualifiers.length > (i - 1) ? allQualifiers[i - 1] : null;
             away = allQualifiers.length > (currentSize - i) ? allQualifiers[currentSize - i] : null;
          }
          await repo.createMatch(tournamentId: tournamentId, round: i, phase: phase, homeTeamId: home, awayTeamId: away);
        }
        currentSize ~/= 2;
      }
    } else {
      // PLAY-IN OR FORCED SPAREGGI
      // If playSpareggi is true and numTeams is 6, we force bracketSize 8
      int effectiveBracketSize = bracketSize;
      if (playSpareggi && numTeams == 6) effectiveBracketSize = 8;
      
      final int numByes = effectiveBracketSize - numTeams;
      final int numPlayIn = numTeams - (effectiveBracketSize ~/ 2);
      
      // 1. Play-In Matches
      for (int i = 1; i <= numPlayIn; i++) {
        final homeIdx = numByes + (i - 1);
        final awayIdx = numTeams - i;
        await repo.createMatch(
          tournamentId: tournamentId, 
          round: i, 
          phase: 'play_in', 
          homeTeamId: allQualifiers.length > homeIdx ? allQualifiers[homeIdx] : null,
          awayTeamId: allQualifiers.length > awayIdx ? allQualifiers[awayIdx] : null,
        );
      }

      // 2. Next Phases (Seeds waiting)
      int currentSize = effectiveBracketSize ~/ 2;
      while (currentSize >= 2) {
        final phase = phaseNames[currentSize]!;
        final numMatches = currentSize ~/ 2;
        for (int i = 1; i <= numMatches; i++) {
          int? home;
          if (currentSize == effectiveBracketSize ~/ 2 && i <= numByes) {
             home = allQualifiers.length > (i - 1) ? allQualifiers[i - 1] : null;
          }
          await repo.createMatch(tournamentId: tournamentId, round: i, phase: phase, homeTeamId: home);
        }
        currentSize ~/= 2;
      }
    }

    if (tournament.includeConsolationFinals) {
      await repo.createMatch(tournamentId: tournamentId, round: 1, phase: 'third_place');
    }

    ref.refresh(bracketProvider(tournamentId));
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bracket generato con successo!')));
  }

  Future<void> _generateBracket(BuildContext context, WidgetRef ref, List<int> orderedTeamIds) async {
     final tournament = await ref.read(tournamentByIdProvider(tournamentId).future);
    if (tournament == null) return;

    final repo = ref.read(matchesRepositoryProvider);
    
    // Delete existing elimination matches
    await repo.deleteMatchesByPhase(tournamentId, 'round_of_16');
    await repo.deleteMatchesByPhase(tournamentId, 'quarterfinal');
    await repo.deleteMatchesByPhase(tournamentId, 'semifinal');
    await repo.deleteMatchesByPhase(tournamentId, 'final');
    await repo.deleteMatchesByPhase(tournamentId, 'third_place');
    await repo.deleteMatchesByPhase(tournamentId, 'fifth_place');
    await repo.deleteMatchesByPhase(tournamentId, 'seventh_place');

    final numTeams = orderedTeamIds.length;
    
    // Generate matches based on team count
    if (numTeams >= 8) {
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

    await repo.createMatch(
      tournamentId: tournamentId,
      homeTeamId: numTeams == 2 ? orderedTeamIds[0] : null,
      awayTeamId: numTeams == 2 ? orderedTeamIds[1] : null,
      round: 1,
      phase: 'final',
    );

    if (tournament.includeConsolationFinals) {
      await repo.createMatch(tournamentId: tournamentId, round: 1, phase: 'third_place');
    }

    ref.refresh(bracketProvider(tournamentId));
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bracket generato!')));
  }

  Widget _buildBracketView(BuildContext context, Map<String, List<BracketMatch>> bracket) {
    final phases = ['play_in', 'round_of_16', 'quarterfinal', 'semifinal', 'final'];
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
      case 'play_in':
        return 'Spareggi';
      case 'round_of_16':
        return 'Ottavi';
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

Future<void> deleteBracket(BuildContext context, WidgetRef ref, int tournamentId) async {
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
  await repo.deleteMatchesByPhase(tournamentId, 'play_in');
  await repo.deleteMatchesByPhase(tournamentId, 'round_of_32');
  await repo.deleteMatchesByPhase(tournamentId, 'round_of_16');
  await repo.deleteMatchesByPhase(tournamentId, 'quarterfinal');
  await repo.deleteMatchesByPhase(tournamentId, 'semifinal');
  await repo.deleteMatchesByPhase(tournamentId, 'final');
  await repo.deleteMatchesByPhase(tournamentId, 'third_place');
  await repo.deleteMatchesByPhase(tournamentId, 'fifth_place');
  await repo.deleteMatchesByPhase(tournamentId, 'seventh_place');

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tabellone eliminato con successo.')),
    );
  }

  // ignore: unused_result
  ref.refresh(bracketProvider(tournamentId));
}
