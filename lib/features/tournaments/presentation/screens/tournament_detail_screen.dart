import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart' as drift;
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/tournaments_repository.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
class TournamentDetailScreen extends ConsumerStatefulWidget {
  final int tournamentId;
  const TournamentDetailScreen({super.key, required this.tournamentId});

  @override
  ConsumerState<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends ConsumerState<TournamentDetailScreen> {
  bool _isSyncing = false;
  String? _syncError;
  DateTime? _lastSync;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() async {
    // Wait for the first frame to check it's read-only
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final tournament = await ref.read(tournamentByIdProvider(widget.tournamentId).future);
    if (tournament != null && tournament.isReadOnly && tournament.sourceIp != null) {
      // Poll every 30 seconds
      _syncFromSource(tournament);
      Future.doWhile(() async {
        await Future.delayed(const Duration(seconds: 30));
        if (!mounted) return false;
        final latest = await ref.read(tournamentByIdProvider(widget.tournamentId).future);
        if (latest != null && latest.isReadOnly && latest.sourceIp != null) {
          await _syncFromSource(latest);
          return true;
        }
        return false;
      });
    }
  }

  Future<void> _syncFromSource(dynamic tournament) async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    
    try {
      final response = await http.get(
        Uri.parse('http://${tournament.sourceIp}:${tournament.sourcePort}/tournament/${tournament.remoteId}')
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        await _updateTournamentFromBundle(widget.tournamentId, data);
        setState(() {
          _lastSync = DateTime.now();
          _syncError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _syncError = 'Sync failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  Future<void> _updateTournamentFromBundle(int localId, Map<String, dynamic> data) async {
    final db = ref.read(dbProvider);
    final matchesData = data['matches'] as List<dynamic>;
    final teamsData = data['teams'] as List<dynamic>;

    // 1. Get local team mapping
    final tournamentTeams = await (db.select(db.tournamentTeams)
      ..where((tt) => tt.tournamentId.equals(localId))).get();
    final teamIds = tournamentTeams.map((tt) => tt.teamId).toList();
    
    final localTeams = await (db.select(db.teams)
      ..where((t) => t.id.isIn(teamIds))).get();

    final Map<int, int> teamMapping = {};
    for (final remoteTeam in teamsData) {
      final localTeam = localTeams.firstWhere((lt) => lt.name == remoteTeam['name'], orElse: () => localTeams.first);
      teamMapping[remoteTeam['id']] = localTeam.id;
    }

    // 2. Update matches
    await db.transaction(() async {
      // Remove old matches (simplest way to sync)
      await (db.delete(db.matches)..where((m) => m.tournamentId.equals(localId))).go();
      
      for (final matchJson in matchesData) {
        final homeId = matchJson['homeTeamId'] as int?;
        final awayId = matchJson['awayTeamId'] as int?;
        
        await db.into(db.matches).insert(
          MatchesCompanion.insert(
            tournamentId: localId,
            homeTeamId: drift.Value(homeId != null ? teamMapping[homeId] : null),
            awayTeamId: drift.Value(awayId != null ? teamMapping[awayId] : null),
            homeScore: drift.Value(matchJson['homeScore']),
            awayScore: drift.Value(matchJson['awayScore']),
            round: matchJson['round'],
            phase: matchJson['phase'],
            isCompleted: drift.Value(matchJson['isCompleted']),
          )
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tournamentAsync = ref.watch(tournamentByIdProvider(widget.tournamentId));
    final teamsAsync = ref.watch(tournamentTeamsProvider(widget.tournamentId));

    return tournamentAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.error)),
        body: Center(child: Text('${AppLocalizations.of(context)!.error}: $error')),
      ),
      data: (tournament) {
        if (tournament == null) {
          return Scaffold(
            appBar: AppBar(title: Text(AppLocalizations.of(context)!.notFound)),
            body: Center(child: Text(AppLocalizations.of(context)!.tournamentNotFound)),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 150,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(tournament.name),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                          Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.emoji_events,
                        size: 55,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    tooltip: AppLocalizations.of(context)!.share,
                    onPressed: () => context.push('/share/${widget.tournamentId}?name=${tournament.name}'),
                  ),
                  if (!tournament.isReadOnly)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: AppLocalizations.of(context)!.edit,
                      onPressed: () => context.go('/tournaments/${widget.tournamentId}/edit'),
                    ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sync badge
                      if (tournament.isReadOnly) ...[
                        Row(
                          children: [
                            Icon(_isSyncing ? Icons.sync : Icons.cloud_download, 
                                 size: 14, 
                                 color: _syncError != null ? Colors.red : Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              _isSyncing ? "Syncing..." : (_syncError != null ? "Sync error" : "Read Only (Sync enabled)"),
                              style: TextStyle(
                                fontSize: 11, 
                                color: _syncError != null ? Colors.red : Colors.blue, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            if (_lastSync != null) 
                               Text(" • Last: ${_lastSync!.hour}:${_lastSync!.minute}:${_lastSync!.second}", 
                                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Location
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.stadium, size: 20, color: Colors.orange),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    tournament.location,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Actions
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            tournament.startDate != null 
                              ? "${tournament.startDate!.day}/${tournament.startDate!.month}/${tournament.startDate!.year}"
                              : "${tournament.createdAt.day}/${tournament.createdAt.month}/${tournament.createdAt.year}",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 200.ms),
                        ],
                      ).animate().fadeIn(),
                      
                      const SizedBox(height: 24),
                      
                      // Teams section
                      Text(
                        AppLocalizations.of(context)!.participatingTeams,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                       teamsAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, s) => Text('${AppLocalizations.of(context)!.error}: $e'),
                        data: (teams) => SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: teams.map((tt) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Chip(
                                avatar: CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  child: Text(
                                    tt.team.name.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                                label: Text(tt.team.name),
                              ),
                            )).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildActionCards(context, tournament),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionCards(BuildContext context, dynamic tournament) {
    final mode = tournament.mode;
    final actions = <Widget>[];

    // Calendar (for group modes)
    if (mode == 'group_only' || mode == 'group_and_elimination') {
      actions.add(_buildActionCard(
        context,
        icon: Icons.calendar_month,
        title: AppLocalizations.of(context)!.calendar,
        subtitle: AppLocalizations.of(context)!.groupPhase,
        color: Colors.blue,
        onTap: () => context.go('/tournaments/${widget.tournamentId}/calendar'),
      ));
    }

    // Standings (for group modes)
    if (mode == 'group_only' || mode == 'group_and_elimination') {
      actions.add(_buildActionCard(
        context,
        icon: Icons.leaderboard,
        title: AppLocalizations.of(context)!.standings,
        subtitle: AppLocalizations.of(context)!.pointsAndStats,
        color: Colors.green,
        onTap: () => context.go('/tournaments/${widget.tournamentId}/standings'),
      ));
    }

    // Bracket (for elimination modes)
    if (mode == 'elimination_only' || mode == 'group_and_elimination') {
      actions.add(_buildActionCard(
        context,
        icon: Icons.account_tree,
        title: AppLocalizations.of(context)!.elimination,
        subtitle: AppLocalizations.of(context)!.playoffBracket,
        color: Colors.orange,
        onTap: () => context.go('/tournaments/${widget.tournamentId}/bracket'),
      ));
    }

    // Madness
    if (mode == 'madness') {
      actions.add(_buildActionCard(
        context,
        icon: Icons.flash_on,
        title: AppLocalizations.of(context)!.madness,
        subtitle: AppLocalizations.of(context)!.madnessSubtitle,
        color: Colors.deepPurple,
        onTap: () => context.go('/tournaments/${widget.tournamentId}/madness'),
      ));
    }

    // Timer
    actions.add(_buildActionCard(
      context,
      icon: Icons.timer,
      title: AppLocalizations.of(context)!.timerLabel,
      subtitle: AppLocalizations.of(context)!.minutesX(tournament.timerMinutes),
      color: Colors.red,
      onTap: () => context.go('/timer'),
    ));

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: actions.asMap().entries.map((entry) {
        return entry.value.animate().fadeIn(delay: Duration(milliseconds: 100 * entry.key)).scale(begin: const Offset(0.9, 0.9));
      }).toList(),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.3),
                color.withValues(alpha: 0.1),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
