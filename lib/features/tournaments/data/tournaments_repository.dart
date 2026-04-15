import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for all tournaments
final tournamentsProvider = StreamProvider<List<Tournament>>((ref) async* {
  final db = ref.watch(dbProvider);
  yield* (db.select(db.tournaments)
    ..orderBy([(t) => OrderingTerm.desc(t.startDate), (t) => OrderingTerm.desc(t.createdAt)]))
    .watch();
});

enum CloudFilter { past, inProgress, future }

final cloudFilterProvider = StateProvider<Set<CloudFilter>>((ref) => {CloudFilter.inProgress});

/// Provider for global/cloud published tournaments from Supabase
final cloudTournamentsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final supabase = Supabase.instance.client;
  final activeFilters = ref.watch(cloudFilterProvider);
  
  return supabase.from('published_tournaments')
    .stream(primaryKey: ['id'])
    .order('last_updated', ascending: false)
    .map((data) {
      final now = DateTime.now();
      
      final List<Map<String, dynamic>> allTournaments = [];
      for (final item in data) {
        try {
          final tournamentData = item['data'] as Map<String, dynamic>?;
          if (tournamentData != null) {
            // CRITICAL: Merge DB metadata into the map so UI can access it
            tournamentData['id'] = item['id'];
            tournamentData['community_slug'] = item['community_slug'];
            tournamentData['community_id'] = item['community_id'];
            
            allTournaments.add(tournamentData);
          }
        } catch (_) {
          // Skip invalid items
        }
      }

      // Sort ALL tournaments by startDate (Newest first)
      allTournaments.sort((a, b) {
        final tA = a['tournament'] as Map<String, dynamic>?;
        final tB = b['tournament'] as Map<String, dynamic>?;
        
        DateTime parseDate(dynamic val) {
          if (val is String) return DateTime.tryParse(val) ?? DateTime(1970);
          if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
          return DateTime(1970);
        }

        final dateA = parseDate(tA?['startDate']);
        final dateB = parseDate(tB?['startDate']);
        return dateB.compareTo(dateA); // Descending (Newer first)
      });

      List<Map<String, dynamic>> filterData(Set<CloudFilter> filters) {
        return allTournaments.where((data) {
          try {
            final t = data['tournament'] as Map<String, dynamic>?;
            if (t == null) return false;
            
            final startDateVal = t['startDate'];
            DateTime? startDate;
            if (startDateVal is String) {
              startDate = DateTime.tryParse(startDateVal);
            } else if (startDateVal is int) {
              // Drift JSON can sometimes serialize DateTime as int (ms)
              startDate = DateTime.fromMillisecondsSinceEpoch(startDateVal);
            }
            
            final isActive = t['isActive'] as bool? ?? false;

            if (filters.contains(CloudFilter.past) && !isActive && (startDate != null && startDate.isBefore(now))) return true;
            if (filters.contains(CloudFilter.inProgress) && isActive) return true;
            if (filters.contains(CloudFilter.future) && !isActive && (startDate != null && startDate.isAfter(now))) return true;
          } catch (_) {
            // Silently handle format errors
          }
          return false;
        }).take(3).toList();
      }

      // 1. Try with user selected filters
      var result = filterData(activeFilters);
      if (result.isNotEmpty) return result;

      // 2. Fallback logic: if empty, try to find ANY active tournament first (Live)
      final liveFallback = filterData({CloudFilter.inProgress});
      if (liveFallback.isNotEmpty) return liveFallback;

      // 3. Then try Future
      final futureFallback = filterData({CloudFilter.future});
      if (futureFallback.isNotEmpty) return futureFallback;
      
      // 4. Finally try Past
      final pastFallback = filterData({CloudFilter.past});
      if (pastFallback.isNotEmpty) return pastFallback;

      // 5. If REALLY empty, but cloud has data, return the first 3 regardless of filtering
      if (allTournaments.isNotEmpty) {
        return allTournaments.take(3).toList();
      }

      return [];
    });
});

/// Providers for filtering
final tournamentSearchQueryProvider = StateProvider<String>((ref) => '');
final tournamentModeFilterProvider = StateProvider<String?>((ref) => null);
final tournamentStatusFilterProvider = StateProvider<String>((ref) => 'all'); // Default to local as requested

/// Provider for filtered tournaments
final filteredTournamentsProvider = Provider<AsyncValue<List<Tournament>>>((ref) {
  final tournamentsAsync = ref.watch(tournamentsProvider);
  final searchQuery = ref.watch(tournamentSearchQueryProvider).toLowerCase();
  final modeFilter = ref.watch(tournamentModeFilterProvider);
  final statusFilter = ref.watch(tournamentStatusFilterProvider);

  return tournamentsAsync.whenData((tournaments) {
    final list = tournaments.where((t) {
      final matchesSearch = t.name.toLowerCase().contains(searchQuery) || 
                           t.location.toLowerCase().contains(searchQuery);
      final matchesMode = modeFilter == null || t.mode == modeFilter;
      
      bool matchesStatus = true;
      if (statusFilter == 'local') matchesStatus = !t.isPublished;
      if (statusFilter == 'cloud') matchesStatus = t.isPublished;

      return matchesSearch && matchesMode && matchesStatus;
    }).toList();

    // Secondary explicit sort to be absolutely sure (Newest first)
    list.sort((a, b) {
      final dateA = a.startDate ?? a.createdAt;
      final dateB = b.startDate ?? b.createdAt;
      return dateB.compareTo(dateA); 
    });
    
    return list;
  });
});

/// Provider for a single tournament by ID
final tournamentByIdProvider = StreamProvider.family<Tournament?, int>((ref, id) {
  final db = ref.watch(dbProvider);
  return (db.select(db.tournaments)..where((t) => t.id.equals(id)))
      .watchSingleOrNull();
});

/// Provider for teams in a tournament
final tournamentTeamsProvider = StreamProvider.family<List<TournamentTeamWithTeam>, int>((ref, tournamentId) {
  final db = ref.watch(dbProvider);
  final query = db.select(db.tournamentTeams).join([
    innerJoin(db.teams, db.teams.id.equalsExp(db.tournamentTeams.teamId)),
  ])..where(db.tournamentTeams.tournamentId.equals(tournamentId))
    ..orderBy([OrderingTerm.asc(db.tournamentTeams.seed)]);
  
  return query.watch().map((rows) => rows.map((row) {
    return TournamentTeamWithTeam(
      tournamentTeam: row.readTable(db.tournamentTeams),
      team: row.readTable(db.teams),
    );
  }).toList());
});

/// Combined data class for tournament team with team info
class TournamentTeamWithTeam {
  final TournamentTeam tournamentTeam;
  final Team team;

  TournamentTeamWithTeam({required this.tournamentTeam, required this.team});
}

/// Tournaments repository for CRUD operations
class TournamentsRepository {
  final AppDatabase _db;

  TournamentsRepository(this._db);

  Future<int> createTournament({
    required String name,
    required String location,
    required String mode,
    required String scoringSystem,
    DateTime? startDate,
    int winPoints = 2,
    int drawPoints = 0,
    int lossPoints = 1,
    bool includeConsolationFinals = false,
    int timerMinutes = 10,
    int groupCount = 1,
    int qualifiersPerGroup = 2,
    bool hasPlayIn = false,
    String? groupNames,
    String? twitchChannel,
    String? communityId,
  }) async {
    return await _db.into(_db.tournaments).insert(
      TournamentsCompanion.insert(
        name: name,
        location: location,
        mode: Value(mode),
        scoringSystem: Value(scoringSystem),
        winPoints: Value(winPoints),
        drawPoints: Value(drawPoints),
        lossPoints: Value(lossPoints),
        includeConsolationFinals: Value(includeConsolationFinals),
        timerMinutes: Value(timerMinutes),
        startDate: Value(startDate ?? DateTime.now()),
        groupCount: Value(groupCount),
        qualifiersPerGroup: Value(qualifiersPerGroup),
        hasPlayIn: Value(hasPlayIn),
        groupNames: Value(groupNames),
        twitchChannel: Value(twitchChannel),
        communityId: Value(communityId),
      ),
    );
  }

  Future<bool> updateTournament({
    required int id,
    String? name,
    String? location,
    String? mode,
    String? scoringSystem,
    int? winPoints,
    int? drawPoints,
    int? lossPoints,
    bool? includeConsolationFinals,
    int? timerMinutes,
    bool? isActive,
    DateTime? startDate,
    int? groupCount,
    int? qualifiersPerGroup,
    bool? hasPlayIn,
    String? groupNames,
    String? twitchChannel,
    String? customTicker,
  }) async {
    return await (_db.update(_db.tournaments)..where((t) => t.id.equals(id))).write(
      TournamentsCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        location: location != null ? Value(location) : const Value.absent(),
        mode: mode != null ? Value(mode) : const Value.absent(),
        scoringSystem: scoringSystem != null ? Value(scoringSystem) : const Value.absent(),
        winPoints: winPoints != null ? Value(winPoints) : const Value.absent(),
        drawPoints: drawPoints != null ? Value(drawPoints) : const Value.absent(),
        lossPoints: lossPoints != null ? Value(lossPoints) : const Value.absent(),
        includeConsolationFinals: includeConsolationFinals != null ? Value(includeConsolationFinals) : const Value.absent(),
        timerMinutes: timerMinutes != null ? Value(timerMinutes) : const Value.absent(),
        isActive: isActive != null ? Value(isActive) : const Value.absent(),
        startDate: startDate != null ? Value(startDate) : const Value.absent(),
        groupCount: groupCount != null ? Value(groupCount) : const Value.absent(),
        qualifiersPerGroup: qualifiersPerGroup != null ? Value(qualifiersPerGroup) : const Value.absent(),
        hasPlayIn: hasPlayIn != null ? Value(hasPlayIn) : const Value.absent(),
        groupNames: groupNames != null ? Value(groupNames) : const Value.absent(),
        twitchChannel: twitchChannel != null ? Value(twitchChannel) : const Value.absent(),
        customTicker: customTicker != null ? Value(customTicker) : const Value.absent(),
      ),
    ) > 0;
  }

  Future<bool> updateTwitchChannel(int id, String? twitchChannel) async {
    return await (_db.update(_db.tournaments)..where((t) => t.id.equals(id))).write(
      TournamentsCompanion(
        twitchChannel: Value(twitchChannel),
      ),
    ) > 0;
  }

  Future<int> deleteTournament(int id) async {
    // Delete tournament teams first
    await (_db.delete(_db.tournamentTeams)..where((tt) => tt.tournamentId.equals(id))).go();
    // Delete matches
    await (_db.delete(_db.matches)..where((m) => m.tournamentId.equals(id))).go();
    // Delete tournament
    return await (_db.delete(_db.tournaments)..where((t) => t.id.equals(id))).go();
  }

  Future<void> addTeamToTournament(int tournamentId, int teamId, {int groupNumber = 1, int seed = 0}) async {
    await _db.into(_db.tournamentTeams).insert(
      TournamentTeamsCompanion.insert(
        tournamentId: tournamentId,
        teamId: teamId,
        groupNumber: Value(groupNumber),
        seed: Value(seed),
      ),
    );
  }

  Future<void> removeTeamFromTournament(int tournamentId, int teamId) async {
    await (_db.delete(_db.tournamentTeams)
      ..where((tt) => tt.tournamentId.equals(tournamentId) & tt.teamId.equals(teamId)))
      .go();
  }

  Future<void> setTournamentTeams(int tournamentId, List<int> teamIds, {Map<int, int>? teamToGroup}) async {
    // Remove all existing teams
    await (_db.delete(_db.tournamentTeams)..where((tt) => tt.tournamentId.equals(tournamentId))).go();
    // Add new teams
    for (var i = 0; i < teamIds.length; i++) {
      final teamId = teamIds[i];
      final group = teamToGroup?[teamId] ?? 1;
      await addTeamToTournament(tournamentId, teamId, seed: i, groupNumber: group);
    }
  }

  Future<void> finalizeTournament(int tournamentId, int winnerTeamId) async {
    await (_db.update(_db.tournaments)..where((t) => t.id.equals(tournamentId))).write(
      TournamentsCompanion(
        isActive: const Value(false),
        winnerTeamId: Value(winnerTeamId),
      ),
    );
  }
}

/// Provider for tournaments repository
final tournamentsRepositoryProvider = Provider<TournamentsRepository>((ref) {
  final db = ref.watch(dbProvider);
  return TournamentsRepository(db);
});
