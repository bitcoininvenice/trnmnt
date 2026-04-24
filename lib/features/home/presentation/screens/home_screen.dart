import 'dart:async';
import 'package:flutter/material.dart';
import '../../../explorer/presentation/screens/hub_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import 'package:trnmnt/core/providers/icon_provider.dart';
import 'package:trnmnt/features/stats/presentation/widgets/stats_overview.dart';
import 'package:trnmnt/features/stats/data/stats_repository.dart';
import 'package:trnmnt/features/tournaments/data/tournaments_repository.dart';
import 'package:trnmnt/features/community/data/community_repository.dart';
import 'package:trnmnt/features/tournaments/presentation/widgets/cloud_tournament_card.dart';
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
                                    _currentPage == 1 ? 'TRNMNT' : 'TRNMNT HUB',
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ).animate(key: ValueKey('title_$_currentPage')).fadeIn(duration: 400.ms).slideX(begin: -0.2),
                                  Text(
                                    _currentPage == 1 ? l10n.appSubtitle : l10n.hubSubtitle,
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
          const _HubDashboard(),
          _LocalDashboard(activeGame: activeGame),
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
        const SliverToBoxAdapter(
          child: _ActiveGameCard(),
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
                icon: Icons.track_changes,
                title: l10n.radar,
                subtitle: l10n.radarSubtitle,
                color: Colors.teal,
                onTap: () => context.go('/radar'),
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
        _CloudTournamentsSlider(),
        const _SponsorTicker(),
        Expanded(
          child: const HubScreen(embedded: true),
        ),
      ],
    );
  }
}


class _SponsorTicker extends StatefulWidget {
  const _SponsorTicker();

  @override
  State<_SponsorTicker> createState() => _SponsorTickerState();
}

class _SponsorTickerState extends State<_SponsorTicker> {
  late ScrollController _scrollController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Start scrolling after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() {
    if (!mounted) return;
    
    // We use a periodic timer to jump the scroll offset slightly
    // This creates a much smoother continuous loop than animateTo
    const speed = 0.5; // pixels per tick
    const tickDuration = Duration(milliseconds: 16); // ~60fps
    
    _timer = Timer.periodic(tickDuration, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_scrollController.hasClients) {
        final currentOffset = _scrollController.offset;
        _scrollController.jumpTo(currentOffset + speed);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final tickerText = ref.watch(sponsorTickerProvider).value ?? "TRNMNT • SPAZIO PARTNERSHIP DISPONIBILE • CONTATTACI PER MAGGIORI INFO";
        
        return Container(
          height: 32,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.symmetric(
              horizontal: BorderSide(color: Colors.orange.withOpacity(0.1), width: 0.5),
            ),
          ),
          child: IgnorePointer(
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              // Use a very large number for infinite effect
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    const SizedBox(width: 40),
                    Text(
                      tickerText.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 40),
                    Icon(Icons.star, size: 8, color: Colors.orange.withOpacity(0.5)),
                    const SizedBox(width: 40),
                    Container(width: 1, height: 12, color: Colors.white.withOpacity(0.1)),
                  ],
                );
              },
            ),
          ),
        );
      },
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

    return cloudTournamentsAsync.when(
      data: (tournamentsRaw) {
        final now = DateTime.now();
        final tournaments = tournamentsRaw.where((data) {
          final tournament = Map<String, dynamic>.from(data['tournament'] ?? {});
          final dateVal = tournament['startDate'];
          DateTime? startDate;
          if (dateVal is String) startDate = DateTime.tryParse(dateVal);
          if (dateVal is int) startDate = DateTime.fromMillisecondsSinceEpoch(dateVal);
          
          if (startDate == null) return true;

          final endDateVal = tournament['endDate'];
          DateTime? endDate;
          if (endDateVal is String) endDate = DateTime.tryParse(endDateVal);
          if (endDateVal is int) endDate = DateTime.fromMillisecondsSinceEpoch(endDateVal);
          endDate ??= startDate.add(const Duration(hours: 8));

          final isCompleted = tournament['winnerTeamId'] != null;
          
          if (isCompleted) return false;
          
          if (now.isBefore(startDate)) {
            return currentFilters.contains(CloudFilter.future);
          } else if (now.isAfter(endDate)) {
            return false;
          } else {
            return currentFilters.contains(CloudFilter.inProgress);
          }
        }).toList();

        final isVisible = tournaments.isNotEmpty;

        return AnimatedCrossFade(
          key: const ValueKey('cloud_slider_cross_fade'),
          duration: const Duration(milliseconds: 400),
          crossFadeState: isVisible ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Column(
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
                    Icon(Icons.cloud_done, size: 14, color: Colors.green.withValues(alpha: 0.4)),
                    const SizedBox(width: 4),
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.tune, size: 18, color: Colors.grey),
                        onPressed: () async {
                          final RenderBox button = context.findRenderObject() as RenderBox;
                          final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
                          final RelativeRect position = RelativeRect.fromRect(
                            Rect.fromPoints(
                              button.localToGlobal(Offset.zero, ancestor: overlay),
                              button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                            ),
                            Offset.zero & overlay.size,
                          );

                          final result = await showMenu<CloudFilter>(
                            context: context,
                            position: position,
                            items: [
                              _buildPopupItem(CloudFilter.inProgress, l10n.inProgress, currentFilters.contains(CloudFilter.inProgress)),
                              _buildPopupItem(CloudFilter.future, l10n.future, currentFilters.contains(CloudFilter.future)),
                            ],
                          );

                          if (result != null && context.mounted) {
                            final newFilters = Set<CloudFilter>.from(currentFilters);
                            if (newFilters.contains(result)) {
                              if (newFilters.length > 1) newFilters.remove(result);
                            } else {
                              newFilters.add(result);
                            }
                            ref.read(cloudFilterProvider.notifier).state = newFilters;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 131,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: tournaments.length,
                  itemBuilder: (context, index) {
                    return CloudTournamentCard(
                      data: tournaments[index],
                      style: CloudTournamentCardStyle.compact,
                      translatedMode: homeState?._getTranslatedMode(context, (Map<String, dynamic>.from(tournaments[index]['tournament'] ?? {}))['mode'] as String?),
                    );
                  },
                ),
              ),
            ],
          ),
          secondChild: const SizedBox(width: double.infinity, height: 0),
        );
      },
      loading: () => Column(
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
                    Icon(Icons.cloud_done, size: 14, color: Colors.green.withValues(alpha: 0.4)),
                    const SizedBox(width: 4),
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.tune, size: 18, color: Colors.grey),
                        onPressed: () async {
                          final RenderBox button = context.findRenderObject() as RenderBox;
                          final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
                          final RelativeRect position = RelativeRect.fromRect(
                            Rect.fromPoints(
                              button.localToGlobal(Offset.zero, ancestor: overlay),
                              button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                            ),
                            Offset.zero & overlay.size,
                          );

                          final result = await showMenu<CloudFilter>(
                            context: context,
                            position: position,
                            items: [
                              _buildPopupItem(CloudFilter.inProgress, l10n.inProgress, currentFilters.contains(CloudFilter.inProgress)),
                              _buildPopupItem(CloudFilter.future, l10n.future, currentFilters.contains(CloudFilter.future)),
                            ],
                          );

                          if (result != null && context.mounted) {
                            final newFilters = Set<CloudFilter>.from(currentFilters);
                            if (newFilters.contains(result)) {
                              if (newFilters.length > 1) newFilters.remove(result);
                            } else {
                              newFilters.add(result);
                            }
                            ref.read(cloudFilterProvider.notifier).state = newFilters;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
          SizedBox(
            height: 131,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 3,
              itemBuilder: (context, index) => const _CloudTournamentSkeleton(),
            ),
          ),
        ],
      ),
      error: (e, s) => const SizedBox.shrink(),
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

class _CloudTournamentSkeleton extends StatelessWidget {
  const _CloudTournamentSkeleton();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -20, bottom: -20,
            child: Icon(Icons.sports_basketball, size: 120, color: Colors.white.withValues(alpha: 0.02)),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 70,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white10, size: 18),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 60,
                  height: 10,
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  width: 200,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white10, size: 14),
                    const SizedBox(width: 4),
                    Container(
                      width: 120,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms, color: Colors.orange.withValues(alpha: 0.1));
  }
}

class _ActiveGameCard extends ConsumerWidget {
  const _ActiveGameCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeGame = ref.watch(activeGameProvider);
    final l10n = AppLocalizations.of(context)!;

    if (!(activeGame.matchId != null || 
          activeGame.isRunning || 
          activeGame.homeScore > 0 || 
          activeGame.awayScore > 0 ||
          activeGame.isFinished)) {
      return const SizedBox.shrink();
    }

    return Padding(
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (activeGame.matchId != null ? Colors.orange : Colors.purple).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    activeGame.matchId != null ? Icons.emoji_events : Icons.sports_basketball,
                    color: activeGame.matchId != null ? Colors.orange : Colors.purple,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeGame.matchId != null ? l10n.activeTournamentMatch : l10n.matchInProgress,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        '${activeGame.homeTeamName} vs ${activeGame.awayTeamName}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${activeGame.homeScore} - ${activeGame.awayScore}',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                    Text(
                      activeGame.formattedTime,
                      style: TextStyle(
                        color: activeGame.isRunning ? Colors.green : Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

