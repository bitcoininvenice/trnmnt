import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import 'package:trnmnt/core/providers/icon_provider.dart';
import 'package:trnmnt/features/stats/presentation/widgets/stats_overview.dart';
import 'package:trnmnt/features/stats/data/stats_repository.dart';
import 'package:trnmnt/features/single_match/data/single_match_provider.dart';
import 'package:trnmnt/features/tournaments/data/tournaments_repository.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customIconPath = ref.watch(customIconProvider);
    final statsAsync = ref.watch(appStatsProvider);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header Section (Concept 3 Hero style)
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
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
                      padding: const EdgeInsets.all(24.0),
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
                                  : Image.asset('assets/icon/app_icon.png', fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.apps, color: Colors.orange)),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TRNMNT',
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.appSubtitle,
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
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

          // Cloud Tournaments Slider
          SliverToBoxAdapter(
            child: _CloudTournamentsSlider(),
          ),

          // Stats Section (Concept 2 integration)
          SliverToBoxAdapter(
            child: statsAsync.when(
              data: (stats) {
                return StatsOverviewWidget(stats: stats);
              },
              loading: () {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              },
              error: (e, s) {
                return const SizedBox.shrink();
              },
            ),
          ),

          // Active Single Match Resume Section
          if (ref.watch(singleMatchProvider).isRunning || 
              ref.watch(singleMatchProvider).homeScore > 0 || 
              ref.watch(singleMatchProvider).awayScore > 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Card(
                  color: Colors.purple.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Colors.purple, width: 1),
                  ),
                  child: InkWell(
                    onTap: () {
                      final match = ref.read(singleMatchProvider);
                      context.pushNamed(
                        'single-match-board',
                        extra: {
                          'homeTeamName': match.homeTeamName,
                          'awayTeamName': match.awayTeamName,
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.sports_basketball, color: Colors.purple, size: 32),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.matchInProgress,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  '${ref.watch(singleMatchProvider).homeTeamName} ${ref.watch(singleMatchProvider).homeScore} - ${ref.watch(singleMatchProvider).awayScore} ${ref.watch(singleMatchProvider).awayTeamName}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.purple),
                        ],
                      ),
                    ),
                  ),
                ).animate().slideY(begin: 1).fadeIn(),
              ),
            ),

          // Quick Actions Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              childAspectRatio: 1.4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildQuickAction(
                  context,
                  icon: Icons.sports_basketball,
                  title: AppLocalizations.of(context)!.singleMatch,
                  subtitle: AppLocalizations.of(context)!.manageSingleMatch,
                  color: Colors.purple,
                  onTap: () => context.go('/single-match-setup'),
                ).animate().fadeIn(delay: 500.ms).scale(),
                _buildQuickAction(
                  context,
                  icon: Icons.emoji_events,
                  title: AppLocalizations.of(context)!.tournaments,
                  subtitle: AppLocalizations.of(context)!.createAndManage,
                  color: Colors.orange,
                  onTap: () => context.go('/tournaments'),
                ).animate().fadeIn(delay: 550.ms).scale(),
                _buildQuickAction(
                  context,
                  icon: Icons.groups,
                  title: AppLocalizations.of(context)!.teams,
                  subtitle: AppLocalizations.of(context)!.manageTeams,
                  color: Colors.blue,
                  onTap: () => context.go('/teams'),
                ).animate().fadeIn(delay: 600.ms).scale(),
                _buildQuickAction(
                  context,
                  icon: Icons.emoji_events,
                  title: AppLocalizations.of(context)!.hallOfFame,
                  subtitle: AppLocalizations.of(context)!.viewWinners,
                  color: Colors.amber,
                  onTap: () => context.go('/stats'),
                ).animate().fadeIn(delay: 650.ms).scale(),
                _buildQuickAction(
                  context,
                  icon: Icons.map,
                  title: AppLocalizations.of(context)!.map,
                  subtitle: AppLocalizations.of(context)!.courtsMap,
                  color: Colors.teal,
                  onTap: () => context.go('/map'),
                ).animate().fadeIn(delay: 700.ms).scale(),
                _buildQuickAction(
                  context,
                  icon: Icons.settings,
                  title: AppLocalizations.of(context)!.settings,
                  subtitle: AppLocalizations.of(context)!.appOptions,
                  color: Colors.grey,
                  onTap: () => context.go('/settings'),
                ).animate().fadeIn(delay: 750.ms).scale(),
                _buildQuickAction(
                  context,
                  icon: Icons.qr_code_scanner,
                  title: AppLocalizations.of(context)!.scanTournament,
                  subtitle: AppLocalizations.of(context)!.syncFromScout,
                  color: Colors.indigo,
                  onTap: () => context.push('/scan'),
                ).animate().fadeIn(delay: 800.ms).scale(),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
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
        borderRadius: BorderRadius.circular(20),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 11,
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

class _CloudTournamentsSlider extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cloudTournamentsAsync = ref.watch(cloudTournamentsProvider);
    final currentFilters = ref.watch(cloudFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            children: [
              Text(
                'LIVE HIGHLIGHTS',
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
              
              // Multi-select Dropdown (PopupMenuButton)
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
                  _buildPopupItem(CloudFilter.inProgress, 'In Corso', currentFilters.contains(CloudFilter.inProgress)),
                  _buildPopupItem(CloudFilter.future, 'Futuri', currentFilters.contains(CloudFilter.future)),
                  _buildPopupItem(CloudFilter.past, 'Passati', currentFilters.contains(CloudFilter.past)),
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
                    'Non ci sono tornei al momento',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ),
              );
            }

            return SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: tournaments.length,
                itemBuilder: (context, index) {
                  final data = tournaments[index];
                  final tournament = data['tournament'] as Map<String, dynamic>;
                  return _CloudTournamentCard(tournament: tournament);
                },
              ),
            );
          },
          loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
          error: (e, s) => const SizedBox.shrink(),
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

  const _CloudTournamentCard({required this.tournament});

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
          // Background Court Texture (simulated with opacity)
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusBadge(tournament),
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
                          (tournament['mode'] as String? ?? 'LEAGUE').replaceAll('_', ' ').toUpperCase(),
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                Text(
                  (tournament['name'] as String).toUpperCase(),
                  maxLines: 2,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        tournament['location'] as String,
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
                  final id = int.tryParse(tournament['id'].toString());
                  if (id != null) {
                    context.pushNamed(
                      'tournament-detail',
                      pathParameters: {'tournamentId': id.toString()},
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Map<String, dynamic> tournament) {
    final isActive = tournament['isActive'] as bool? ?? false;
    final dateVal = tournament['startDate'];
    
    DateTime? startDate;
    if (dateVal is String) {
      startDate = DateTime.tryParse(dateVal);
    } else if (dateVal is int) {
      startDate = DateTime.fromMillisecondsSinceEpoch(dateVal);
    }
    
    final now = DateTime.now();

    String label = 'Prossimamente';
    Color color = Colors.blue;
    IconData icon = Icons.calendar_today;

    if (isActive) {
      label = 'Live';
      color = Colors.green;
      icon = Icons.sensors;
    } else if (startDate != null && startDate.isBefore(now)) {
      label = 'Concluso';
      color = Colors.grey;
      icon = Icons.check_circle_outline;
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
