import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import 'package:trnmnt/core/providers/icon_provider.dart';
import 'package:trnmnt/features/stats/presentation/widgets/stats_overview.dart';
import 'package:trnmnt/features/stats/data/stats_repository.dart';
import 'package:trnmnt/features/tournaments/data/tournaments_repository.dart';
import 'package:trnmnt/features/community/data/community_repository.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import '../../../game/providers/game_provider.dart';

import 'package:trnmnt/core/providers/default_tab_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = ref.read(defaultTabProvider);
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getTranslatedMode(BuildContext context, String? mode) {
    final l10n = AppLocalizations.of(context)!;
    String label;
    switch (mode) {
      case 'group_only':
        label = l10n.groupOnly;
        break;
      case 'elimination_only':
        label = l10n.eliminationOnly;
        break;
      case 'group_and_elimination':
        label = l10n.groupAndElimination;
        break;
      case 'madness':
        label = l10n.madness;
        break;
      default:
        label = mode?.replaceAll('_', ' ') ?? l10n.groupOnly;
    }
    return label.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final activeGame = ref.watch(activeGameProvider);
    final customIconPath = ref.watch(customIconProvider);
    final l10n = AppLocalizations.of(context)!;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(20),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(2, (index) {
                    final isSelected = _currentPage == index;
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(index, duration: 300.ms, curve: Curves.easeInOut);
                      },
                      child: AnimatedContainer(
                        duration: 300.ms,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isSelected ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.orange : Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: Colors.orange.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            )
                          ] : null,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Icon(
                        Icons.sports_basketball,
                        size: 200,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: customIconPath != null
                                  ? Image.file(File(customIconPath), fit: BoxFit.cover)
                                  : Image.asset('assets/icon/logo.png', fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.apps, color: Colors.orange)),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _currentPage == 0 ? 'TRNMNT' : 'TRNMNT HUB',
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ).animate(key: ValueKey('title_$_currentPage')).fadeIn(duration: 400.ms).slideX(begin: -0.2),
                                  Text(
                                    _currentPage == 0 ? l10n.appSubtitle : l10n.hubSubtitle,
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  ).animate(key: ValueKey('subtitle_$_currentPage')).fadeIn(duration: 600.ms, delay: 200.ms),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ];
      },
      body: PageView(
        controller: _pageController,
        onPageChanged: (page) {
          setState(() => _currentPage = page);
        },
        children: [
          _LocalDashboard(activeGame: activeGame),
          const _HubDashboard(),
        ],
      ),
    );
  }
}


class _LocalDashboard extends ConsumerWidget {
  final dynamic activeGame;
  const _LocalDashboard({required this.activeGame});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(appStatsProvider);
    final l10n = AppLocalizations.of(context)!;

    return CustomScrollView(
      key: const PageStorageKey('local_dashboard'),
      slivers: [
        // Removed _CloudTournamentsSlider from here

        if (activeGame.matchId != null || 
            activeGame.isRunning || 
            activeGame.homeScore > 0 || 
            activeGame.awayScore > 0 ||
            activeGame.isFinished)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Card(
                color: (activeGame.matchId != null ? Colors.orange : Colors.purple).withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: activeGame.matchId != null ? Colors.orange : Colors.purple, width: 1),
                ),
                child: InkWell(
                  onTap: () {
                    if (activeGame.matchId != null) {
                       context.push('/hub');
                    } else {
                       context.pushNamed(
                        'single-match-board',
                        extra: {
                          'homeTeamName': activeGame.homeTeamName,
                          'awayTeamName': activeGame.awayTeamName,
                        },
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          activeGame.matchId != null ? Icons.flash_on : Icons.sports_basketball, 
                          color: activeGame.matchId != null ? Colors.orange : Colors.purple, 
                          size: 32
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activeGame.matchId != null ? l10n.activeTournamentMatch : l10n.matchInProgress,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                '${activeGame.homeTeamName} ${activeGame.homeScore} - ${activeGame.awayScore} ${activeGame.awayTeamName} (${activeGame.formattedTime})',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ).animate().slideY(begin: 0.1, duration: 400.ms).fadeIn(),
            ),
          ),

        SliverToBoxAdapter(
          child: statsAsync.when(
            data: (stats) {
              return StatsOverviewWidget(stats: stats);
            },
            loading: () => const Center(child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            )),
            error: (e, s) => const SizedBox.shrink(),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          sliver: SliverGrid.count(
            crossAxisCount: 2,
            childAspectRatio: 1.85,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            children: [
              _buildQuickAction(
                context,
                icon: Icons.storefront,
                title: l10n.myCommunity,
                subtitle: ref.watch(currentCommunityProvider).when(
                  data: (c) => c?.name ?? l10n.manageYourBrand,
                  loading: () => '...',
                  error: (_, __) => l10n.manageYourBrand,
                ),
                color: Colors.pink,
                onTap: () => context.push('/community'),
              ).animate().fadeIn(delay: 50.ms).scale(),
              _buildQuickAction(
                context,
                icon: Icons.sports_basketball,
                title: l10n.singleMatch,
                subtitle: l10n.manageSingleMatch,
                color: Colors.purple,
                onTap: () => context.go('/single-match-setup'),
              ).animate().fadeIn(delay: 100.ms).scale(),
              _buildQuickAction(
                context,
                icon: Icons.emoji_events,
                title: l10n.tournaments,
                subtitle: l10n.createAndManage,
                color: Colors.orange,
                onTap: () => context.go('/tournaments'),
              ).animate().fadeIn(delay: 150.ms).scale(),
              _buildQuickAction(
                context,
                icon: Icons.groups,
                title: l10n.teams,
                subtitle: l10n.manageTeams,
                color: Colors.blue,
                onTap: () => context.go('/teams'),
              ).animate().fadeIn(delay: 200.ms).scale(),
              _buildQuickAction(
                context,
                icon: Icons.qr_code_scanner,
                title: l10n.scanTournament,
                subtitle: l10n.syncFromScout,
                color: Colors.indigo,
                onTap: () => context.push('/scan'),
              ).animate().fadeIn(delay: 250.ms).scale(),
              _buildQuickAction(
                context,
                icon: Icons.military_tech,
                title: l10n.hallOfFame,
                subtitle: l10n.viewWinners,
                color: Colors.amber,
                onTap: () => context.go('/stats'),
              ).animate().fadeIn(delay: 300.ms).scale(),
              _buildQuickAction(
                context,
                icon: Icons.map,
                title: l10n.map,
                subtitle: l10n.courtsMap,
                color: Colors.teal,
                onTap: () => context.go('/map'),
              ).animate().fadeIn(delay: 350.ms).scale(),
              _buildQuickAction(
                context,
                icon: Icons.settings,
                title: l10n.settings,
                subtitle: l10n.appOptions,
                color: Colors.grey,
                onTap: () => context.go('/settings'),
              ).animate().fadeIn(delay: 400.ms).scale(),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.1), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.15),
                color.withValues(alpha: 0.05),
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HubDashboard extends ConsumerStatefulWidget {
  const _HubDashboard();

  @override
  ConsumerState<_HubDashboard> createState() => _HubDashboardState();
}

class _HubDashboardState extends ConsumerState<_HubDashboard> with SingleTickerProviderStateMixin {
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
    
    return Column(
      children: [
        _CloudTournamentsSlider(), // Removed const
        TabBar(
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
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              const _CloudTournamentsList(),
              const _CloudLiveMatchesList(),
            ],
          ),
        ),
      ],
    );
  }
}

class _CloudTournamentsList extends ConsumerWidget {
  const _CloudTournamentsList();
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

class _CloudLiveMatchesList extends ConsumerWidget {
  const _CloudLiveMatchesList();
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
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
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
    ).animate().fadeIn().slideX(begin: -0.1);
  }
}

class _CloudTournamentsSlider extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cloudTournamentsAsync = ref.watch(cloudTournamentsProvider);
    final currentFilters = ref.watch(cloudFilterProvider);
    final l10n = AppLocalizations.of(context)!;
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Row(
            children: [
              Text(
                l10n.liveHighlights,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ).animate(onPlay: (c) => c.repeat()).fadeIn(duration: 500.ms).fadeOut(duration: 500.ms),
              const Spacer(),
              cloudTournamentsAsync.maybeWhen(
                error: (_, __) => IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.cloud_off, size: 14, color: Colors.red.withValues(alpha: 0.6)),
                  onPressed: () => ref.refresh(cloudTournamentsProvider),
                  tooltip: "Offline - Tap to reconnect",
                ),
                loading: () => Icon(Icons.cloud_queue, size: 14, color: Colors.grey.withValues(alpha: 0.5))
                    .animate(onPlay: (c) => c.repeat())
                    .fadeIn(duration: 800.ms)
                    .then()
                    .fadeOut(duration: 800.ms),
                orElse: () => Icon(Icons.cloud_done, size: 14, color: Colors.green.withValues(alpha: 0.4)),
              ),
              if (cloudTournamentsAsync.hasError) ...[
                const SizedBox(width: 4),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.refresh, size: 14, color: Colors.grey),
                  onPressed: () => ref.refresh(cloudTournamentsProvider),
                ),
              ],
              const SizedBox(width: 4),
              PopupMenuButton<CloudFilter>(
                icon: const Icon(Icons.tune, size: 18, color: Colors.grey),
                onSelected: (filter) {
                  final newFilters = Set<CloudFilter>.from(currentFilters);
                  if (newFilters.contains(filter)) {
                    if (newFilters.length > 1) newFilters.remove(filter);
                  } else {
                    newFilters.add(filter);
                  }
                  ref.read(cloudFilterProvider.notifier).state = newFilters;
                },
                itemBuilder: (context) => [
                  _buildPopupItem(CloudFilter.inProgress, l10n.inProgress, currentFilters.contains(CloudFilter.inProgress)),
                  _buildPopupItem(CloudFilter.future, l10n.future, currentFilters.contains(CloudFilter.future)),
                  _buildPopupItem(CloudFilter.past, l10n.past, currentFilters.contains(CloudFilter.past)),
                ],
              ),
            ],
          ),
        ),

        cloudTournamentsAsync.when(
          data: (tournaments) {
            if (tournaments.isEmpty) {
              return SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    l10n.noTournamentsAtMoment,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ),
              );
            }

            return SizedBox(
              height: 131,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: tournaments.length,
                itemBuilder: (context, index) {
                  final data = tournaments[index];
                  final tournamentRaw = data['tournament'];
                  if (tournamentRaw == null || tournamentRaw is! Map) return const SizedBox.shrink();
                  
                  final tournament = Map<String, dynamic>.from(tournamentRaw);
                  final dbSlug = data['community_slug']?.toString();
                  final dbId = data['id']?.toString();
                  
                  return _CloudTournamentCard(
                    tournament: tournament, 
                    communitySlug: dbSlug,
                    tournamentId: dbId,
                    translatedMode: homeState?._getTranslatedMode(context, tournament['mode'] as String?) ?? (tournament['mode']?.toString().toUpperCase() ?? ''),
                  );
                },
              ),
            );
          },
          loading: () => SizedBox(
            height: 131,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 3,
              itemBuilder: (context, index) => const _CloudTournamentSkeleton(),
            ),
          ),
          error: (e, s) => SizedBox(
            height: 80, 
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 24, color: Colors.grey.withValues(alpha: 0.5)),
                  const SizedBox(height: 8),
                  Text(
                    "Cloud Sync Offline", 
                    style: TextStyle(color: Colors.grey.withValues(alpha: 0.5), fontSize: 11, fontWeight: FontWeight.bold)
                  ),
                ],
              )
            )
          ),
        ),
      ],
    );
  }

  PopupMenuItem<CloudFilter> _buildPopupItem(CloudFilter value, String label, bool isSelected) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_box : Icons.check_box_outline_blank,
            color: isSelected ? Colors.orange : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

class _CloudTournamentCard extends StatelessWidget {
  final Map<String, dynamic> tournament;
  final String? communitySlug;
  final String? tournamentId;
  final String translatedMode;

  const _CloudTournamentCard({
    required this.tournament,
    this.communitySlug,
    this.tournamentId,
    required this.translatedMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade900,
            Colors.orange.withValues(alpha: 0.1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.sports_basketball,
              size: 150,
              color: Colors.orange.withValues(alpha: 0.05),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusBadge(context, tournament),
                    const Icon(Icons.chevron_right, color: Colors.white38),
                  ],
                ),
                const Spacer(),
                if (tournament['startDate'] != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(tournament['startDate']),
                          style: TextStyle(color: Colors.orange.withValues(alpha: 0.8), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                        Text(
                          translatedMode,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                Text(
                  (tournament['name']?.toString() ?? 'TRNMNT').toUpperCase(),
                  maxLines: 2,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        tournament['location']?.toString() ?? '',
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  var webUrl = tournament['webUrl'] as String?;
                  final String? effectiveId = tournamentId ?? tournament['id']?.toString();
                  
                   if (effectiveId != null) {
                      context.push('/hub/tournament/$effectiveId');
                    }
                  
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, Map<String, dynamic> tournament) {
    final dateVal = tournament['startDate'];
    DateTime? startDate;
    if (dateVal is String) {
      startDate = DateTime.tryParse(dateVal);
    } else if (dateVal is int) {
      startDate = DateTime.fromMillisecondsSinceEpoch(dateVal);
    }
    
    final now = DateTime.now();
    final winnerTeamId = tournament['winnerTeamId'];
    final isCompleted = winnerTeamId != null;

    final l10n = AppLocalizations.of(context)!;
    Color color = Colors.blue;
    IconData icon = Icons.calendar_today;
    String label = l10n.upcoming;

    if (isCompleted) {
      label = l10n.concluded;
      color = Colors.grey;
      icon = Icons.check_circle_outline;
    } else if (startDate != null) {
      final endDateVal = tournament['endDate'];
      DateTime? endDate;
      if (endDateVal is String) {
        endDate = DateTime.tryParse(endDateVal);
      } else if (endDateVal is int) {
        endDate = DateTime.fromMillisecondsSinceEpoch(endDateVal);
      }
      endDate ??= startDate.add(const Duration(hours: 8));

      if (now.isBefore(startDate)) {
        label = l10n.upcoming;
        color = Colors.blue;
        icon = Icons.calendar_today;
      } else if (now.isAfter(endDate)) {
        label = l10n.concluded;
        color = Colors.grey;
        icon = Icons.check_circle_outline;
      } else {
        label = l10n.live;
        color = Colors.green;
        icon = Icons.sensors;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic dateVal) {
    if (dateVal == null) return '';
    DateTime? date;
    if (dateVal is String) {
      date = DateTime.tryParse(dateVal);
    } else if (dateVal is int) {
      date = DateTime.fromMillisecondsSinceEpoch(dateVal);
    }
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _CloudTournamentSkeleton extends StatelessWidget {
  const _CloudTournamentSkeleton();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 80, height: 20, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8))),
          const Spacer(),
          Container(width: 200, height: 18, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 8),
          Container(width: 120, height: 12, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(4))),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms, color: Colors.orange.withValues(alpha: 0.1));
  }
}
