import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3/open.dart';
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

// ==================== DATABASE ====================

@DriftDatabase(tables: [Teams, Tournaments, TournamentTeams, Matches])
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal(super.e);

  static AppDatabase? _instance;
  static bool _sqlCipherInitialized = false;

  /// Initialize SQLCipher for Android - must be called before database access
  static Future<void> initializeSqlCipher() async {
    if (Platform.isAndroid && !_sqlCipherInitialized) {
      await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
      
      // Override the default sqlite3 open to use sqlcipher
      open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
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
        // Set the encryption key
        rawDb.execute("PRAGMA key = '$password';");
        // Verify the database is accessible
        rawDb.execute('SELECT 1;');
      },
    );

    _instance = AppDatabase._internal(database);
    return _instance!;
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle future migrations here
      },
    );
  }
}
