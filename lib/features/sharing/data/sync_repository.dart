import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trnmnt/core/database/app_database.dart';
import 'package:trnmnt/core/providers/database_provider.dart';

class SyncRepository {
  final AppDatabase _db;
  RealtimeChannel? _subscription;
  bool _isSyncBlocked = false;

  SyncRepository(this._db);

  /// Blocks cloud updates from overwriting local data (used during admin saves)
  void blockSync() => _isSyncBlocked = true;
  
  /// Unblocks cloud updates
  void unblockSync() => _isSyncBlocked = false;

  /// Subscribes to realtime updates for a specific tournament on Supabase
  Future<void> subscribeToTournament(String cloudId, int tournamentId) async {
    _subscription?.unsubscribe();
    
    final supabase = Supabase.instance.client;
    
    // First, immediately fetch the latest data since our local DB is just a stub
    try {
      final response = await supabase
          .from('published_tournaments')
          .select('data, description')
          .eq('id', cloudId)
          .maybeSingle();


      if (response != null && response['data'] != null) {
        await _handleCloudUpdate(tournamentId, response['data'] as Map<String, dynamic>, description: response['description'] as String?);
      }
    } catch (e) {
      // Ignore errors, realtime will handle it if possible
    }

    // Then subscribe for future changes
    _subscription = supabase
        .channel('tournament_sync_$cloudId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'published_tournaments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: cloudId,
          ),
          callback: (payload) {
            final data = payload.newRecord['data'] as Map<String, dynamic>?;
            final description = payload.newRecord['description'] as String?;
            if (data != null) {
              _handleCloudUpdate(tournamentId, data, description: description);
            }
          },
        )
        .subscribe();
  }

  void unsubscribe() {
    _subscription?.unsubscribe();
    _subscription = null;
  }

  Future<void> _handleCloudUpdate(int tournamentId, Map<String, dynamic> data, {String? description}) async {
    if (_isSyncBlocked) {
      return;
    }
    final tournamentData = data['tournament'] as Map<String, dynamic>?;
    final teamsData = data['teams'] as List<dynamic>?;
    final matchesData = data['matches'] as List<dynamic>?;
    
    if (tournamentData == null || teamsData == null || matchesData == null) {
      return;
    }


    // 1. Update general tournament info
    await (_db.update(_db.tournaments)..where((t) => t.id.equals(tournamentId))).write(
      TournamentsCompanion(
        name: Value(tournamentData['name']),
        location: Value(tournamentData['location']),
        mode: Value(tournamentData['mode']),
        startDate: Value(tournamentData['startDate'] != null ? DateTime.tryParse(tournamentData['startDate']) : null),
        endDate: Value(tournamentData['endDate'] != null ? DateTime.tryParse(tournamentData['endDate']) : null),
        description: Value(description ?? tournamentData['description']),
        venueCourtId: Value(tournamentData['venue_court_id'] ?? tournamentData['venueCourtId']),
        scoringSystem: Value(tournamentData['scoringSystem']),
        winPoints: Value(tournamentData['winPoints'] ?? 2),
        drawPoints: Value(tournamentData['drawPoints'] ?? 0),
        lossPoints: Value(tournamentData['lossPoints'] ?? 1),
        timerMinutes: Value(tournamentData['timerMinutes'] ?? 10),
        isActive: Value(tournamentData['isActive'] ?? true),
        twitchChannel: Value(tournamentData['twitchChannel']),
        youtubeVideoId: Value(tournamentData['youtubeVideoId']),
        customTicker: Value(tournamentData['customTicker']),
        groupCount: Value(tournamentData['groupCount'] ?? 1),
      ),
    );

    // 2. Map Teams by NAME (safer than IDs which diverge between devices)
    final Map<int, int> teamMapping = {}; // { RemoteId : LocalId }
    
    for (final teamJson in teamsData) {
      final remoteId = teamJson['id'] as int;
      final teamName = teamJson['name'] as String;
      
      // Check if team exists globally by name (use limit(1) to avoid Bad State if duplicates exist)
      final existingTeams = await (_db.select(_db.teams)
            ..where((t) => t.name.equals(teamName))
            ..limit(1))
          .get();
      final existingTeam = existingTeams.firstOrNull;
      
      int localTeamId;
      if (existingTeam != null) {
        localTeamId = existingTeam.id;
      } else {
        localTeamId = await _db.into(_db.teams).insert(
          TeamsCompanion.insert(
            name: teamName,
            logoPath: Value(teamJson['logoPath']),
          )
        );
      }

      // Link it to the tournament (using insertOnConflictUpdate to avoid duplicate link errors)
      await _db.into(_db.tournamentTeams).insertOnConflictUpdate(
        TournamentTeamsCompanion.insert(
          tournamentId: tournamentId,
          teamId: localTeamId,
          groupNumber: Value(teamJson['groupNumber'] ?? 1),
        )
      );

      teamMapping[remoteId] = localTeamId;
    }

    // 3. Smart Matches Sync (Preserving IDs to avoid UI breakage)
    // We map local matches by a stable key: "phase_round_home_away"
    final localMatches = await (_db.select(_db.matches)
      ..where((m) => m.tournamentId.equals(tournamentId))).get();
    
    final Map<String, int> localMatchesMapByTeams = {
      for (var m in localMatches) 
        if (m.homeTeamId != null && m.awayTeamId != null)
          '${m.phase}_${m.round}_${m.homeTeamId}_${m.awayTeamId}': m.id
    };

    // Store indices of matches we've already synced to avoid duplicate inserts
    final List<int> processedLocalIds = [];

    await _db.batch((batch) {
      for (final m in matchesData) {
        final homeRemoteId = m['homeTeamId'] as int?;
        final awayRemoteId = m['awayTeamId'] as int?;
        
        final localHomeId = homeRemoteId != null ? teamMapping[homeRemoteId] : null;
        final localAwayId = awayRemoteId != null ? teamMapping[awayRemoteId] : null;
        
        // 3.1 Try to find match by TEAMS first (stable across devices)
        int? existingId;
        if (localHomeId != null && localAwayId != null) {
          final String teamsKey = '${m['phase'] ?? 'group'}_${m['round'] ?? 1}_${localHomeId}_${localAwayId}';
          existingId = localMatchesMapByTeams[teamsKey];
        }

        // 3.2 If not found by teams and we are in bracket/knockout, 
        // fallback to Index-based matching if the local list size matches
        if (existingId == null) {
          final int? rIndex = m['remoteIndex'] as int?;
          if (rIndex != null && rIndex < localMatches.length) {
            existingId = localMatches[rIndex].id;
          }
        }

        if (existingId != null) {
          processedLocalIds.add(existingId);
          
          final localMatch = localMatches.firstWhere((lm) => lm.id == existingId);
          final bool remoteCompleted = m['isCompleted'] ?? false;
          final int remoteHomeScore = m['homeScore'] ?? 0;
          final int remoteAwayScore = m['awayScore'] ?? 0;

          // SMART SCORE UPDATE LOGIC:
          // 1. If remote is completed, cloud result is final and should win if different
          // 2. If both are live, take remote if local is 0-0 or if remote actually changed
          bool shouldUpdateScores = false;
          if (remoteCompleted) {
            if (localMatch.homeScore != remoteHomeScore || 
                localMatch.awayScore != remoteAwayScore || 
                !localMatch.isCompleted) {
              shouldUpdateScores = true;
            }
          } else if (!localMatch.isCompleted) {
            // Both are live: update if local is empty or if remote has a new score
            if ((localMatch.homeScore == 0 && localMatch.awayScore == 0) ||
                (remoteHomeScore != localMatch.homeScore || remoteAwayScore != localMatch.awayScore)) {
              shouldUpdateScores = true;
            }
          }

          batch.update(
            _db.matches,
            MatchesCompanion(
              homeScore: shouldUpdateScores ? Value(remoteHomeScore) : const Value.absent(),
              awayScore: shouldUpdateScores ? Value(remoteAwayScore) : const Value.absent(),
              isCompleted: Value(remoteCompleted),
              isBye: Value(m['isBye'] ?? false),
              scheduledAt: Value(m['scheduledAt'] != null 
                  ? DateTime.tryParse(m['scheduledAt'].toString()) 
                  : null),
            ),
            where: (row) => row.id.equals(existingId!),
          );
        } else {
          // INSERT new match
          batch.insert(
            _db.matches,
            MatchesCompanion.insert(
              tournamentId: tournamentId,
              homeTeamId: Value(localHomeId),
              awayTeamId: Value(localAwayId),
              homeScore: Value(m['homeScore']),
              awayScore: Value(m['awayScore']),
              round: Value(m['round'] ?? 1),
              phase: Value(m['phase'] ?? 'group'),
              groupNumber: Value(m['groupNumber'] ?? 1),
              isCompleted: Value(m['isCompleted'] ?? false),
              isBye: Value(m['isBye'] ?? false),
              scheduledAt: Value(m['scheduledAt'] != null 
                  ? DateTime.tryParse(m['scheduledAt'].toString()) 
                  : null),
            ),
          );
        }
      }

      // 4. Pruning: Delete matches that are no longer in the cloud
      // We only delete IDs that WERE here locally but were not found in the cloud bundle
      final originalLocalIds = localMatches.map((lm) => lm.id).toList();
      final idsToRemove = originalLocalIds.where((id) => !processedLocalIds.contains(id)).toList();
      
      if (idsToRemove.isNotEmpty) {
        batch.deleteWhere(_db.matches, (t) => t.id.isIn(idsToRemove));
      }
    });
  }
}

final syncRepositoryProvider = Provider((ref) {
  final db = ref.watch(dbProvider);
  return SyncRepository(db);
});
