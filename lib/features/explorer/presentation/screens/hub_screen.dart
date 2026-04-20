import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../tournaments/data/tournaments_repository.dart';
import '../../../../generated/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HubScreen extends ConsumerStatefulWidget {
  const HubScreen({super.key});

  @override
  ConsumerState<HubScreen> createState() => _HubScreenState();
}

class _HubScreenState extends ConsumerState<HubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: Text(l10n.cloudHub, style: const TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: const Color(0xFF0F172A),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.orange,
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(text: l10n.tournaments.toUpperCase()),
            Tab(text: l10n.liveMatches.toUpperCase()),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _TournamentsTab(),
          const _LiveMatchesTab(),
        ],
      ),
    );
  }
}

class _TournamentsTab extends ConsumerWidget {
  const _TournamentsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentsAsync = ref.watch(cloudTournamentsProvider);
    final l10n = AppLocalizations.of(context)!;

    return tournamentsAsync.when(
      data: (tournaments) {
        if (tournaments.isEmpty) {
          return Center(child: Text(l10n.noTournamentsAtMoment, style: const TextStyle(color: Colors.grey)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tournaments.length,
          itemBuilder: (context, index) {
             final data = tournaments[index];
             return _WideCloudTournamentCard(data: data);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.orange)),
      error: (e, s) => Center(child: Text('${l10n.errorLoadingData}: $e')),
    );
  }
}

class _LiveMatchesTab extends ConsumerWidget {
  const _LiveMatchesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveMatchesAsync = ref.watch(cloudLiveMatchesProvider);
    final l10n = AppLocalizations.of(context)!;

    return liveMatchesAsync.when(
      data: (matches) {
        if (matches.isEmpty) {
          return Center(child: Text(l10n.noLiveMatches, style: const TextStyle(color: Colors.grey)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            return _WideLiveMatchCard(match: match);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.orange)),
      error: (e, s) => Center(child: Text('${l10n.errorLoadingData}: $e')),
    );
  }
}

class _WideCloudTournamentCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _WideCloudTournamentCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final tournamentMap = Map<String, dynamic>.from(data['tournament'] ?? {});
    final id = data['id']?.toString();
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF1E293B),
      child: InkWell(
        onTap: () {
          if (id != null) {
            context.push('/hub/tournament/$id');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Expanded(
                    child: Text(
                      tournamentMap['name']?.toString().toUpperCase() ?? l10n.tournaments.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                   const Icon(Icons.location_on, size: 14, color: Colors.orange),
                   const SizedBox(width: 4),
                   Expanded(
                     child: Text(
                       tournamentMap['location']?.toString() ?? '', 
                       style: const TextStyle(color: Colors.white70, fontSize: 13),
                       overflow: TextOverflow.ellipsis,
                     ),
                   ),
                   const SizedBox(width: 8),
                   _buildModeBadge(tournamentMap['mode']?.toString() ?? 'group_only'),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Widget _buildModeBadge(String mode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(mode.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}

class _WideLiveMatchCard extends StatelessWidget {
  final Map<String, dynamic> match;
  const _WideLiveMatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
