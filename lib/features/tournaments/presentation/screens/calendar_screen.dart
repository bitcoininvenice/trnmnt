import '../../../sharing/providers/live_sync_providers.dart';
import 'dart:ui';
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
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import '../widgets/live_match_widgets.dart';

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

    final l10n = AppLocalizations.of(context)!;

    if (_isProcessing) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.calendar)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Determine data source
    if (_isGuest) {
      return _buildGuestCalendar(context, ref, l10n);
    }

    final localId = _localId!;
    final matchesAsync = ref.watch(groupMatchesProvider(localId));
    final tournament = ref.watch(tournamentByIdProvider(localId)).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isSelectionMode ? l10n.matchesSelected(_selectedMatchIds.length) : l10n.calendar),
        leading: _isSelectionMode 
          ? IconButton(icon: const Icon(Icons.close), onPressed: _resetSelection)
          : null,
        actions: [
          if (!_isSelectionMode && tournament != null && tournament.isActive) ...[
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: l10n.addMatch,
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
            if(tournament != null && !tournament.isReadOnly)
              IconButton(
                icon: const Icon(Icons.shuffle),
                tooltip: l10n.generateAutomatic,
                onPressed: () async {
                  if (_isProcessing) return;
                  final doubleRound = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.generateCalendar),
                      content: Text(l10n.generateCalendarPrompt),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.onlyOneWay)),
                        ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.roundTrip)),
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
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
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
          if (tournament != null && !tournament.isReadOnly && tournament.isActive)
            IconButton(
              icon: Icon(_isSelectionMode ? Icons.delete : Icons.delete_outline, color: _isSelectionMode ? Colors.redAccent : null),
              tooltip: _isSelectionMode ? l10n.deleteSelected : l10n.deleteCalendar,
              onPressed: () async {
                if (_isProcessing) return;
                
                final isBulk = !_isSelectionMode;
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(isBulk ? l10n.deleteCalendar : l10n.deleteMatches),
                    content: Text(isBulk 
                      ? l10n.deleteAllMatchesConfirm
                      : l10n.deleteSelectedMatchesConfirm(_selectedMatchIds.length)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l10n.cancel),
                      ),
                      ElevatedButton(
                        style: isBulk ? null : ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(isBulk ? l10n.deleteAll : l10n.delete),
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
          
          if (tournament != null && !tournament.isReadOnly && !_isSelectionMode && tournament.isActive)
            if (!((tournament.groupCount ?? 1) > 1 && tournament.mode != 'league_madness'))
              if (tournament.mode == 'group_only' || tournament.mode == 'madness' || tournament.mode == 'league_madness')
                IconButton(
                  icon: const Icon(FontAwesomeIcons.trophy, color: Colors.orange, size: 20),
                  tooltip: l10n.finalizeTournamentTitle,
                  onPressed: () => _finalizeTournament(context, ref, tournament, l10n),
                ),
        ],
      ),
      body: matchesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('${l10n.error}: $error')),
        data: (matches) {
          if (matches.isEmpty) {
            return _buildEmptyState(context, ref, tournament, l10n);
          }

          // Group by round
          final matchesByRound = <int, List<MatchWithTeams>>{};
          for (final match in matches) {
            final round = match.match.round;
            matchesByRound.putIfAbsent(round, () => []).add(match);
          }

          // Create flattened list for reordering
          final List<dynamic> items = [];
          final sortedRounds = matchesByRound.keys.toList()..sort();
          for (final round in sortedRounds) {
            items.add(round); // Header
            items.addAll(matchesByRound[round]!); // Matches
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, _) {
                  final double animValue = Curves.easeInOut.transform(animation.value);
                  final double scale = lerpDouble(1, 1.05, animValue)!;
                  final double elevation = lerpDouble(0, 8, animValue)!;
                  return Transform.scale(
                    scale: scale,
                    child: Card(
                      elevation: elevation,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: child,
                    ),
                  );
                },
              );
            },
            buildDefaultDragHandles: false,
            itemCount: items.length,
            onReorder: (oldIndex, newIndex) async {
              if (newIndex > oldIndex) newIndex--;
              
              final localItems = List.from(items);
              final movedItem = localItems.removeAt(oldIndex);
              localItems.insert(newIndex, movedItem);

              if (movedItem is int) return; // Prevent moving headers for now to avoid complexity

              final repo = ref.read(matchesRepositoryProvider);
              final baseDate = DateTime(2026, 1, 1); // Arbitrary base date for sequencing

              // Update all matches to reflect new order and rounds
              int currentRound = 1;
              for (int i = 0; i < localItems.length; i++) {
                final item = localItems[i];
                if (item is int) {
                  currentRound = item;
                } else if (item is MatchWithTeams) {
                  final matchId = item.match.id;
                  // Only update if something actually changed to be efficient, 
                  // but for sequence we usually update all to be safe.
                  // We use index i to ensure absolute order within the database query.
                  await repo.updateMatchRound(matchId, currentRound);
                  await repo.updateMatchSchedule(matchId, baseDate.add(Duration(minutes: i)));
                }
              }
              
              // If tournament is published, sync
              if (tournament?.isPublished == true) {
                ref.read(shareRepositoryProvider).publishToSupabase(_localId!).catchError((_) => null);
              }

              // Refresh list
              ref.refresh(groupMatchesProvider(_localId!));
            },
            itemBuilder: (context, index) {
              final item = items[index];
              if (item is int) {
                return Padding(
                  key: ValueKey('round_$item'),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Giornata $item',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              
              final MatchWithTeams m = item;
              return Container(
                key: ValueKey('match_${m.match.id}'),
                child: _buildMatchCard(context, m, index, l10n, tournament),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildGuestCalendar(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final cloudId = widget.tournamentId.toString();
    final cloudDetail = ref.watch(cloudTournamentDetailProvider(cloudId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.guestCalendar),
        backgroundColor: Colors.blueGrey.withValues(alpha: 0.1),
      ),
      body: cloudDetail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('${l10n.error}: $err')),
        data: (rawData) {
          if (rawData == null) return Center(child: Text(l10n.tournamentNotFound));
          
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

          if (matches.isEmpty) return _buildEmptyState(context, ref, null, l10n);

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
     final cloudId = widget.tournamentId.toString();

     return LiveMatchCard(
       homeName: homeName,
       awayName: awayName,
       match: match,
       cloudId: cloudId,
       isCompleted: match.isCompleted,
     );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, dynamic tournament, AppLocalizations l10n) {
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
            l10n.noMatchesFound,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.generateCalendarToStart,
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
                  label: Text(l10n.addAction),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final doubleRound = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.generateCalendar),
                        content: Text(l10n.generateCalendarPrompt),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.onlyOneWay)),
                          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.roundTrip)),
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
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
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
                  label: Text(l10n.generateAutomatic),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, MatchWithTeams matchWithTeams, int index, AppLocalizations l10n, Tournament? tournament) {
    final match = matchWithTeams.match;
    final homeTeam = matchWithTeams.homeTeam;
    final awayTeam = matchWithTeams.awayTeam;
    // Removed ref.watch here to avoid defunct element errors

    final isBye = match.isBye;
    final isCompleted = match.isCompleted;
    final isSelected = _selectedMatchIds.contains(match.id);

    final card = Card(
      margin: const EdgeInsets.only(bottom: 4),
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
          : (isBye ? null : () async {
              // Lock check
              final cloudId = tournament?.cloudId;
              final isLocked = ref.read(isMatchLockedProvider((
                cloudId: cloudId, 
                match: match,
                homeName: homeTeam?.name,
                awayName: awayTeam?.name,
              )));
              
              if (isLocked) {
                final l10n = AppLocalizations.of(context)!;
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Row(
                      children: [
                        const Icon(Icons.lock, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(l10n.matchInProgress),
                      ],
                    ),
                    content: Text(l10n.matchManagedByOther),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.ok),
                      ),
                    ],
                  ),
                );
                return;
              }

              context.pushNamed('match-detail', pathParameters: {
                'tournamentId': widget.tournamentId.toString(),
                'matchId': match.id.toString(),
              });
            }),
        onLongPress: () => _toggleSelection(match.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              if (_isSelectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.orange : Colors.grey,
                  ),
                )
              else
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.drag_indicator, color: Colors.grey, size: 20),
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
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                        : LiveMatchBadge(
                            match: match, 
                            cloudId: tournament?.cloudId,
                            homeName: homeTeam?.name,
                            awayName: awayTeam?.name,
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
      direction: (tournament?.isReadOnly == true) ? DismissDirection.none : DismissDirection.endToStart,
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
            title: Text(l10n.deleteMatch),
            content: Text(l10n.deleteMatchConfirm),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.delete),
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
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
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

  void _finalizeTournament(BuildContext context, WidgetRef ref, Tournament tournament, AppLocalizations l10n) async {
    // 1. Fetch current standings to find the winner
    final standings = await ref.read(standingsProvider(_localId!).future);
    
    if (standings.isEmpty || standings.values.every((list) => list.isEmpty)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noStandingsToFinalize)),
        );
      }
      return;
    }

    final winner = standings.values.expand((list) => list).firstOrNull;
    if (winner == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noWinnerFound)),
        );
      }
      return;
    }

    if (!mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.finalizeTournamentTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.finalizeTournamentConfirm),
            const SizedBox(height: 12),
            Text(l10n.currentWinnerLabel, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange, letterSpacing: 1)),
            Text(winner.teamName.toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(l10n.readOnlyWarning, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel.toUpperCase()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.black),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirmAndFinalize),
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
    final l10n = AppLocalizations.of(context)!;
    final teamsAsync = ref.watch(tournamentTeamsProvider(widget.tournamentId));

    return AlertDialog(
      title: Text(l10n.addMatch),
      content: teamsAsync.when(
        loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
        error: (err, stack) => Text('${l10n.error}: $err'),
        data: (teamsWithTournamentTeams) {
          final teams = teamsWithTournamentTeams.map((tt) => tt.team).toList();
          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: '1',
                  decoration: InputDecoration(labelText: l10n.matchRoundLabel),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || int.tryParse(value) == null) {
                      return l10n.enterValidNumber;
                    }
                    return null;
                  },
                  onSaved: (value) => _selectedRound = int.parse(value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(labelText: l10n.homeTeam),
                  value: _homeTeamId,
                  items: teams.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                  onChanged: (val) => setState(() => _homeTeamId = val),
                  validator: (value) => value == null ? l10n.selectATeam : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(labelText: l10n.awayTeam),
                  value: _awayTeamId,
                  items: teams.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                  onChanged: (val) => setState(() => _awayTeamId = val),
                  validator: (value) {
                    if (value == null) return l10n.selectATeam;
                    if (value == _homeTeamId) return l10n.differentTeamsRequired;
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
          child: Text(l10n.cancel)
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
                    SnackBar(content: Text('${l10n.error}: $e')),
                  );
                }
              }
            }
          } : null,
          child: _isSaving 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
            : Text(l10n.saveAction),
        ),
      ],
    );
  }
}
