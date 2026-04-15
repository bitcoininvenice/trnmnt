import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import 'package:trnmnt/core/providers/icon_provider.dart';
import 'package:trnmnt/features/community/data/community_repository.dart';

/// Main shell with bottom navigation
class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/teams')) return 1;
    if (location.startsWith('/tournaments')) return 2;
    if (location.startsWith('/timer')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final customIconPath = ref.watch(customIconProvider);
    final currentCommunity = ref.watch(currentCommunityProvider).valueOrNull;
    
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 24, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.orange, Colors.orangeAccent.shade700],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: customIconPath != null
                        ? Image.file(File(customIconPath), fit: BoxFit.cover)
                        : Image.asset(
                            'assets/icon/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(
                              Icons.sports_basketball,
                              size: 32,
                              color: Colors.orange,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.appTitle,
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 22, 
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    l10n.appSubtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8), 
                      fontSize: 11,
                    ),
                  ),
                  if (currentCommunity != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.hub_outlined, size: 10, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            currentCommunity.name.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.hub_outlined, color: Colors.orange),
              title: Text(l10n.myCommunity),
              subtitle: Text(l10n.manageBrandsLogos),
              onTap: () {
                Navigator.pop(context);
                context.push('/community');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.emoji_events_outlined),
              title: Text(l10n.tournaments),
              onTap: () {
                Navigator.pop(context);
                context.push('/tournaments');
              },
            ),
            ListTile(
              leading: const Icon(Icons.groups_outlined),
              title: Text(l10n.teams),
              onTap: () {
                Navigator.pop(context);
                context.push('/teams');
              },
            ),
            ListTile(
              leading: const Icon(Icons.sports_basketball_outlined),
              title: Text(l10n.singleMatch),
              onTap: () {
                Navigator.pop(context);
                context.push('/single-match-setup');
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: Text(l10n.scanTournament),
              onTap: () {
                Navigator.pop(context);
                context.push('/scan');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.military_tech_outlined),
              title: Text(l10n.hallOfFame),
              onTap: () {
                Navigator.pop(context);
                context.push('/stats');
              },
            ),
            ListTile(
              leading: const Icon(Icons.map_outlined),
              title: Text(l10n.map),
              onTap: () {
                Navigator.pop(context);
                context.push('/map');
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(l10n.settings),
              onTap: () {
                Navigator.pop(context);
                context.push('/settings');
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/teams');
              break;
            case 2:
              context.go('/tournaments');
              break;
            case 3:
              context.go('/timer');
              break;
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.groups_outlined),
            selectedIcon: const Icon(Icons.groups),
            label: l10n.navTeams,
          ),
          NavigationDestination(
            icon: const Icon(Icons.emoji_events_outlined),
            selectedIcon: const Icon(Icons.emoji_events),
            label: l10n.navTournaments,
          ),
          NavigationDestination(
            icon: const Icon(Icons.timer_outlined),
            selectedIcon: const Icon(Icons.timer),
            label: l10n.navTimer,
          ),
        ],
      ),
    );
  }
}
