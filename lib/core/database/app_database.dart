import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3/open.dart';
import 'package:flutter/foundation.dart';
import 'dart:ffi';
import '../security/encryption_service.dart';

part 'app_database.g.dart';

// ==================== TABLES ====================

/// Teams table
class Teams extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get logoPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Tournaments table
class Tournaments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get location => text().withLength(min: 1, max: 200)();
  
  /// Tournament mode: 'group_only', 'elimination_only', 'group_and_elimination'
  TextColumn get mode => text().withDefault(const Constant('group_only'))();
  
  /// Scoring system: 'win2_loss1', 'win3_draw1_loss0', 'custom'
  TextColumn get scoringSystem => text().withDefault(const Constant('win2_loss1'))();
  
  IntColumn get winPoints => integer().withDefault(const Constant(2))();
  IntColumn get drawPoints => integer().withDefault(const Constant(0))();
  IntColumn get lossPoints => integer().withDefault(const Constant(1))();
  
  BoolColumn get includeConsolationFinals => boolean().withDefault(const Constant(false))();
  IntColumn get timerMinutes => integer().withDefault(const Constant(10))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isReadOnly => boolean().withDefault(const Constant(false))();
  IntColumn get remoteId => integer().nullable()();
  TextColumn get sourceIp => text().nullable()();
  IntColumn get sourcePort => integer().nullable()();
  BoolColumn get isPublished => boolean().withDefault(const Constant(false))();
  DateTimeColumn get publishedAt => dateTime().nullable()();
  TextColumn get webUrl => text().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Junction table for tournaments and teams
class TournamentTeams extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tournamentId => integer().references(Tournaments, #id)();
  IntColumn get teamId => integer().references(Teams, #id)();
  IntColumn get groupNumber => integer().withDefault(const Constant(1))();
  IntColumn get seed => integer().withDefault(const Constant(0))();
  
  @override
  List<Set<Column>> get uniqueKeys => [
    {tournamentId, teamId}
  ];
}

/// Matches table
class Matches extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tournamentId => integer().references(Tournaments, #id)();
  IntColumn get homeTeamId => integer().nullable().references(Teams, #id)();
  IntColumn get awayTeamId => integer().nullable().references(Teams, #id)();
  IntColumn get homeScore => integer().nullable()();
  IntColumn get awayScore => integer().nullable()();
  IntColumn get round => integer().withDefault(const Constant(1))();
  IntColumn get groupNumber => integer().withDefault(const Constant(1))();
  
  /// Match phase: 'group', 'round_of_16', 'quarterfinal', 'semifinal', 
  /// 'final', 'third_place', 'fifth_place', 'seventh_place'
  TextColumn get phase => text().withDefault(const Constant('group'))();
  
  BoolColumn get isBye => boolean().withDefault(const Constant(false))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get scheduledAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Courts table
class Courts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable().withLength(max: 500)();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  IntColumn get hoops => integer().withDefault(const Constant(2))();
  
  /// Nets status: 'ferro', 'stoffa', 'rotte', 'non presenti'
  TextColumn get netsStatus => text().withDefault(const Constant('stoffa'))();
  
  /// Court status: 'ben mantenuto', 'giocabile', 'preso male'
  TextColumn get courtStatus => text().withDefault(const Constant('giocabile'))();
  
  /// Lines status: 'ben definite', 'visibili', 'rovinate'
  TextColumn get linesStatus => text().withDefault(const Constant('visibili'))();
  
  BoolColumn get hasLights => boolean().withDefault(const Constant(true))();
  IntColumn get stars => integer().withDefault(const Constant(3))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ==================== DATABASE ====================

@DriftDatabase(tables: [Teams, Tournaments, TournamentTeams, Matches, Courts])
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal(super.e);

  static AppDatabase? _instance;
  static bool _sqlCipherInitialized = false;

  /// Initialize SQLCipher - must be called before database access
  static Future<void> initializeSqlCipher() async {
    if (_sqlCipherInitialized) return;
    
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
      open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
      _sqlCipherInitialized = true;
    } else if (Platform.isIOS) {
      // FORCE SQLCipher on iOS. By default, iOS might pick system sqlite3.dylib
      try {
        // Common path for SQLCipher dynamic framework from CocoaPods
        open.overrideFor(OperatingSystem.iOS, () => DynamicLibrary.open('SQLCipher.framework/SQLCipher'));
        debugPrint('DB: SQLCipher override applied for iOS');
      } catch (e) {
        debugPrint('DB WARNING: Could not find SQLCipher.framework, trying process symbols: $e');
        try {
          // Fallback to process symbols (might work if statically linked)
          open.overrideFor(OperatingSystem.iOS, () => DynamicLibrary.process());
        } catch (_) {}
      }
      _sqlCipherInitialized = true;
    }
  }

  static Future<AppDatabase> getInstance() async {
    if (_instance != null) return _instance!;

    // Ensure SQLCipher is initialized
    await initializeSqlCipher();

    final encryptionService = EncryptionService();
    final password = await encryptionService.getDatabasePassword();

    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'trnmnt_encrypted.db'));

    final database = NativeDatabase(
      file,
      setup: (rawDb) {
        try {
          // 1. First, check if the library actually supports SQLCipher
          bool supportsCipher = false;
          try {
            final versionCheck = rawDb.select('PRAGMA cipher_version;');
            supportsCipher = versionCheck.isNotEmpty && versionCheck.first.columnAt(0) != null;
          } catch (_) {
            supportsCipher = false;
          }

          if (!supportsCipher) {
            debugPrint('DB WARNING: SQLCipher symbols not found. Falling back to standard SQLite.');
            return; // Exit setup, standard SQLite is fine for plaintext
          }

          // 2. Detect if the file is plaintext or encrypted
          // We do this by attempting a select WITHOUT a key first.
          bool isPlaintext = false;
          try {
            rawDb.execute('SELECT count(*) FROM sqlite_master;');
            isPlaintext = true;
          } catch (_) {
            isPlaintext = false;
          }

          if (isPlaintext) {
            debugPrint('DB: Plaintext detected. Attempting migration to encrypted...');
            try {
              // Note: In some SQLCipher versions, you can't rekey from plaintext directly.
              rawDb.execute("PRAGMA rekey = '$password';");
              debugPrint('DB: Encryption migration complete.');
            } catch (e) {
              debugPrint('DB WARNING: Could not encrypt plaintext database ($e). Proceeding in plaintext mode to avoid data loss.');
              // We don't rethrow here, so the app can still work with the plaintext data.
            }
          } else {
            // It's already encrypted (or we don't have access yet), so set the key
            rawDb.execute("PRAGMA key = '$password';");
          }
          
          // 3. Set compatibility flags (page size 4KB is standard for SQLCipher)
          rawDb.execute("PRAGMA cipher_page_size = 4096;");

          // 4. Final verification
          try {
            rawDb.execute('SELECT count(*) FROM sqlite_master;');
            debugPrint('DB: Database access verified.');
          } catch (e) {
            debugPrint('DB FATAL: Access denied after applying key. Key might be wrong or file corrupted: $e');
            rethrow;
          }
        } catch (e) {
          debugPrint('DB SETUP ERROR: $e');
          rethrow;
        }
      },
    );

    _instance = AppDatabase._internal(database);
    return _instance!;
  }

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Ultra-safe migration: ensure all expected elements exist regardless of 'from' version
        
        // 1. Ensure Courts table exists (from v2)
        final tableRes = await customSelect("SELECT name FROM sqlite_master WHERE type='table' AND name='courts'").get();
        if (tableRes.isEmpty) {
          await m.createTable(courts);
        }

        // 2. Ensure all columns in tournaments exist (from v3 and v4)
        final columnRes = await customSelect('PRAGMA table_info(tournaments)').get();
        final existingCols = columnRes.map((r) => r.read<String>('name')).toList();

        final expectedCols = {
          'start_date': tournaments.startDate,
          'mode': tournaments.mode,
          'scoring_system': tournaments.scoringSystem,
          'win_points': tournaments.winPoints,
          'draw_points': tournaments.drawPoints,
          'loss_points': tournaments.lossPoints,
          'include_consolation_finals': tournaments.includeConsolationFinals,
          'timer_minutes': tournaments.timerMinutes,
          'is_active': tournaments.isActive,
          'is_read_only': tournaments.isReadOnly,
        };

        for (final entry in expectedCols.entries) {
          if (!existingCols.contains(entry.key)) {
            await m.addColumn(tournaments, entry.value);
          }
        }
      },
    );
  }
}
