import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../game/providers/game_provider.dart';
import '../../../../core/database/app_database.dart';

/// A model representing the live state of a match from the cloud
class CloudLiveMatch {
  final String id; // Composite ID: cloudId_matchId
  final int? matchId;
  final int homeScore;
  final int awayScore;
  final String timer;
  final bool isRunning;
  final DateTime lastUpdate;
  final String? homeTeamName;
  final String? awayTeamName;
  final String? phase;
  final int? round;

  CloudLiveMatch({
    required this.id,
    required this.matchId,
    required this.homeScore,
    required this.awayScore,
    required this.timer,
    required this.isRunning,
    required this.lastUpdate,
    this.homeTeamName,
    this.awayTeamName,
    this.phase,
    this.round,
  });

  factory CloudLiveMatch.fromMap(Map<String, dynamic> map) {
    // Extract matchId from composite ID if possible
    int? mId;
    final idParts = map['id'].toString().split('_');
    if (idParts.length > 1) {
      mId = int.tryParse(idParts.last);
    }

    final res = CloudLiveMatch(
      id: map['id'].toString(),
      matchId: mId,
      homeScore: map['home_score'] ?? 0,
      awayScore: map['away_score'] ?? 0,
      timer: map['timer'] ?? '--:--',
      isRunning: map['is_running'] ?? false,
      lastUpdate: DateTime.parse(map['last_update'] ?? DateTime.now().toIso8601String()),
      homeTeamName: map['home_team_name'],
      awayTeamName: map['away_team_name'],
      phase: map['phase'],
      round: map['round'],
    );
    return res;
  }

  bool get isStale => DateTime.now().difference(lastUpdate.toLocal()).inSeconds > 120;
}

/// Provider that streams live matches for a given tournament Cloud ID
final liveMatchesStreamProvider = StreamProvider.autoDispose.family<List<CloudLiveMatch>, String>((ref, cloudId) {
  if (cloudId.isEmpty) return Stream.value([]);
  final supabase = Supabase.instance.client;
  
  // Use case-insensitive matching for cloudId if possible, or just be careful
  final normalizedCloudId = cloudId.trim();
  
  return supabase
      .from('live_matches')
      .stream(primaryKey: ['id'])
      .eq('tournament_id', normalizedCloudId)
      .map((data) {
        return data.map((m) => CloudLiveMatch.fromMap(m)).toList();
      });
});

/// Alias for backward compatibility with stale builds
final tournamentLiveMatchesProvider = liveMatchesStreamProvider;

/// Provider to check if a specific match is currently being managed by someone else
/// Now matches by names/phase to be stable across devices
final isMatchLockedProvider = Provider.autoDispose.family<bool, ({
  String? cloudId, 
  TournamentMatch match, 
  String? homeName, 
  String? awayName
})>((ref, arg) {
  if (arg.cloudId == null) return false;

  // 1. Check if this match is live on our local device
  final activeGame = ref.watch(activeGameProvider);
  if (activeGame.matchId == arg.match.id) return false; // It's us!

  // 2. Check if it's live on the cloud
  final liveMatch = ref.watch(cloudMatchLiveDataProviderV2((
    cloudId: arg.cloudId,
    homeName: arg.homeName,
    awayName: arg.awayName,
    phase: arg.match.phase,
    round: arg.match.round,
  )));

  final isLocked = liveMatch != null && !liveMatch.isStale;
  return isLocked;
});

/// Provider to get the current live score/timer from the cloud for a specific match
/// Now matches by names/phase to be stable across devices
final cloudMatchLiveDataProviderV2 = Provider.autoDispose.family<CloudLiveMatch?, ({
  String? cloudId, 
  String? homeName, 
  String? awayName, 
  String? phase, 
  int? round
})>((ref, arg) {
  if (arg.cloudId == null) return null;

  final liveMatchesAsync = ref.watch(liveMatchesStreamProvider(arg.cloudId!.trim()));
  
  return liveMatchesAsync.when(
    data: (matches) {
      // Find match by STABLE identifier: Team Names + Phase + Round
      final targetHome = arg.homeName?.trim().toLowerCase();
      final targetAway = arg.awayName?.trim().toLowerCase();
      
      if (targetHome == null || targetAway == null) return null;

      final match = matches.where((m) {
        final String? h1 = m.homeTeamName?.trim().toLowerCase();
        final String? a1 = m.awayTeamName?.trim().toLowerCase();
        
        final bool namesMatch = h1 == targetHome && a1 == targetAway;
        if (!namesMatch) return false;
        
        // If names match, check phase/round but ONLY if they are present on both sides
        // If cloud data doesn't have phase/round, we trust the names (legacy/simple sync)
        if (m.phase != null && arg.phase != null && m.phase != arg.phase) return false;
        if (m.round != null && arg.round != null && m.round != arg.round) return false;
        
        return true;
      }).firstOrNull;
      
      return match;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
