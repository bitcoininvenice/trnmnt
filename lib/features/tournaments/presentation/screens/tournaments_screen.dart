import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import 'package:trnmnt/features/tournaments/data/tournaments_repository.dart';
import 'package:trnmnt/features/community/data/community_repository.dart';
import 'package:trnmnt/core/database/app_database.dart';

class TournamentsScreen extends ConsumerStatefulWidget {
  const TournamentsScreen({super.key});

  @override
  ConsumerState<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends ConsumerState<TournamentsScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    if (_isProcessing) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.myTournaments)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final tournamentsAsync = ref.watch(filteredTournamentsProvider);
    final searchQuery = ref.watch(tournamentSearchQueryProvider);
    final selectedMode = ref.watch(tournamentModeFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myTournaments),
        actions: [
          IconButton(
            icon: const Icon(Icons.hub_outlined),
            tooltip: 'Gestione Community',
            onPressed: () => context.go('/community'),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nuovo Torneo',
            onPressed: () => context.go('/tournaments/new'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(180),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (val) => ref.read(tournamentSearchQueryProvider.notifier).state = val,
                  decoration: InputDecoration(
                    hintText: 'Cerca per nome o campetto...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    hintStyle: const TextStyle(fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    filled: true,
                    fillColor: Colors.grey.shade900,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Tutti', style: TextStyle(fontSize: 12)),
                        selected: selectedMode == null,
                        showCheckmark: false,
                        onSelected: (_) => ref.read(tournamentModeFilterProvider.notifier).state = null,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip('group_only', AppLocalizations.of(context)!.groupOnly, selectedMode),
                      const SizedBox(width: 8),
                      _buildFilterChip('elimination_only', AppLocalizations.of(context)!.eliminationOnly, selectedMode),
                      const SizedBox(width: 8),
                      _buildFilterChip('group_and_elimination', AppLocalizations.of(context)!.groupAndElimination, selectedMode),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const _StatusFilterBar(),
              ],
            ),
          ),
        ),
      ),
      body: tournamentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
        data: (tournaments) {
          if (tournaments.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tournaments.length,
            itemBuilder: (context, index) {
              final tournament = tournaments[index];
              return _buildTournamentCard(context, tournament, index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/tournaments/new'),
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.newTournament),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 100,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.noTournaments,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.createFirstTournament,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/tournaments/new'),
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context)!.createTournament),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildTournamentCard(BuildContext context, Tournament tournament, int index) {
    final modeLabel = _getModeLabel(tournament.mode, context);
    final modeColor = _getModeColor(tournament.mode);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/tournaments/${tournament.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    modeColor.withValues(alpha: 0.3),
                    modeColor.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: modeColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.emoji_events, color: modeColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                tournament.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            if (tournament.isPublished) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.cloud_done, color: Colors.blue, size: 16),
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: Colors.white.withValues(alpha: 0.6)),
                            const SizedBox(width: 4),
                            Text(
                              tournament.startDate != null 
                                ? "${tournament.startDate!.day}/${tournament.startDate!.month}/${tournament.startDate!.year}"
                                : "${tournament.createdAt.day}/${tournament.createdAt.month}/${tournament.createdAt.year}",
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.stadium, size: 14, color: Colors.white.withValues(alpha: 0.6)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.location(tournament.location),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (tournament.communityId != null) ...[
                          const SizedBox(height: 8),
                          _CommunityBadge(
                            communityId: tournament.communityId!,
                            communityName: tournament.communityName,
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'delete') {
                        final isCoManager = tournament.name.endsWith('(Sync)');
                        final titleText = isCoManager ? 'Disconnetti dal Torneo' : AppLocalizations.of(context)!.deleteTournament;
                        final confirmText = isCoManager ? 'Sei sicuro di volerti disconnettere da "${tournament.name}"? Verrà rimosso dal tuo dispositivo ma non dal cloud.' : AppLocalizations.of(context)!.confirmDeleteTournament(tournament.name);
                        final actionText = isCoManager ? 'Disconnetti' : AppLocalizations.of(context)!.delete;
                        
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(titleText),
                            content: Text(confirmText),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(AppLocalizations.of(context)!.cancel),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: Text(actionText),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          setState(() => _isProcessing = true);
                          try {
                            await ref.read(tournamentsRepositoryProvider).deleteTournament(tournament.id);
                          } finally {
                            if (mounted) {
                              setState(() => _isProcessing = false);
                            }
                          }
                        }
                      }
                    },
                    itemBuilder: (context) {
                      final isCoManager = tournament.name.endsWith('(Sync)');
                      return [
                        PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(isCoManager ? Icons.link_off : Icons.delete, color: Colors.red),
                            title: Text(isCoManager ? 'Disconnetti' : AppLocalizations.of(context)!.delete, style: const TextStyle(color: Colors.red)),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildChip(modeLabel, modeColor),
                  const SizedBox(width: 8),
                  if (tournament.includeConsolationFinals)
                    _buildChip(AppLocalizations.of(context)!.consolationFinals, Colors.purple),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideY(begin: 0.1);
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFilterChip(String mode, String label, String? selectedMode) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selectedMode == mode,
      showCheckmark: false,
      onSelected: (val) {
        ref.read(tournamentModeFilterProvider.notifier).state = val ? mode : null;
      },
    );
  }

  String _getModeLabel(String mode, BuildContext context) {
    switch (mode) {
      case 'group_only':
        return AppLocalizations.of(context)!.groupOnly;
      case 'elimination_only':
        return AppLocalizations.of(context)!.eliminationOnly;
      case 'group_and_elimination':
        return AppLocalizations.of(context)!.groupAndElimination;
      default:
        return mode;
    }
  }

  Color _getModeColor(String mode) {
    switch (mode) {
      case 'group_only':
        return Colors.blue;
      case 'elimination_only':
        return Colors.orange;
      case 'group_and_elimination':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class _CommunityBadge extends ConsumerStatefulWidget {
  final String communityId;
  final String? communityName;
  const _CommunityBadge({required this.communityId, this.communityName});

  @override
  ConsumerState<_CommunityBadge> createState() => _CommunityBadgeState();
}

class _CommunityBadgeState extends ConsumerState<_CommunityBadge> {
  @override
  Widget build(BuildContext context) {
    final communityAsync = ref.watch(communityByIdProvider(widget.communityId));
    
    return communityAsync.when(
      data: (community) {
        final displayName = community?.name ?? widget.communityName;
        if (displayName == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.hub_outlined, size: 10, color: Colors.orange),
              const SizedBox(width: 4),
              Text(
                displayName,
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => widget.communityName != null ? _buildBadge(widget.communityName!) : const SizedBox.shrink(),
      error: (_, __) => widget.communityName != null ? _buildBadge(widget.communityName!) : const SizedBox.shrink(),
    );
  }

  Widget _buildBadge(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.hub_outlined, size: 10, color: Colors.orange),
          const SizedBox(width: 4),
          Text(
            name,
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusFilterBar extends ConsumerStatefulWidget {
  const _StatusFilterBar();

  @override
  ConsumerState<_StatusFilterBar> createState() => _StatusFilterBarState();
}

class _StatusFilterBarState extends ConsumerState<_StatusFilterBar> {
  @override
  Widget build(BuildContext context) {
    final status = ref.watch(tournamentStatusFilterProvider);
    
    return Row(
      children: [
        _buildStatusTab('all', const Text('Tutti', style: TextStyle(fontSize: 12)), status == 'all'),
        _buildStatusTab('local', const Icon(Icons.smartphone, size: 20), status == 'local'),
        _buildStatusTab('cloud', const Icon(Icons.cloud, size: 20), status == 'cloud'),
      ],
    );
  }

  Widget _buildStatusTab(String value, Widget content, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(tournamentStatusFilterProvider.notifier).state = value,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: DefaultTextStyle.merge(
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
              child: IconTheme.merge(
                data: IconThemeData(
                  color: isSelected ? Colors.blue : Colors.grey,
                ),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
