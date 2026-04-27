import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for Radar Map - fetches tournaments with location/court link
final radarTournamentsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final supabase = Supabase.instance.client;
  return supabase.from('published_tournaments')
      .stream(primaryKey: ['id'])
      .map((data) => data.where((item) {
        try {
          final tournamentData = item['data'] as Map<String, dynamic>?;
          if (tournamentData == null) return false;

          final tourney = (tournamentData['tournament'] ?? tournamentData) as Map<String, dynamic>?;
          if (tourney == null) return false;

          // Same logic as Web
          final winnerId = tourney['winner_team_id'] ?? tourney['winnerTeamId'];
          final isCompleted = tourney['isCompleted'] == true || tourney['is_completed'] == true;
          final status = tourney['status']?.toString().toLowerCase();
          
          if (winnerId != null && winnerId.toString().trim().isNotEmpty) return false;
          if (isCompleted == true) return false;
          if (status == 'concluded' || status == 'completed' || status == 'finished') return false;

          final startDateVal = tourney['startDate'];
          if (startDateVal != null) {
              final now = DateTime.now();
              DateTime? startDate;
              if (startDateVal is String) {
                startDate = DateTime.tryParse(startDateVal);
                if (startDate == null) {
                  // Robust parsing for DD/MM/YYYY
                  final parts = startDateVal.split('/');
                  if (parts.length == 3) {
                    final day = int.tryParse(parts[0]);
                    final month = int.tryParse(parts[1]);
                    final year = int.tryParse(parts[2].split(' ')[0]);
                    if (day != null && month != null && year != null) {
                      startDate = DateTime(year, month, day);
                    }
                  }
                }
              } else if (startDateVal is int) {
                startDate = DateTime.fromMillisecondsSinceEpoch(startDateVal);
              }

              if (startDate != null) {
                final endDateVal = tourney['endDate'];
                DateTime endDate;
                if (endDateVal is String) {
                  endDate = DateTime.tryParse(endDateVal) ?? startDate.add(const Duration(hours: 8));
                } else if (endDateVal is int) {
                  endDate = DateTime.fromMillisecondsSinceEpoch(endDateVal);
                } else {
                  endDate = startDate.add(const Duration(hours: 8));
                }

                if (now.isAfter(endDate.add(const Duration(hours: 2)))) return false;
              }
            }

          return true;
        } catch (_) {
          return false;
        }
      }).toList());
});

/// Provider for Live Matches - fetches active matches for real-time status on Radar
final liveMatchesProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final supabase = Supabase.instance.client;
  return supabase.from('live_matches')
      .stream(primaryKey: ['id'])
      .map((data) => data.map((item) => Map<String, dynamic>.from(item)).toList());
});

/// Provider for dynamic sponsor ticker text from Supabase
final sponsorTickerProvider = StreamProvider<String>((ref) {
  final supabase = Supabase.instance.client;
  const defaultTicker = "TRNMNT • SPAZIO PARTNERSHIP DISPONIBILE • CONTATTACI PER MAGGIORI INFO";
  
  return supabase.from('sponsor_ticker')
      .stream(primaryKey: ['id'])
      .limit(1)
      .map((data) {
        if (data.isEmpty) return defaultTicker;
        return data.first['text'] as String? ?? defaultTicker;
      })
      .handleError((e) {
        return defaultTicker;
      });
});

/// Provider for all tournaments
final tournamentsProvider = StreamProvider<List<Tournament>>((ref) async* {
  final db = ref.watch(dbProvider);
  yield* (db.select(db.tournaments)
    ..orderBy([(t) => OrderingTerm.desc(t.startDate), (t) => OrderingTerm.desc(t.createdAt)]))
    .watch();
});

enum CloudFilter { past, inProgress, future }

final cloudFilterProvider = StateProvider<Set<CloudFilter>>((ref) => {CloudFilter.inProgress, CloudFilter.future});

/// Memoria interna per gestire gli aggiornamenti parziali dello stream
final Map<String, Map<String, dynamic>> _hubStreamCache = {};

/// Provider for the HUB - returns ALL tournaments without pre-filtering
final hubTournamentsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final supabase = Supabase.instance.client;
  
  return supabase.from('published_tournaments')
    .stream(primaryKey: ['id'])
    .order('last_updated', ascending: false)
    .map((data) {
      final List<Map<String, dynamic>> allTournaments = [];
      
      for (final item in data) {
        try {
          final id = item['id']?.toString();
          if (id == null) continue;

          final tournamentData = item['data'] as Map<String, dynamic>?;
          
          if (tournamentData != null) {
            // Caso 1: Abbiamo i dati completi nel JSONB
            tournamentData['id'] = id;
            tournamentData['community_slug'] = item['community_slug'];
            tournamentData['community_id'] = item['community_id'];
            tournamentData['venue_court_id'] = item['venue_court_id'];
            tournamentData['description'] = item['description'];
            tournamentData['app_views'] = item['app_views'];
            tournamentData['web_views'] = item['web_views'];
            tournamentData['spectators'] = item['spectators'];
            
            // Aggiorniamo la cache con i dati freschi
            _hubStreamCache[id] = Map<String, dynamic>.from(tournamentData);
            allTournaments.add(tournamentData);
          } else if (_hubStreamCache.containsKey(id)) {
            // Caso 2: L'aggiornamento è parziale (senza JSONB), usiamo la cache
            final cached = Map<String, dynamic>.from(_hubStreamCache[id]!);
            
            // Ma aggiorniamo i metadati che potrebbero essere arrivati nella riga "flat"
            item.forEach((key, value) {
              if (value != null) cached[key] = value;
            });
            
            allTournaments.add(cached);
          } else {
            // Caso 3: Primo caricamento ma dato parziale (raro), lo aggiungiamo così com'è
            allTournaments.add(Map<String, dynamic>.from(item));
          }
        } catch (_) {}
      }

      // Ordinamento ultra-stabile
      allTournaments.sort((a, b) {
        final tA = a['tournament'] as Map<String, dynamic>? ?? a;
        final tB = b['tournament'] as Map<String, dynamic>? ?? b;
        DateTime parse(dynamic v) => (v is String) ? (DateTime.tryParse(v) ?? DateTime(1970)) : (v is int ? DateTime.fromMillisecondsSinceEpoch(v) : DateTime(1970));
        
        final dateA = parse(tA['startDate']);
        final dateB = parse(tB['startDate']);
        final now = DateTime.now();

        final isActiveA = tA['isActive'] == true;
        final isActiveB = tB['isActive'] == true;

        if (isActiveA && !isActiveB) return -1;
        if (!isActiveA && isActiveB) return 1;

        final isFutureA = dateA.isAfter(now);
        final isFutureB = dateB.isAfter(now);

        if (isFutureA && !isFutureB) return -1;
        if (!isFutureA && isFutureB) return 1;

        if (isFutureA && isFutureB) return dateA.compareTo(dateB);
        return dateB.compareTo(dateA);
      });

      return allTournaments;
    });
});

/// Memoria interna per gestire gli aggiornamenti parziali del cloudTournamentsProvider
final Map<String, Map<String, dynamic>> _cloudStreamCache = {};

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
          final id = item['id']?.toString();
          if (id == null) continue;

          final tournamentData = item['data'] as Map<String, dynamic>?;
          
          if (tournamentData != null) {
            tournamentData['id'] = id;
            tournamentData['community_slug'] = item['community_slug'];
            tournamentData['community_id'] = item['community_id'];
            tournamentData['venue_court_id'] = item['venue_court_id'];
            tournamentData['description'] = item['description'];
            tournamentData['app_views'] = item['app_views'];
            tournamentData['web_views'] = item['web_views'];
            tournamentData['spectators'] = item['spectators'];
            
            _cloudStreamCache[id] = Map<String, dynamic>.from(tournamentData);
            allTournaments.add(tournamentData);
          } else if (_cloudStreamCache.containsKey(id)) {
            final cached = Map<String, dynamic>.from(_cloudStreamCache[id]!);
            item.forEach((key, value) {
              if (value != null) cached[key] = value;
            });
            allTournaments.add(cached);
          } else {
            allTournaments.add(Map<String, dynamic>.from(item));
          }
        } catch (_) {}
      }

      // Sort ALL tournaments: Active > Future (Soonest First) > Past (Newest First)
      allTournaments.sort((a, b) {
        final tA = a['tournament'] as Map<String, dynamic>? ?? a;
        final tB = b['tournament'] as Map<String, dynamic>? ?? b;
        
        DateTime parseDate(dynamic val) {
          if (val is String) return DateTime.tryParse(val) ?? DateTime(1970);
          if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
          return DateTime(1970);
        }

        final dateA = parseDate(tA['startDate']);
        final dateB = parseDate(tB['startDate']);
        
        final isActiveA = tA['isActive'] == true;
        final isActiveB = tB['isActive'] == true;

        if (isActiveA && !isActiveB) return -1;
        if (!isActiveA && isActiveB) return 1;

        final isFutureA = dateA.isAfter(now);
        final isFutureB = dateB.isAfter(now);

        if (isFutureA && !isFutureB) return -1;
        if (!isFutureA && isFutureB) return 1;

        if (isFutureA && isFutureB) return dateA.compareTo(dateB);
        return dateB.compareTo(dateA);
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
              startDate = DateTime.fromMillisecondsSinceEpoch(startDateVal);
            }
            
            final isActive = t['isActive'] as bool? ?? false;

            if (filters.contains(CloudFilter.past) && !isActive && (startDate != null && startDate.isBefore(now))) return true;
            if (filters.contains(CloudFilter.inProgress) && isActive) return true;
            if (filters.contains(CloudFilter.future) && !isActive && (startDate != null && startDate.isAfter(now))) return true;
          } catch (_) {}
          return false;
        }).take(50).toList();
      }

      var result = filterData(activeFilters);
      if (result.isNotEmpty) return result;

      final liveFallback = filterData({CloudFilter.inProgress});
      if (liveFallback.isNotEmpty) return liveFallback;

      final futureFallback = filterData({CloudFilter.future});
      if (futureFallback.isNotEmpty) return futureFallback;
      
      final pastFallback = filterData({CloudFilter.past});
      if (pastFallback.isNotEmpty) return pastFallback;

      if (allTournaments.isNotEmpty) return allTournaments.take(50).toList();
      return [];
    });
});

/// Provider for filtering
final tournamentSearchQueryProvider = StateProvider<String>((ref) => '');
final tournamentModeFilterProvider = StateProvider<String?>((ref) => null);
final tournamentStatusFilterProvider = StateProvider<String>((ref) => 'all'); // Default to local as requested

/// Cache per mantenere i dati del torneo stabili durante gli aggiornamenti parziali dello stream
final Map<String, Map<String, dynamic>> _cloudTournamentCache = {};

/// Provider for a specific cloud tournament by UUID - Hybrid (Future for stability + Stream for updates with Merge Logic)
final cloudTournamentDetailProvider = StreamProvider.family<Map<String, dynamic>?, String>((ref, cloudId) async* {
  final supabase = Supabase.instance.client;
  
  // 1. Initial stable fetch to avoid flickering
  try {
    final initialData = await supabase.from('published_tournaments')
      .select('*')
      .eq('id', cloudId)
      .single();
    _cloudTournamentCache[cloudId] = Map<String, dynamic>.from(initialData);
    yield initialData;
  } catch (_) {
    // Se fallisce il fetch iniziale, proviamo a usare la cache se esiste
    if (_cloudTournamentCache.containsKey(cloudId)) {
      yield _cloudTournamentCache[cloudId];
    }
  }
  
  // 2. Continuous stream for real-time updates with MERGE logic
  final stream = supabase.from('published_tournaments')
    .stream(primaryKey: ['id'])
    .eq('id', cloudId)
    .map((data) => data.isNotEmpty ? data.first : null);

  await for (final update in stream) {
    if (update == null) {
      yield _cloudTournamentCache[cloudId];
      continue;
    }

    // Fondiamo l'aggiornamento con i dati esistenti per non perdere colonne
    final existing = _cloudTournamentCache[cloudId] ?? {};
    final merged = Map<String, dynamic>.from(existing);
    
    update.forEach((key, value) {
      // Sovrascriviamo solo se il valore non è nullo (per evitare perdite durante i partial updates)
      if (value != null) {
        merged[key] = value;
      }
    });

    _cloudTournamentCache[cloudId] = merged;
    yield merged;
  }
});

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
    String? youtubeVideoId,
    String? communityId,
    bool isWebRegistrationEnabled = false,
    int courtCount = 1,
    int lunchDuration = 0,
    DateTime? endDate,
    int? venueCourtId,
    String? description,
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
        youtubeVideoId: Value(youtubeVideoId),
        communityId: Value(communityId),
        isWebRegistrationEnabled: Value(isWebRegistrationEnabled),
        courtCount: Value(courtCount),
        lunchDuration: Value(lunchDuration),
        endDate: Value(endDate),
        venueCourtId: Value(venueCourtId),
        description: Value(description),
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
    String? youtubeVideoId,
    String? customTicker,
    bool? isWebRegistrationEnabled,
    int? courtCount,
    int? lunchDuration,
    DateTime? endDate,
    int? venueCourtId,
    String? description,
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
        youtubeVideoId: youtubeVideoId != null ? Value(youtubeVideoId) : const Value.absent(),
        customTicker: customTicker != null ? Value(customTicker) : const Value.absent(),
        isWebRegistrationEnabled: isWebRegistrationEnabled != null ? Value(isWebRegistrationEnabled) : const Value.absent(),
        courtCount: courtCount != null ? Value(courtCount) : const Value.absent(),
        lunchDuration: lunchDuration != null ? Value(lunchDuration) : const Value.absent(),
        endDate: endDate != null ? Value(endDate) : const Value.absent(),
        venueCourtId: venueCourtId != null ? Value(venueCourtId) : const Value.absent(),
        description: description != null ? Value(description) : const Value.absent(),
      ),
    ) > 0;
  }

  Future<Tournament?> getTournamentById(int id) async {
    return await (_db.select(_db.tournaments)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<bool> updateTwitchChannel(int id, String? twitchChannel) async {
    return await (_db.update(_db.tournaments)..where((t) => t.id.equals(id))).write(
      TournamentsCompanion(
        twitchChannel: Value(twitchChannel),
      ),
    ) > 0;
  }

  Future<bool> updateVideoIds(int id, {String? twitchChannel, String? youtubeVideoId}) async {
    return await (_db.update(_db.tournaments)..where((t) => t.id.equals(id))).write(
      TournamentsCompanion(
        twitchChannel: twitchChannel != null ? Value(twitchChannel) : const Value.absent(),
        youtubeVideoId: youtubeVideoId != null ? Value(youtubeVideoId) : const Value.absent(),
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

/// Provider for specific cloud match detail
final cloudLiveMatchDetailProvider = StreamProvider.family<Map<String, dynamic>?, String>((ref, matchId) {
  final supabase = Supabase.instance.client;
  return supabase.from('live_matches')
    .stream(primaryKey: ['id'])
    .eq('id', matchId)
    .map((data) => data.isNotEmpty ? data.first : null);
});

/// Provider for all live matches in the cloud
final cloudLiveMatchesProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final supabase = Supabase.instance.client;
  return supabase.from('live_matches')
    .stream(primaryKey: ['id'])
    .order('last_update', ascending: false)
    .map((data) => data);
});

/// Provider for tournaments repository
final tournamentsRepositoryProvider = Provider<TournamentsRepository>((ref) {
  final db = ref.watch(dbProvider);
  return TournamentsRepository(db);
});
