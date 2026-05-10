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
    // Resolve venue court if present (Cloud stores UUID, Local stores Int ID)
    int? localVenueCourtId;
    final remoteVenueId = tournamentData['venue_court_id'] ?? tournamentData['venueCourtId'];
    if (remoteVenueId != null) {
      if (remoteVenueId is int) {
        localVenueCourtId = remoteVenueId;
      } else if (remoteVenueId is String) {
        final court = await (_db.select(_db.courts)..where((c) => c.cloudId.equals(remoteVenueId))).getSingleOrNull();
        localVenueCourtId = court?.id;
      }
    }

    await (_db.update(_db.tournaments)..where((t) => t.id.equals(tournamentId))).write(
      TournamentsCompanion(
        name: Value((tournamentData['name'] ?? tournamentData['name'])?.toString() ?? ''),
        location: Value((tournamentData['location'] ?? tournamentData['location'])?.toString() ?? ''),
        mode: Value((tournamentData['mode'] ?? tournamentData['mode'])?.toString() ?? 'group_only'),
        startDate: Value(_parseDateTime(tournamentData['startDate'] ?? tournamentData['start_date'])),
        endDate: Value(_parseDateTime(tournamentData['endDate'] ?? tournamentData['end_date'])),
        description: Value((description ?? tournamentData['description'] ?? tournamentData['description'])?.toString()),
        venueCourtId: Value(localVenueCourtId),
        scoringSystem: Value((tournamentData['scoringSystem'] ?? tournamentData['scoring_system'])?.toString() ?? 'standard'),
        winPoints: Value(int.tryParse((tournamentData['winPoints'] ?? tournamentData['win_points'])?.toString() ?? '') ?? 3),
        drawPoints: Value(int.tryParse((tournamentData['drawPoints'] ?? tournamentData['draw_points'])?.toString() ?? '') ?? 1),
        lossPoints: Value(int.tryParse((tournamentData['lossPoints'] ?? tournamentData['loss_points'])?.toString() ?? '') ?? 0),
        timerMinutes: Value(int.tryParse((tournamentData['timerMinutes'] ?? tournamentData['timer_minutes'])?.toString() ?? '') ?? 10),
        isActive: Value(tournamentData['isActive'] != false && tournamentData['is_active'] != false),
        twitchChannel: Value((tournamentData['twitchChannel'] ?? tournamentData['twitch_channel'])?.toString()),
        youtubeVideoId: Value((tournamentData['youtubeVideoId'] ?? tournamentData['youtube_video_id'])?.toString()),
        customTicker: Value((tournamentData['customTicker'] ?? tournamentData['custom_ticker'])?.toString()),
        groupCount: Value(int.tryParse((tournamentData['groupCount'] ?? tournamentData['group_count'])?.toString() ?? '') ?? 1),
      ),
    );

    // 2. Map Teams by NAME (safer than IDs which diverge between devices)
    final Map<int, int> teamMapping = {}; // { RemoteId : LocalId }
    
    for (final teamJson in teamsData) {
      final remoteId = int.tryParse(teamJson['id']?.toString() ?? '') ?? 0;
      final teamName = (teamJson['name'] ?? teamJson['name'])?.toString() ?? 'Squadra';
      
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
            logoPath: Value((teamJson['logoPath'] ?? teamJson['logo_path'])?.toString()),
          )
        );
      }

      // Link it to the tournament (using insertOnConflictUpdate to avoid duplicate link errors)
      await _db.into(_db.tournamentTeams).insertOnConflictUpdate(
        TournamentTeamsCompanion.insert(
          tournamentId: tournamentId,
          teamId: localTeamId,
          groupNumber: Value(int.tryParse((teamJson['groupNumber'] ?? teamJson['group_number'])?.toString() ?? '') ?? 1),
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
        final homeRemoteId = int.tryParse((m['homeTeamId'] ?? m['home_team_id'])?.toString() ?? '');
        final awayRemoteId = int.tryParse((m['awayTeamId'] ?? m['away_team_id'])?.toString() ?? '');
        
        final localHomeId = homeRemoteId != null ? teamMapping[homeRemoteId] : null;
        final localAwayId = awayRemoteId != null ? teamMapping[awayRemoteId] : null;
        
        // 3.1 Try to find match by TEAMS first (stable across devices)
        int? existingId;
        if (localHomeId != null && localAwayId != null) {
          final String teamsKey = '${(m['phase'] ?? m['phase'])?.toString() ?? 'group'}_${int.tryParse((m['round'] ?? m['round'])?.toString() ?? '') ?? 1}_${localHomeId}_${localAwayId}';
          existingId = localMatchesMapByTeams[teamsKey];
        }

        // 3.2 If not found by teams and we are in bracket/knockout, 
        // fallback to Index-based matching if the local list size matches
        if (existingId == null) {
          final int? rIndex = int.tryParse((m['remoteIndex'] ?? m['remote_index'])?.toString() ?? '');
          if (rIndex != null && rIndex < localMatches.length) {
            existingId = localMatches[rIndex].id;
          }
        }

        if (existingId != null) {
          processedLocalIds.add(existingId);
          
          final localMatch = localMatches.firstWhere((lm) => lm.id == existingId);
          final bool remoteCompleted = m['isCompleted'] == true || m['is_completed'] == true;
          final int remoteHomeScore = int.tryParse((m['homeScore'] ?? m['home_score'])?.toString() ?? '') ?? 0;
          final int remoteAwayScore = int.tryParse((m['awayScore'] ?? m['away_score'])?.toString() ?? '') ?? 0;

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
              isBye: Value(m['isBye'] == true || m['is_bye'] == true),
              scheduledAt: Value(_parseDateTime(m['scheduledAt'] ?? m['scheduled_at'])),
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
              homeScore: Value(int.tryParse((m['homeScore'] ?? m['home_score'])?.toString() ?? '')),
              awayScore: Value(int.tryParse((m['awayScore'] ?? m['away_score'])?.toString() ?? '')),
              round: Value(int.tryParse((m['round'] ?? m['round'])?.toString() ?? '') ?? 1),
              phase: Value((m['phase'] ?? m['phase'])?.toString() ?? 'group'),
              groupNumber: Value(int.tryParse((m['groupNumber'] ?? m['group_number'])?.toString() ?? '') ?? 1),
              isCompleted: Value(m['isCompleted'] == true || m['is_completed'] == true),
              isBye: Value(m['isBye'] == true || m['is_bye'] == true),
              scheduledAt: Value(_parseDateTime(m['scheduledAt'] ?? m['scheduled_at'])),
            ),
          );
        }
      }

      // 4. Pruning: Delete matches that are no longer in the cloud
      final originalLocalIds = localMatches.map((lm) => lm.id).toList();
      final idsToRemove = originalLocalIds.where((id) => !processedLocalIds.contains(id)).toList();
      
      if (idsToRemove.isNotEmpty) {
        batch.deleteWhere(_db.matches, (t) => t.id.isIn(idsToRemove));
      }
    });
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.tryParse(value.toString());
  }
}

final syncRepositoryProvider = Provider((ref) {
  final db = ref.watch(dbProvider);
  return SyncRepository(db);
});
