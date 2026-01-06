import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/teams/presentation/screens/teams_screen.dart';
import '../../features/teams/presentation/screens/team_form_screen.dart';
import '../../features/tournaments/presentation/screens/tournaments_screen.dart';
import '../../features/tournaments/presentation/screens/tournament_setup_screen.dart';
import '../../features/tournaments/presentation/screens/tournament_detail_screen.dart';
import '../../features/tournaments/presentation/screens/calendar_screen.dart';
import '../../features/tournaments/presentation/screens/standings_screen.dart';
import '../../features/tournaments/presentation/screens/bracket_screen.dart';
import '../../features/tournaments/presentation/screens/match_screen.dart';
import '../../features/timer/presentation/screens/timer_screen.dart';
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
        ],
      ),
    ],
  );
});
