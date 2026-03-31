import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import 'package:trnmnt/core/providers/icon_provider.dart';
import 'package:trnmnt/features/stats/presentation/widgets/stats_overview.dart';
import 'package:trnmnt/features/stats/data/stats_repository.dart';
import 'dart:io';

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

          // Stats Section (Concept 2 integration)
          SliverToBoxAdapter(
            child: statsAsync.when(
              data: (stats) {
                print('Home: Stats loaded successfully');
                return StatsOverviewWidget(stats: stats);
              },
              loading: () {
                print('Home: Stats still loading...');
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              },
              error: (e, s) {
                print('Home: Stats error = $e');
                return const SizedBox.shrink();
              },
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
