import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';

/// Main shell with bottom navigation
class MainShell extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.orangeAccent.shade700],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.sports_basketball, size: 50, color: Colors.white),
                    const SizedBox(height: 12),
                    Text(
                      l10n.appTitle,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      l10n.appSubtitle,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
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
