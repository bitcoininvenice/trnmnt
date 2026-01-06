import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';

/// Provider for the encrypted database instance
final databaseProvider = FutureProvider<AppDatabase>((ref) async {
  return await AppDatabase.getInstance();
});

/// Provides the database synchronously (throws if not ready)
final dbProvider = Provider<AppDatabase>((ref) {
  final asyncDb = ref.watch(databaseProvider);
  return asyncDb.when(
    data: (db) => db,
    loading: () => throw Exception('Database not initialized yet'),
    error: (error, stack) => throw error,
  );
});
