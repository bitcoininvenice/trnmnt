import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';

/// Synchronous provider for database instance, used by repositories.
final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Asynchronous provider for database initialization, used by main.dart for loading UI.
final databaseProvider = FutureProvider<AppDatabase>((ref) async {
  // We can add a small delay or a health check if needed
  return ref.watch(dbProvider);
});
