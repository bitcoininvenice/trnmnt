import 'package:collection/collection.dart';
import 'package:trnmnt/core/database/app_database.dart';
import '../data/tournaments_repository.dart';
import '../data/matches_repository.dart';
import '../presentation/screens/standings_screen.dart';

class MadnessLogicState {
  final TournamentTeamWithTeam? king;
  final TournamentTeamWithTeam? challenger;
  final List<TournamentTeamWithTeam> queue;

  MadnessLogicState({this.king, this.challenger, required this.queue});
}

class MadnessLogic {
  static MadnessLogicState calculateCurrentState(
    List<TournamentTeamWithTeam> teams, 
    List<MatchWithTeams> matches,
  ) {
    if (teams.length < 2) return MadnessLogicState(queue: []);
    
    List<TournamentTeamWithTeam> queue = List.from(teams);
    TournamentTeamWithTeam? king = queue.removeAt(0);
    TournamentTeamWithTeam? challenger = queue.removeAt(0);

    for (final m in matches) {
      final h = (m.match.homeScore ?? 0) as int;
      final a = (m.match.awayScore ?? 0) as int;

      if (h > a) {
        // King stays
        queue.add(challenger!);
        if (queue.isNotEmpty) challenger = queue.removeAt(0);
        else challenger = null;
      } else if (a > h) {
        // Challenger becomes king
        queue.add(king!);
        king = challenger;
        if (queue.isNotEmpty) challenger = queue.removeAt(0);
        else challenger = null;
      } else {
        // Draw: both leave
        queue.add(king!);
        queue.add(challenger!);
        if (queue.length >= 2) {
          king = queue.removeAt(0);
          challenger = queue.removeAt(0);
        } else if (queue.length == 1) {
          king = queue.removeAt(0);
          challenger = null;
        }
      }
    }

    return MadnessLogicState(king: king, challenger: challenger, queue: queue);
  }

  static List<TournamentTeamWithTeam> getSortedTeams({
    required List<TournamentTeamWithTeam> teams,
    required Tournament? tournament,
    required Map<int, List<StandingEntry>>? standings,
  }) {
    final isReversedFlag = tournament?.customTicker?.contains('[REV_Q]') ?? false;
    final isManualOrder = tournament?.customTicker?.contains('[MANUAL_Q]') ?? false;
    
    // 1. BASE SORT: Always trust the 'seed' (administrative order) first
    List<TournamentTeamWithTeam> sortedTeams = List.from(teams);
    sortedTeams.sort((a, b) => (a.tournamentTeam.seed ?? 0).compareTo(b.tournamentTeam.seed ?? 0));
    List<TournamentTeamWithTeam> finalTeams;

    if (tournament?.mode == 'league_madness' && standings != null && standings.isNotEmpty && !isManualOrder) {
      final allStandings = standings.values.expand((e) => e).toList();
      
      // Sort standings exactly like the dashboard
      allStandings.sort((a, b) {
        final pointsComp = b.classificationPoints.compareTo(a.classificationPoints);
        if (pointsComp != 0) return pointsComp;
        final diffComp = (b.pointsFor - b.pointsAgainst).compareTo(a.pointsFor - a.pointsAgainst);
        if (diffComp != 0) return diffComp;
        final pointsForComp = b.pointsFor.compareTo(a.pointsFor);
        if (pointsForComp != 0) return pointsForComp;
        
        // TIE-BREAKER: Use the administrative seed from the tournament_teams table
        final teamA = teams.firstWhereOrNull((t) => t.team.id == a.teamId);
        final teamB = teams.firstWhereOrNull((t) => t.team.id == b.teamId);
        final seedA = teamA?.tournamentTeam.seed ?? 0;
        final seedB = teamB?.tournamentTeam.seed ?? 0;
        return seedA.compareTo(seedB);
      });

      // Map back to our rich objects preserving the standings order
      finalTeams = allStandings.map((s) {
        return teams.firstWhere((t) => t.team.id == s.teamId);
      }).toList();
    } else {
      // Pure Madness or Manual Order: use the base sorted list (by seed)
      finalTeams = sortedTeams;
    }

    // IMPORTANT: If order is MANUAL, we don't apply reversal because the manual seeds already represent the desired order
    if (isManualOrder) return finalTeams;
    
    return isReversedFlag ? finalTeams.reversed.toList() : finalTeams;
  }
}
