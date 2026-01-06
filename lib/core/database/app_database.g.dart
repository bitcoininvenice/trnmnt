// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TeamsTable extends Teams with TableInfo<$TeamsTable, Team> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeamsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _logoPathMeta = const VerificationMeta(
    'logoPath',
  );
  @override
  late final GeneratedColumn<String> logoPath = GeneratedColumn<String>(
    'logo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, logoPath, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'teams';
  @override
  VerificationContext validateIntegrity(
    Insertable<Team> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('logo_path')) {
      context.handle(
        _logoPathMeta,
        logoPath.isAcceptableOrUnknown(data['logo_path']!, _logoPathMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Team map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Team(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      logoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TeamsTable createAlias(String alias) {
    return $TeamsTable(attachedDatabase, alias);
  }
}

class Team extends DataClass implements Insertable<Team> {
  final int id;
  final String name;
  final String? logoPath;
  final DateTime createdAt;
  const Team({
    required this.id,
    required this.name,
    this.logoPath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || logoPath != null) {
      map['logo_path'] = Variable<String>(logoPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TeamsCompanion toCompanion(bool nullToAbsent) {
    return TeamsCompanion(
      id: Value(id),
      name: Value(name),
      logoPath: logoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(logoPath),
      createdAt: Value(createdAt),
    );
  }

  factory Team.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Team(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      logoPath: serializer.fromJson<String?>(json['logoPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'logoPath': serializer.toJson<String?>(logoPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Team copyWith({
    int? id,
    String? name,
    Value<String?> logoPath = const Value.absent(),
    DateTime? createdAt,
  }) => Team(
    id: id ?? this.id,
    name: name ?? this.name,
    logoPath: logoPath.present ? logoPath.value : this.logoPath,
    createdAt: createdAt ?? this.createdAt,
  );
  Team copyWithCompanion(TeamsCompanion data) {
    return Team(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      logoPath: data.logoPath.present ? data.logoPath.value : this.logoPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Team(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('logoPath: $logoPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, logoPath, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Team &&
          other.id == this.id &&
          other.name == this.name &&
          other.logoPath == this.logoPath &&
          other.createdAt == this.createdAt);
}

class TeamsCompanion extends UpdateCompanion<Team> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> logoPath;
  final Value<DateTime> createdAt;
  const TeamsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.logoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TeamsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.logoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Team> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? logoPath,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (logoPath != null) 'logo_path': logoPath,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TeamsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? logoPath,
    Value<DateTime>? createdAt,
  }) {
    return TeamsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      logoPath: logoPath ?? this.logoPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (logoPath.present) {
      map['logo_path'] = Variable<String>(logoPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeamsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('logoPath: $logoPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TournamentsTable extends Tournaments
    with TableInfo<$TournamentsTable, Tournament> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TournamentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('group_only'),
  );
  static const VerificationMeta _scoringSystemMeta = const VerificationMeta(
    'scoringSystem',
  );
  @override
  late final GeneratedColumn<String> scoringSystem = GeneratedColumn<String>(
    'scoring_system',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('win2_loss1'),
  );
  static const VerificationMeta _winPointsMeta = const VerificationMeta(
    'winPoints',
  );
  @override
  late final GeneratedColumn<int> winPoints = GeneratedColumn<int>(
    'win_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _drawPointsMeta = const VerificationMeta(
    'drawPoints',
  );
  @override
  late final GeneratedColumn<int> drawPoints = GeneratedColumn<int>(
    'draw_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lossPointsMeta = const VerificationMeta(
    'lossPoints',
  );
  @override
  late final GeneratedColumn<int> lossPoints = GeneratedColumn<int>(
    'loss_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _includeConsolationFinalsMeta =
      const VerificationMeta('includeConsolationFinals');
  @override
  late final GeneratedColumn<bool> includeConsolationFinals =
      GeneratedColumn<bool>(
        'include_consolation_finals',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("include_consolation_finals" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _timerMinutesMeta = const VerificationMeta(
    'timerMinutes',
  );
  @override
  late final GeneratedColumn<int> timerMinutes = GeneratedColumn<int>(
    'timer_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    location,
    mode,
    scoringSystem,
    winPoints,
    drawPoints,
    lossPoints,
    includeConsolationFinals,
    timerMinutes,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tournaments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tournament> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    }
    if (data.containsKey('scoring_system')) {
      context.handle(
        _scoringSystemMeta,
        scoringSystem.isAcceptableOrUnknown(
          data['scoring_system']!,
          _scoringSystemMeta,
        ),
      );
    }
    if (data.containsKey('win_points')) {
      context.handle(
        _winPointsMeta,
        winPoints.isAcceptableOrUnknown(data['win_points']!, _winPointsMeta),
      );
    }
    if (data.containsKey('draw_points')) {
      context.handle(
        _drawPointsMeta,
        drawPoints.isAcceptableOrUnknown(data['draw_points']!, _drawPointsMeta),
      );
    }
    if (data.containsKey('loss_points')) {
      context.handle(
        _lossPointsMeta,
        lossPoints.isAcceptableOrUnknown(data['loss_points']!, _lossPointsMeta),
      );
    }
    if (data.containsKey('include_consolation_finals')) {
      context.handle(
        _includeConsolationFinalsMeta,
        includeConsolationFinals.isAcceptableOrUnknown(
          data['include_consolation_finals']!,
          _includeConsolationFinalsMeta,
        ),
      );
    }
    if (data.containsKey('timer_minutes')) {
      context.handle(
        _timerMinutesMeta,
        timerMinutes.isAcceptableOrUnknown(
          data['timer_minutes']!,
          _timerMinutesMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tournament map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tournament(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      scoringSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scoring_system'],
      )!,
      winPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}win_points'],
      )!,
      drawPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}draw_points'],
      )!,
      lossPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}loss_points'],
      )!,
      includeConsolationFinals: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}include_consolation_finals'],
      )!,
      timerMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timer_minutes'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TournamentsTable createAlias(String alias) {
    return $TournamentsTable(attachedDatabase, alias);
  }
}

class Tournament extends DataClass implements Insertable<Tournament> {
  final int id;
  final String name;
  final String location;

  /// Tournament mode: 'group_only', 'elimination_only', 'group_and_elimination'
  final String mode;

  /// Scoring system: 'win2_loss1', 'win3_draw1_loss0', 'custom'
  final String scoringSystem;
  final int winPoints;
  final int drawPoints;
  final int lossPoints;
  final bool includeConsolationFinals;
  final int timerMinutes;
  final bool isActive;
  final DateTime createdAt;
  const Tournament({
    required this.id,
    required this.name,
    required this.location,
    required this.mode,
    required this.scoringSystem,
    required this.winPoints,
    required this.drawPoints,
    required this.lossPoints,
    required this.includeConsolationFinals,
    required this.timerMinutes,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['location'] = Variable<String>(location);
    map['mode'] = Variable<String>(mode);
    map['scoring_system'] = Variable<String>(scoringSystem);
    map['win_points'] = Variable<int>(winPoints);
    map['draw_points'] = Variable<int>(drawPoints);
    map['loss_points'] = Variable<int>(lossPoints);
    map['include_consolation_finals'] = Variable<bool>(
      includeConsolationFinals,
    );
    map['timer_minutes'] = Variable<int>(timerMinutes);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TournamentsCompanion toCompanion(bool nullToAbsent) {
    return TournamentsCompanion(
      id: Value(id),
      name: Value(name),
      location: Value(location),
      mode: Value(mode),
      scoringSystem: Value(scoringSystem),
      winPoints: Value(winPoints),
      drawPoints: Value(drawPoints),
      lossPoints: Value(lossPoints),
      includeConsolationFinals: Value(includeConsolationFinals),
      timerMinutes: Value(timerMinutes),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory Tournament.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tournament(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      location: serializer.fromJson<String>(json['location']),
      mode: serializer.fromJson<String>(json['mode']),
      scoringSystem: serializer.fromJson<String>(json['scoringSystem']),
      winPoints: serializer.fromJson<int>(json['winPoints']),
      drawPoints: serializer.fromJson<int>(json['drawPoints']),
      lossPoints: serializer.fromJson<int>(json['lossPoints']),
      includeConsolationFinals: serializer.fromJson<bool>(
        json['includeConsolationFinals'],
      ),
      timerMinutes: serializer.fromJson<int>(json['timerMinutes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'location': serializer.toJson<String>(location),
      'mode': serializer.toJson<String>(mode),
      'scoringSystem': serializer.toJson<String>(scoringSystem),
      'winPoints': serializer.toJson<int>(winPoints),
      'drawPoints': serializer.toJson<int>(drawPoints),
      'lossPoints': serializer.toJson<int>(lossPoints),
      'includeConsolationFinals': serializer.toJson<bool>(
        includeConsolationFinals,
      ),
      'timerMinutes': serializer.toJson<int>(timerMinutes),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Tournament copyWith({
    int? id,
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
    DateTime? createdAt,
  }) => Tournament(
    id: id ?? this.id,
    name: name ?? this.name,
    location: location ?? this.location,
    mode: mode ?? this.mode,
    scoringSystem: scoringSystem ?? this.scoringSystem,
    winPoints: winPoints ?? this.winPoints,
    drawPoints: drawPoints ?? this.drawPoints,
    lossPoints: lossPoints ?? this.lossPoints,
    includeConsolationFinals:
        includeConsolationFinals ?? this.includeConsolationFinals,
    timerMinutes: timerMinutes ?? this.timerMinutes,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  Tournament copyWithCompanion(TournamentsCompanion data) {
    return Tournament(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      location: data.location.present ? data.location.value : this.location,
      mode: data.mode.present ? data.mode.value : this.mode,
      scoringSystem: data.scoringSystem.present
          ? data.scoringSystem.value
          : this.scoringSystem,
      winPoints: data.winPoints.present ? data.winPoints.value : this.winPoints,
      drawPoints: data.drawPoints.present
          ? data.drawPoints.value
          : this.drawPoints,
      lossPoints: data.lossPoints.present
          ? data.lossPoints.value
          : this.lossPoints,
      includeConsolationFinals: data.includeConsolationFinals.present
          ? data.includeConsolationFinals.value
          : this.includeConsolationFinals,
      timerMinutes: data.timerMinutes.present
          ? data.timerMinutes.value
          : this.timerMinutes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tournament(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('mode: $mode, ')
          ..write('scoringSystem: $scoringSystem, ')
          ..write('winPoints: $winPoints, ')
          ..write('drawPoints: $drawPoints, ')
          ..write('lossPoints: $lossPoints, ')
          ..write('includeConsolationFinals: $includeConsolationFinals, ')
          ..write('timerMinutes: $timerMinutes, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    location,
    mode,
    scoringSystem,
    winPoints,
    drawPoints,
    lossPoints,
    includeConsolationFinals,
    timerMinutes,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tournament &&
          other.id == this.id &&
          other.name == this.name &&
          other.location == this.location &&
          other.mode == this.mode &&
          other.scoringSystem == this.scoringSystem &&
          other.winPoints == this.winPoints &&
          other.drawPoints == this.drawPoints &&
          other.lossPoints == this.lossPoints &&
          other.includeConsolationFinals == this.includeConsolationFinals &&
          other.timerMinutes == this.timerMinutes &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class TournamentsCompanion extends UpdateCompanion<Tournament> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> location;
  final Value<String> mode;
  final Value<String> scoringSystem;
  final Value<int> winPoints;
  final Value<int> drawPoints;
  final Value<int> lossPoints;
  final Value<bool> includeConsolationFinals;
  final Value<int> timerMinutes;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const TournamentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.location = const Value.absent(),
    this.mode = const Value.absent(),
    this.scoringSystem = const Value.absent(),
    this.winPoints = const Value.absent(),
    this.drawPoints = const Value.absent(),
    this.lossPoints = const Value.absent(),
    this.includeConsolationFinals = const Value.absent(),
    this.timerMinutes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TournamentsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String location,
    this.mode = const Value.absent(),
    this.scoringSystem = const Value.absent(),
    this.winPoints = const Value.absent(),
    this.drawPoints = const Value.absent(),
    this.lossPoints = const Value.absent(),
    this.includeConsolationFinals = const Value.absent(),
    this.timerMinutes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       location = Value(location);
  static Insertable<Tournament> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? location,
    Expression<String>? mode,
    Expression<String>? scoringSystem,
    Expression<int>? winPoints,
    Expression<int>? drawPoints,
    Expression<int>? lossPoints,
    Expression<bool>? includeConsolationFinals,
    Expression<int>? timerMinutes,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (location != null) 'location': location,
      if (mode != null) 'mode': mode,
      if (scoringSystem != null) 'scoring_system': scoringSystem,
      if (winPoints != null) 'win_points': winPoints,
      if (drawPoints != null) 'draw_points': drawPoints,
      if (lossPoints != null) 'loss_points': lossPoints,
      if (includeConsolationFinals != null)
        'include_consolation_finals': includeConsolationFinals,
      if (timerMinutes != null) 'timer_minutes': timerMinutes,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TournamentsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? location,
    Value<String>? mode,
    Value<String>? scoringSystem,
    Value<int>? winPoints,
    Value<int>? drawPoints,
    Value<int>? lossPoints,
    Value<bool>? includeConsolationFinals,
    Value<int>? timerMinutes,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
  }) {
    return TournamentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      mode: mode ?? this.mode,
      scoringSystem: scoringSystem ?? this.scoringSystem,
      winPoints: winPoints ?? this.winPoints,
      drawPoints: drawPoints ?? this.drawPoints,
      lossPoints: lossPoints ?? this.lossPoints,
      includeConsolationFinals:
          includeConsolationFinals ?? this.includeConsolationFinals,
      timerMinutes: timerMinutes ?? this.timerMinutes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (scoringSystem.present) {
      map['scoring_system'] = Variable<String>(scoringSystem.value);
    }
    if (winPoints.present) {
      map['win_points'] = Variable<int>(winPoints.value);
    }
    if (drawPoints.present) {
      map['draw_points'] = Variable<int>(drawPoints.value);
    }
    if (lossPoints.present) {
      map['loss_points'] = Variable<int>(lossPoints.value);
    }
    if (includeConsolationFinals.present) {
      map['include_consolation_finals'] = Variable<bool>(
        includeConsolationFinals.value,
      );
    }
    if (timerMinutes.present) {
      map['timer_minutes'] = Variable<int>(timerMinutes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TournamentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('mode: $mode, ')
          ..write('scoringSystem: $scoringSystem, ')
          ..write('winPoints: $winPoints, ')
          ..write('drawPoints: $drawPoints, ')
          ..write('lossPoints: $lossPoints, ')
          ..write('includeConsolationFinals: $includeConsolationFinals, ')
          ..write('timerMinutes: $timerMinutes, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TournamentTeamsTable extends TournamentTeams
    with TableInfo<$TournamentTeamsTable, TournamentTeam> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TournamentTeamsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tournamentIdMeta = const VerificationMeta(
    'tournamentId',
  );
  @override
  late final GeneratedColumn<int> tournamentId = GeneratedColumn<int>(
    'tournament_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tournaments (id)',
    ),
  );
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<int> teamId = GeneratedColumn<int>(
    'team_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES teams (id)',
    ),
  );
  static const VerificationMeta _groupNumberMeta = const VerificationMeta(
    'groupNumber',
  );
  @override
  late final GeneratedColumn<int> groupNumber = GeneratedColumn<int>(
    'group_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _seedMeta = const VerificationMeta('seed');
  @override
  late final GeneratedColumn<int> seed = GeneratedColumn<int>(
    'seed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tournamentId,
    teamId,
    groupNumber,
    seed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tournament_teams';
  @override
  VerificationContext validateIntegrity(
    Insertable<TournamentTeam> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tournament_id')) {
      context.handle(
        _tournamentIdMeta,
        tournamentId.isAcceptableOrUnknown(
          data['tournament_id']!,
          _tournamentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tournamentIdMeta);
    }
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teamIdMeta);
    }
    if (data.containsKey('group_number')) {
      context.handle(
        _groupNumberMeta,
        groupNumber.isAcceptableOrUnknown(
          data['group_number']!,
          _groupNumberMeta,
        ),
      );
    }
    if (data.containsKey('seed')) {
      context.handle(
        _seedMeta,
        seed.isAcceptableOrUnknown(data['seed']!, _seedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {tournamentId, teamId},
  ];
  @override
  TournamentTeam map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TournamentTeam(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tournamentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tournament_id'],
      )!,
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}team_id'],
      )!,
      groupNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_number'],
      )!,
      seed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seed'],
      )!,
    );
  }

  @override
  $TournamentTeamsTable createAlias(String alias) {
    return $TournamentTeamsTable(attachedDatabase, alias);
  }
}

class TournamentTeam extends DataClass implements Insertable<TournamentTeam> {
  final int id;
  final int tournamentId;
  final int teamId;
  final int groupNumber;
  final int seed;
  const TournamentTeam({
    required this.id,
    required this.tournamentId,
    required this.teamId,
    required this.groupNumber,
    required this.seed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tournament_id'] = Variable<int>(tournamentId);
    map['team_id'] = Variable<int>(teamId);
    map['group_number'] = Variable<int>(groupNumber);
    map['seed'] = Variable<int>(seed);
    return map;
  }

  TournamentTeamsCompanion toCompanion(bool nullToAbsent) {
    return TournamentTeamsCompanion(
      id: Value(id),
      tournamentId: Value(tournamentId),
      teamId: Value(teamId),
      groupNumber: Value(groupNumber),
      seed: Value(seed),
    );
  }

  factory TournamentTeam.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TournamentTeam(
      id: serializer.fromJson<int>(json['id']),
      tournamentId: serializer.fromJson<int>(json['tournamentId']),
      teamId: serializer.fromJson<int>(json['teamId']),
      groupNumber: serializer.fromJson<int>(json['groupNumber']),
      seed: serializer.fromJson<int>(json['seed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tournamentId': serializer.toJson<int>(tournamentId),
      'teamId': serializer.toJson<int>(teamId),
      'groupNumber': serializer.toJson<int>(groupNumber),
      'seed': serializer.toJson<int>(seed),
    };
  }

  TournamentTeam copyWith({
    int? id,
    int? tournamentId,
    int? teamId,
    int? groupNumber,
    int? seed,
  }) => TournamentTeam(
    id: id ?? this.id,
    tournamentId: tournamentId ?? this.tournamentId,
    teamId: teamId ?? this.teamId,
    groupNumber: groupNumber ?? this.groupNumber,
    seed: seed ?? this.seed,
  );
  TournamentTeam copyWithCompanion(TournamentTeamsCompanion data) {
    return TournamentTeam(
      id: data.id.present ? data.id.value : this.id,
      tournamentId: data.tournamentId.present
          ? data.tournamentId.value
          : this.tournamentId,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      groupNumber: data.groupNumber.present
          ? data.groupNumber.value
          : this.groupNumber,
      seed: data.seed.present ? data.seed.value : this.seed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TournamentTeam(')
          ..write('id: $id, ')
          ..write('tournamentId: $tournamentId, ')
          ..write('teamId: $teamId, ')
          ..write('groupNumber: $groupNumber, ')
          ..write('seed: $seed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tournamentId, teamId, groupNumber, seed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TournamentTeam &&
          other.id == this.id &&
          other.tournamentId == this.tournamentId &&
          other.teamId == this.teamId &&
          other.groupNumber == this.groupNumber &&
          other.seed == this.seed);
}

class TournamentTeamsCompanion extends UpdateCompanion<TournamentTeam> {
  final Value<int> id;
  final Value<int> tournamentId;
  final Value<int> teamId;
  final Value<int> groupNumber;
  final Value<int> seed;
  const TournamentTeamsCompanion({
    this.id = const Value.absent(),
    this.tournamentId = const Value.absent(),
    this.teamId = const Value.absent(),
    this.groupNumber = const Value.absent(),
    this.seed = const Value.absent(),
  });
  TournamentTeamsCompanion.insert({
    this.id = const Value.absent(),
    required int tournamentId,
    required int teamId,
    this.groupNumber = const Value.absent(),
    this.seed = const Value.absent(),
  }) : tournamentId = Value(tournamentId),
       teamId = Value(teamId);
  static Insertable<TournamentTeam> custom({
    Expression<int>? id,
    Expression<int>? tournamentId,
    Expression<int>? teamId,
    Expression<int>? groupNumber,
    Expression<int>? seed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tournamentId != null) 'tournament_id': tournamentId,
      if (teamId != null) 'team_id': teamId,
      if (groupNumber != null) 'group_number': groupNumber,
      if (seed != null) 'seed': seed,
    });
  }

  TournamentTeamsCompanion copyWith({
    Value<int>? id,
    Value<int>? tournamentId,
    Value<int>? teamId,
    Value<int>? groupNumber,
    Value<int>? seed,
  }) {
    return TournamentTeamsCompanion(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      teamId: teamId ?? this.teamId,
      groupNumber: groupNumber ?? this.groupNumber,
      seed: seed ?? this.seed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tournamentId.present) {
      map['tournament_id'] = Variable<int>(tournamentId.value);
    }
    if (teamId.present) {
      map['team_id'] = Variable<int>(teamId.value);
    }
    if (groupNumber.present) {
      map['group_number'] = Variable<int>(groupNumber.value);
    }
    if (seed.present) {
      map['seed'] = Variable<int>(seed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TournamentTeamsCompanion(')
          ..write('id: $id, ')
          ..write('tournamentId: $tournamentId, ')
          ..write('teamId: $teamId, ')
          ..write('groupNumber: $groupNumber, ')
          ..write('seed: $seed')
          ..write(')'))
        .toString();
  }
}

class $MatchesTable extends Matches with TableInfo<$MatchesTable, Matche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tournamentIdMeta = const VerificationMeta(
    'tournamentId',
  );
  @override
  late final GeneratedColumn<int> tournamentId = GeneratedColumn<int>(
    'tournament_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tournaments (id)',
    ),
  );
  static const VerificationMeta _homeTeamIdMeta = const VerificationMeta(
    'homeTeamId',
  );
  @override
  late final GeneratedColumn<int> homeTeamId = GeneratedColumn<int>(
    'home_team_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES teams (id)',
    ),
  );
  static const VerificationMeta _awayTeamIdMeta = const VerificationMeta(
    'awayTeamId',
  );
  @override
  late final GeneratedColumn<int> awayTeamId = GeneratedColumn<int>(
    'away_team_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES teams (id)',
    ),
  );
  static const VerificationMeta _homeScoreMeta = const VerificationMeta(
    'homeScore',
  );
  @override
  late final GeneratedColumn<int> homeScore = GeneratedColumn<int>(
    'home_score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _awayScoreMeta = const VerificationMeta(
    'awayScore',
  );
  @override
  late final GeneratedColumn<int> awayScore = GeneratedColumn<int>(
    'away_score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roundMeta = const VerificationMeta('round');
  @override
  late final GeneratedColumn<int> round = GeneratedColumn<int>(
    'round',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _groupNumberMeta = const VerificationMeta(
    'groupNumber',
  );
  @override
  late final GeneratedColumn<int> groupNumber = GeneratedColumn<int>(
    'group_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _phaseMeta = const VerificationMeta('phase');
  @override
  late final GeneratedColumn<String> phase = GeneratedColumn<String>(
    'phase',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('group'),
  );
  static const VerificationMeta _isByeMeta = const VerificationMeta('isBye');
  @override
  late final GeneratedColumn<bool> isBye = GeneratedColumn<bool>(
    'is_bye',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_bye" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tournamentId,
    homeTeamId,
    awayTeamId,
    homeScore,
    awayScore,
    round,
    groupNumber,
    phase,
    isBye,
    isCompleted,
    scheduledAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'matches';
  @override
  VerificationContext validateIntegrity(
    Insertable<Matche> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tournament_id')) {
      context.handle(
        _tournamentIdMeta,
        tournamentId.isAcceptableOrUnknown(
          data['tournament_id']!,
          _tournamentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tournamentIdMeta);
    }
    if (data.containsKey('home_team_id')) {
      context.handle(
        _homeTeamIdMeta,
        homeTeamId.isAcceptableOrUnknown(
          data['home_team_id']!,
          _homeTeamIdMeta,
        ),
      );
    }
    if (data.containsKey('away_team_id')) {
      context.handle(
        _awayTeamIdMeta,
        awayTeamId.isAcceptableOrUnknown(
          data['away_team_id']!,
          _awayTeamIdMeta,
        ),
      );
    }
    if (data.containsKey('home_score')) {
      context.handle(
        _homeScoreMeta,
        homeScore.isAcceptableOrUnknown(data['home_score']!, _homeScoreMeta),
      );
    }
    if (data.containsKey('away_score')) {
      context.handle(
        _awayScoreMeta,
        awayScore.isAcceptableOrUnknown(data['away_score']!, _awayScoreMeta),
      );
    }
    if (data.containsKey('round')) {
      context.handle(
        _roundMeta,
        round.isAcceptableOrUnknown(data['round']!, _roundMeta),
      );
    }
    if (data.containsKey('group_number')) {
      context.handle(
        _groupNumberMeta,
        groupNumber.isAcceptableOrUnknown(
          data['group_number']!,
          _groupNumberMeta,
        ),
      );
    }
    if (data.containsKey('phase')) {
      context.handle(
        _phaseMeta,
        phase.isAcceptableOrUnknown(data['phase']!, _phaseMeta),
      );
    }
    if (data.containsKey('is_bye')) {
      context.handle(
        _isByeMeta,
        isBye.isAcceptableOrUnknown(data['is_bye']!, _isByeMeta),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Matche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Matche(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tournamentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tournament_id'],
      )!,
      homeTeamId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}home_team_id'],
      ),
      awayTeamId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}away_team_id'],
      ),
      homeScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}home_score'],
      ),
      awayScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}away_score'],
      ),
      round: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}round'],
      )!,
      groupNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_number'],
      )!,
      phase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phase'],
      )!,
      isBye: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_bye'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MatchesTable createAlias(String alias) {
    return $MatchesTable(attachedDatabase, alias);
  }
}

class Matche extends DataClass implements Insertable<Matche> {
  final int id;
  final int tournamentId;
  final int? homeTeamId;
  final int? awayTeamId;
  final int? homeScore;
  final int? awayScore;
  final int round;
  final int groupNumber;

  /// Match phase: 'group', 'round_of_16', 'quarterfinal', 'semifinal',
  /// 'final', 'third_place', 'fifth_place', 'seventh_place'
  final String phase;
  final bool isBye;
  final bool isCompleted;
  final DateTime? scheduledAt;
  final DateTime createdAt;
  const Matche({
    required this.id,
    required this.tournamentId,
    this.homeTeamId,
    this.awayTeamId,
    this.homeScore,
    this.awayScore,
    required this.round,
    required this.groupNumber,
    required this.phase,
    required this.isBye,
    required this.isCompleted,
    this.scheduledAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tournament_id'] = Variable<int>(tournamentId);
    if (!nullToAbsent || homeTeamId != null) {
      map['home_team_id'] = Variable<int>(homeTeamId);
    }
    if (!nullToAbsent || awayTeamId != null) {
      map['away_team_id'] = Variable<int>(awayTeamId);
    }
    if (!nullToAbsent || homeScore != null) {
      map['home_score'] = Variable<int>(homeScore);
    }
    if (!nullToAbsent || awayScore != null) {
      map['away_score'] = Variable<int>(awayScore);
    }
    map['round'] = Variable<int>(round);
    map['group_number'] = Variable<int>(groupNumber);
    map['phase'] = Variable<String>(phase);
    map['is_bye'] = Variable<bool>(isBye);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || scheduledAt != null) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MatchesCompanion toCompanion(bool nullToAbsent) {
    return MatchesCompanion(
      id: Value(id),
      tournamentId: Value(tournamentId),
      homeTeamId: homeTeamId == null && nullToAbsent
          ? const Value.absent()
          : Value(homeTeamId),
      awayTeamId: awayTeamId == null && nullToAbsent
          ? const Value.absent()
          : Value(awayTeamId),
      homeScore: homeScore == null && nullToAbsent
          ? const Value.absent()
          : Value(homeScore),
      awayScore: awayScore == null && nullToAbsent
          ? const Value.absent()
          : Value(awayScore),
      round: Value(round),
      groupNumber: Value(groupNumber),
      phase: Value(phase),
      isBye: Value(isBye),
      isCompleted: Value(isCompleted),
      scheduledAt: scheduledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledAt),
      createdAt: Value(createdAt),
    );
  }

  factory Matche.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Matche(
      id: serializer.fromJson<int>(json['id']),
      tournamentId: serializer.fromJson<int>(json['tournamentId']),
      homeTeamId: serializer.fromJson<int?>(json['homeTeamId']),
      awayTeamId: serializer.fromJson<int?>(json['awayTeamId']),
      homeScore: serializer.fromJson<int?>(json['homeScore']),
      awayScore: serializer.fromJson<int?>(json['awayScore']),
      round: serializer.fromJson<int>(json['round']),
      groupNumber: serializer.fromJson<int>(json['groupNumber']),
      phase: serializer.fromJson<String>(json['phase']),
      isBye: serializer.fromJson<bool>(json['isBye']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      scheduledAt: serializer.fromJson<DateTime?>(json['scheduledAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tournamentId': serializer.toJson<int>(tournamentId),
      'homeTeamId': serializer.toJson<int?>(homeTeamId),
      'awayTeamId': serializer.toJson<int?>(awayTeamId),
      'homeScore': serializer.toJson<int?>(homeScore),
      'awayScore': serializer.toJson<int?>(awayScore),
      'round': serializer.toJson<int>(round),
      'groupNumber': serializer.toJson<int>(groupNumber),
      'phase': serializer.toJson<String>(phase),
      'isBye': serializer.toJson<bool>(isBye),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'scheduledAt': serializer.toJson<DateTime?>(scheduledAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Matche copyWith({
    int? id,
    int? tournamentId,
    Value<int?> homeTeamId = const Value.absent(),
    Value<int?> awayTeamId = const Value.absent(),
    Value<int?> homeScore = const Value.absent(),
    Value<int?> awayScore = const Value.absent(),
    int? round,
    int? groupNumber,
    String? phase,
    bool? isBye,
    bool? isCompleted,
    Value<DateTime?> scheduledAt = const Value.absent(),
    DateTime? createdAt,
  }) => Matche(
    id: id ?? this.id,
    tournamentId: tournamentId ?? this.tournamentId,
    homeTeamId: homeTeamId.present ? homeTeamId.value : this.homeTeamId,
    awayTeamId: awayTeamId.present ? awayTeamId.value : this.awayTeamId,
    homeScore: homeScore.present ? homeScore.value : this.homeScore,
    awayScore: awayScore.present ? awayScore.value : this.awayScore,
    round: round ?? this.round,
    groupNumber: groupNumber ?? this.groupNumber,
    phase: phase ?? this.phase,
    isBye: isBye ?? this.isBye,
    isCompleted: isCompleted ?? this.isCompleted,
    scheduledAt: scheduledAt.present ? scheduledAt.value : this.scheduledAt,
    createdAt: createdAt ?? this.createdAt,
  );
  Matche copyWithCompanion(MatchesCompanion data) {
    return Matche(
      id: data.id.present ? data.id.value : this.id,
      tournamentId: data.tournamentId.present
          ? data.tournamentId.value
          : this.tournamentId,
      homeTeamId: data.homeTeamId.present
          ? data.homeTeamId.value
          : this.homeTeamId,
      awayTeamId: data.awayTeamId.present
          ? data.awayTeamId.value
          : this.awayTeamId,
      homeScore: data.homeScore.present ? data.homeScore.value : this.homeScore,
      awayScore: data.awayScore.present ? data.awayScore.value : this.awayScore,
      round: data.round.present ? data.round.value : this.round,
      groupNumber: data.groupNumber.present
          ? data.groupNumber.value
          : this.groupNumber,
      phase: data.phase.present ? data.phase.value : this.phase,
      isBye: data.isBye.present ? data.isBye.value : this.isBye,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Matche(')
          ..write('id: $id, ')
          ..write('tournamentId: $tournamentId, ')
          ..write('homeTeamId: $homeTeamId, ')
          ..write('awayTeamId: $awayTeamId, ')
          ..write('homeScore: $homeScore, ')
          ..write('awayScore: $awayScore, ')
          ..write('round: $round, ')
          ..write('groupNumber: $groupNumber, ')
          ..write('phase: $phase, ')
          ..write('isBye: $isBye, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tournamentId,
    homeTeamId,
    awayTeamId,
    homeScore,
    awayScore,
    round,
    groupNumber,
    phase,
    isBye,
    isCompleted,
    scheduledAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Matche &&
          other.id == this.id &&
          other.tournamentId == this.tournamentId &&
          other.homeTeamId == this.homeTeamId &&
          other.awayTeamId == this.awayTeamId &&
          other.homeScore == this.homeScore &&
          other.awayScore == this.awayScore &&
          other.round == this.round &&
          other.groupNumber == this.groupNumber &&
          other.phase == this.phase &&
          other.isBye == this.isBye &&
          other.isCompleted == this.isCompleted &&
          other.scheduledAt == this.scheduledAt &&
          other.createdAt == this.createdAt);
}

class MatchesCompanion extends UpdateCompanion<Matche> {
  final Value<int> id;
  final Value<int> tournamentId;
  final Value<int?> homeTeamId;
  final Value<int?> awayTeamId;
  final Value<int?> homeScore;
  final Value<int?> awayScore;
  final Value<int> round;
  final Value<int> groupNumber;
  final Value<String> phase;
  final Value<bool> isBye;
  final Value<bool> isCompleted;
  final Value<DateTime?> scheduledAt;
  final Value<DateTime> createdAt;
  const MatchesCompanion({
    this.id = const Value.absent(),
    this.tournamentId = const Value.absent(),
    this.homeTeamId = const Value.absent(),
    this.awayTeamId = const Value.absent(),
    this.homeScore = const Value.absent(),
    this.awayScore = const Value.absent(),
    this.round = const Value.absent(),
    this.groupNumber = const Value.absent(),
    this.phase = const Value.absent(),
    this.isBye = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MatchesCompanion.insert({
    this.id = const Value.absent(),
    required int tournamentId,
    this.homeTeamId = const Value.absent(),
    this.awayTeamId = const Value.absent(),
    this.homeScore = const Value.absent(),
    this.awayScore = const Value.absent(),
    this.round = const Value.absent(),
    this.groupNumber = const Value.absent(),
    this.phase = const Value.absent(),
    this.isBye = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : tournamentId = Value(tournamentId);
  static Insertable<Matche> custom({
    Expression<int>? id,
    Expression<int>? tournamentId,
    Expression<int>? homeTeamId,
    Expression<int>? awayTeamId,
    Expression<int>? homeScore,
    Expression<int>? awayScore,
    Expression<int>? round,
    Expression<int>? groupNumber,
    Expression<String>? phase,
    Expression<bool>? isBye,
    Expression<bool>? isCompleted,
    Expression<DateTime>? scheduledAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tournamentId != null) 'tournament_id': tournamentId,
      if (homeTeamId != null) 'home_team_id': homeTeamId,
      if (awayTeamId != null) 'away_team_id': awayTeamId,
      if (homeScore != null) 'home_score': homeScore,
      if (awayScore != null) 'away_score': awayScore,
      if (round != null) 'round': round,
      if (groupNumber != null) 'group_number': groupNumber,
      if (phase != null) 'phase': phase,
      if (isBye != null) 'is_bye': isBye,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MatchesCompanion copyWith({
    Value<int>? id,
    Value<int>? tournamentId,
    Value<int?>? homeTeamId,
    Value<int?>? awayTeamId,
    Value<int?>? homeScore,
    Value<int?>? awayScore,
    Value<int>? round,
    Value<int>? groupNumber,
    Value<String>? phase,
    Value<bool>? isBye,
    Value<bool>? isCompleted,
    Value<DateTime?>? scheduledAt,
    Value<DateTime>? createdAt,
  }) {
    return MatchesCompanion(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      homeTeamId: homeTeamId ?? this.homeTeamId,
      awayTeamId: awayTeamId ?? this.awayTeamId,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      round: round ?? this.round,
      groupNumber: groupNumber ?? this.groupNumber,
      phase: phase ?? this.phase,
      isBye: isBye ?? this.isBye,
      isCompleted: isCompleted ?? this.isCompleted,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tournamentId.present) {
      map['tournament_id'] = Variable<int>(tournamentId.value);
    }
    if (homeTeamId.present) {
      map['home_team_id'] = Variable<int>(homeTeamId.value);
    }
    if (awayTeamId.present) {
      map['away_team_id'] = Variable<int>(awayTeamId.value);
    }
    if (homeScore.present) {
      map['home_score'] = Variable<int>(homeScore.value);
    }
    if (awayScore.present) {
      map['away_score'] = Variable<int>(awayScore.value);
    }
    if (round.present) {
      map['round'] = Variable<int>(round.value);
    }
    if (groupNumber.present) {
      map['group_number'] = Variable<int>(groupNumber.value);
    }
    if (phase.present) {
      map['phase'] = Variable<String>(phase.value);
    }
    if (isBye.present) {
      map['is_bye'] = Variable<bool>(isBye.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatchesCompanion(')
          ..write('id: $id, ')
          ..write('tournamentId: $tournamentId, ')
          ..write('homeTeamId: $homeTeamId, ')
          ..write('awayTeamId: $awayTeamId, ')
          ..write('homeScore: $homeScore, ')
          ..write('awayScore: $awayScore, ')
          ..write('round: $round, ')
          ..write('groupNumber: $groupNumber, ')
          ..write('phase: $phase, ')
          ..write('isBye: $isBye, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TeamsTable teams = $TeamsTable(this);
  late final $TournamentsTable tournaments = $TournamentsTable(this);
  late final $TournamentTeamsTable tournamentTeams = $TournamentTeamsTable(
    this,
  );
  late final $MatchesTable matches = $MatchesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    teams,
    tournaments,
    tournamentTeams,
    matches,
  ];
}

typedef $$TeamsTableCreateCompanionBuilder =
    TeamsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> logoPath,
      Value<DateTime> createdAt,
    });
typedef $$TeamsTableUpdateCompanionBuilder =
    TeamsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> logoPath,
      Value<DateTime> createdAt,
    });

final class $$TeamsTableReferences
    extends BaseReferences<_$AppDatabase, $TeamsTable, Team> {
  $$TeamsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TournamentTeamsTable, List<TournamentTeam>>
  _tournamentTeamsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tournamentTeams,
    aliasName: $_aliasNameGenerator(db.teams.id, db.tournamentTeams.teamId),
  );

  $$TournamentTeamsTableProcessedTableManager get tournamentTeamsRefs {
    final manager = $$TournamentTeamsTableTableManager(
      $_db,
      $_db.tournamentTeams,
    ).filter((f) => f.teamId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _tournamentTeamsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TeamsTableFilterComposer extends Composer<_$AppDatabase, $TeamsTable> {
  $$TeamsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoPath => $composableBuilder(
    column: $table.logoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tournamentTeamsRefs(
    Expression<bool> Function($$TournamentTeamsTableFilterComposer f) f,
  ) {
    final $$TournamentTeamsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tournamentTeams,
      getReferencedColumn: (t) => t.teamId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TournamentTeamsTableFilterComposer(
            $db: $db,
            $table: $db.tournamentTeams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TeamsTableOrderingComposer
    extends Composer<_$AppDatabase, $TeamsTable> {
  $$TeamsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoPath => $composableBuilder(
    column: $table.logoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TeamsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TeamsTable> {
  $$TeamsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get logoPath =>
      $composableBuilder(column: $table.logoPath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> tournamentTeamsRefs<T extends Object>(
    Expression<T> Function($$TournamentTeamsTableAnnotationComposer a) f,
  ) {
    final $$TournamentTeamsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tournamentTeams,
      getReferencedColumn: (t) => t.teamId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TournamentTeamsTableAnnotationComposer(
            $db: $db,
            $table: $db.tournamentTeams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TeamsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TeamsTable,
          Team,
          $$TeamsTableFilterComposer,
          $$TeamsTableOrderingComposer,
          $$TeamsTableAnnotationComposer,
          $$TeamsTableCreateCompanionBuilder,
          $$TeamsTableUpdateCompanionBuilder,
          (Team, $$TeamsTableReferences),
          Team,
          PrefetchHooks Function({bool tournamentTeamsRefs})
        > {
  $$TeamsTableTableManager(_$AppDatabase db, $TeamsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeamsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeamsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TeamsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> logoPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TeamsCompanion(
                id: id,
                name: name,
                logoPath: logoPath,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> logoPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TeamsCompanion.insert(
                id: id,
                name: name,
                logoPath: logoPath,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TeamsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({tournamentTeamsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (tournamentTeamsRefs) db.tournamentTeams,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tournamentTeamsRefs)
                    await $_getPrefetchedData<
                      Team,
                      $TeamsTable,
                      TournamentTeam
                    >(
                      currentTable: table,
                      referencedTable: $$TeamsTableReferences
                          ._tournamentTeamsRefsTable(db),
                      managerFromTypedResult: (p0) => $$TeamsTableReferences(
                        db,
                        table,
                        p0,
                      ).tournamentTeamsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.teamId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TeamsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TeamsTable,
      Team,
      $$TeamsTableFilterComposer,
      $$TeamsTableOrderingComposer,
      $$TeamsTableAnnotationComposer,
      $$TeamsTableCreateCompanionBuilder,
      $$TeamsTableUpdateCompanionBuilder,
      (Team, $$TeamsTableReferences),
      Team,
      PrefetchHooks Function({bool tournamentTeamsRefs})
    >;
typedef $$TournamentsTableCreateCompanionBuilder =
    TournamentsCompanion Function({
      Value<int> id,
      required String name,
      required String location,
      Value<String> mode,
      Value<String> scoringSystem,
      Value<int> winPoints,
      Value<int> drawPoints,
      Value<int> lossPoints,
      Value<bool> includeConsolationFinals,
      Value<int> timerMinutes,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });
typedef $$TournamentsTableUpdateCompanionBuilder =
    TournamentsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> location,
      Value<String> mode,
      Value<String> scoringSystem,
      Value<int> winPoints,
      Value<int> drawPoints,
      Value<int> lossPoints,
      Value<bool> includeConsolationFinals,
      Value<int> timerMinutes,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });

final class $$TournamentsTableReferences
    extends BaseReferences<_$AppDatabase, $TournamentsTable, Tournament> {
  $$TournamentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TournamentTeamsTable, List<TournamentTeam>>
  _tournamentTeamsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tournamentTeams,
    aliasName: $_aliasNameGenerator(
      db.tournaments.id,
      db.tournamentTeams.tournamentId,
    ),
  );

  $$TournamentTeamsTableProcessedTableManager get tournamentTeamsRefs {
    final manager = $$TournamentTeamsTableTableManager(
      $_db,
      $_db.tournamentTeams,
    ).filter((f) => f.tournamentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _tournamentTeamsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MatchesTable, List<Matche>> _matchesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.matches,
    aliasName: $_aliasNameGenerator(db.tournaments.id, db.matches.tournamentId),
  );

  $$MatchesTableProcessedTableManager get matchesRefs {
    final manager = $$MatchesTableTableManager(
      $_db,
      $_db.matches,
    ).filter((f) => f.tournamentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_matchesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TournamentsTableFilterComposer
    extends Composer<_$AppDatabase, $TournamentsTable> {
  $$TournamentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scoringSystem => $composableBuilder(
    column: $table.scoringSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get winPoints => $composableBuilder(
    column: $table.winPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get drawPoints => $composableBuilder(
    column: $table.drawPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lossPoints => $composableBuilder(
    column: $table.lossPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get includeConsolationFinals => $composableBuilder(
    column: $table.includeConsolationFinals,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timerMinutes => $composableBuilder(
    column: $table.timerMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tournamentTeamsRefs(
    Expression<bool> Function($$TournamentTeamsTableFilterComposer f) f,
  ) {
    final $$TournamentTeamsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tournamentTeams,
      getReferencedColumn: (t) => t.tournamentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TournamentTeamsTableFilterComposer(
            $db: $db,
            $table: $db.tournamentTeams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> matchesRefs(
    Expression<bool> Function($$MatchesTableFilterComposer f) f,
  ) {
    final $$MatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.tournamentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchesTableFilterComposer(
            $db: $db,
            $table: $db.matches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TournamentsTableOrderingComposer
    extends Composer<_$AppDatabase, $TournamentsTable> {
  $$TournamentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scoringSystem => $composableBuilder(
    column: $table.scoringSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get winPoints => $composableBuilder(
    column: $table.winPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get drawPoints => $composableBuilder(
    column: $table.drawPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lossPoints => $composableBuilder(
    column: $table.lossPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get includeConsolationFinals => $composableBuilder(
    column: $table.includeConsolationFinals,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timerMinutes => $composableBuilder(
    column: $table.timerMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TournamentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TournamentsTable> {
  $$TournamentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get scoringSystem => $composableBuilder(
    column: $table.scoringSystem,
    builder: (column) => column,
  );

  GeneratedColumn<int> get winPoints =>
      $composableBuilder(column: $table.winPoints, builder: (column) => column);

  GeneratedColumn<int> get drawPoints => $composableBuilder(
    column: $table.drawPoints,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lossPoints => $composableBuilder(
    column: $table.lossPoints,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get includeConsolationFinals => $composableBuilder(
    column: $table.includeConsolationFinals,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timerMinutes => $composableBuilder(
    column: $table.timerMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> tournamentTeamsRefs<T extends Object>(
    Expression<T> Function($$TournamentTeamsTableAnnotationComposer a) f,
  ) {
    final $$TournamentTeamsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tournamentTeams,
      getReferencedColumn: (t) => t.tournamentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TournamentTeamsTableAnnotationComposer(
            $db: $db,
            $table: $db.tournamentTeams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> matchesRefs<T extends Object>(
    Expression<T> Function($$MatchesTableAnnotationComposer a) f,
  ) {
    final $$MatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.tournamentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.matches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TournamentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TournamentsTable,
          Tournament,
          $$TournamentsTableFilterComposer,
          $$TournamentsTableOrderingComposer,
          $$TournamentsTableAnnotationComposer,
          $$TournamentsTableCreateCompanionBuilder,
          $$TournamentsTableUpdateCompanionBuilder,
          (Tournament, $$TournamentsTableReferences),
          Tournament,
          PrefetchHooks Function({bool tournamentTeamsRefs, bool matchesRefs})
        > {
  $$TournamentsTableTableManager(_$AppDatabase db, $TournamentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TournamentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TournamentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TournamentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> scoringSystem = const Value.absent(),
                Value<int> winPoints = const Value.absent(),
                Value<int> drawPoints = const Value.absent(),
                Value<int> lossPoints = const Value.absent(),
                Value<bool> includeConsolationFinals = const Value.absent(),
                Value<int> timerMinutes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TournamentsCompanion(
                id: id,
                name: name,
                location: location,
                mode: mode,
                scoringSystem: scoringSystem,
                winPoints: winPoints,
                drawPoints: drawPoints,
                lossPoints: lossPoints,
                includeConsolationFinals: includeConsolationFinals,
                timerMinutes: timerMinutes,
                isActive: isActive,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String location,
                Value<String> mode = const Value.absent(),
                Value<String> scoringSystem = const Value.absent(),
                Value<int> winPoints = const Value.absent(),
                Value<int> drawPoints = const Value.absent(),
                Value<int> lossPoints = const Value.absent(),
                Value<bool> includeConsolationFinals = const Value.absent(),
                Value<int> timerMinutes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TournamentsCompanion.insert(
                id: id,
                name: name,
                location: location,
                mode: mode,
                scoringSystem: scoringSystem,
                winPoints: winPoints,
                drawPoints: drawPoints,
                lossPoints: lossPoints,
                includeConsolationFinals: includeConsolationFinals,
                timerMinutes: timerMinutes,
                isActive: isActive,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TournamentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({tournamentTeamsRefs = false, matchesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tournamentTeamsRefs) db.tournamentTeams,
                    if (matchesRefs) db.matches,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tournamentTeamsRefs)
                        await $_getPrefetchedData<
                          Tournament,
                          $TournamentsTable,
                          TournamentTeam
                        >(
                          currentTable: table,
                          referencedTable: $$TournamentsTableReferences
                              ._tournamentTeamsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TournamentsTableReferences(
                                db,
                                table,
                                p0,
                              ).tournamentTeamsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tournamentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (matchesRefs)
                        await $_getPrefetchedData<
                          Tournament,
                          $TournamentsTable,
                          Matche
                        >(
                          currentTable: table,
                          referencedTable: $$TournamentsTableReferences
                              ._matchesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TournamentsTableReferences(
                                db,
                                table,
                                p0,
                              ).matchesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tournamentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TournamentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TournamentsTable,
      Tournament,
      $$TournamentsTableFilterComposer,
      $$TournamentsTableOrderingComposer,
      $$TournamentsTableAnnotationComposer,
      $$TournamentsTableCreateCompanionBuilder,
      $$TournamentsTableUpdateCompanionBuilder,
      (Tournament, $$TournamentsTableReferences),
      Tournament,
      PrefetchHooks Function({bool tournamentTeamsRefs, bool matchesRefs})
    >;
typedef $$TournamentTeamsTableCreateCompanionBuilder =
    TournamentTeamsCompanion Function({
      Value<int> id,
      required int tournamentId,
      required int teamId,
      Value<int> groupNumber,
      Value<int> seed,
    });
typedef $$TournamentTeamsTableUpdateCompanionBuilder =
    TournamentTeamsCompanion Function({
      Value<int> id,
      Value<int> tournamentId,
      Value<int> teamId,
      Value<int> groupNumber,
      Value<int> seed,
    });

final class $$TournamentTeamsTableReferences
    extends
        BaseReferences<_$AppDatabase, $TournamentTeamsTable, TournamentTeam> {
  $$TournamentTeamsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TournamentsTable _tournamentIdTable(_$AppDatabase db) =>
      db.tournaments.createAlias(
        $_aliasNameGenerator(
          db.tournamentTeams.tournamentId,
          db.tournaments.id,
        ),
      );

  $$TournamentsTableProcessedTableManager get tournamentId {
    final $_column = $_itemColumn<int>('tournament_id')!;

    final manager = $$TournamentsTableTableManager(
      $_db,
      $_db.tournaments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tournamentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TeamsTable _teamIdTable(_$AppDatabase db) => db.teams.createAlias(
    $_aliasNameGenerator(db.tournamentTeams.teamId, db.teams.id),
  );

  $$TeamsTableProcessedTableManager get teamId {
    final $_column = $_itemColumn<int>('team_id')!;

    final manager = $$TeamsTableTableManager(
      $_db,
      $_db.teams,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_teamIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TournamentTeamsTableFilterComposer
    extends Composer<_$AppDatabase, $TournamentTeamsTable> {
  $$TournamentTeamsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get groupNumber => $composableBuilder(
    column: $table.groupNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seed => $composableBuilder(
    column: $table.seed,
    builder: (column) => ColumnFilters(column),
  );

  $$TournamentsTableFilterComposer get tournamentId {
    final $$TournamentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tournamentId,
      referencedTable: $db.tournaments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TournamentsTableFilterComposer(
            $db: $db,
            $table: $db.tournaments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TeamsTableFilterComposer get teamId {
    final $$TeamsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.teamId,
      referencedTable: $db.teams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TeamsTableFilterComposer(
            $db: $db,
            $table: $db.teams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TournamentTeamsTableOrderingComposer
    extends Composer<_$AppDatabase, $TournamentTeamsTable> {
  $$TournamentTeamsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get groupNumber => $composableBuilder(
    column: $table.groupNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seed => $composableBuilder(
    column: $table.seed,
    builder: (column) => ColumnOrderings(column),
  );

  $$TournamentsTableOrderingComposer get tournamentId {
    final $$TournamentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tournamentId,
      referencedTable: $db.tournaments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TournamentsTableOrderingComposer(
            $db: $db,
            $table: $db.tournaments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TeamsTableOrderingComposer get teamId {
    final $$TeamsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.teamId,
      referencedTable: $db.teams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TeamsTableOrderingComposer(
            $db: $db,
            $table: $db.teams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TournamentTeamsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TournamentTeamsTable> {
  $$TournamentTeamsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get groupNumber => $composableBuilder(
    column: $table.groupNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seed =>
      $composableBuilder(column: $table.seed, builder: (column) => column);

  $$TournamentsTableAnnotationComposer get tournamentId {
    final $$TournamentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tournamentId,
      referencedTable: $db.tournaments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TournamentsTableAnnotationComposer(
            $db: $db,
            $table: $db.tournaments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TeamsTableAnnotationComposer get teamId {
    final $$TeamsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.teamId,
      referencedTable: $db.teams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TeamsTableAnnotationComposer(
            $db: $db,
            $table: $db.teams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TournamentTeamsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TournamentTeamsTable,
          TournamentTeam,
          $$TournamentTeamsTableFilterComposer,
          $$TournamentTeamsTableOrderingComposer,
          $$TournamentTeamsTableAnnotationComposer,
          $$TournamentTeamsTableCreateCompanionBuilder,
          $$TournamentTeamsTableUpdateCompanionBuilder,
          (TournamentTeam, $$TournamentTeamsTableReferences),
          TournamentTeam,
          PrefetchHooks Function({bool tournamentId, bool teamId})
        > {
  $$TournamentTeamsTableTableManager(
    _$AppDatabase db,
    $TournamentTeamsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TournamentTeamsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TournamentTeamsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TournamentTeamsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> tournamentId = const Value.absent(),
                Value<int> teamId = const Value.absent(),
                Value<int> groupNumber = const Value.absent(),
                Value<int> seed = const Value.absent(),
              }) => TournamentTeamsCompanion(
                id: id,
                tournamentId: tournamentId,
                teamId: teamId,
                groupNumber: groupNumber,
                seed: seed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int tournamentId,
                required int teamId,
                Value<int> groupNumber = const Value.absent(),
                Value<int> seed = const Value.absent(),
              }) => TournamentTeamsCompanion.insert(
                id: id,
                tournamentId: tournamentId,
                teamId: teamId,
                groupNumber: groupNumber,
                seed: seed,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TournamentTeamsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tournamentId = false, teamId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tournamentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tournamentId,
                                referencedTable:
                                    $$TournamentTeamsTableReferences
                                        ._tournamentIdTable(db),
                                referencedColumn:
                                    $$TournamentTeamsTableReferences
                                        ._tournamentIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (teamId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.teamId,
                                referencedTable:
                                    $$TournamentTeamsTableReferences
                                        ._teamIdTable(db),
                                referencedColumn:
                                    $$TournamentTeamsTableReferences
                                        ._teamIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TournamentTeamsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TournamentTeamsTable,
      TournamentTeam,
      $$TournamentTeamsTableFilterComposer,
      $$TournamentTeamsTableOrderingComposer,
      $$TournamentTeamsTableAnnotationComposer,
      $$TournamentTeamsTableCreateCompanionBuilder,
      $$TournamentTeamsTableUpdateCompanionBuilder,
      (TournamentTeam, $$TournamentTeamsTableReferences),
      TournamentTeam,
      PrefetchHooks Function({bool tournamentId, bool teamId})
    >;
typedef $$MatchesTableCreateCompanionBuilder =
    MatchesCompanion Function({
      Value<int> id,
      required int tournamentId,
      Value<int?> homeTeamId,
      Value<int?> awayTeamId,
      Value<int?> homeScore,
      Value<int?> awayScore,
      Value<int> round,
      Value<int> groupNumber,
      Value<String> phase,
      Value<bool> isBye,
      Value<bool> isCompleted,
      Value<DateTime?> scheduledAt,
      Value<DateTime> createdAt,
    });
typedef $$MatchesTableUpdateCompanionBuilder =
    MatchesCompanion Function({
      Value<int> id,
      Value<int> tournamentId,
      Value<int?> homeTeamId,
      Value<int?> awayTeamId,
      Value<int?> homeScore,
      Value<int?> awayScore,
      Value<int> round,
      Value<int> groupNumber,
      Value<String> phase,
      Value<bool> isBye,
      Value<bool> isCompleted,
      Value<DateTime?> scheduledAt,
      Value<DateTime> createdAt,
    });

final class $$MatchesTableReferences
    extends BaseReferences<_$AppDatabase, $MatchesTable, Matche> {
  $$MatchesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TournamentsTable _tournamentIdTable(_$AppDatabase db) =>
      db.tournaments.createAlias(
        $_aliasNameGenerator(db.matches.tournamentId, db.tournaments.id),
      );

  $$TournamentsTableProcessedTableManager get tournamentId {
    final $_column = $_itemColumn<int>('tournament_id')!;

    final manager = $$TournamentsTableTableManager(
      $_db,
      $_db.tournaments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tournamentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TeamsTable _homeTeamIdTable(_$AppDatabase db) => db.teams.createAlias(
    $_aliasNameGenerator(db.matches.homeTeamId, db.teams.id),
  );

  $$TeamsTableProcessedTableManager? get homeTeamId {
    final $_column = $_itemColumn<int>('home_team_id');
    if ($_column == null) return null;
    final manager = $$TeamsTableTableManager(
      $_db,
      $_db.teams,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_homeTeamIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TeamsTable _awayTeamIdTable(_$AppDatabase db) => db.teams.createAlias(
    $_aliasNameGenerator(db.matches.awayTeamId, db.teams.id),
  );

  $$TeamsTableProcessedTableManager? get awayTeamId {
    final $_column = $_itemColumn<int>('away_team_id');
    if ($_column == null) return null;
    final manager = $$TeamsTableTableManager(
      $_db,
      $_db.teams,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_awayTeamIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MatchesTableFilterComposer
    extends Composer<_$AppDatabase, $MatchesTable> {
  $$MatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get homeScore => $composableBuilder(
    column: $table.homeScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get awayScore => $composableBuilder(
    column: $table.awayScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get round => $composableBuilder(
    column: $table.round,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get groupNumber => $composableBuilder(
    column: $table.groupNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBye => $composableBuilder(
    column: $table.isBye,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TournamentsTableFilterComposer get tournamentId {
    final $$TournamentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tournamentId,
      referencedTable: $db.tournaments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TournamentsTableFilterComposer(
            $db: $db,
            $table: $db.tournaments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TeamsTableFilterComposer get homeTeamId {
    final $$TeamsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.homeTeamId,
      referencedTable: $db.teams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TeamsTableFilterComposer(
            $db: $db,
            $table: $db.teams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TeamsTableFilterComposer get awayTeamId {
    final $$TeamsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.awayTeamId,
      referencedTable: $db.teams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TeamsTableFilterComposer(
            $db: $db,
            $table: $db.teams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $MatchesTable> {
  $$MatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get homeScore => $composableBuilder(
    column: $table.homeScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get awayScore => $composableBuilder(
    column: $table.awayScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get round => $composableBuilder(
    column: $table.round,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get groupNumber => $composableBuilder(
    column: $table.groupNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBye => $composableBuilder(
    column: $table.isBye,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TournamentsTableOrderingComposer get tournamentId {
    final $$TournamentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tournamentId,
      referencedTable: $db.tournaments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TournamentsTableOrderingComposer(
            $db: $db,
            $table: $db.tournaments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TeamsTableOrderingComposer get homeTeamId {
    final $$TeamsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.homeTeamId,
      referencedTable: $db.teams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TeamsTableOrderingComposer(
            $db: $db,
            $table: $db.teams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TeamsTableOrderingComposer get awayTeamId {
    final $$TeamsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.awayTeamId,
      referencedTable: $db.teams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TeamsTableOrderingComposer(
            $db: $db,
            $table: $db.teams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MatchesTable> {
  $$MatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get homeScore =>
      $composableBuilder(column: $table.homeScore, builder: (column) => column);

  GeneratedColumn<int> get awayScore =>
      $composableBuilder(column: $table.awayScore, builder: (column) => column);

  GeneratedColumn<int> get round =>
      $composableBuilder(column: $table.round, builder: (column) => column);

  GeneratedColumn<int> get groupNumber => $composableBuilder(
    column: $table.groupNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phase =>
      $composableBuilder(column: $table.phase, builder: (column) => column);

  GeneratedColumn<bool> get isBye =>
      $composableBuilder(column: $table.isBye, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TournamentsTableAnnotationComposer get tournamentId {
    final $$TournamentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tournamentId,
      referencedTable: $db.tournaments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TournamentsTableAnnotationComposer(
            $db: $db,
            $table: $db.tournaments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TeamsTableAnnotationComposer get homeTeamId {
    final $$TeamsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.homeTeamId,
      referencedTable: $db.teams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TeamsTableAnnotationComposer(
            $db: $db,
            $table: $db.teams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TeamsTableAnnotationComposer get awayTeamId {
    final $$TeamsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.awayTeamId,
      referencedTable: $db.teams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TeamsTableAnnotationComposer(
            $db: $db,
            $table: $db.teams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MatchesTable,
          Matche,
          $$MatchesTableFilterComposer,
          $$MatchesTableOrderingComposer,
          $$MatchesTableAnnotationComposer,
          $$MatchesTableCreateCompanionBuilder,
          $$MatchesTableUpdateCompanionBuilder,
          (Matche, $$MatchesTableReferences),
          Matche,
          PrefetchHooks Function({
            bool tournamentId,
            bool homeTeamId,
            bool awayTeamId,
          })
        > {
  $$MatchesTableTableManager(_$AppDatabase db, $MatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> tournamentId = const Value.absent(),
                Value<int?> homeTeamId = const Value.absent(),
                Value<int?> awayTeamId = const Value.absent(),
                Value<int?> homeScore = const Value.absent(),
                Value<int?> awayScore = const Value.absent(),
                Value<int> round = const Value.absent(),
                Value<int> groupNumber = const Value.absent(),
                Value<String> phase = const Value.absent(),
                Value<bool> isBye = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> scheduledAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MatchesCompanion(
                id: id,
                tournamentId: tournamentId,
                homeTeamId: homeTeamId,
                awayTeamId: awayTeamId,
                homeScore: homeScore,
                awayScore: awayScore,
                round: round,
                groupNumber: groupNumber,
                phase: phase,
                isBye: isBye,
                isCompleted: isCompleted,
                scheduledAt: scheduledAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int tournamentId,
                Value<int?> homeTeamId = const Value.absent(),
                Value<int?> awayTeamId = const Value.absent(),
                Value<int?> homeScore = const Value.absent(),
                Value<int?> awayScore = const Value.absent(),
                Value<int> round = const Value.absent(),
                Value<int> groupNumber = const Value.absent(),
                Value<String> phase = const Value.absent(),
                Value<bool> isBye = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> scheduledAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MatchesCompanion.insert(
                id: id,
                tournamentId: tournamentId,
                homeTeamId: homeTeamId,
                awayTeamId: awayTeamId,
                homeScore: homeScore,
                awayScore: awayScore,
                round: round,
                groupNumber: groupNumber,
                phase: phase,
                isBye: isBye,
                isCompleted: isCompleted,
                scheduledAt: scheduledAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MatchesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({tournamentId = false, homeTeamId = false, awayTeamId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (tournamentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.tournamentId,
                                    referencedTable: $$MatchesTableReferences
                                        ._tournamentIdTable(db),
                                    referencedColumn: $$MatchesTableReferences
                                        ._tournamentIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (homeTeamId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.homeTeamId,
                                    referencedTable: $$MatchesTableReferences
                                        ._homeTeamIdTable(db),
                                    referencedColumn: $$MatchesTableReferences
                                        ._homeTeamIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (awayTeamId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.awayTeamId,
                                    referencedTable: $$MatchesTableReferences
                                        ._awayTeamIdTable(db),
                                    referencedColumn: $$MatchesTableReferences
                                        ._awayTeamIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$MatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MatchesTable,
      Matche,
      $$MatchesTableFilterComposer,
      $$MatchesTableOrderingComposer,
      $$MatchesTableAnnotationComposer,
      $$MatchesTableCreateCompanionBuilder,
      $$MatchesTableUpdateCompanionBuilder,
      (Matche, $$MatchesTableReferences),
      Matche,
      PrefetchHooks Function({
        bool tournamentId,
        bool homeTeamId,
        bool awayTeamId,
      })
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TeamsTableTableManager get teams =>
      $$TeamsTableTableManager(_db, _db.teams);
  $$TournamentsTableTableManager get tournaments =>
      $$TournamentsTableTableManager(_db, _db.tournaments);
  $$TournamentTeamsTableTableManager get tournamentTeams =>
      $$TournamentTeamsTableTableManager(_db, _db.tournamentTeams);
  $$MatchesTableTableManager get matches =>
      $$MatchesTableTableManager(_db, _db.matches);
}
