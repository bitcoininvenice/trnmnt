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
    return Scaffold(
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
            label: AppLocalizations.of(context)!.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.groups_outlined),
            selectedIcon: const Icon(Icons.groups),
            label: AppLocalizations.of(context)!.navTeams,
          ),
          NavigationDestination(
            icon: const Icon(Icons.emoji_events_outlined),
            selectedIcon: const Icon(Icons.emoji_events),
            label: AppLocalizations.of(context)!.navTournaments,
          ),
          NavigationDestination(
            icon: const Icon(Icons.timer_outlined),
            selectedIcon: const Icon(Icons.timer),
            label: AppLocalizations.of(context)!.navTimer,
          ),
        ],
      ),
    );
  }
}
