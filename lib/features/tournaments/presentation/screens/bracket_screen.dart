import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/tournaments_repository.dart';
import '../../data/matches_repository.dart';
import '../../../../core/database/app_database.dart';
import '../../../sharing/data/share_repository.dart';
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

class BracketScreen extends ConsumerStatefulWidget {
  final dynamic tournamentId;

  const BracketScreen({super.key, required this.tournamentId});

  @override
  ConsumerState<BracketScreen> createState() => _BracketScreenState();
}

class _BracketScreenState extends ConsumerState<BracketScreen> {
  bool _isProcessing = false;

  int? get _localId => int.tryParse(widget.tournamentId.toString());
  bool get _isGuest => _localId == null;

  @override
  Widget build(BuildContext context) {
    // 1. Defensive check
    if (!mounted) return const SizedBox.shrink();

    if (_isGuest) {
      return _buildGuestBracket(context, ref);
    }

    final localId = _localId!;
    // 2. Unconditional watches at the top (Riverpod best practice)
    final bracketAsync = ref.watch(bracketProvider(localId));
    final tournamentAsync = ref.watch(tournamentByIdProvider(localId));

    // 3. Early return for processing state
    if (_isProcessing) {
      return Scaffold(
        appBar: AppBar(title: const Text('Eliminatoria')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
            onPressed: () => _softDeleteBracket(context, ref, localId),
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
    final playSpareggi = ref.watch(playSpareggiProvider(widget.tournamentId));

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
            const SizedBox(height: 32),
            
            // SPAREGGI TOGGLE
            Card(
              color: Colors.white.withValues(alpha: 0.05),
              child: SwitchListTile(
                title: const Text('Gioca Spareggi', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('2ª vs 3ª dei gironi (Qualifica 3 per girone)'),
                value: playSpareggi,
                onChanged: (val) => ref.read(playSpareggiProvider(widget.tournamentId).notifier).state = val,
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
    final tournament = await ref.read(tournamentByIdProvider(widget.tournamentId).future);
    if (tournament == null) return;
    
    final playSpareggi = ref.read(playSpareggiProvider(widget.tournamentId));
    final standingsMap = await ref.read(standingsProvider(widget.tournamentId).future);
    
    if (standingsMap.isEmpty) {
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completare le partite dei gironi per generare il tabellone.')));
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
    final teams = await ref.read(tournamentTeamsProvider(widget.tournamentId).future);
    final tournament = await ref.read(tournamentByIdProvider(widget.tournamentId).future);
    if (teams.isEmpty || tournament == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nessuna squadra nel torneo.')));
      return;
    }

    final teamIds = teams.map((t) => t.team.id).toList()..shuffle();
    if (!mounted) return;
    await _generateDynamicBracket(context, ref, tournament, teamIds, false);
  }

  Future<void> _generateDynamicBracket(
    BuildContext context, 
    WidgetRef ref, 
    dynamic tournament, 
    List<int> allQualifiers,
    bool playSpareggi,
  ) async {
    setState(() => _isProcessing = true);
    try {
      final repo = ref.read(matchesRepositoryProvider);
      final numTeams = allQualifiers.length;
      
      if (numTeams < 2) {
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Numero di squadre insufficiente.')));
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
      await repo.deleteMatchesByPhase(widget.tournamentId, 'play_in');
      await repo.deleteMatchesByPhase(widget.tournamentId, 'round_of_32');
      await repo.deleteMatchesByPhase(widget.tournamentId, 'round_of_16');
      await repo.deleteMatchesByPhase(widget.tournamentId, 'quarterfinal');
      await repo.deleteMatchesByPhase(widget.tournamentId, 'semifinal');
      await repo.deleteMatchesByPhase(widget.tournamentId, 'final');
      await repo.deleteMatchesByPhase(widget.tournamentId, 'third_place');

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
            await repo.createMatch(tournamentId: widget.tournamentId, round: i, phase: phase, homeTeamId: home, awayTeamId: away);
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
            tournamentId: widget.tournamentId, 
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
            await repo.createMatch(tournamentId: widget.tournamentId, round: i, phase: phase, homeTeamId: home);
          }
          currentSize ~/= 2;
        }
      }

      if (tournament.includeConsolationFinals) {
        await repo.createMatch(tournamentId: widget.tournamentId, round: 1, phase: 'third_place');
      }

      // Auto-sync back to cloud if published
      if (tournament.isPublished) {
        await ref.read(shareRepositoryProvider).publishToSupabase(widget.tournamentId);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bracket generato con successo!')));
    } catch (e) {
       if (mounted) {
         setState(() => _isProcessing = false);
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore: $e')));
       }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _generateBracket(BuildContext context, WidgetRef ref, List<int> orderedTeamIds) async {
     final tournament = await ref.read(tournamentByIdProvider(widget.tournamentId).future);
    if (tournament == null) return;

    final repo = ref.read(matchesRepositoryProvider);
    
    // Delete existing elimination matches
    await repo.deleteMatchesByPhase(widget.tournamentId, 'round_of_16');
    await repo.deleteMatchesByPhase(widget.tournamentId, 'quarterfinal');
    await repo.deleteMatchesByPhase(widget.tournamentId, 'semifinal');
    await repo.deleteMatchesByPhase(widget.tournamentId, 'final');
    await repo.deleteMatchesByPhase(widget.tournamentId, 'third_place');
    await repo.deleteMatchesByPhase(widget.tournamentId, 'fifth_place');
    await repo.deleteMatchesByPhase(widget.tournamentId, 'seventh_place');

    final numTeams = orderedTeamIds.length;
    
    // Generate matches based on team count
    if (numTeams >= 8) {
      for (var i = 0; i < 4; i++) {
        final homeIdx = i;
        final awayIdx = 7 - i;
        await repo.createMatch(
          tournamentId: widget.tournamentId,
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
          tournamentId: widget.tournamentId,
          homeTeamId: numTeams < 8 && homeIdx != null && homeIdx < numTeams ? orderedTeamIds[homeIdx] : null,
          awayTeamId: numTeams < 8 && awayIdx != null && awayIdx < numTeams ? orderedTeamIds[awayIdx] : null,
          round: i + 1,
          phase: 'semifinal',
        );
      }
    }

    await repo.createMatch(
      tournamentId: widget.tournamentId,
      homeTeamId: numTeams == 2 ? orderedTeamIds[0] : null,
      awayTeamId: numTeams == 2 ? orderedTeamIds[1] : null,
      round: 1,
      phase: 'final',
    );

    if (tournament.includeConsolationFinals) {
      await repo.createMatch(tournamentId: widget.tournamentId, round: 1, phase: 'third_place');
    }

    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bracket generato!')));
  }

  Widget _buildBracketView(BuildContext context, Map<String, List<BracketMatch>> bracket) {
    final phases = ['play_in', 'round_of_16', 'quarterfinal', 'semifinal', 'final'];
    final consolationPhases = ['consolation_semifinal', 'third_place', 'fifth_place', 'seventh_place'];

    final activePhases = phases.where((p) => bracket.containsKey(p)).toList();

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
                   const Text('🏆 VINCITORE 🏆', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
                   const SizedBox(height: 8),
                   Text(tournamentWinner, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

          // Main bracket area
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: CustomPaint(
              painter: BracketPainter(bracket: bracket, activePhases: activePhases),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: activePhases.map((phase) {
                  return _buildPhaseColumn(context, phase, bracket[phase]!, activePhases.indexOf(phase));
                }).toList(),
              ),
            ),
          ),
          
          // Consolation finals (simplified)
          if (bracket.keys.any((k) => consolationPhases.contains(k))) ...[
            const SizedBox(height: 32),
            const Divider(),
            Padding(
               padding: const EdgeInsets.all(16),
               child: Text('Tabellone Consolazione', style: Theme.of(context).textTheme.titleMedium),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: consolationPhases.where((p) => bracket.containsKey(p)).map((phase) {
                  return _buildPhaseColumn(context, phase, bracket[phase]!, 0);
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 120), // Increased bottom padding for lines visibility
        ],
      ),
    );
  }

  Widget _buildPhaseColumn(BuildContext context, String phase, List<BracketMatch> matches, int phaseIdx) {
    // Standard bracket spacing logic
    final double initialPadding = pow(2, phaseIdx).toDouble() * 30 - 30;
    final double matchGap = pow(2, phaseIdx).toDouble() * 100 - 100;

    return Padding(
      padding: const EdgeInsets.only(right: 64), // Space for connectors
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              _getPhaseLabel(phase).toUpperCase(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(height: initialPadding), // Offset for centering
          ...matches.map((match) => Column(
            children: [
              _buildMatchCard(context, null, match),
              SizedBox(height: 16 + matchGap), // Dynamic gap
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, String? label, BracketMatch match) {
    final bool isCompleted = match.isCompleted;
    final bool homeWon = isCompleted && (match.homeScore ?? 0) > (match.awayScore ?? 0);
    final bool awayWon = isCompleted && (match.awayScore ?? 0) > (match.homeScore ?? 0);

    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: () {
          if (match.matchId != null) {
            context.pushNamed('match-detail', pathParameters: {
              'tournamentId': widget.tournamentId.toString(),
              'matchId': match.matchId.toString(),
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTeamRow(context, match.homeTeam, match.homeScore, homeWon, match.matchId, true),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Divider(height: 1, color: Colors.white10),
              ),
              _buildTeamRow(context, match.awayTeam, match.awayScore, awayWon, match.matchId, false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamRow(BuildContext context, String? teamName, int? score, bool isWinner, int? matchId, bool isHome) {
    return InkWell(
      onLongPress: matchId == null ? null : () => _showTeamPicker(context, matchId, isHome),
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 24,
        child: Row(
          children: [
            Expanded(
              child: Text(
                (teamName ?? 'TBD').toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isWinner ? FontWeight.w900 : FontWeight.w500,
                  color: teamName == null ? Colors.white24 : (isWinner ? Colors.orange : Colors.white70),
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (score != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isWinner ? Colors.orange.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: isWinner ? Colors.orange : Colors.white38,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTeamPicker(BuildContext context, int matchId, bool isHome) async {
    final teamsAsync = await ref.read(tournamentTeamsProvider(widget.tournamentId).future);
    if (!context.mounted) return;

    final selectedTeam = await showDialog<Team>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isHome ? 'Seleziona Squadra Casa' : 'Seleziona Squadra Trasferta'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: teamsAsync.length,
            itemBuilder: (context, index) {
              final team = teamsAsync[index].team;
              return ListTile(
                leading: (team.logoPath != null && team.logoPath!.isNotEmpty) 
                  ? Image.network(team.logoPath!, width: 24, height: 24, errorBuilder: (_, __, ___) => const Icon(Icons.shield))
                  : const Icon(Icons.shield),
                title: Text(team.name),
                onTap: () => Navigator.pop(context, team),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANNULLA')),
        ],
      ),
    );

    if (!context.mounted) return;
    if (selectedTeam == null) return;
    
    final repo = ref.read(matchesRepositoryProvider);
    if (isHome) {
      await repo.updateMatchTeams(matchId, homeTeamId: selectedTeam.id);
    } else {
      await repo.updateMatchTeams(matchId, awayTeamId: selectedTeam.id);
    }
    
    ref.invalidate(bracketProvider(widget.tournamentId));
  }

  String _getPhaseLabel(String phase) {
    switch (phase) {
      case 'play_in':
        return 'Play-In';
      case 'round_of_32':
        return 'Sedicesimi';
      case 'round_of_16':
        return 'Ottavi';
      case 'quarterfinal':
        return 'Quarti';
      case 'semifinal':
        return 'Semifinale';
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

  Future<void> _softDeleteBracket(BuildContext context, WidgetRef ref, int tournamentId) async {
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

    setState(() => _isProcessing = true);
    try {
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

      if (!mounted) return;
      // Auto-sync after deletion if published
      final tournament = await ref.read(tournamentByIdProvider(tournamentId).future);
      if (!mounted) return;
      if (tournament != null && tournament.isPublished) {
        await ref.read(shareRepositoryProvider).publishToSupabase(tournamentId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tabellone eliminato con successo.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}

class BracketPainter extends CustomPainter {
  final Map<String, List<BracketMatch>> bracket;
  final List<String> activePhases;

  BracketPainter({required this.bracket, required this.activePhases});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const double cardWidth = 180.0;
    const double columnGap = 64.0;
    const double cardHeight = 73.0; // Precise height after paddings/borders
    const double cardVerticalMargin = 16.0;
    const double headerHeight = 36.0; // Text height + spacing

    for (int i = 0; i < activePhases.length - 1; i++) {
        final currentPhase = activePhases[i];
        final nextPhase = activePhases[i + 1];
        final currentMatches = bracket[currentPhase] ?? [];

        // Setup paints for glow effect
        final glowPaint = Paint()
            ..color = Colors.orange.withValues(alpha: 0.1)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6.0
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

        for (int mIdx = 0; mIdx < currentMatches.length; mIdx++) {
            // Find target match index
            final int targetMatchIdx = mIdx ~/ 2;
            final isUpperBranch = mIdx % 2 == 0;

            final double phaseIdx = i.toDouble();
            final double currentMatchGap = pow(2, phaseIdx).toDouble() * 100 - 100;
            final double currentInitialPadding = pow(2, phaseIdx).toDouble() * 30 - 30;
            
            final double startY = headerHeight + currentInitialPadding + (mIdx * (cardHeight + cardVerticalMargin + currentMatchGap)) + cardHeight / 2;
            
            final double xStart = (i * (cardWidth + columnGap)) + cardWidth;
            final double xMid = xStart + columnGap / 2;
            final double xEnd = (i + 1) * (cardWidth + columnGap);
            
            final double nextPhaseIdx = phaseIdx + 1;
            final double nextMatchGap = pow(2, nextPhaseIdx).toDouble() * 100 - 100;
            final double nextInitialPadding = pow(2, nextPhaseIdx).toDouble() * 30 - 30;
            final double endY = headerHeight + nextInitialPadding + (targetMatchIdx * (cardHeight + cardVerticalMargin + nextMatchGap)) + (isUpperBranch ? cardHeight * 0.35 : cardHeight * 0.65);

            final path = Path();
            path.moveTo(xStart, startY);
            
            // Standard elbow logic
            path.lineTo(xMid - 12, startY);
            path.quadraticBezierTo(xMid, startY, xMid, startY + (endY > startY ? 12 : -12));
            path.lineTo(xMid, endY - (endY > startY ? 12 : -12));
            path.quadraticBezierTo(xMid, endY, xMid + 12, endY);
            path.lineTo(xEnd, endY);

            canvas.drawPath(path, glowPaint);
            canvas.drawPath(path, paint);
        }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

extension on _BracketScreenState {
  Widget _buildGuestBracket(BuildContext context, WidgetRef ref) {
    final cloudId = widget.tournamentId.toString();
    final cloudDetail = ref.watch(cloudTournamentDetailProvider(cloudId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eliminatoria (Ospite)'),
        backgroundColor: Colors.blueGrey.withValues(alpha: 0.1),
      ),
      body: cloudDetail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Errore: $err')),
        data: (data) {
          if (data == null) return const Center(child: Text('Torneo non trovato'));
          final tournamentData = data['data'] as Map<String, dynamic>?;
          if (tournamentData == null) return const Center(child: Text('Dati non disponibili'));

          final List<dynamic> rawMatches = tournamentData['matches'] as List? ?? [];
          final bracket = <String, List<BracketMatch>>{};
          
          for (final m in rawMatches) {
            final phase = m['phase'] as String;
            if (phase == 'group') continue;

            bracket.putIfAbsent(phase, () => []).add(BracketMatch(
              matchId: m['id'] as int?,
              phase: phase,
              homeTeam: m['homeTeamName'] as String?,
              awayTeam: m['awayTeamName'] as String?,
              homeScore: m['homeScore'] as int?,
              awayScore: m['awayScore'] as int?,
              isCompleted: m['isCompleted'] as bool? ?? false,
              position: m['round'] as int? ?? 1,
            ));
          }

          if (bracket.isEmpty) {
             return Center(child: Text('Nessun tabellone generato', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey)));
          }

          return _buildBracketView(context, bracket);
        },
      ),
    );
  }
}
