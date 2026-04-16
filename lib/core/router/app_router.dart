import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/teams/presentation/screens/teams_screen.dart';
import '../../features/teams/presentation/screens/team_form_screen.dart';
import '../../features/tournaments/presentation/screens/tournaments_screen.dart';
import '../../features/tournaments/presentation/screens/tournament_setup_screen.dart';
import '../../features/tournaments/presentation/screens/tournament_edit_screen.dart';
import '../../features/tournaments/presentation/screens/tournament_detail_screen.dart';
import '../../features/tournaments/presentation/screens/calendar_screen.dart';
import '../../features/tournaments/presentation/screens/standings_screen.dart';
import '../../features/tournaments/presentation/screens/bracket_screen.dart';
import '../../features/tournaments/presentation/screens/match_screen.dart';
import '../../features/tournaments/presentation/screens/madness_screen.dart';
import '../../features/timer/presentation/screens/timer_screen.dart';
import '../../features/single_match/presentation/screens/single_match_setup_screen.dart';
import '../../features/map/presentation/screens/map_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/mode_legend_screen.dart';
import '../../features/settings/presentation/screens/mode_detail_screen.dart';
import '../../features/stats/presentation/screens/hall_of_fame_screen.dart';
import '../../features/sharing/presentation/screens/share_tournament_screen.dart';
import '../../features/sharing/presentation/screens/scan_tournament_screen.dart';
import '../../features/community/presentation/screens/community_dashboard_screen.dart';
import '../../features/community/presentation/screens/join_community_screen.dart';
import '../../features/tournaments/presentation/screens/registration_management_screen.dart';
import '../shell/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/teams',
            name: 'teams',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TeamsScreen(),
            ),
            routes: [
              GoRoute(
                path: 'new',
                name: 'team-new',
                builder: (context, state) => const TeamFormScreen(),
              ),
              GoRoute(
                path: 'edit/:teamId',
                name: 'team-edit',
                builder: (context, state) {
                  final teamId = int.parse(state.pathParameters['teamId']!);
                  return TeamFormScreen(teamId: teamId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/tournaments',
            name: 'tournaments',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TournamentsScreen(),
            ),
            routes: [
              GoRoute(
                path: 'new',
                name: 'tournament-new',
                builder: (context, state) => const TournamentSetupScreen(),
              ),
              GoRoute(
                path: ':tournamentId',
                name: 'tournament-detail',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['tournamentId']!);
                  return TournamentDetailScreen(tournamentId: id);
                },
                routes: [
                  GoRoute(
                    path: 'calendar',
                    name: 'tournament-calendar',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['tournamentId']!);
                      return CalendarScreen(tournamentId: id);
                    },
                  ),
                  GoRoute(
                    path: 'standings',
                    name: 'tournament-standings',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['tournamentId']!);
                      return StandingsScreen(tournamentId: id);
                    },
                  ),
                  GoRoute(
                    path: 'bracket',
                    name: 'tournament-bracket',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['tournamentId']!);
                      return BracketScreen(tournamentId: id);
                    },
                  ),
                  GoRoute(
                    path: 'match/:matchId',
                    name: 'match-detail',
                    builder: (context, state) {
                      final matchId = int.parse(state.pathParameters['matchId']!);
                      return MatchScreen(matchId: matchId);
                    },
                  ),
                  GoRoute(
                    path: 'madness',
                    name: 'tournament-madness',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['tournamentId']!);
                      return MadnessScreen(tournamentId: id);
                    },
                  ),
                  GoRoute(
                    path: 'edit',
                    name: 'tournament-edit',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['tournamentId']!);
                      return TournamentEditScreen(tournamentId: id);
                    },
                  ),
                  GoRoute(
                    path: 'registrations',
                    name: 'tournament-registrations',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['tournamentId']!);
                      final cloudId = state.uri.queryParameters['cloudId']!;
                      return RegistrationManagementScreen(tournamentId: id, cloudId: cloudId);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/timer',
            name: 'timer',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TimerScreen(),
            ),
          ),
          GoRoute(
            path: '/single-match-setup',
            name: 'single-match-setup',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SingleMatchSetupScreen(),
            ),
          ),
          GoRoute(
            path: '/single-match-board',
            name: 'single-match-board',
            builder: (context, state) => const MatchScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
            routes: [
              GoRoute(
                path: 'legend',
                builder: (context, state) => const ModeLegendScreen(),
                routes: [
                  GoRoute(
                    path: ':modeId',
                    builder: (context, state) {
                      final modeId = state.pathParameters['modeId']!;
                      return ModeDetailScreen(modeId: modeId);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/map',
            name: 'map',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MapScreen(),
            ),
          ),
          GoRoute(
            path: '/stats',
            name: 'hall-of-fame',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HallOfFameScreen(),
            ),
          ),
          GoRoute(
            path: '/share/:tournamentId',
            name: 'tournament-share',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['tournamentId']!);
              final name = state.uri.queryParameters['name'] ?? 'Tournament';
              return ShareTournamentScreen(tournamentId: id, tournamentName: name);
            },
          ),
          GoRoute(
            path: '/scan',
            name: 'tournament-scan',
            builder: (context, state) => const ScanTournamentScreen(),
          ),
          GoRoute(
            path: '/community',
            name: 'community',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CommunityDashboardScreen(),
            ),
            routes: [
              GoRoute(
                path: 'join',
                name: 'community-join',
                builder: (context, state) => const JoinCommunityScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
