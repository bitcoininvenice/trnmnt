import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../tournaments/data/tournaments_repository.dart';
import '../../../map/data/courts_repository.dart';
import '../../../../generated/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trnmnt/features/tournaments/presentation/widgets/cloud_tournament_card.dart';

class HubScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const HubScreen({super.key, this.embedded = false});

  @override
  ConsumerState<HubScreen> createState() => _HubScreenState();
}

final hubInitialTabIndexProvider = StateProvider<int>((ref) => 0);
final hubSelectedMatchIdProvider = StateProvider<String?>((ref) => null);

class _HubScreenState extends ConsumerState<HubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final initialIndex = ref.read(hubInitialTabIndexProvider);
    _tabController = TabController(length: 2, vsync: this, initialIndex: initialIndex);
    
    // Reset initial index after consumption to avoid sticking to it on subsequent navigations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hubInitialTabIndexProvider.notifier).state = 0;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final liveMatchesAsync = ref.watch(cloudLiveMatchesProvider);
    final hasLiveMatches = liveMatchesAsync.value?.isNotEmpty ?? false;

    final body = Column(
      children: [
        if (widget.embedded)
          SizedBox(
            height: 38,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.orange,
              indicatorWeight: 2,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
              tabs: [
                Tab(text: l10n.tournaments.toUpperCase()),
                _buildTab(l10n.liveMatches.toUpperCase(), hasLiveMatches),
              ],
            ),
          ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              const _TournamentsTab(),
              const _LiveMatchesTab(),
            ],
          ),
        ),
      ],
    );

    if (widget.embedded) return body;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: Text(l10n.cloudHub, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        backgroundColor: const Color(0xFF0F172A),
        centerTitle: false,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(38),
          child: SizedBox(
            height: 38,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.orange,
              indicatorWeight: 2,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
              tabs: [
                Tab(text: l10n.tournaments.toUpperCase()),
                _buildTab(l10n.liveMatches.toUpperCase(), hasLiveMatches),
              ],
            ),
          ),
        ),
      ),
      body: body,
    );
  }

  Widget _buildTab(String text, bool hasLive) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text),
          if (hasLive) ...[
            const SizedBox(width: 6),
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.green, blurRadius: 4, spreadRadius: 1),
                ],
              ),
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 800.ms)
            .custom(builder: (context, value, child) {
              return Opacity(opacity: 0.5 + (value * 0.5), child: child);
            }),
          ],
        ],
      ),
    );
  }
}

final hubTournamentFilterProvider = StateProvider<String>((ref) => 'all');

class _TournamentsTab extends ConsumerWidget {
  const _TournamentsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentsAsync = ref.watch(hubTournamentsProvider);
    final filter = ref.watch(hubTournamentFilterProvider);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Filter Bar (Compact)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: Row(
            children: [
              _FilterChip(
                label: l10n.all.toUpperCase(),
                isSelected: filter == 'all',
                onSelected: () => ref.read(hubTournamentFilterProvider.notifier).state = 'all',
              ),
              const SizedBox(width: 6),
              _FilterChip(
                label: l10n.live.toUpperCase(),
                isSelected: filter == 'live',
                onSelected: () => ref.read(hubTournamentFilterProvider.notifier).state = 'live',
              ),
              const SizedBox(width: 6),
              _FilterChip(
                label: l10n.upcoming.toUpperCase(),
                isSelected: filter == 'upcoming',
                onSelected: () => ref.read(hubTournamentFilterProvider.notifier).state = 'upcoming',
              ),
              const SizedBox(width: 6),
              _FilterChip(
                label: l10n.concluded.toUpperCase(),
                isSelected: filter == 'concluded',
                onSelected: () => ref.read(hubTournamentFilterProvider.notifier).state = 'concluded',
              ),
            ],
          ),
        ),
        Expanded(
          child: tournamentsAsync.when(
            data: (tournaments) {
              final now = DateTime.now();
              final filteredTournaments = tournaments.where((t) {
                // Estrazione sicura dei dati del torneo (coerente con CloudTournamentDetailScreen)
                final Map<String, dynamic> data = (t['data'] is Map 
                    ? Map<String, dynamic>.from(t['data'] as Map) 
                    : Map<String, dynamic>.from(t));
                
                final tournament = data['tournament'] as Map? ?? {};
                
                final winnerId = tournament['winner_team_id'] ?? 
                                 tournament['winnerTeamId'] ?? 
                                 t['winner_team_id'] ?? 
                                 t['winnerTeamId'];
                                 
                final isConcluded = winnerId != null && winnerId.toString().isNotEmpty;
                
                final startDateVal = tournament['startDate'] ?? t['startDate'];
                DateTime? startDate;
                if (startDateVal is String) startDate = DateTime.tryParse(startDateVal);
                if (startDateVal is int) startDate = DateTime.fromMillisecondsSinceEpoch(startDateVal);

                final endDateVal = tournament['endDate'] ?? t['endDate'];
                DateTime? endDate;
                if (endDateVal is String) endDate = DateTime.tryParse(endDateVal);
                if (endDateVal is int) endDate = DateTime.fromMillisecondsSinceEpoch(endDateVal);
                if (startDate != null) endDate ??= startDate.add(const Duration(hours: 8));

                bool matchLive = false;
                bool matchUpcoming = false;
                bool matchConcluded = isConcluded;

                if (isConcluded) {
                  matchConcluded = true;
                } else if (startDate != null && endDate != null) {
                  if (now.isBefore(startDate)) {
                    matchUpcoming = true;
                  } else if (now.isAfter(endDate)) {
                    matchConcluded = true;
                  } else {
                    matchLive = true;
                  }
                } else {
                  // Fallback: se mancano le date ma il torneo è attivo, mostralo in 'live' o 'all'
                  matchLive = true;
                }

                if (filter == 'live') return matchLive;
                if (filter == 'upcoming') return matchUpcoming;
                if (filter == 'concluded') return matchConcluded;
                return true;
              }).toList();

              if (filteredTournaments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.filter_list_off, size: 48, color: Colors.grey.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text(l10n.noTournamentsAtMoment, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(hubTournamentsProvider);
                  ref.invalidate(mergedCourtsProvider);
                },
                color: Colors.orange,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTournaments.length,
                  itemBuilder: (context, index) {
                    return CloudTournamentCard(
                      data: filteredTournaments[index],
                      style: CloudTournamentCardStyle.wide,
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: Colors.orange)),
            error: (e, s) => Center(child: Text('${l10n.errorLoadingData}: $e')),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.grey.shade400,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: Colors.orange,
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide.none,
      showCheckmark: false,
    );
  }
}

class _LiveMatchesTab extends ConsumerWidget {
  const _LiveMatchesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveMatchesAsync = ref.watch(cloudLiveMatchesProvider);
    final selectedMatchId = ref.watch(hubSelectedMatchIdProvider);
    final l10n = AppLocalizations.of(context)!;

    return liveMatchesAsync.when(
      data: (matches) {
        if (matches.isEmpty) {
          return Center(child: Text(l10n.noLiveMatches, style: const TextStyle(color: Colors.grey)));
        }

        // Optional: Reorder matches to put the selected one first
        final sortedMatches = [...matches];
        if (selectedMatchId != null) {
          final index = sortedMatches.indexWhere((m) => m['id']?.toString() == selectedMatchId);
          if (index != -1) {
            final match = sortedMatches.removeAt(index);
            sortedMatches.insert(0, match);
          }
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedMatches.length,
          itemBuilder: (context, index) {
            final match = sortedMatches[index];
            final isSelected = match['id']?.toString() == selectedMatchId;
            return _WideLiveMatchCard(match: match, isSelected: isSelected);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.orange)),
      error: (e, s) => Center(child: Text('${l10n.errorLoadingData}: $e')),
    );
  }
}

class _WideLiveMatchCard extends StatelessWidget {
  final Map<String, dynamic> match;
  final bool isSelected;
  const _WideLiveMatchCard({required this.match, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected ? const BorderSide(color: Colors.orange, width: 2) : BorderSide.none,
      ),
      color: const Color(0xFF1E293B),
      child: InkWell(
        onTap: () {
          // Future: match details
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isSelected)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'LA TUA SELEZIONE',
                    style: TextStyle(color: Colors.orange, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 2),
                  ),
                ),
              if (match['match_title'] != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    match['match_title'].toString().toUpperCase(),
                    style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      match['home_team_name'] ?? 'Team A',
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${match['home_score'] ?? 0} - ${match['away_score'] ?? 0}',
                      style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      match['away_team_name'] ?? 'Team B',
                      textAlign: TextAlign.left,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer_outlined, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    l10n.periodLabel(match['period']?.toString() ?? '1'),
                    style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: -0.1);
  }
}
