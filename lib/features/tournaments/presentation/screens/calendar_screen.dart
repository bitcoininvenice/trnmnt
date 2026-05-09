import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/matches_repository.dart';
import '../../data/tournaments_repository.dart';
import '../../../stats/data/stats_repository.dart';
import '../screens/standings_screen.dart'; // Add this for standingsProvider
import '../../../../core/database/app_database.dart';
import '../../../sharing/data/share_repository.dart';
import '../../../game/providers/game_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'bracket_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  final dynamic tournamentId;

  const CalendarScreen({super.key, required this.tournamentId});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  bool _isProcessing = false;
  final Set<int> _selectedMatchIds = {};
  bool _isSelectionMode = false;

  void _toggleSelection(int matchId) {
    if (_isGuest) return; // Disable selection in guest mode
    setState(() {
      if (_selectedMatchIds.contains(matchId)) {
        _selectedMatchIds.remove(matchId);
        if (_selectedMatchIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedMatchIds.add(matchId);
        _isSelectionMode = true;
      }
    });
  }

  void _resetSelection() {
    setState(() {
      _selectedMatchIds.clear();
      _isSelectionMode = false;
    });
  }

  int? get _localId => int.tryParse(widget.tournamentId.toString());
  bool get _isGuest => _localId == null;

  @override
  Widget build(BuildContext context) {
    // If we are already disposed, stop building
    if (!mounted) return const SizedBox.shrink();

    if (_isProcessing) {
      return Scaffold(
        appBar: AppBar(title: const Text('Calendario')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Determine data source
    if (_isGuest) {
      return _buildGuestCalendar(context, ref);
    }

    final localId = _localId!;
    final tournamentsAsync = ref.watch(tournamentsProvider);
    final matchesAsync = ref.watch(groupMatchesProvider(localId));
    
    // Safety check for tournament data
    final tournament = tournamentsAsync.value?.firstWhere(
      (t) => t.id == localId,
      orElse: () => null as dynamic,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_isSelectionMode ? '${_selectedMatchIds.length} selezionate' : 'Calendario'),
        leading: _isSelectionMode 
          ? IconButton(icon: const Icon(Icons.close), onPressed: _resetSelection)
          : null,
        actions: [
          if (!_isSelectionMode && tournament != null && tournament.isActive) ...[
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Aggiungi partita',
              onPressed: () async {
                if (_isProcessing) return;
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => AddMatchDialog(tournamentId: _localId!),
                );
                if (result == true && mounted) {
                  ref.invalidate(groupMatchesProvider(_localId!));
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.shuffle),
              tooltip: 'Genera automatico',
              onPressed: () async {
                if (_isProcessing) return;
                final doubleRound = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Genera Calendario'),
                    content: const Text('Vuoi generare solo l\'andata o anche il ritorno?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Solo Andata')),
                      ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Andata e Ritorno')),
                    ],
                  ),
                );
                
                if (doubleRound == null) return;

                setState(() => _isProcessing = true);
                try {
                  await ref.read(matchesRepositoryProvider).generateGroupCalendar(_localId!, doubleRound: doubleRound);
                  if (tournament?.isPublished == true) {
                    await ref.read(shareRepositoryProvider).publishToSupabase(_localId!);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore: $e')));
                  }
                } finally {
                  if (mounted) {
                    setState(() => _isProcessing = false);
                    ref.invalidate(groupMatchesProvider(_localId!));
                  }
                }
              },
            ),
          ],
          if (tournament != null && tournament.isActive)
            IconButton(
              icon: Icon(_isSelectionMode ? Icons.delete : Icons.delete_outline, color: _isSelectionMode ? Colors.redAccent : null),
              tooltip: _isSelectionMode ? 'Elimina selezionate' : 'Elimina calendario',
              onPressed: () async {
                if (_isProcessing) return;
                
                final isBulk = !_isSelectionMode;
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(isBulk ? 'Elimina calendario' : 'Elimina partite'),
                    content: Text(isBulk 
                      ? 'Questo cancellerà TUTTO il calendario esistente. Continuare?'
                      : 'Vuoi eliminare le ${_selectedMatchIds.length} partite selezionate?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annulla'),
                      ),
                      ElevatedButton(
                        style: isBulk ? null : ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(isBulk ? 'Elimina tutto' : 'Elimina'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && mounted) {
                  setState(() => _isProcessing = true);
                  try {
                    if (isBulk) {
                      await ref.read(matchesRepositoryProvider).deleteMatchesByPhase(_localId!, 'group');
                    } else {
                      await ref.read(matchesRepositoryProvider).deleteMatches(_selectedMatchIds.toList());
                      _resetSelection();
                    }
                    
                    if (!mounted) return;
                    if (tournament?.isPublished == true) {
                      await ref.read(shareRepositoryProvider).publishToSupabase(_localId!);
                    }
                  } catch (e) {
                  } finally {
                    if (mounted) {
                      setState(() => _isProcessing = false);
                      ref.invalidate(groupMatchesProvider(_localId!));
                    }
                  }
                }
              },
            ),
          
          if (!_isSelectionMode && tournament != null && tournament.isActive)
            if (!((tournament.groupCount ?? 1) > 1 && tournament.mode != 'league_madness'))
              if (tournament.mode == 'group_only' || tournament.mode == 'madness' || tournament.mode == 'league_madness')
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
            return _buildEmptyState(context, ref, tournament);
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
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildGuestCalendar(BuildContext context, WidgetRef ref) {
    final cloudId = widget.tournamentId.toString();
    final cloudDetail = ref.watch(cloudTournamentDetailProvider(cloudId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario (Ospite)'),
        backgroundColor: Colors.blueGrey.withValues(alpha: 0.1),
      ),
      body: cloudDetail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Errore: $err')),
        data: (rawData) {
          if (rawData == null) return const Center(child: Text('Torneo non trovato'));
          
          // Logica resiliente per estrarre i dati (coerente con CloudTournamentDetailScreen)
          final Map<String, dynamic> data = (rawData['data'] is Map 
              ? Map<String, dynamic>.from(rawData['data'] as Map) 
              : Map<String, dynamic>.from(rawData));
          
          final matches = (data['matches'] as List? ?? []).map((m) {
            final match = TournamentMatch.fromJson(m);
            return (
              match: match, 
              homeName: m['homeTeamName'] as String? ?? 'Home',
              awayName: m['awayTeamName'] as String? ?? 'Away',
            );
          }).toList();

          if (matches.isEmpty) return _buildEmptyState(context, ref, null);

          // Group by round
          final matchesByRound = <int, List<dynamic>>{};
          for (final m in matches) {
            final round = m.match.round;
            matchesByRound.putIfAbsent(round, () => []).add(m);
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
                  ...roundMatches.map((m) => _buildGuestMatchCard(context, m)),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildGuestMatchCard(BuildContext context, dynamic m) {
     final match = m.match as TournamentMatch;
     final homeName = m.homeName as String;
     final awayName = m.awayName as String;

     return Card(
       margin: const EdgeInsets.only(bottom: 8),
       child: ListTile(
         onTap: null, // Disabilitato in modalità ospite
         title: Row(
           children: [
             Expanded(child: Text(homeName, textAlign: TextAlign.right, style: const TextStyle(fontSize: 14))),
             Container(
               margin: const EdgeInsets.symmetric(horizontal: 16),
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
               decoration: BoxDecoration(
                 color: match.isCompleted ? Colors.blue.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
                 borderRadius: BorderRadius.circular(4),
               ),
               child: Text(
                 match.isCompleted ? '${match.homeScore} - ${match.awayScore}' : 'vs',
                 style: const TextStyle(fontWeight: FontWeight.bold),
               ),
             ),
             Expanded(child: Text(awayName, textAlign: TextAlign.left, style: const TextStyle(fontSize: 14))),
           ],
         ),
       ),
     );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, dynamic tournament) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 100,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 32),
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
          if (!_isGuest && _localId != null && (tournament?.isActive ?? false))
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (context) => AddMatchDialog(tournamentId: _localId!),
                    );
                    if (result == true) {
                      if (!mounted) return;
                      // ignore: unused_result
                      ref.refresh(groupMatchesProvider(_localId!));
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Aggiungi'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final doubleRound = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Genera Calendario'),
                        content: const Text('Vuoi generare solo l\'andata o anche il ritorno?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Solo Andata')),
                          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Andata e Ritorno')),
                        ],
                      ),
                    );
                    
                    if (doubleRound == null) return;

                    setState(() => _isProcessing = true);
                    try {
                      await ref.read(matchesRepositoryProvider).generateGroupCalendar(_localId!, doubleRound: doubleRound);
                      if (tournament?.isPublished == true) {
                        await ref.read(shareRepositoryProvider).publishToSupabase(_localId!);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore: $e')));
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isProcessing = false);
                        // ignore: unused_result
                        ref.refresh(groupMatchesProvider(_localId!));
                      }
                    }
                  },
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Genera automatico'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, MatchWithTeams matchWithTeams, int index) {
    final match = matchWithTeams.match;
    final homeTeam = matchWithTeams.homeTeam;
    final awayTeam = matchWithTeams.awayTeam;
    // Removed ref.watch here to avoid defunct element errors

    final isBye = match.isBye;
    final isCompleted = match.isCompleted;
    final isSelected = _selectedMatchIds.contains(match.id);

    final card = Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected 
          ? Colors.orange.withValues(alpha: 0.1) 
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.orange : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: _isSelectionMode 
          ? () => _toggleSelection(match.id)
          : (isBye ? null : () => context.pushNamed('match-detail', pathParameters: {
              'tournamentId': widget.tournamentId.toString(),
              'matchId': match.id.toString(),
            })),
        onLongPress: () => _toggleSelection(match.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (_isSelectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.orange : Colors.grey,
                  ),
                ),
                
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
                child: isBye 
                    ? const Text(
                        'BYE',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
                      )
                    : isCompleted
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${match.homeScore}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: (match.homeScore ?? 0) > (match.awayScore ?? 0)
                                      ? Colors.greenAccent
                                      : (match.homeScore ?? 0) < (match.awayScore ?? 0)
                                          ? Colors.redAccent
                                          : Colors.blueAccent,
                                ),
                              ),
                              Text(
                                ' - ',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${match.awayScore}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: (match.awayScore ?? 0) > (match.homeScore ?? 0)
                                      ? Colors.greenAccent
                                      : (match.awayScore ?? 0) < (match.homeScore ?? 0)
                                          ? Colors.redAccent
                                          : Colors.blueAccent,
                                ),
                              ),
                            ],
                          )
                        : _LiveMatchBadge(matchId: match.id),
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
              
              if (!isBye && !_isSelectionMode)
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
    );

    if (_isSelectionMode) return card.animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideX(begin: 0.1);

    return Dismissible(
      key: ValueKey('match_${match.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Elimina partita'),
            content: const Text('Vuoi eliminare questa partita dal calendario?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annulla')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Elimina'),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (direction) async {
        setState(() => _isProcessing = true);
        try {
          await ref.read(matchesRepositoryProvider).deleteMatches([match.id]);
          final tournament = await ref.read(tournamentByIdProvider(_localId!).future);
          if (tournament?.isPublished == true) {
            await ref.read(shareRepositoryProvider).publishToSupabase(_localId!);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore: $e')));
          }
        } finally {
          if (mounted) {
            setState(() => _isProcessing = false);
          }
        }
      },
      child: card,
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideX(begin: 0.1);
  }

  void _finalizeTournament(BuildContext context, WidgetRef ref, Tournament tournament) async {
    // 1. Fetch current standings to find the winner
    final standings = await ref.read(standingsProvider(_localId!).future);
    
    if (standings.isEmpty || standings.values.every((list) => list.isEmpty)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nessuna squadra in classifica. Impossibile finalizzare.')),
        );
      }
      return;
    }

    final winner = standings.values.first.first;

    if (!mounted) return;

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
      if (!mounted) return;
      setState(() => _isProcessing = true);
      await ref.read(tournamentsRepositoryProvider).finalizeTournament(_localId!, winner.teamId);
      if (!mounted) return;
      
      // Auto-sync after finalization if published
      if (tournament.isPublished) {
         await ref.read(shareRepositoryProvider).publishToSupabase(_localId!);
      }
      if (!mounted) return;

      if (mounted) {
        setState(() => _isProcessing = false);
        context.go('/tournaments/${widget.tournamentId}'); // Back to detail (read-only)
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
  bool _isSaving = false;
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
          onPressed: _isSaving ? null : () => Navigator.pop(context), 
          child: const Text('Annulla')
        ),
        ElevatedButton(
          onPressed: (teamsAsync.hasValue && !_isSaving) ? () async {
            if (_formKey.currentState?.validate() ?? false) {
              _formKey.currentState!.save();
              setState(() => _isSaving = true);
              
              try {
                await ref.read(matchesRepositoryProvider).createMatch(
                  tournamentId: widget.tournamentId,
                  homeTeamId: _homeTeamId,
                  awayTeamId: _awayTeamId,
                  round: _selectedRound,
                  phase: 'group',
                );
                
                if (mounted) {
                  final tournament = await ref.read(tournamentByIdProvider(widget.tournamentId).future);
                  if (tournament?.isPublished == true) {
                    ref.read(shareRepositoryProvider).publishToSupabase(widget.tournamentId).catchError((_) => null);
                  }
                  Navigator.pop(context, true);
                }
              } catch (e) {
                if (mounted) {
                  setState(() => _isSaving = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Errore: $e')),
                  );
                }
              }
            }
          } : null,
          child: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Salva'),
        ),
      ],
    );
  }
}

class _LiveMatchBadge extends ConsumerWidget {
  final int matchId;
  const _LiveMatchBadge({required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeGame = ref.watch(activeGameProvider);
    final isLive = activeGame.matchId == matchId;

    if (!isLive) {
      return const Text(
        'vs',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('LIVE', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.2)),
        Text(
          activeGame.formattedTime,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'monospace'),
        ),
      ],
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds);
  }
}