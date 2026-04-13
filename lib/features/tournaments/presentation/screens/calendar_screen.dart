import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/matches_repository.dart';
import '../../data/tournaments_repository.dart';
import '../../../stats/data/stats_repository.dart';
import '../screens/standings_screen.dart'; // Add this for standingsProvider
import '../../../../core/database/app_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'bracket_screen.dart';

class CalendarScreen extends ConsumerWidget {
  final int tournamentId;

  const CalendarScreen({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(groupMatchesProvider(tournamentId));
    final tournamentsAsync = ref.watch(tournamentsProvider);
    final tournament = tournamentsAsync.value?.firstWhere((t) => t.id == tournamentId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Aggiungi partita',
            onPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => AddMatchDialog(tournamentId: tournamentId),
              );
              if (result == true) {
                // ignore: unused_result
                ref.refresh(groupMatchesProvider(tournamentId));
              }
            },
          ),
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
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Elimina e ricrea',
            onPressed: () => deleteBracket(context, ref, tournamentId),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Elimina calendario',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Elimina calendario'),
                  content: const Text('Questo cancellerà il calendario esistente. Continuare?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annulla'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Elimina'),
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
          
          if (tournament != null && tournament.isActive && (tournament.mode == 'group_only' || tournament.mode == 'madness'))
            IconButton(
              icon: const Icon(FontAwesomeIcons.trophy, color: Colors.orange, size: 20),
              tooltip: 'Finalizza torneo',
              onPressed: () => _finalizeTournament(context, ref, tournament),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) => AddMatchDialog(tournamentId: tournamentId),
                  );
                  if (result == true) {
                    // ignore: unused_result
                    ref.refresh(groupMatchesProvider(tournamentId));
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Aggiungi'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(matchesRepositoryProvider).generateGroupCalendar(tournamentId);
                  // ignore: unused_result
                  ref.refresh(groupMatchesProvider(tournamentId));
                },
                icon: const Icon(Icons.shuffle),
                label: const Text('Genera automatico'),
              ),
            ],
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

  void _finalizeTournament(BuildContext context, WidgetRef ref, Tournament tournament) async {
    // 1. Fetch current standings to find the winner
    final standings = await ref.read(standingsProvider(tournamentId).future);
    
    if (standings.isEmpty || standings.values.every((list) => list.isEmpty)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nessuna squadra in classifica. Impossibile finalizzare.')),
        );
      }
      return;
    }

    final winner = standings.values.first.first;

    if (!context.mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizza Torneo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sei sicuro di voler chiudere il torneo?'),
            const SizedBox(height: 12),
            const Text('VINCITORE ATTUALE:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange, letterSpacing: 1)),
            Text(winner.teamName.toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('Il torneo diventerà di sola lettura.', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ANNULLA'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.black),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CONFERMA E FINALIZZA'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(tournamentsRepositoryProvider).finalizeTournament(tournamentId, winner.teamId);
      if (context.mounted) {
        context.go('/tournaments/$tournamentId'); // Back to detail (read-only)
      }
    }
  }
}

class AddMatchDialog extends ConsumerStatefulWidget {
  final int tournamentId;
  const AddMatchDialog({super.key, required this.tournamentId});

  @override
  ConsumerState<AddMatchDialog> createState() => _AddMatchDialogState();
}

class _AddMatchDialogState extends ConsumerState<AddMatchDialog> {
  final _formKey = GlobalKey<FormState>();
  int _selectedRound = 1;
  int? _homeTeamId;
  int? _awayTeamId;

  @override
  Widget build(BuildContext context) {
    final teamsAsync = ref.watch(tournamentTeamsProvider(widget.tournamentId));

    return AlertDialog(
      title: const Text('Aggiungi Partita'),
      content: teamsAsync.when(
        loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
        error: (err, stack) => Text('Errore: $err'),
        data: (teamsWithTournamentTeams) {
          final teams = teamsWithTournamentTeams.map((tt) => tt.team).toList();
          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: '1',
                  decoration: const InputDecoration(labelText: 'Giornata (Round)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || int.tryParse(value) == null) {
                      return 'Inserisci un numero valido';
                    }
                    return null;
                  },
                  onSaved: (value) => _selectedRound = int.parse(value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Squadra di casa'),
                  value: _homeTeamId,
                  items: teams.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                  onChanged: (val) => setState(() => _homeTeamId = val),
                  validator: (value) => value == null ? 'Seleziona una squadra' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Squadra in trasferta'),
                  value: _awayTeamId,
                  items: teams.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                  onChanged: (val) => setState(() => _awayTeamId = val),
                  validator: (value) {
                    if (value == null) return 'Seleziona una squadra';
                    if (value == _homeTeamId) return 'Le due squadre devono essere diverse';
                    return null;
                  },
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text('Annulla')
        ),
        ElevatedButton(
          onPressed: teamsAsync.hasValue ? () async {
            if (_formKey.currentState?.validate() ?? false) {
              _formKey.currentState!.save();
              await ref.read(matchesRepositoryProvider).createMatch(
                tournamentId: widget.tournamentId,
                homeTeamId: _homeTeamId,
                awayTeamId: _awayTeamId,
                round: _selectedRound,
                phase: 'group',
              );
              ref.invalidate(tournamentMatchesProvider(widget.tournamentId));
              if (!context.mounted) return;
              Navigator.pop(context, true);
            }
          } : null,
          child: const Text('Salva'),
        ),
      ],
    );
  }
}

