import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

/// Communities table
class Communities extends Table {
  TextColumn get id => text()(); // Cloud UUID
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get slug => text().withLength(min: 1, max: 50)();
  TextColumn get logoUrl => text().nullable()();
  
  // New: Security & Invites
  TextColumn get inviteToken => text().nullable()();
  DateTimeColumn get inviteTokenExpiresAt => dateTime().nullable()();

  TextColumn get location => text().nullable()();
  TextColumn get instagramUrl => text().nullable()();
  TextColumn get tiktokUrl => text().nullable()();
  BoolColumn get isOwner => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Teams table
class Teams extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get logoPath => text().nullable()();
  TextColumn get communityId => text().nullable().references(Communities, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Tournaments table
class Tournaments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get location => text().withLength(min: 1, max: 200)();
  DateTimeColumn get startDate => dateTime().nullable()();
  
  TextColumn get mode => text().withDefault(const Constant('group_only'))();
  
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isPublished => boolean().withDefault(const Constant(false))();
  DateTimeColumn get publishedAt => dateTime().nullable()();
  TextColumn get webUrl => text().nullable()();
  TextColumn get cloudId => text().nullable()(); 
  
  /// Co-management flag: true if downloaded from someone else
  BoolColumn get isReadOnly => boolean().withDefault(const Constant(false))();

  IntColumn get groupCount => integer().withDefault(const Constant(0))();
  IntColumn get qualifiersPerGroup => integer().withDefault(const Constant(0))();
  BoolColumn get hasPlayIn => boolean().withDefault(const Constant(false))();
  TextColumn get groupNames => text().nullable()(); 
  TextColumn get twitchChannel => text().nullable()();
  TextColumn get customTicker => text().nullable()(); 
  
  IntColumn get winPoints => integer().withDefault(const Constant(3))();
  IntColumn get drawPoints => integer().withDefault(const Constant(1))();
  IntColumn get lossPoints => integer().withDefault(const Constant(0))();
  TextColumn get scoringSystem => text().withDefault(const Constant('standard'))(); 
  BoolColumn get includeConsolationFinals => boolean().withDefault(const Constant(false))();
  IntColumn get timerMinutes => integer().withDefault(const Constant(10))();
  
  IntColumn get winnerTeamId => integer().nullable().references(Teams, #id)();
  TextColumn get communityId => text().nullable().references(Communities, #id)();
  TextColumn get communityName => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Link table between Tournaments and Teams
class TournamentTeams extends Table {
  IntColumn get tournamentId => integer().references(Tournaments, #id)();
  IntColumn get teamId => integer().references(Teams, #id)();
  IntColumn get groupNumber => integer().withDefault(const Constant(1))();
  IntColumn get seed => integer().nullable()();

  @override
  Set<Column> get primaryKey => {tournamentId, teamId};
}

/// Matches table
class Matches extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tournamentId => integer().references(Tournaments, #id)();
  IntColumn get homeTeamId => integer().nullable().references(Teams, #id)();
  IntColumn get awayTeamId => integer().nullable().references(Teams, #id)();
  IntColumn get homeScore => integer().nullable()();
  IntColumn get awayScore => integer().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  
  TextColumn get phase => text().withDefault(const Constant('group'))();
  IntColumn get round => integer().withDefault(const Constant(1))();
  BoolColumn get isBye => boolean().withDefault(const Constant(false))();
  IntColumn get groupNumber => integer().nullable()();
  
  DateTimeColumn get scheduledAt => dateTime().nullable()();
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Courts / Fields table
class Courts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tournamentId => integer().nullable().references(Tournaments, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  IntColumn get hoops => integer().withDefault(const Constant(2))();
  TextColumn get netsStatus => text().withDefault(const Constant('stoffa'))();
  TextColumn get courtStatus => text().withDefault(const Constant('giocabile'))();
  TextColumn get linesStatus => text().withDefault(const Constant('visibili'))();
  BoolColumn get hasLights => boolean().withDefault(const Constant(true))();
  IntColumn get stars => integer().withDefault(const Constant(3))();
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Teams, Tournaments, TournamentTeams, Matches, Courts, Communities])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 14;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 5) await m.createTable(courts);
        if (from < 6) {
          await m.addColumn(tournaments, tournaments.groupCount);
          await m.addColumn(tournaments, tournaments.qualifiersPerGroup);
          await m.addColumn(tournaments, tournaments.hasPlayIn);
          await m.addColumn(tournaments, tournaments.groupNames);
        }
        if (from < 7) await m.addColumn(tournaments, tournaments.twitchChannel);
        if (from < 8) await m.addColumn(this.tournaments, this.tournaments.cloudId);
        if (from < 9) await m.addColumn(this.tournaments, this.tournaments.customTicker);
        if (from < 10) {
          await m.createTable(communities);
          await m.addColumn(this.tournaments, this.tournaments.communityId);
          await m.addColumn(this.teams, this.teams.communityId);
          await m.addColumn(this.tournaments, this.tournaments.isReadOnly);
          await m.addColumn(this.matches, this.matches.scheduledAt);
          
          // Data Migration: Create a default community for legacy data
          final legacySuffix = DateTime.now().millisecondsSinceEpoch.toString().substring(10);
          await customStatement('INSERT INTO communities (id, name, slug, is_owner, created_at) VALUES (?, ?, ?, ?, ?)', 
            ['legacy-$legacySuffix', 'La mia Community', 'my-community-$legacySuffix', 1, DateTime.now().millisecondsSinceEpoch]);
             
          // Link all existing tournaments and teams to this community
          await customStatement('UPDATE tournaments SET community_id = ?', ['legacy-$legacySuffix']);
          await customStatement('UPDATE teams SET community_id = ?', ['legacy-$legacySuffix']);
        }
        if (from < 11) {
          await m.addColumn(communities, communities.location);
          await m.addColumn(communities, communities.instagramUrl);
          await m.addColumn(communities, communities.tiktokUrl);
        }
        if (from < 12) {
          // Extra safety check: try adding the column to teams if it was missed in v10
          try {
            await m.addColumn(this.teams, this.teams.communityId);
          } catch (_) {
            // Column might already exist
          }
        }
        if (from < 13) {
          await m.addColumn(communities, communities.inviteToken);
          await m.addColumn(communities, communities.inviteTokenExpiresAt);
        }
        if (from < 14) {
          await m.addColumn(this.tournaments, this.tournaments.communityName);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
