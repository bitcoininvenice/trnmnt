import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trnmnt/features/sharing/data/sync_repository.dart';
import 'package:trnmnt/features/tournaments/data/tournaments_repository.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import 'package:trnmnt/features/community/data/community_repository.dart';

class TournamentDetailScreen extends ConsumerStatefulWidget {
  final int tournamentId;
  const TournamentDetailScreen({super.key, required this.tournamentId});

  @override
  ConsumerState<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends ConsumerState<TournamentDetailScreen> {
  @override
  void initState() {
    super.initState();
    _handleSubscription();
  }

  @override
  void dispose() {
    ref.read(syncRepositoryProvider).unsubscribe();
    super.dispose();
  }

  void _handleSubscription() async {
    // Wait for the tournament data to see if we have a cloudId
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final tournament = await ref.read(tournamentByIdProvider(widget.tournamentId).future);
    if (!mounted) return;
    
    if (tournament != null && tournament.cloudId != null) {
      ref.read(syncRepositoryProvider).subscribeToTournament(
        tournament.cloudId!, 
        widget.tournamentId
      );
    }
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
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Tooltip(
                      message: tournament.isPublished ? "Published to Cloud" : "Private on Device",
                      child: Icon(
                        tournament.isPublished ? Icons.cloud : Icons.smartphone,
                        color: tournament.isPublished ? Colors.green : Colors.white60,
                        size: 22,
                      ),
                    ),
                  ),
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
                      // Cloud Sync badge
                      if (tournament.cloudId != null) ...[
                        Row(
                          children: [
                            const Icon(Icons.cloud_done, size: 16, color: Colors.blueAccent),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.cloudSyncActive,
                              style: const TextStyle(
                                fontSize: 12, 
                                color: Colors.blueAccent, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      
                      // Community Badge
                      if (tournament.communityId != null) ...[
                        Row(
                          children: [
                            const Icon(Icons.hub_outlined, size: 16, color: Colors.orange),
                            const SizedBox(width: 8),
                            _CommunityBadge(
                              communityId: tournament.communityId!,
                              communityName: tournament.communityName,
                            ),
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

    // Bracket (for elimination modes OR multi-group tournaments)
    final isEliminationMode = mode == 'elimination_only' || mode == 'group_and_elimination';
    final hasMultiGroups = (tournament.groupCount ?? 1) > 1;
    
    if (isEliminationMode || hasMultiGroups) {
      actions.add(_buildActionCard(
        context,
        icon: Icons.account_tree,
        title: AppLocalizations.of(context)!.elimination,
        subtitle: hasMultiGroups && !isEliminationMode ? 'Tabellone Finale' : AppLocalizations.of(context)!.playoffBracket,
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

    // Rules (Mode Legend)
    actions.add(_buildActionCard(
      context,
      icon: Icons.gavel_outlined, // or Icons.menu_book
      title: AppLocalizations.of(context)!.rules,
      subtitle: AppLocalizations.of(context)!.viewTournamentRules,
      color: Colors.brown,
      onTap: () => context.push('/settings/legend/$mode'),
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

class _CommunityBadge extends ConsumerWidget {
  final String communityId;
  final String? communityName;
  const _CommunityBadge({required this.communityId, this.communityName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communityAsync = ref.watch(communityByIdProvider(communityId));
    
    return communityAsync.when(
      data: (community) {
        final name = community?.name ?? communityName;
        if (name == null) return const SizedBox.shrink();
        return Text(
          name,
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        );
      },
      loading: () => communityName != null 
          ? Text(communityName!, style: const TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.bold))
          : const SizedBox(child: CircularProgressIndicator(strokeWidth: 2), height: 12, width: 12),
      error: (_, __) => communityName != null 
          ? Text(communityName!, style: const TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.bold))
          : const SizedBox.shrink(),
    );
  }
}
