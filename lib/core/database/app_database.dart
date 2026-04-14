import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ==================== TABLES ====================
// ... (omitting table definitions for brevity, keep everything till @DriftDatabase)

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
  IntColumn get winnerTeamId => integer().nullable().references(Teams, #id)();
  
  // New for multi-group
  IntColumn get groupCount => integer().withDefault(const Constant(1))();
  IntColumn get qualifiersPerGroup => integer().withDefault(const Constant(2))();
  BoolColumn get hasPlayIn => boolean().withDefault(const Constant(false))();
  TextColumn get groupNames => text().nullable()(); // JSON list of names
  TextColumn get twitchChannel => text().nullable()(); // Optional: "venicestreetball"
  TextColumn get cloudId => text().nullable()(); // Unique ID for Supabase link
  TextColumn get customTicker => text().nullable()(); // Optional custom scrolling text

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

// ... (existing code omitted)

@DriftDatabase(tables: [Teams, Tournaments, TournamentTeams, Matches, Courts])
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal(super.e);

  static AppDatabase? _instance;

  static Future<AppDatabase> getInstance() async {
    if (_instance != null) return _instance!;

    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'trnmnt_v3.db'));

    final database = NativeDatabase(file);
    _instance = AppDatabase._internal(database);

    return _instance!;
  }

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 5) {
          await m.createTable(courts);
        }
        if (from < 6) {
          await m.addColumn(tournaments, tournaments.groupCount);
          await m.addColumn(tournaments, tournaments.qualifiersPerGroup);
          await m.addColumn(tournaments, tournaments.hasPlayIn);
          await m.addColumn(tournaments, tournaments.groupNames);
        }
        if (from < 7) {
          await m.addColumn(tournaments, tournaments.twitchChannel);
        }
        if (from < 8) {
          await m.addColumn(this.tournaments, this.tournaments.cloudId);
        }
        if (from < 9) {
          await m.addColumn(this.tournaments, this.tournaments.customTicker);
        }
      },
    );
  }
}
