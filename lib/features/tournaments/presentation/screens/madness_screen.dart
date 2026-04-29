import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import 'package:trnmnt/core/providers/database_provider.dart';
import 'package:trnmnt/core/database/app_database.dart';
import '../../data/tournaments_repository.dart';
import '../../data/matches_repository.dart';
import '../../../sharing/data/share_repository.dart';
import 'package:drift/drift.dart' as drift;

class MadnessScreen extends ConsumerStatefulWidget {
  final int tournamentId;
  const MadnessScreen({super.key, required this.tournamentId});

  @override
  ConsumerState<MadnessScreen> createState() => _MadnessScreenState();
}

class _MadnessScreenState extends ConsumerState<MadnessScreen> {
  int? get _localId => int.tryParse(widget.tournamentId.toString());
  bool get _isGuest => _localId == null;

  @override
  Widget build(BuildContext context) {
    if (_isGuest) {
      return _buildGuestMadness(context, ref);
    }

    final teamsAsync = ref.watch(tournamentTeamsProvider(widget.tournamentId));
    final matchesAsync = ref.watch(tournamentMatchesProvider(widget.tournamentId));
    final tournamentAsync = ref.watch(tournamentByIdProvider(widget.tournamentId));

    return teamsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (teams) {
        return matchesAsync.when(
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
          data: (matches) {
            final madnessMatches = matches.where((m) => m.match.phase == 'madness' && m.match.isCompleted).toList();
            final playoffMatches = matches.where((m) => 
               m.match.phase == 'final' || 
               m.match.phase == 'semifinale_spareggio'
            ).toList();
            
            final finalMatch = playoffMatches.where((m) => m.match.phase == 'final' && m.match.isCompleted).firstOrNull;
            dynamic winner = finalMatch != null 
                ? (finalMatch.match.homeScore! > finalMatch.match.awayScore! ? finalMatch.homeTeam : finalMatch.awayTeam)
                : null;
                
            // If no final match, check global winner
            if (winner == null && tournamentAsync.value?.winnerTeamId != null) {
              winner = teams.firstWhereOrNull((t) => t.team.id == tournamentAsync.value!.winnerTeamId)?.team;
            }

            final state = _calculateCurrentState(teams, madnessMatches);
            
            return Scaffold(
              appBar: AppBar(
                title: const Text('Madness Mode'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.timer),
                    onPressed: () => context.push('/timer'),
                  ),
                ],
              ),
              body: ListView(
                children: [
                  // Winner Celebration!
                  if (winner != null) ...[
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.amber.shade400, Colors.orange.shade800],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 20, spreadRadius: 5),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.emoji_events, size: 80, color: Colors.white),
                          const SizedBox(height: 16),
                          const Text(
                            'WINNER',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white70, letterSpacing: 4),
                          ),
                          Text(
                            winner.name.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                        ],
                      ),
                    ).animate().scale(duration: 600.ms, curve: Curves.elasticOut).shimmer(delay: 1.seconds),
                    const Divider(),
                  ],

                  // Playoff Matches (if generated)
                  if (playoffMatches.isNotEmpty) ...[
                    _buildSectionHeader(context, Icons.emoji_events, 'PLAYOFFS', Colors.amber),
                    ...playoffMatches.map((m) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Card(
                        elevation: 4,
                        color: Colors.amber.shade900.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.amber.withOpacity(0.5)),
                        ),
                        child: ListTile(
                          title: Text(
                            m.match.phase == 'final' ? 'GRAND FINAL' : 'PLAYBACK MATCH',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber),
                          ),
                          subtitle: Text(
                            '${m.homeTeam?.name ?? 'TBD'} vs ${m.awayTeam?.name ?? 'TBD'}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          trailing: m.match.isCompleted 
                            ? Text('${m.match.homeScore} - ${m.match.awayScore}', style: const TextStyle(fontWeight: FontWeight.bold))
                            : ElevatedButton(
                                onPressed: () => context.push('/tournaments/${widget.tournamentId}/match/${m.match.id}'),
                                child: const Text('PLAY'),
                              ),
                        ),
                      ).animate().shimmer(),
                    )),
                    const Divider(),
                  ] else ... [
                      // Current Match Card
                    if (state.king != null && state.challenger != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildMatchCard(state.king!, state.challenger!, teams, madnessMatches),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: Text('Need at least 2 teams for Madness!')),
                      ),

                    // Queue section
                    _buildSectionHeader(context, Icons.people_outline, 'Next Challengers', Colors.blue),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: state.queue.length,
                        itemBuilder: (context, index) {
                          final team = state.queue[index];
                          return Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                CircleAvatar(radius: 20, child: Text('${index + 1}')),
                                const SizedBox(height: 4),
                                Text(team.team.name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10)),
                              ],
                            ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)),
                          );
                        },
                      ),
                    ),
                  ],

                  

                  const Divider(),

                  // Live Standings Section
                  _buildSectionHeader(context, Icons.leaderboard, 'Live Standings', Colors.purple),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      child: Column(
                        children: [
                          ..._calculateStandings(teams, madnessMatches).asMap().entries.map((entry) {
                            final i = entry.key;
                            final s = entry.value;
                            return ListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              leading: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                              title: Text(s.team.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('W: ${s.wins} | PF: ${s.points} | PA: ${s.pointsAgainst}'),
                              trailing: Text('${s.points}', style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.w900, fontSize: 16)),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  const Divider(),

                  // Matches history section
                  _buildSectionHeader(context, Icons.history, 'Recent Matches', Colors.orange),
                  ...madnessMatches.reversed.map((m) {
                    final home = m.homeTeam?.name ?? '???';
                    final away = m.awayTeam?.name ?? '???';
                    final hScore = m.match.homeScore ?? 0;
                    final aScore = m.match.awayScore ?? 0;
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Card(
                        child: ListTile(
                          dense: true,
                          leading: const Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
                          title: Text('$home $hScore - $aScore $away', style: const TextStyle(fontWeight: FontWeight.w500)),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, size: 16),
                            onPressed: () => context.push('/tournaments/${widget.tournamentId}/match/${m.match.id}'),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, IconData icon, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  _MadnessLogicState _calculateCurrentState(List<TournamentTeamWithTeam> teams, List<MatchWithTeams> matches) {
    if (teams.length < 2) return _MadnessLogicState(queue: []);
    
    List<TournamentTeamWithTeam> queue = List.from(teams);
    TournamentTeamWithTeam? king = queue.removeAt(0);
    TournamentTeamWithTeam? challenger = queue.removeAt(0);

    for (final m in matches) {
      final h = (m.match.homeScore ?? 0) as int;
      final a = (m.match.awayScore ?? 0) as int;

      if (h > a) {
        // King stays
        queue.add(challenger!);
        if (queue.isNotEmpty) challenger = queue.removeAt(0);
        else challenger = null;
      } else if (a > h) {
        // Challenger becomes king
        queue.add(king!);
        king = challenger;
        if (queue.isNotEmpty) challenger = queue.removeAt(0);
        else challenger = null;
      } else {
        // Draw: both leave
        queue.add(king!);
        queue.add(challenger!);
        if (queue.length >= 2) {
          king = queue.removeAt(0);
          challenger = queue.removeAt(0);
        } else if (queue.length == 1) {
          king = queue.removeAt(0);
          challenger = null;
        }
      }
    }

    return _MadnessLogicState(king: king, challenger: challenger, queue: queue);
  }

  Widget _buildMatchCard(TournamentTeamWithTeam king, TournamentTeamWithTeam challenger, List<TournamentTeamWithTeam> teams, List<MatchWithTeams> matches) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.deepPurple.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const Text(
              'KING OF THE COURT',
              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTeamSlot(king, 'KING', Colors.amber),
                const Text('VS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white54)),
                _buildTeamSlot(challenger, 'CHALLENGER', Colors.white70),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () => _navigateToScoreEntry(king, challenger),
                  child: const Text('ENTER RESULT', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onPressed: () => _showFinalizationDialog(teams, matches),
                  icon: const Icon(Icons.emoji_events, size: 18),
                  label: const Text('FINALIZE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSlot(TournamentTeamWithTeam tt, String role, Color color) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: color.withOpacity(0.2),
            child: Text(
              tt.team.name.substring(0, 1).toUpperCase(),
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            tt.team.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            role,
            style: TextStyle(fontSize: 10, color: color, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToScoreEntry(TournamentTeamWithTeam king, TournamentTeamWithTeam challenger) async {
    final repo = ref.read(matchesRepositoryProvider);
    
    // Check for an existing incomplete madness match first (to avoid duplicates)
    final existingMatches = await ref.read(tournamentMatchesProvider(widget.tournamentId).future);
    final incomplete = existingMatches.where((m) => 
      m.match.phase == 'madness' && 
      !m.match.isCompleted &&
      m.match.homeTeamId == king.team.id &&
      m.match.awayTeamId == challenger.team.id
    ).toList();

    int matchId;
    if (incomplete.isNotEmpty) {
      matchId = incomplete.first.match.id;
    } else {
      matchId = await repo.createMatch(
        tournamentId: widget.tournamentId,
        homeTeamId: king.team.id,
        awayTeamId: challenger.team.id,
        round: existingMatches.where((m) => m.match.phase == 'madness').length + 1,
        phase: 'madness',
      );
    }

    if (mounted) {
      final tournament = await ref.read(tournamentByIdProvider(widget.tournamentId).future);
      if (tournament?.isPublished == true) {
        ref.read(shareRepositoryProvider).publishToSupabase(widget.tournamentId).catchError((_) => null);
      }
      context.push('/tournaments/${widget.tournamentId}/match/$matchId');
    }
  }

  void _showStandings(List<TournamentTeamWithTeam> teams, List<MatchWithTeams> matches) {
     showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('LIVE STANDINGS (Baskets count as points)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Divider(),
             Expanded(
               child: ListView.builder(
                 itemCount: teams.length,
                 itemBuilder: (context, i) {
                   final standings = _calculateStandings(teams, matches);
                   final s = standings[i];
                   return ListTile(
                     leading: CircleAvatar(child: Text('${i+1}')),
                     title: Text(s.team.name),
                     subtitle: Text('Score: ${s.points} PF | W: ${s.wins} | PA: ${s.pointsAgainst}'),
                     trailing: Text('${s.points} pts', style: const TextStyle(fontWeight: FontWeight.bold)),
                   );
                 },
               ),
             ),
          ],
        ),
      ),
    );
  }

  List<MadnessStanding> _calculateStandings(List<TournamentTeamWithTeam> teams, List<MatchWithTeams> matches) {
    final Map<int, MadnessStanding> stats = {};
    for (final t in teams) {
      stats[t.team.id] = MadnessStanding(team: t.team);
    }

    for (final m in matches) {
      final h = (m.match.homeScore ?? 0) as int;
      final a = (m.match.awayScore ?? 0) as int;
      
      final homeStats = stats[m.match.homeTeamId];
      final awayStats = stats[m.match.awayTeamId];

      if (homeStats != null) {
        homeStats.points += h;
        homeStats.pointsAgainst += a;
        if (h > a) homeStats.wins++;
      }
      if (awayStats != null) {
        awayStats.points += a;
        awayStats.pointsAgainst += h;
        if (a > h) awayStats.wins++;
      }
    }

    final list = stats.values.toList();
    list.sort((a, b) {
      if (b.points != a.points) return b.points.compareTo(a.points);
      if (b.wins != a.wins) return b.wins.compareTo(a.wins);
      final diffA = a.points - a.pointsAgainst;
      final diffB = b.points - b.pointsAgainst;
      return diffB.compareTo(diffA);
    });

    return list;
  }

  void _showFinalizationDialog(List<TournamentTeamWithTeam> teams, List<MatchWithTeams> matches) async {
    final standings = _calculateStandings(teams, matches);
    if (standings.length < 2) return;

    MadnessStanding? p1 = standings[1];
    MadnessStanding? p2 = standings.length > 2 ? standings[2] : null;

    bool needsPlaybackMatch = false;
    if (p2 != null && p1.points == p2.points) {
       int tieCount = standings.where((s) => s.points == p1!.points).length;
       if (tieCount == 2) needsPlaybackMatch = true;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalize Season'),
        content: Text(
          needsPlaybackMatch 
            ? 'Playback match needed between ${standings[1].team.name} and ${standings[2].team.name} for the final spot!'
            : 'Final Match will be: ${standings[0].team.name} vs ${standings[1].team.name}'
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _generateFinalMatch(standings[0], standings[1], needsPlaybackMatch ? standings[2] : null);
            }, 
            child: const Text('PROCEED'),
          ),
        ],
      ),
    );
  }

  void _generateFinalMatch(MadnessStanding s1, MadnessStanding s2, MadnessStanding? tieBreak2) async {
    final repo = ref.read(matchesRepositoryProvider);
    
    if (tieBreak2 != null) {
      await repo.createMatch(
        tournamentId: widget.tournamentId,
        homeTeamId: s2.team.id,
        awayTeamId: tieBreak2.team.id,
        phase: 'semifinale_spareggio',
        round: 99,
      );
    } else {
       await repo.createMatch(
        tournamentId: widget.tournamentId,
        homeTeamId: s1.team.id,
        awayTeamId: s2.team.id,
        phase: 'final',
        round: 100,
      );
    }

    if (mounted) {
       final tournament = await ref.read(tournamentByIdProvider(widget.tournamentId).future);
       if (tournament?.isPublished == true) {
         ref.read(shareRepositoryProvider).publishToSupabase(widget.tournamentId).catchError((_) => null);
       }
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Matches generated!')));
       context.pop();
    }
  }

  Widget _buildGuestMadness(BuildContext context, WidgetRef ref) {
    final cloudId = widget.tournamentId.toString();
    final cloudDetail = ref.watch(cloudTournamentDetailProvider(cloudId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Madness Mode (Guest)'),
        backgroundColor: Colors.blueGrey.withValues(alpha: 0.1),
      ),
      body: cloudDetail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Errore: $err')),
        data: (data) {
          if (data == null) return const Center(child: Text('Torneo non trovato'));
          final tournamentData = data['data'] as Map<String, dynamic>?;
          if (tournamentData == null) return const Center(child: Text('Dati non disponibili'));

          // 1. Extract teams and matches
          final teamsList = tournamentData['teams'] as List? ?? [];
          final matchesList = tournamentData['matches'] as List? ?? [];

          // Map teams to local model
          final List<TournamentTeamWithTeam> teams = teamsList.map((t) {
             final team = Team(
               id: t['id'], 
               name: t['name'] ?? 'Team',
               createdAt: DateTime.now(),
             );
             return TournamentTeamWithTeam(
                tournamentTeam: TournamentTeam(
                  tournamentId: 0, 
                  teamId: t['id'], 
                  groupNumber: t['groupNumber'] ?? 1,
                ),
                team: team,
             );
          }).toList();

          // Map matches to local model
          final List<MatchWithTeams> matches = matchesList.map((m) {
             final match = TournamentMatch(
               id: m['id'],
               tournamentId: 0,
               homeTeamId: m['homeTeamId'],
               awayTeamId: m['awayTeamId'],
               homeScore: m['homeScore'],
               awayScore: m['awayScore'],
               isCompleted: m['isCompleted'] ?? false,
               phase: m['phase'] ?? 'group',
               round: m['round'] ?? 1,
               isBye: m['isBye'] ?? false,
               createdAt: DateTime.now(),
             );
             final hTeam = teams.where((t) => t.team.id == m['homeTeamId']).firstOrNull?.team;
             final aTeam = teams.where((t) => t.team.id == m['awayTeamId']).firstOrNull?.team;
             return MatchWithTeams(match: match, homeTeam: hTeam, awayTeam: aTeam);
          }).toList();

          final madnessMatches = matches.where((m) => m.match.phase == 'madness' && m.match.isCompleted).toList();
          final playoffMatches = matches.where((m) => 
             m.match.phase == 'final' || 
             m.match.phase == 'semifinale_spareggio'
          ).toList();
          
          final finalMatch = playoffMatches.where((m) => m.match.phase == 'final' && m.match.isCompleted).firstOrNull;
          dynamic winner = finalMatch != null 
              ? (finalMatch.match.homeScore! > finalMatch.match.awayScore! ? finalMatch.homeTeam : finalMatch.awayTeam)
              : null;
              
          if (winner == null) {
            final tInfo = tournamentData['tournament'] as Map<String, dynamic>?;
            final winnerTeamId = tInfo?['winnerTeamId'];
            if (winnerTeamId != null) {
              winner = teams.firstWhereOrNull((t) => t.team.id == winnerTeamId)?.team;
            }
          }

          final state = _calculateCurrentState(teams, madnessMatches);
          
          return ListView(
            children: [
              if (winner != null) ...[
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber.shade400, Colors.orange.shade800],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.emoji_events, size: 80, color: Colors.white),
                      const SizedBox(height: 16),
                      Text(winner.name.toUpperCase(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
                    ],
                  ),
                ).animate().scale().shimmer(),
                const Divider(),
              ],

              if (playoffMatches.isNotEmpty) ...[
                _buildSectionHeader(context, Icons.emoji_events, 'PLAYOFFS', Colors.amber),
                ...playoffMatches.map((m) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Card(
                    color: Colors.amber.shade900.withOpacity(0.1),
                    child: ListTile(
                      title: Text('${m.homeTeam?.name ?? 'TBD'} vs ${m.awayTeam?.name ?? 'TBD'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text('${m.match.homeScore ?? 0} - ${m.match.awayScore ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                )),
                const Divider(),
              ] else ... [
                if (state.king != null && state.challenger != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildGuestMatchCard(state.king!, state.challenger!),
                  ),
                
                _buildSectionHeader(context, Icons.people_outline, 'Next Challengers', Colors.blue),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: state.queue.length,
                    itemBuilder: (context, index) {
                      final team = state.queue[index];
                      return Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 12),
                        child: Column(
                          children: [
                            CircleAvatar(radius: 20, child: Text('${index + 1}')),
                            const SizedBox(height: 4),
                            Text(team.team.name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],

              const Divider(),
              _buildSectionHeader(context, Icons.leaderboard, 'Live Standings', Colors.purple),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Column(
                    children: [
                      ..._calculateStandings(teams, madnessMatches).asMap().entries.map((entry) {
                        final i = entry.key;
                        final s = entry.value;
                        return ListTile(
                          dense: true,
                          leading: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          title: Text(s.team.name),
                          trailing: Text('${s.points}', style: const TextStyle(fontWeight: FontWeight.w900)),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const Divider(),
              _buildSectionHeader(context, Icons.history, 'Recent Matches', Colors.orange),
              ...madnessMatches.reversed.map((m) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Card(
                    child: ListTile(
                      dense: true,
                      title: Text('${m.homeTeam?.name} ${m.match.homeScore} - ${m.match.awayScore} ${m.awayTeam?.name}'),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGuestMatchCard(TournamentTeamWithTeam king, TournamentTeamWithTeam challenger) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [Colors.blue.shade800, Colors.deepPurple.shade800],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTeamSlot(king, 'KING', Colors.amber),
            const Text('VS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white54)),
            _buildTeamSlot(challenger, 'CHALLENGER', Colors.white70),
          ],
        ),
      ),
    );
  }
}

class _MadnessLogicState {
  final TournamentTeamWithTeam? king;
  final TournamentTeamWithTeam? challenger;
  final List<TournamentTeamWithTeam> queue;

  _MadnessLogicState({this.king, this.challenger, required this.queue});
}

class MadnessStanding {
  final Team team;
  int points = 0;
  int wins = 0;
  int pointsAgainst = 0;

  MadnessStanding({required this.team});
}
