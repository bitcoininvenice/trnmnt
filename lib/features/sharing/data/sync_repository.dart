import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trnmnt/core/database/app_database.dart';
import 'package:trnmnt/core/providers/database_provider.dart';

class SyncRepository {
  final AppDatabase _db;
  RealtimeChannel? _subscription;

  SyncRepository(this._db);

  /// Subscribes to realtime updates for a specific tournament on Supabase
  void subscribeToTournament(String cloudId, int tournamentId) {
    _subscription?.unsubscribe();
    
    final supabase = Supabase.instance.client;
    
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
            if (data != null) {
              _handleCloudUpdate(tournamentId, data);
            }
          },
        )
        .subscribe();
  }

  void unsubscribe() {
    _subscription?.unsubscribe();
    _subscription = null;
  }

  Future<void> _handleCloudUpdate(int tournamentId, Map<String, dynamic> data) async {
    final matchesData = data['matches'] as List<dynamic>?;
    if (matchesData == null) return;

    // Batch update matches
    await _db.batch((batch) {
      for (final matchJson in matchesData) {
        final matchId = matchJson['id'] as int?;
        if (matchId == null) continue;

        // Note: we assume IDs are already consistent between co-organizers 
        // because they imported the same bundle
        batch.update(
          _db.matches,
          MatchesCompanion(
            homeScore: Value(matchJson['homeScore']),
            awayScore: Value(matchJson['awayScore']),
            isCompleted: Value(matchJson['isCompleted'] ?? false),
          ),
          where: (t) => t.id.equals(matchId) & t.tournamentId.equals(tournamentId),
        );
      }
    });
  }
}

final syncRepositoryProvider = Provider((ref) {
  final db = ref.watch(dbProvider);
  return SyncRepository(db);
});
