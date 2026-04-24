// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CommunitiesTable extends Communities
    with TableInfo<$CommunitiesTable, Community> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommunitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _logoUrlMeta = const VerificationMeta(
    'logoUrl',
  );
  @override
  late final GeneratedColumn<String> logoUrl = GeneratedColumn<String>(
    'logo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inviteTokenMeta = const VerificationMeta(
    'inviteToken',
  );
  @override
  late final GeneratedColumn<String> inviteToken = GeneratedColumn<String>(
    'invite_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inviteTokenExpiresAtMeta =
      const VerificationMeta('inviteTokenExpiresAt');
  @override
  late final GeneratedColumn<DateTime> inviteTokenExpiresAt =
      GeneratedColumn<DateTime>(
        'invite_token_expires_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _instagramUrlMeta = const VerificationMeta(
    'instagramUrl',
  );
  @override
  late final GeneratedColumn<String> instagramUrl = GeneratedColumn<String>(
    'instagram_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tiktokUrlMeta = const VerificationMeta(
    'tiktokUrl',
  );
  @override
  late final GeneratedColumn<String> tiktokUrl = GeneratedColumn<String>(
    'tiktok_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isOwnerMeta = const VerificationMeta(
    'isOwner',
  );
  @override
  late final GeneratedColumn<bool> isOwner = GeneratedColumn<bool>(
    'is_owner',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_owner" IN (0, 1))',
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
    slug,
    logoUrl,
    inviteToken,
    inviteTokenExpiresAt,
    location,
    instagramUrl,
    tiktokUrl,
    isOwner,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'communities';
  @override
  VerificationContext validateIntegrity(
    Insertable<Community> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('slug')) {
      context.handle(
        _slugMeta,
        slug.isAcceptableOrUnknown(data['slug']!, _slugMeta),
      );
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('logo_url')) {
      context.handle(
        _logoUrlMeta,
        logoUrl.isAcceptableOrUnknown(data['logo_url']!, _logoUrlMeta),
      );
    }
    if (data.containsKey('invite_token')) {
      context.handle(
        _inviteTokenMeta,
        inviteToken.isAcceptableOrUnknown(
          data['invite_token']!,
          _inviteTokenMeta,
        ),
      );
    }
    if (data.containsKey('invite_token_expires_at')) {
      context.handle(
        _inviteTokenExpiresAtMeta,
        inviteTokenExpiresAt.isAcceptableOrUnknown(
          data['invite_token_expires_at']!,
          _inviteTokenExpiresAtMeta,
        ),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('instagram_url')) {
      context.handle(
        _instagramUrlMeta,
        instagramUrl.isAcceptableOrUnknown(
          data['instagram_url']!,
          _instagramUrlMeta,
        ),
      );
    }
    if (data.containsKey('tiktok_url')) {
      context.handle(
        _tiktokUrlMeta,
        tiktokUrl.isAcceptableOrUnknown(data['tiktok_url']!, _tiktokUrlMeta),
      );
    }
    if (data.containsKey('is_owner')) {
      context.handle(
        _isOwnerMeta,
        isOwner.isAcceptableOrUnknown(data['is_owner']!, _isOwnerMeta),
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
  Community map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Community(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      slug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slug'],
      )!,
      logoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_url'],
      ),
      inviteToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invite_token'],
      ),
      inviteTokenExpiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}invite_token_expires_at'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      instagramUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instagram_url'],
      ),
      tiktokUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tiktok_url'],
      ),
      isOwner: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_owner'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CommunitiesTable createAlias(String alias) {
    return $CommunitiesTable(attachedDatabase, alias);
  }
}

class Community extends DataClass implements Insertable<Community> {
  final String id;
  final String name;
  final String slug;
  final String? logoUrl;
  final String? inviteToken;
  final DateTime? inviteTokenExpiresAt;
  final String? location;
  final String? instagramUrl;
  final String? tiktokUrl;
  final bool isOwner;
  final DateTime createdAt;
  const Community({
    required this.id,
    required this.name,
    required this.slug,
    this.logoUrl,
    this.inviteToken,
    this.inviteTokenExpiresAt,
    this.location,
    this.instagramUrl,
    this.tiktokUrl,
    required this.isOwner,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['slug'] = Variable<String>(slug);
    if (!nullToAbsent || logoUrl != null) {
      map['logo_url'] = Variable<String>(logoUrl);
    }
    if (!nullToAbsent || inviteToken != null) {
      map['invite_token'] = Variable<String>(inviteToken);
    }
    if (!nullToAbsent || inviteTokenExpiresAt != null) {
      map['invite_token_expires_at'] = Variable<DateTime>(inviteTokenExpiresAt);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || instagramUrl != null) {
      map['instagram_url'] = Variable<String>(instagramUrl);
    }
    if (!nullToAbsent || tiktokUrl != null) {
      map['tiktok_url'] = Variable<String>(tiktokUrl);
    }
    map['is_owner'] = Variable<bool>(isOwner);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CommunitiesCompanion toCompanion(bool nullToAbsent) {
    return CommunitiesCompanion(
      id: Value(id),
      name: Value(name),
      slug: Value(slug),
      logoUrl: logoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(logoUrl),
      inviteToken: inviteToken == null && nullToAbsent
          ? const Value.absent()
          : Value(inviteToken),
      inviteTokenExpiresAt: inviteTokenExpiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(inviteTokenExpiresAt),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      instagramUrl: instagramUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(instagramUrl),
      tiktokUrl: tiktokUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(tiktokUrl),
      isOwner: Value(isOwner),
      createdAt: Value(createdAt),
    );
  }

  factory Community.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Community(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      slug: serializer.fromJson<String>(json['slug']),
      logoUrl: serializer.fromJson<String?>(json['logoUrl']),
      inviteToken: serializer.fromJson<String?>(json['inviteToken']),
      inviteTokenExpiresAt: serializer.fromJson<DateTime?>(
        json['inviteTokenExpiresAt'],
      ),
      location: serializer.fromJson<String?>(json['location']),
      instagramUrl: serializer.fromJson<String?>(json['instagramUrl']),
      tiktokUrl: serializer.fromJson<String?>(json['tiktokUrl']),
      isOwner: serializer.fromJson<bool>(json['isOwner']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'slug': serializer.toJson<String>(slug),
      'logoUrl': serializer.toJson<String?>(logoUrl),
      'inviteToken': serializer.toJson<String?>(inviteToken),
      'inviteTokenExpiresAt': serializer.toJson<DateTime?>(
        inviteTokenExpiresAt,
      ),
      'location': serializer.toJson<String?>(location),
      'instagramUrl': serializer.toJson<String?>(instagramUrl),
      'tiktokUrl': serializer.toJson<String?>(tiktokUrl),
      'isOwner': serializer.toJson<bool>(isOwner),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Community copyWith({
    String? id,
    String? name,
    String? slug,
    Value<String?> logoUrl = const Value.absent(),
    Value<String?> inviteToken = const Value.absent(),
    Value<DateTime?> inviteTokenExpiresAt = const Value.absent(),
    Value<String?> location = const Value.absent(),
    Value<String?> instagramUrl = const Value.absent(),
    Value<String?> tiktokUrl = const Value.absent(),
    bool? isOwner,
    DateTime? createdAt,
  }) => Community(
    id: id ?? this.id,
    name: name ?? this.name,
    slug: slug ?? this.slug,
    logoUrl: logoUrl.present ? logoUrl.value : this.logoUrl,
    inviteToken: inviteToken.present ? inviteToken.value : this.inviteToken,
    inviteTokenExpiresAt: inviteTokenExpiresAt.present
        ? inviteTokenExpiresAt.value
        : this.inviteTokenExpiresAt,
    location: location.present ? location.value : this.location,
    instagramUrl: instagramUrl.present ? instagramUrl.value : this.instagramUrl,
    tiktokUrl: tiktokUrl.present ? tiktokUrl.value : this.tiktokUrl,
    isOwner: isOwner ?? this.isOwner,
    createdAt: createdAt ?? this.createdAt,
  );
  Community copyWithCompanion(CommunitiesCompanion data) {
    return Community(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      slug: data.slug.present ? data.slug.value : this.slug,
      logoUrl: data.logoUrl.present ? data.logoUrl.value : this.logoUrl,
      inviteToken: data.inviteToken.present
          ? data.inviteToken.value
          : this.inviteToken,
      inviteTokenExpiresAt: data.inviteTokenExpiresAt.present
          ? data.inviteTokenExpiresAt.value
          : this.inviteTokenExpiresAt,
      location: data.location.present ? data.location.value : this.location,
      instagramUrl: data.instagramUrl.present
          ? data.instagramUrl.value
          : this.instagramUrl,
      tiktokUrl: data.tiktokUrl.present ? data.tiktokUrl.value : this.tiktokUrl,
      isOwner: data.isOwner.present ? data.isOwner.value : this.isOwner,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Community(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('slug: $slug, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('inviteToken: $inviteToken, ')
          ..write('inviteTokenExpiresAt: $inviteTokenExpiresAt, ')
          ..write('location: $location, ')
          ..write('instagramUrl: $instagramUrl, ')
          ..write('tiktokUrl: $tiktokUrl, ')
          ..write('isOwner: $isOwner, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    slug,
    logoUrl,
    inviteToken,
    inviteTokenExpiresAt,
    location,
    instagramUrl,
    tiktokUrl,
    isOwner,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Community &&
          other.id == this.id &&
          other.name == this.name &&
          other.slug == this.slug &&
          other.logoUrl == this.logoUrl &&
          other.inviteToken == this.inviteToken &&
          other.inviteTokenExpiresAt == this.inviteTokenExpiresAt &&
          other.location == this.location &&
          other.instagramUrl == this.instagramUrl &&
          other.tiktokUrl == this.tiktokUrl &&
          other.isOwner == this.isOwner &&
          other.createdAt == this.createdAt);
}

class CommunitiesCompanion extends UpdateCompanion<Community> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> slug;
  final Value<String?> logoUrl;
  final Value<String?> inviteToken;
  final Value<DateTime?> inviteTokenExpiresAt;
  final Value<String?> location;
  final Value<String?> instagramUrl;
  final Value<String?> tiktokUrl;
  final Value<bool> isOwner;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CommunitiesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.slug = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.inviteToken = const Value.absent(),
    this.inviteTokenExpiresAt = const Value.absent(),
    this.location = const Value.absent(),
    this.instagramUrl = const Value.absent(),
    this.tiktokUrl = const Value.absent(),
    this.isOwner = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CommunitiesCompanion.insert({
    required String id,
    required String name,
    required String slug,
    this.logoUrl = const Value.absent(),
    this.inviteToken = const Value.absent(),
    this.inviteTokenExpiresAt = const Value.absent(),
    this.location = const Value.absent(),
    this.instagramUrl = const Value.absent(),
    this.tiktokUrl = const Value.absent(),
    this.isOwner = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       slug = Value(slug);
  static Insertable<Community> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? slug,
    Expression<String>? logoUrl,
    Expression<String>? inviteToken,
    Expression<DateTime>? inviteTokenExpiresAt,
    Expression<String>? location,
    Expression<String>? instagramUrl,
    Expression<String>? tiktokUrl,
    Expression<bool>? isOwner,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (slug != null) 'slug': slug,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (inviteToken != null) 'invite_token': inviteToken,
      if (inviteTokenExpiresAt != null)
        'invite_token_expires_at': inviteTokenExpiresAt,
      if (location != null) 'location': location,
      if (instagramUrl != null) 'instagram_url': instagramUrl,
      if (tiktokUrl != null) 'tiktok_url': tiktokUrl,
      if (isOwner != null) 'is_owner': isOwner,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CommunitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? slug,
    Value<String?>? logoUrl,
    Value<String?>? inviteToken,
    Value<DateTime?>? inviteTokenExpiresAt,
    Value<String?>? location,
    Value<String?>? instagramUrl,
    Value<String?>? tiktokUrl,
    Value<bool>? isOwner,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CommunitiesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      logoUrl: logoUrl ?? this.logoUrl,
      inviteToken: inviteToken ?? this.inviteToken,
      inviteTokenExpiresAt: inviteTokenExpiresAt ?? this.inviteTokenExpiresAt,
      location: location ?? this.location,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      tiktokUrl: tiktokUrl ?? this.tiktokUrl,
      isOwner: isOwner ?? this.isOwner,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (logoUrl.present) {
      map['logo_url'] = Variable<String>(logoUrl.value);
    }
    if (inviteToken.present) {
      map['invite_token'] = Variable<String>(inviteToken.value);
    }
    if (inviteTokenExpiresAt.present) {
      map['invite_token_expires_at'] = Variable<DateTime>(
        inviteTokenExpiresAt.value,
      );
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (instagramUrl.present) {
      map['instagram_url'] = Variable<String>(instagramUrl.value);
    }
    if (tiktokUrl.present) {
      map['tiktok_url'] = Variable<String>(tiktokUrl.value);
    }
    if (isOwner.present) {
      map['is_owner'] = Variable<bool>(isOwner.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommunitiesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('slug: $slug, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('inviteToken: $inviteToken, ')
          ..write('inviteTokenExpiresAt: $inviteTokenExpiresAt, ')
          ..write('location: $location, ')
          ..write('instagramUrl: $instagramUrl, ')
          ..write('tiktokUrl: $tiktokUrl, ')
          ..write('isOwner: $isOwner, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

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
      maxTextLength: 50,
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
  static const VerificationMeta _communityIdMeta = const VerificationMeta(
    'communityId',
  );
  @override
  late final GeneratedColumn<String> communityId = GeneratedColumn<String>(
    'community_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES communities (id)',
    ),
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
    logoPath,
    communityId,
    createdAt,
  ];
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
    if (data.containsKey('community_id')) {
      context.handle(
        _communityIdMeta,
        communityId.isAcceptableOrUnknown(
          data['community_id']!,
          _communityIdMeta,
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
      communityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}community_id'],
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
  final String? communityId;
  final DateTime createdAt;
  const Team({
    required this.id,
    required this.name,
    this.logoPath,
    this.communityId,
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
    if (!nullToAbsent || communityId != null) {
      map['community_id'] = Variable<String>(communityId);
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
      communityId: communityId == null && nullToAbsent
          ? const Value.absent()
          : Value(communityId),
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
      communityId: serializer.fromJson<String?>(json['communityId']),
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
      'communityId': serializer.toJson<String?>(communityId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Team copyWith({
    int? id,
    String? name,
    Value<String?> logoPath = const Value.absent(),
    Value<String?> communityId = const Value.absent(),
    DateTime? createdAt,
  }) => Team(
    id: id ?? this.id,
    name: name ?? this.name,
    logoPath: logoPath.present ? logoPath.value : this.logoPath,
    communityId: communityId.present ? communityId.value : this.communityId,
    createdAt: createdAt ?? this.createdAt,
  );
  Team copyWithCompanion(TeamsCompanion data) {
    return Team(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      logoPath: data.logoPath.present ? data.logoPath.value : this.logoPath,
      communityId: data.communityId.present
          ? data.communityId.value
          : this.communityId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Team(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('logoPath: $logoPath, ')
          ..write('communityId: $communityId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, logoPath, communityId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Team &&
          other.id == this.id &&
          other.name == this.name &&
          other.logoPath == this.logoPath &&
          other.communityId == this.communityId &&
          other.createdAt == this.createdAt);
}

class TeamsCompanion extends UpdateCompanion<Team> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> logoPath;
  final Value<String?> communityId;
  final Value<DateTime> createdAt;
  const TeamsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.logoPath = const Value.absent(),
    this.communityId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TeamsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.logoPath = const Value.absent(),
    this.communityId = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Team> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? logoPath,
    Expression<String>? communityId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (logoPath != null) 'logo_path': logoPath,
      if (communityId != null) 'community_id': communityId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TeamsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? logoPath,
    Value<String?>? communityId,
    Value<DateTime>? createdAt,
  }) {
    return TeamsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      logoPath: logoPath ?? this.logoPath,
      communityId: communityId ?? this.communityId,
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
    if (communityId.present) {
      map['community_id'] = Variable<String>(communityId.value);
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
          ..write('communityId: $communityId, ')
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
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _isPublishedMeta = const VerificationMeta(
    'isPublished',
  );
  @override
  late final GeneratedColumn<bool> isPublished = GeneratedColumn<bool>(
    'is_published',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_published" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _publishedAtMeta = const VerificationMeta(
    'publishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> publishedAt = GeneratedColumn<DateTime>(
    'published_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _webUrlMeta = const VerificationMeta('webUrl');
  @override
  late final GeneratedColumn<String> webUrl = GeneratedColumn<String>(
    'web_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isReadOnlyMeta = const VerificationMeta(
    'isReadOnly',
  );
  @override
  late final GeneratedColumn<bool> isReadOnly = GeneratedColumn<bool>(
    'is_read_only',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read_only" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _groupCountMeta = const VerificationMeta(
    'groupCount',
  );
  @override
  late final GeneratedColumn<int> groupCount = GeneratedColumn<int>(
    'group_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _qualifiersPerGroupMeta =
      const VerificationMeta('qualifiersPerGroup');
  @override
  late final GeneratedColumn<int> qualifiersPerGroup = GeneratedColumn<int>(
    'qualifiers_per_group',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hasPlayInMeta = const VerificationMeta(
    'hasPlayIn',
  );
  @override
  late final GeneratedColumn<bool> hasPlayIn = GeneratedColumn<bool>(
    'has_play_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_play_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _groupNamesMeta = const VerificationMeta(
    'groupNames',
  );
  @override
  late final GeneratedColumn<String> groupNames = GeneratedColumn<String>(
    'group_names',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _twitchChannelMeta = const VerificationMeta(
    'twitchChannel',
  );
  @override
  late final GeneratedColumn<String> twitchChannel = GeneratedColumn<String>(
    'twitch_channel',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _youtubeVideoIdMeta = const VerificationMeta(
    'youtubeVideoId',
  );
  @override
  late final GeneratedColumn<String> youtubeVideoId = GeneratedColumn<String>(
    'youtube_video_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customTickerMeta = const VerificationMeta(
    'customTicker',
  );
  @override
  late final GeneratedColumn<String> customTicker = GeneratedColumn<String>(
    'custom_ticker',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    defaultValue: const Constant(3),
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
    defaultValue: const Constant(1),
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
    defaultValue: const Constant(0),
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
    defaultValue: const Constant('standard'),
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
  static const VerificationMeta _isWebRegistrationEnabledMeta =
      const VerificationMeta('isWebRegistrationEnabled');
  @override
  late final GeneratedColumn<bool> isWebRegistrationEnabled =
      GeneratedColumn<bool>(
        'is_web_registration_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_web_registration_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _winnerTeamIdMeta = const VerificationMeta(
    'winnerTeamId',
  );
  @override
  late final GeneratedColumn<int> winnerTeamId = GeneratedColumn<int>(
    'winner_team_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES teams (id)',
    ),
  );
  static const VerificationMeta _communityIdMeta = const VerificationMeta(
    'communityId',
  );
  @override
  late final GeneratedColumn<String> communityId = GeneratedColumn<String>(
    'community_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES communities (id)',
    ),
  );
  static const VerificationMeta _communityNameMeta = const VerificationMeta(
    'communityName',
  );
  @override
  late final GeneratedColumn<String> communityName = GeneratedColumn<String>(
    'community_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _courtCountMeta = const VerificationMeta(
    'courtCount',
  );
  @override
  late final GeneratedColumn<int> courtCount = GeneratedColumn<int>(
    'court_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _lunchDurationMeta = const VerificationMeta(
    'lunchDuration',
  );
  @override
  late final GeneratedColumn<int> lunchDuration = GeneratedColumn<int>(
    'lunch_duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _venueCourtIdMeta = const VerificationMeta(
    'venueCourtId',
  );
  @override
  late final GeneratedColumn<int> venueCourtId = GeneratedColumn<int>(
    'venue_court_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
    name,
    location,
    startDate,
    mode,
    isActive,
    isPublished,
    publishedAt,
    webUrl,
    cloudId,
    isReadOnly,
    groupCount,
    qualifiersPerGroup,
    hasPlayIn,
    groupNames,
    twitchChannel,
    youtubeVideoId,
    customTicker,
    winPoints,
    drawPoints,
    lossPoints,
    scoringSystem,
    includeConsolationFinals,
    timerMinutes,
    isWebRegistrationEnabled,
    winnerTeamId,
    communityId,
    communityName,
    courtCount,
    lunchDuration,
    endDate,
    venueCourtId,
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
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('is_published')) {
      context.handle(
        _isPublishedMeta,
        isPublished.isAcceptableOrUnknown(
          data['is_published']!,
          _isPublishedMeta,
        ),
      );
    }
    if (data.containsKey('published_at')) {
      context.handle(
        _publishedAtMeta,
        publishedAt.isAcceptableOrUnknown(
          data['published_at']!,
          _publishedAtMeta,
        ),
      );
    }
    if (data.containsKey('web_url')) {
      context.handle(
        _webUrlMeta,
        webUrl.isAcceptableOrUnknown(data['web_url']!, _webUrlMeta),
      );
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    }
    if (data.containsKey('is_read_only')) {
      context.handle(
        _isReadOnlyMeta,
        isReadOnly.isAcceptableOrUnknown(
          data['is_read_only']!,
          _isReadOnlyMeta,
        ),
      );
    }
    if (data.containsKey('group_count')) {
      context.handle(
        _groupCountMeta,
        groupCount.isAcceptableOrUnknown(data['group_count']!, _groupCountMeta),
      );
    }
    if (data.containsKey('qualifiers_per_group')) {
      context.handle(
        _qualifiersPerGroupMeta,
        qualifiersPerGroup.isAcceptableOrUnknown(
          data['qualifiers_per_group']!,
          _qualifiersPerGroupMeta,
        ),
      );
    }
    if (data.containsKey('has_play_in')) {
      context.handle(
        _hasPlayInMeta,
        hasPlayIn.isAcceptableOrUnknown(data['has_play_in']!, _hasPlayInMeta),
      );
    }
    if (data.containsKey('group_names')) {
      context.handle(
        _groupNamesMeta,
        groupNames.isAcceptableOrUnknown(data['group_names']!, _groupNamesMeta),
      );
    }
    if (data.containsKey('twitch_channel')) {
      context.handle(
        _twitchChannelMeta,
        twitchChannel.isAcceptableOrUnknown(
          data['twitch_channel']!,
          _twitchChannelMeta,
        ),
      );
    }
    if (data.containsKey('youtube_video_id')) {
      context.handle(
        _youtubeVideoIdMeta,
        youtubeVideoId.isAcceptableOrUnknown(
          data['youtube_video_id']!,
          _youtubeVideoIdMeta,
        ),
      );
    }
    if (data.containsKey('custom_ticker')) {
      context.handle(
        _customTickerMeta,
        customTicker.isAcceptableOrUnknown(
          data['custom_ticker']!,
          _customTickerMeta,
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
    if (data.containsKey('scoring_system')) {
      context.handle(
        _scoringSystemMeta,
        scoringSystem.isAcceptableOrUnknown(
          data['scoring_system']!,
          _scoringSystemMeta,
        ),
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
    if (data.containsKey('is_web_registration_enabled')) {
      context.handle(
        _isWebRegistrationEnabledMeta,
        isWebRegistrationEnabled.isAcceptableOrUnknown(
          data['is_web_registration_enabled']!,
          _isWebRegistrationEnabledMeta,
        ),
      );
    }
    if (data.containsKey('winner_team_id')) {
      context.handle(
        _winnerTeamIdMeta,
        winnerTeamId.isAcceptableOrUnknown(
          data['winner_team_id']!,
          _winnerTeamIdMeta,
        ),
      );
    }
    if (data.containsKey('community_id')) {
      context.handle(
        _communityIdMeta,
        communityId.isAcceptableOrUnknown(
          data['community_id']!,
          _communityIdMeta,
        ),
      );
    }
    if (data.containsKey('community_name')) {
      context.handle(
        _communityNameMeta,
        communityName.isAcceptableOrUnknown(
          data['community_name']!,
          _communityNameMeta,
        ),
      );
    }
    if (data.containsKey('court_count')) {
      context.handle(
        _courtCountMeta,
        courtCount.isAcceptableOrUnknown(data['court_count']!, _courtCountMeta),
      );
    }
    if (data.containsKey('lunch_duration')) {
      context.handle(
        _lunchDurationMeta,
        lunchDuration.isAcceptableOrUnknown(
          data['lunch_duration']!,
          _lunchDurationMeta,
        ),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('venue_court_id')) {
      context.handle(
        _venueCourtIdMeta,
        venueCourtId.isAcceptableOrUnknown(
          data['venue_court_id']!,
          _venueCourtIdMeta,
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
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      isPublished: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_published'],
      )!,
      publishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}published_at'],
      ),
      webUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}web_url'],
      ),
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      ),
      isReadOnly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read_only'],
      )!,
      groupCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_count'],
      )!,
      qualifiersPerGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}qualifiers_per_group'],
      )!,
      hasPlayIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_play_in'],
      )!,
      groupNames: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_names'],
      ),
      twitchChannel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}twitch_channel'],
      ),
      youtubeVideoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}youtube_video_id'],
      ),
      customTicker: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_ticker'],
      ),
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
      scoringSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scoring_system'],
      )!,
      includeConsolationFinals: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}include_consolation_finals'],
      )!,
      timerMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timer_minutes'],
      )!,
      isWebRegistrationEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_web_registration_enabled'],
      )!,
      winnerTeamId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}winner_team_id'],
      ),
      communityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}community_id'],
      ),
      communityName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}community_name'],
      ),
      courtCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}court_count'],
      )!,
      lunchDuration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lunch_duration'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      venueCourtId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}venue_court_id'],
      ),
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
  final DateTime? startDate;
  final String mode;
  final bool isActive;
  final bool isPublished;
  final DateTime? publishedAt;
  final String? webUrl;
  final String? cloudId;

  /// Co-management flag: true if downloaded from someone else
  final bool isReadOnly;
  final int groupCount;
  final int qualifiersPerGroup;
  final bool hasPlayIn;
  final String? groupNames;
  final String? twitchChannel;
  final String? youtubeVideoId;
  final String? customTicker;
  final int winPoints;
  final int drawPoints;
  final int lossPoints;
  final String scoringSystem;
  final bool includeConsolationFinals;
  final int timerMinutes;
  final bool isWebRegistrationEnabled;
  final int? winnerTeamId;
  final String? communityId;
  final String? communityName;
  final int courtCount;
  final int lunchDuration;
  final DateTime? endDate;
  final int? venueCourtId;
  final DateTime createdAt;
  const Tournament({
    required this.id,
    required this.name,
    required this.location,
    this.startDate,
    required this.mode,
    required this.isActive,
    required this.isPublished,
    this.publishedAt,
    this.webUrl,
    this.cloudId,
    required this.isReadOnly,
    required this.groupCount,
    required this.qualifiersPerGroup,
    required this.hasPlayIn,
    this.groupNames,
    this.twitchChannel,
    this.youtubeVideoId,
    this.customTicker,
    required this.winPoints,
    required this.drawPoints,
    required this.lossPoints,
    required this.scoringSystem,
    required this.includeConsolationFinals,
    required this.timerMinutes,
    required this.isWebRegistrationEnabled,
    this.winnerTeamId,
    this.communityId,
    this.communityName,
    required this.courtCount,
    required this.lunchDuration,
    this.endDate,
    this.venueCourtId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['location'] = Variable<String>(location);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    map['mode'] = Variable<String>(mode);
    map['is_active'] = Variable<bool>(isActive);
    map['is_published'] = Variable<bool>(isPublished);
    if (!nullToAbsent || publishedAt != null) {
      map['published_at'] = Variable<DateTime>(publishedAt);
    }
    if (!nullToAbsent || webUrl != null) {
      map['web_url'] = Variable<String>(webUrl);
    }
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    map['is_read_only'] = Variable<bool>(isReadOnly);
    map['group_count'] = Variable<int>(groupCount);
    map['qualifiers_per_group'] = Variable<int>(qualifiersPerGroup);
    map['has_play_in'] = Variable<bool>(hasPlayIn);
    if (!nullToAbsent || groupNames != null) {
      map['group_names'] = Variable<String>(groupNames);
    }
    if (!nullToAbsent || twitchChannel != null) {
      map['twitch_channel'] = Variable<String>(twitchChannel);
    }
    if (!nullToAbsent || youtubeVideoId != null) {
      map['youtube_video_id'] = Variable<String>(youtubeVideoId);
    }
    if (!nullToAbsent || customTicker != null) {
      map['custom_ticker'] = Variable<String>(customTicker);
    }
    map['win_points'] = Variable<int>(winPoints);
    map['draw_points'] = Variable<int>(drawPoints);
    map['loss_points'] = Variable<int>(lossPoints);
    map['scoring_system'] = Variable<String>(scoringSystem);
    map['include_consolation_finals'] = Variable<bool>(
      includeConsolationFinals,
    );
    map['timer_minutes'] = Variable<int>(timerMinutes);
    map['is_web_registration_enabled'] = Variable<bool>(
      isWebRegistrationEnabled,
    );
    if (!nullToAbsent || winnerTeamId != null) {
      map['winner_team_id'] = Variable<int>(winnerTeamId);
    }
    if (!nullToAbsent || communityId != null) {
      map['community_id'] = Variable<String>(communityId);
    }
    if (!nullToAbsent || communityName != null) {
      map['community_name'] = Variable<String>(communityName);
    }
    map['court_count'] = Variable<int>(courtCount);
    map['lunch_duration'] = Variable<int>(lunchDuration);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || venueCourtId != null) {
      map['venue_court_id'] = Variable<int>(venueCourtId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TournamentsCompanion toCompanion(bool nullToAbsent) {
    return TournamentsCompanion(
      id: Value(id),
      name: Value(name),
      location: Value(location),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      mode: Value(mode),
      isActive: Value(isActive),
      isPublished: Value(isPublished),
      publishedAt: publishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(publishedAt),
      webUrl: webUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(webUrl),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
      isReadOnly: Value(isReadOnly),
      groupCount: Value(groupCount),
      qualifiersPerGroup: Value(qualifiersPerGroup),
      hasPlayIn: Value(hasPlayIn),
      groupNames: groupNames == null && nullToAbsent
          ? const Value.absent()
          : Value(groupNames),
      twitchChannel: twitchChannel == null && nullToAbsent
          ? const Value.absent()
          : Value(twitchChannel),
      youtubeVideoId: youtubeVideoId == null && nullToAbsent
          ? const Value.absent()
          : Value(youtubeVideoId),
      customTicker: customTicker == null && nullToAbsent
          ? const Value.absent()
          : Value(customTicker),
      winPoints: Value(winPoints),
      drawPoints: Value(drawPoints),
      lossPoints: Value(lossPoints),
      scoringSystem: Value(scoringSystem),
      includeConsolationFinals: Value(includeConsolationFinals),
      timerMinutes: Value(timerMinutes),
      isWebRegistrationEnabled: Value(isWebRegistrationEnabled),
      winnerTeamId: winnerTeamId == null && nullToAbsent
          ? const Value.absent()
          : Value(winnerTeamId),
      communityId: communityId == null && nullToAbsent
          ? const Value.absent()
          : Value(communityId),
      communityName: communityName == null && nullToAbsent
          ? const Value.absent()
          : Value(communityName),
      courtCount: Value(courtCount),
      lunchDuration: Value(lunchDuration),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      venueCourtId: venueCourtId == null && nullToAbsent
          ? const Value.absent()
          : Value(venueCourtId),
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
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      mode: serializer.fromJson<String>(json['mode']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isPublished: serializer.fromJson<bool>(json['isPublished']),
      publishedAt: serializer.fromJson<DateTime?>(json['publishedAt']),
      webUrl: serializer.fromJson<String?>(json['webUrl']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
      isReadOnly: serializer.fromJson<bool>(json['isReadOnly']),
      groupCount: serializer.fromJson<int>(json['groupCount']),
      qualifiersPerGroup: serializer.fromJson<int>(json['qualifiersPerGroup']),
      hasPlayIn: serializer.fromJson<bool>(json['hasPlayIn']),
      groupNames: serializer.fromJson<String?>(json['groupNames']),
      twitchChannel: serializer.fromJson<String?>(json['twitchChannel']),
      youtubeVideoId: serializer.fromJson<String?>(json['youtubeVideoId']),
      customTicker: serializer.fromJson<String?>(json['customTicker']),
      winPoints: serializer.fromJson<int>(json['winPoints']),
      drawPoints: serializer.fromJson<int>(json['drawPoints']),
      lossPoints: serializer.fromJson<int>(json['lossPoints']),
      scoringSystem: serializer.fromJson<String>(json['scoringSystem']),
      includeConsolationFinals: serializer.fromJson<bool>(
        json['includeConsolationFinals'],
      ),
      timerMinutes: serializer.fromJson<int>(json['timerMinutes']),
      isWebRegistrationEnabled: serializer.fromJson<bool>(
        json['isWebRegistrationEnabled'],
      ),
      winnerTeamId: serializer.fromJson<int?>(json['winnerTeamId']),
      communityId: serializer.fromJson<String?>(json['communityId']),
      communityName: serializer.fromJson<String?>(json['communityName']),
      courtCount: serializer.fromJson<int>(json['courtCount']),
      lunchDuration: serializer.fromJson<int>(json['lunchDuration']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      venueCourtId: serializer.fromJson<int?>(json['venueCourtId']),
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
      'startDate': serializer.toJson<DateTime?>(startDate),
      'mode': serializer.toJson<String>(mode),
      'isActive': serializer.toJson<bool>(isActive),
      'isPublished': serializer.toJson<bool>(isPublished),
      'publishedAt': serializer.toJson<DateTime?>(publishedAt),
      'webUrl': serializer.toJson<String?>(webUrl),
      'cloudId': serializer.toJson<String?>(cloudId),
      'isReadOnly': serializer.toJson<bool>(isReadOnly),
      'groupCount': serializer.toJson<int>(groupCount),
      'qualifiersPerGroup': serializer.toJson<int>(qualifiersPerGroup),
      'hasPlayIn': serializer.toJson<bool>(hasPlayIn),
      'groupNames': serializer.toJson<String?>(groupNames),
      'twitchChannel': serializer.toJson<String?>(twitchChannel),
      'youtubeVideoId': serializer.toJson<String?>(youtubeVideoId),
      'customTicker': serializer.toJson<String?>(customTicker),
      'winPoints': serializer.toJson<int>(winPoints),
      'drawPoints': serializer.toJson<int>(drawPoints),
      'lossPoints': serializer.toJson<int>(lossPoints),
      'scoringSystem': serializer.toJson<String>(scoringSystem),
      'includeConsolationFinals': serializer.toJson<bool>(
        includeConsolationFinals,
      ),
      'timerMinutes': serializer.toJson<int>(timerMinutes),
      'isWebRegistrationEnabled': serializer.toJson<bool>(
        isWebRegistrationEnabled,
      ),
      'winnerTeamId': serializer.toJson<int?>(winnerTeamId),
      'communityId': serializer.toJson<String?>(communityId),
      'communityName': serializer.toJson<String?>(communityName),
      'courtCount': serializer.toJson<int>(courtCount),
      'lunchDuration': serializer.toJson<int>(lunchDuration),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'venueCourtId': serializer.toJson<int?>(venueCourtId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Tournament copyWith({
    int? id,
    String? name,
    String? location,
    Value<DateTime?> startDate = const Value.absent(),
    String? mode,
    bool? isActive,
    bool? isPublished,
    Value<DateTime?> publishedAt = const Value.absent(),
    Value<String?> webUrl = const Value.absent(),
    Value<String?> cloudId = const Value.absent(),
    bool? isReadOnly,
    int? groupCount,
    int? qualifiersPerGroup,
    bool? hasPlayIn,
    Value<String?> groupNames = const Value.absent(),
    Value<String?> twitchChannel = const Value.absent(),
    Value<String?> youtubeVideoId = const Value.absent(),
    Value<String?> customTicker = const Value.absent(),
    int? winPoints,
    int? drawPoints,
    int? lossPoints,
    String? scoringSystem,
    bool? includeConsolationFinals,
    int? timerMinutes,
    bool? isWebRegistrationEnabled,
    Value<int?> winnerTeamId = const Value.absent(),
    Value<String?> communityId = const Value.absent(),
    Value<String?> communityName = const Value.absent(),
    int? courtCount,
    int? lunchDuration,
    Value<DateTime?> endDate = const Value.absent(),
    Value<int?> venueCourtId = const Value.absent(),
    DateTime? createdAt,
  }) => Tournament(
    id: id ?? this.id,
    name: name ?? this.name,
    location: location ?? this.location,
    startDate: startDate.present ? startDate.value : this.startDate,
    mode: mode ?? this.mode,
    isActive: isActive ?? this.isActive,
    isPublished: isPublished ?? this.isPublished,
    publishedAt: publishedAt.present ? publishedAt.value : this.publishedAt,
    webUrl: webUrl.present ? webUrl.value : this.webUrl,
    cloudId: cloudId.present ? cloudId.value : this.cloudId,
    isReadOnly: isReadOnly ?? this.isReadOnly,
    groupCount: groupCount ?? this.groupCount,
    qualifiersPerGroup: qualifiersPerGroup ?? this.qualifiersPerGroup,
    hasPlayIn: hasPlayIn ?? this.hasPlayIn,
    groupNames: groupNames.present ? groupNames.value : this.groupNames,
    twitchChannel: twitchChannel.present
        ? twitchChannel.value
        : this.twitchChannel,
    youtubeVideoId: youtubeVideoId.present
        ? youtubeVideoId.value
        : this.youtubeVideoId,
    customTicker: customTicker.present ? customTicker.value : this.customTicker,
    winPoints: winPoints ?? this.winPoints,
    drawPoints: drawPoints ?? this.drawPoints,
    lossPoints: lossPoints ?? this.lossPoints,
    scoringSystem: scoringSystem ?? this.scoringSystem,
    includeConsolationFinals:
        includeConsolationFinals ?? this.includeConsolationFinals,
    timerMinutes: timerMinutes ?? this.timerMinutes,
    isWebRegistrationEnabled:
        isWebRegistrationEnabled ?? this.isWebRegistrationEnabled,
    winnerTeamId: winnerTeamId.present ? winnerTeamId.value : this.winnerTeamId,
    communityId: communityId.present ? communityId.value : this.communityId,
    communityName: communityName.present
        ? communityName.value
        : this.communityName,
    courtCount: courtCount ?? this.courtCount,
    lunchDuration: lunchDuration ?? this.lunchDuration,
    endDate: endDate.present ? endDate.value : this.endDate,
    venueCourtId: venueCourtId.present ? venueCourtId.value : this.venueCourtId,
    createdAt: createdAt ?? this.createdAt,
  );
  Tournament copyWithCompanion(TournamentsCompanion data) {
    return Tournament(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      location: data.location.present ? data.location.value : this.location,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      mode: data.mode.present ? data.mode.value : this.mode,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isPublished: data.isPublished.present
          ? data.isPublished.value
          : this.isPublished,
      publishedAt: data.publishedAt.present
          ? data.publishedAt.value
          : this.publishedAt,
      webUrl: data.webUrl.present ? data.webUrl.value : this.webUrl,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      isReadOnly: data.isReadOnly.present
          ? data.isReadOnly.value
          : this.isReadOnly,
      groupCount: data.groupCount.present
          ? data.groupCount.value
          : this.groupCount,
      qualifiersPerGroup: data.qualifiersPerGroup.present
          ? data.qualifiersPerGroup.value
          : this.qualifiersPerGroup,
      hasPlayIn: data.hasPlayIn.present ? data.hasPlayIn.value : this.hasPlayIn,
      groupNames: data.groupNames.present
          ? data.groupNames.value
          : this.groupNames,
      twitchChannel: data.twitchChannel.present
          ? data.twitchChannel.value
          : this.twitchChannel,
      youtubeVideoId: data.youtubeVideoId.present
          ? data.youtubeVideoId.value
          : this.youtubeVideoId,
      customTicker: data.customTicker.present
          ? data.customTicker.value
          : this.customTicker,
      winPoints: data.winPoints.present ? data.winPoints.value : this.winPoints,
      drawPoints: data.drawPoints.present
          ? data.drawPoints.value
          : this.drawPoints,
      lossPoints: data.lossPoints.present
          ? data.lossPoints.value
          : this.lossPoints,
      scoringSystem: data.scoringSystem.present
          ? data.scoringSystem.value
          : this.scoringSystem,
      includeConsolationFinals: data.includeConsolationFinals.present
          ? data.includeConsolationFinals.value
          : this.includeConsolationFinals,
      timerMinutes: data.timerMinutes.present
          ? data.timerMinutes.value
          : this.timerMinutes,
      isWebRegistrationEnabled: data.isWebRegistrationEnabled.present
          ? data.isWebRegistrationEnabled.value
          : this.isWebRegistrationEnabled,
      winnerTeamId: data.winnerTeamId.present
          ? data.winnerTeamId.value
          : this.winnerTeamId,
      communityId: data.communityId.present
          ? data.communityId.value
          : this.communityId,
      communityName: data.communityName.present
          ? data.communityName.value
          : this.communityName,
      courtCount: data.courtCount.present
          ? data.courtCount.value
          : this.courtCount,
      lunchDuration: data.lunchDuration.present
          ? data.lunchDuration.value
          : this.lunchDuration,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      venueCourtId: data.venueCourtId.present
          ? data.venueCourtId.value
          : this.venueCourtId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tournament(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('startDate: $startDate, ')
          ..write('mode: $mode, ')
          ..write('isActive: $isActive, ')
          ..write('isPublished: $isPublished, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('webUrl: $webUrl, ')
          ..write('cloudId: $cloudId, ')
          ..write('isReadOnly: $isReadOnly, ')
          ..write('groupCount: $groupCount, ')
          ..write('qualifiersPerGroup: $qualifiersPerGroup, ')
          ..write('hasPlayIn: $hasPlayIn, ')
          ..write('groupNames: $groupNames, ')
          ..write('twitchChannel: $twitchChannel, ')
          ..write('youtubeVideoId: $youtubeVideoId, ')
          ..write('customTicker: $customTicker, ')
          ..write('winPoints: $winPoints, ')
          ..write('drawPoints: $drawPoints, ')
          ..write('lossPoints: $lossPoints, ')
          ..write('scoringSystem: $scoringSystem, ')
          ..write('includeConsolationFinals: $includeConsolationFinals, ')
          ..write('timerMinutes: $timerMinutes, ')
          ..write('isWebRegistrationEnabled: $isWebRegistrationEnabled, ')
          ..write('winnerTeamId: $winnerTeamId, ')
          ..write('communityId: $communityId, ')
          ..write('communityName: $communityName, ')
          ..write('courtCount: $courtCount, ')
          ..write('lunchDuration: $lunchDuration, ')
          ..write('endDate: $endDate, ')
          ..write('venueCourtId: $venueCourtId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    location,
    startDate,
    mode,
    isActive,
    isPublished,
    publishedAt,
    webUrl,
    cloudId,
    isReadOnly,
    groupCount,
    qualifiersPerGroup,
    hasPlayIn,
    groupNames,
    twitchChannel,
    youtubeVideoId,
    customTicker,
    winPoints,
    drawPoints,
    lossPoints,
    scoringSystem,
    includeConsolationFinals,
    timerMinutes,
    isWebRegistrationEnabled,
    winnerTeamId,
    communityId,
    communityName,
    courtCount,
    lunchDuration,
    endDate,
    venueCourtId,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tournament &&
          other.id == this.id &&
          other.name == this.name &&
          other.location == this.location &&
          other.startDate == this.startDate &&
          other.mode == this.mode &&
          other.isActive == this.isActive &&
          other.isPublished == this.isPublished &&
          other.publishedAt == this.publishedAt &&
          other.webUrl == this.webUrl &&
          other.cloudId == this.cloudId &&
          other.isReadOnly == this.isReadOnly &&
          other.groupCount == this.groupCount &&
          other.qualifiersPerGroup == this.qualifiersPerGroup &&
          other.hasPlayIn == this.hasPlayIn &&
          other.groupNames == this.groupNames &&
          other.twitchChannel == this.twitchChannel &&
          other.youtubeVideoId == this.youtubeVideoId &&
          other.customTicker == this.customTicker &&
          other.winPoints == this.winPoints &&
          other.drawPoints == this.drawPoints &&
          other.lossPoints == this.lossPoints &&
          other.scoringSystem == this.scoringSystem &&
          other.includeConsolationFinals == this.includeConsolationFinals &&
          other.timerMinutes == this.timerMinutes &&
          other.isWebRegistrationEnabled == this.isWebRegistrationEnabled &&
          other.winnerTeamId == this.winnerTeamId &&
          other.communityId == this.communityId &&
          other.communityName == this.communityName &&
          other.courtCount == this.courtCount &&
          other.lunchDuration == this.lunchDuration &&
          other.endDate == this.endDate &&
          other.venueCourtId == this.venueCourtId &&
          other.createdAt == this.createdAt);
}

class TournamentsCompanion extends UpdateCompanion<Tournament> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> location;
  final Value<DateTime?> startDate;
  final Value<String> mode;
  final Value<bool> isActive;
  final Value<bool> isPublished;
  final Value<DateTime?> publishedAt;
  final Value<String?> webUrl;
  final Value<String?> cloudId;
  final Value<bool> isReadOnly;
  final Value<int> groupCount;
  final Value<int> qualifiersPerGroup;
  final Value<bool> hasPlayIn;
  final Value<String?> groupNames;
  final Value<String?> twitchChannel;
  final Value<String?> youtubeVideoId;
  final Value<String?> customTicker;
  final Value<int> winPoints;
  final Value<int> drawPoints;
  final Value<int> lossPoints;
  final Value<String> scoringSystem;
  final Value<bool> includeConsolationFinals;
  final Value<int> timerMinutes;
  final Value<bool> isWebRegistrationEnabled;
  final Value<int?> winnerTeamId;
  final Value<String?> communityId;
  final Value<String?> communityName;
  final Value<int> courtCount;
  final Value<int> lunchDuration;
  final Value<DateTime?> endDate;
  final Value<int?> venueCourtId;
  final Value<DateTime> createdAt;
  const TournamentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.location = const Value.absent(),
    this.startDate = const Value.absent(),
    this.mode = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isPublished = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.webUrl = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.isReadOnly = const Value.absent(),
    this.groupCount = const Value.absent(),
    this.qualifiersPerGroup = const Value.absent(),
    this.hasPlayIn = const Value.absent(),
    this.groupNames = const Value.absent(),
    this.twitchChannel = const Value.absent(),
    this.youtubeVideoId = const Value.absent(),
    this.customTicker = const Value.absent(),
    this.winPoints = const Value.absent(),
    this.drawPoints = const Value.absent(),
    this.lossPoints = const Value.absent(),
    this.scoringSystem = const Value.absent(),
    this.includeConsolationFinals = const Value.absent(),
    this.timerMinutes = const Value.absent(),
    this.isWebRegistrationEnabled = const Value.absent(),
    this.winnerTeamId = const Value.absent(),
    this.communityId = const Value.absent(),
    this.communityName = const Value.absent(),
    this.courtCount = const Value.absent(),
    this.lunchDuration = const Value.absent(),
    this.endDate = const Value.absent(),
    this.venueCourtId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TournamentsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String location,
    this.startDate = const Value.absent(),
    this.mode = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isPublished = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.webUrl = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.isReadOnly = const Value.absent(),
    this.groupCount = const Value.absent(),
    this.qualifiersPerGroup = const Value.absent(),
    this.hasPlayIn = const Value.absent(),
    this.groupNames = const Value.absent(),
    this.twitchChannel = const Value.absent(),
    this.youtubeVideoId = const Value.absent(),
    this.customTicker = const Value.absent(),
    this.winPoints = const Value.absent(),
    this.drawPoints = const Value.absent(),
    this.lossPoints = const Value.absent(),
    this.scoringSystem = const Value.absent(),
    this.includeConsolationFinals = const Value.absent(),
    this.timerMinutes = const Value.absent(),
    this.isWebRegistrationEnabled = const Value.absent(),
    this.winnerTeamId = const Value.absent(),
    this.communityId = const Value.absent(),
    this.communityName = const Value.absent(),
    this.courtCount = const Value.absent(),
    this.lunchDuration = const Value.absent(),
    this.endDate = const Value.absent(),
    this.venueCourtId = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       location = Value(location);
  static Insertable<Tournament> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? location,
    Expression<DateTime>? startDate,
    Expression<String>? mode,
    Expression<bool>? isActive,
    Expression<bool>? isPublished,
    Expression<DateTime>? publishedAt,
    Expression<String>? webUrl,
    Expression<String>? cloudId,
    Expression<bool>? isReadOnly,
    Expression<int>? groupCount,
    Expression<int>? qualifiersPerGroup,
    Expression<bool>? hasPlayIn,
    Expression<String>? groupNames,
    Expression<String>? twitchChannel,
    Expression<String>? youtubeVideoId,
    Expression<String>? customTicker,
    Expression<int>? winPoints,
    Expression<int>? drawPoints,
    Expression<int>? lossPoints,
    Expression<String>? scoringSystem,
    Expression<bool>? includeConsolationFinals,
    Expression<int>? timerMinutes,
    Expression<bool>? isWebRegistrationEnabled,
    Expression<int>? winnerTeamId,
    Expression<String>? communityId,
    Expression<String>? communityName,
    Expression<int>? courtCount,
    Expression<int>? lunchDuration,
    Expression<DateTime>? endDate,
    Expression<int>? venueCourtId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (location != null) 'location': location,
      if (startDate != null) 'start_date': startDate,
      if (mode != null) 'mode': mode,
      if (isActive != null) 'is_active': isActive,
      if (isPublished != null) 'is_published': isPublished,
      if (publishedAt != null) 'published_at': publishedAt,
      if (webUrl != null) 'web_url': webUrl,
      if (cloudId != null) 'cloud_id': cloudId,
      if (isReadOnly != null) 'is_read_only': isReadOnly,
      if (groupCount != null) 'group_count': groupCount,
      if (qualifiersPerGroup != null)
        'qualifiers_per_group': qualifiersPerGroup,
      if (hasPlayIn != null) 'has_play_in': hasPlayIn,
      if (groupNames != null) 'group_names': groupNames,
      if (twitchChannel != null) 'twitch_channel': twitchChannel,
      if (youtubeVideoId != null) 'youtube_video_id': youtubeVideoId,
      if (customTicker != null) 'custom_ticker': customTicker,
      if (winPoints != null) 'win_points': winPoints,
      if (drawPoints != null) 'draw_points': drawPoints,
      if (lossPoints != null) 'loss_points': lossPoints,
      if (scoringSystem != null) 'scoring_system': scoringSystem,
      if (includeConsolationFinals != null)
        'include_consolation_finals': includeConsolationFinals,
      if (timerMinutes != null) 'timer_minutes': timerMinutes,
      if (isWebRegistrationEnabled != null)
        'is_web_registration_enabled': isWebRegistrationEnabled,
      if (winnerTeamId != null) 'winner_team_id': winnerTeamId,
      if (communityId != null) 'community_id': communityId,
      if (communityName != null) 'community_name': communityName,
      if (courtCount != null) 'court_count': courtCount,
      if (lunchDuration != null) 'lunch_duration': lunchDuration,
      if (endDate != null) 'end_date': endDate,
      if (venueCourtId != null) 'venue_court_id': venueCourtId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TournamentsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? location,
    Value<DateTime?>? startDate,
    Value<String>? mode,
    Value<bool>? isActive,
    Value<bool>? isPublished,
    Value<DateTime?>? publishedAt,
    Value<String?>? webUrl,
    Value<String?>? cloudId,
    Value<bool>? isReadOnly,
    Value<int>? groupCount,
    Value<int>? qualifiersPerGroup,
    Value<bool>? hasPlayIn,
    Value<String?>? groupNames,
    Value<String?>? twitchChannel,
    Value<String?>? youtubeVideoId,
    Value<String?>? customTicker,
    Value<int>? winPoints,
    Value<int>? drawPoints,
    Value<int>? lossPoints,
    Value<String>? scoringSystem,
    Value<bool>? includeConsolationFinals,
    Value<int>? timerMinutes,
    Value<bool>? isWebRegistrationEnabled,
    Value<int?>? winnerTeamId,
    Value<String?>? communityId,
    Value<String?>? communityName,
    Value<int>? courtCount,
    Value<int>? lunchDuration,
    Value<DateTime?>? endDate,
    Value<int?>? venueCourtId,
    Value<DateTime>? createdAt,
  }) {
    return TournamentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      mode: mode ?? this.mode,
      isActive: isActive ?? this.isActive,
      isPublished: isPublished ?? this.isPublished,
      publishedAt: publishedAt ?? this.publishedAt,
      webUrl: webUrl ?? this.webUrl,
      cloudId: cloudId ?? this.cloudId,
      isReadOnly: isReadOnly ?? this.isReadOnly,
      groupCount: groupCount ?? this.groupCount,
      qualifiersPerGroup: qualifiersPerGroup ?? this.qualifiersPerGroup,
      hasPlayIn: hasPlayIn ?? this.hasPlayIn,
      groupNames: groupNames ?? this.groupNames,
      twitchChannel: twitchChannel ?? this.twitchChannel,
      youtubeVideoId: youtubeVideoId ?? this.youtubeVideoId,
      customTicker: customTicker ?? this.customTicker,
      winPoints: winPoints ?? this.winPoints,
      drawPoints: drawPoints ?? this.drawPoints,
      lossPoints: lossPoints ?? this.lossPoints,
      scoringSystem: scoringSystem ?? this.scoringSystem,
      includeConsolationFinals:
          includeConsolationFinals ?? this.includeConsolationFinals,
      timerMinutes: timerMinutes ?? this.timerMinutes,
      isWebRegistrationEnabled:
          isWebRegistrationEnabled ?? this.isWebRegistrationEnabled,
      winnerTeamId: winnerTeamId ?? this.winnerTeamId,
      communityId: communityId ?? this.communityId,
      communityName: communityName ?? this.communityName,
      courtCount: courtCount ?? this.courtCount,
      lunchDuration: lunchDuration ?? this.lunchDuration,
      endDate: endDate ?? this.endDate,
      venueCourtId: venueCourtId ?? this.venueCourtId,
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
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (isPublished.present) {
      map['is_published'] = Variable<bool>(isPublished.value);
    }
    if (publishedAt.present) {
      map['published_at'] = Variable<DateTime>(publishedAt.value);
    }
    if (webUrl.present) {
      map['web_url'] = Variable<String>(webUrl.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (isReadOnly.present) {
      map['is_read_only'] = Variable<bool>(isReadOnly.value);
    }
    if (groupCount.present) {
      map['group_count'] = Variable<int>(groupCount.value);
    }
    if (qualifiersPerGroup.present) {
      map['qualifiers_per_group'] = Variable<int>(qualifiersPerGroup.value);
    }
    if (hasPlayIn.present) {
      map['has_play_in'] = Variable<bool>(hasPlayIn.value);
    }
    if (groupNames.present) {
      map['group_names'] = Variable<String>(groupNames.value);
    }
    if (twitchChannel.present) {
      map['twitch_channel'] = Variable<String>(twitchChannel.value);
    }
    if (youtubeVideoId.present) {
      map['youtube_video_id'] = Variable<String>(youtubeVideoId.value);
    }
    if (customTicker.present) {
      map['custom_ticker'] = Variable<String>(customTicker.value);
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
    if (scoringSystem.present) {
      map['scoring_system'] = Variable<String>(scoringSystem.value);
    }
    if (includeConsolationFinals.present) {
      map['include_consolation_finals'] = Variable<bool>(
        includeConsolationFinals.value,
      );
    }
    if (timerMinutes.present) {
      map['timer_minutes'] = Variable<int>(timerMinutes.value);
    }
    if (isWebRegistrationEnabled.present) {
      map['is_web_registration_enabled'] = Variable<bool>(
        isWebRegistrationEnabled.value,
      );
    }
    if (winnerTeamId.present) {
      map['winner_team_id'] = Variable<int>(winnerTeamId.value);
    }
    if (communityId.present) {
      map['community_id'] = Variable<String>(communityId.value);
    }
    if (communityName.present) {
      map['community_name'] = Variable<String>(communityName.value);
    }
    if (courtCount.present) {
      map['court_count'] = Variable<int>(courtCount.value);
    }
    if (lunchDuration.present) {
      map['lunch_duration'] = Variable<int>(lunchDuration.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (venueCourtId.present) {
      map['venue_court_id'] = Variable<int>(venueCourtId.value);
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
          ..write('startDate: $startDate, ')
          ..write('mode: $mode, ')
          ..write('isActive: $isActive, ')
          ..write('isPublished: $isPublished, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('webUrl: $webUrl, ')
          ..write('cloudId: $cloudId, ')
          ..write('isReadOnly: $isReadOnly, ')
          ..write('groupCount: $groupCount, ')
          ..write('qualifiersPerGroup: $qualifiersPerGroup, ')
          ..write('hasPlayIn: $hasPlayIn, ')
          ..write('groupNames: $groupNames, ')
          ..write('twitchChannel: $twitchChannel, ')
          ..write('youtubeVideoId: $youtubeVideoId, ')
          ..write('customTicker: $customTicker, ')
          ..write('winPoints: $winPoints, ')
          ..write('drawPoints: $drawPoints, ')
          ..write('lossPoints: $lossPoints, ')
          ..write('scoringSystem: $scoringSystem, ')
          ..write('includeConsolationFinals: $includeConsolationFinals, ')
          ..write('timerMinutes: $timerMinutes, ')
          ..write('isWebRegistrationEnabled: $isWebRegistrationEnabled, ')
          ..write('winnerTeamId: $winnerTeamId, ')
          ..write('communityId: $communityId, ')
          ..write('communityName: $communityName, ')
          ..write('courtCount: $courtCount, ')
          ..write('lunchDuration: $lunchDuration, ')
          ..write('endDate: $endDate, ')
          ..write('venueCourtId: $venueCourtId, ')
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
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
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
  Set<GeneratedColumn> get $primaryKey => {tournamentId, teamId};
  @override
  TournamentTeam map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TournamentTeam(
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
      ),
    );
  }

  @override
  $TournamentTeamsTable createAlias(String alias) {
    return $TournamentTeamsTable(attachedDatabase, alias);
  }
}

class TournamentTeam extends DataClass implements Insertable<TournamentTeam> {
  final int tournamentId;
  final int teamId;
  final int groupNumber;
  final int? seed;
  const TournamentTeam({
    required this.tournamentId,
    required this.teamId,
    required this.groupNumber,
    this.seed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tournament_id'] = Variable<int>(tournamentId);
    map['team_id'] = Variable<int>(teamId);
    map['group_number'] = Variable<int>(groupNumber);
    if (!nullToAbsent || seed != null) {
      map['seed'] = Variable<int>(seed);
    }
    return map;
  }

  TournamentTeamsCompanion toCompanion(bool nullToAbsent) {
    return TournamentTeamsCompanion(
      tournamentId: Value(tournamentId),
      teamId: Value(teamId),
      groupNumber: Value(groupNumber),
      seed: seed == null && nullToAbsent ? const Value.absent() : Value(seed),
    );
  }

  factory TournamentTeam.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TournamentTeam(
      tournamentId: serializer.fromJson<int>(json['tournamentId']),
      teamId: serializer.fromJson<int>(json['teamId']),
      groupNumber: serializer.fromJson<int>(json['groupNumber']),
      seed: serializer.fromJson<int?>(json['seed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tournamentId': serializer.toJson<int>(tournamentId),
      'teamId': serializer.toJson<int>(teamId),
      'groupNumber': serializer.toJson<int>(groupNumber),
      'seed': serializer.toJson<int?>(seed),
    };
  }

  TournamentTeam copyWith({
    int? tournamentId,
    int? teamId,
    int? groupNumber,
    Value<int?> seed = const Value.absent(),
  }) => TournamentTeam(
    tournamentId: tournamentId ?? this.tournamentId,
    teamId: teamId ?? this.teamId,
    groupNumber: groupNumber ?? this.groupNumber,
    seed: seed.present ? seed.value : this.seed,
  );
  TournamentTeam copyWithCompanion(TournamentTeamsCompanion data) {
    return TournamentTeam(
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
          ..write('tournamentId: $tournamentId, ')
          ..write('teamId: $teamId, ')
          ..write('groupNumber: $groupNumber, ')
          ..write('seed: $seed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tournamentId, teamId, groupNumber, seed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TournamentTeam &&
          other.tournamentId == this.tournamentId &&
          other.teamId == this.teamId &&
          other.groupNumber == this.groupNumber &&
          other.seed == this.seed);
}

class TournamentTeamsCompanion extends UpdateCompanion<TournamentTeam> {
  final Value<int> tournamentId;
  final Value<int> teamId;
  final Value<int> groupNumber;
  final Value<int?> seed;
  final Value<int> rowid;
  const TournamentTeamsCompanion({
    this.tournamentId = const Value.absent(),
    this.teamId = const Value.absent(),
    this.groupNumber = const Value.absent(),
    this.seed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TournamentTeamsCompanion.insert({
    required int tournamentId,
    required int teamId,
    this.groupNumber = const Value.absent(),
    this.seed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : tournamentId = Value(tournamentId),
       teamId = Value(teamId);
  static Insertable<TournamentTeam> custom({
    Expression<int>? tournamentId,
    Expression<int>? teamId,
    Expression<int>? groupNumber,
    Expression<int>? seed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tournamentId != null) 'tournament_id': tournamentId,
      if (teamId != null) 'team_id': teamId,
      if (groupNumber != null) 'group_number': groupNumber,
      if (seed != null) 'seed': seed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TournamentTeamsCompanion copyWith({
    Value<int>? tournamentId,
    Value<int>? teamId,
    Value<int>? groupNumber,
    Value<int?>? seed,
    Value<int>? rowid,
  }) {
    return TournamentTeamsCompanion(
      tournamentId: tournamentId ?? this.tournamentId,
      teamId: teamId ?? this.teamId,
      groupNumber: groupNumber ?? this.groupNumber,
      seed: seed ?? this.seed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TournamentTeamsCompanion(')
          ..write('tournamentId: $tournamentId, ')
          ..write('teamId: $teamId, ')
          ..write('groupNumber: $groupNumber, ')
          ..write('seed: $seed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MatchesTable extends Matches
    with TableInfo<$MatchesTable, TournamentMatch> {
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
  static const VerificationMeta _groupNumberMeta = const VerificationMeta(
    'groupNumber',
  );
  @override
  late final GeneratedColumn<int> groupNumber = GeneratedColumn<int>(
    'group_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
    isCompleted,
    phase,
    round,
    isBye,
    groupNumber,
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
    Insertable<TournamentMatch> instance, {
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
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('phase')) {
      context.handle(
        _phaseMeta,
        phase.isAcceptableOrUnknown(data['phase']!, _phaseMeta),
      );
    }
    if (data.containsKey('round')) {
      context.handle(
        _roundMeta,
        round.isAcceptableOrUnknown(data['round']!, _roundMeta),
      );
    }
    if (data.containsKey('is_bye')) {
      context.handle(
        _isByeMeta,
        isBye.isAcceptableOrUnknown(data['is_bye']!, _isByeMeta),
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
  TournamentMatch map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TournamentMatch(
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
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      phase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phase'],
      )!,
      round: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}round'],
      )!,
      isBye: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_bye'],
      )!,
      groupNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_number'],
      ),
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

class TournamentMatch extends DataClass implements Insertable<TournamentMatch> {
  final int id;
  final int tournamentId;
  final int? homeTeamId;
  final int? awayTeamId;
  final int? homeScore;
  final int? awayScore;
  final bool isCompleted;
  final String phase;
  final int round;
  final bool isBye;
  final int? groupNumber;
  final DateTime? scheduledAt;
  final DateTime createdAt;
  const TournamentMatch({
    required this.id,
    required this.tournamentId,
    this.homeTeamId,
    this.awayTeamId,
    this.homeScore,
    this.awayScore,
    required this.isCompleted,
    required this.phase,
    required this.round,
    required this.isBye,
    this.groupNumber,
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
    map['is_completed'] = Variable<bool>(isCompleted);
    map['phase'] = Variable<String>(phase);
    map['round'] = Variable<int>(round);
    map['is_bye'] = Variable<bool>(isBye);
    if (!nullToAbsent || groupNumber != null) {
      map['group_number'] = Variable<int>(groupNumber);
    }
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
      isCompleted: Value(isCompleted),
      phase: Value(phase),
      round: Value(round),
      isBye: Value(isBye),
      groupNumber: groupNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(groupNumber),
      scheduledAt: scheduledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledAt),
      createdAt: Value(createdAt),
    );
  }

  factory TournamentMatch.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TournamentMatch(
      id: serializer.fromJson<int>(json['id']),
      tournamentId: serializer.fromJson<int>(json['tournamentId']),
      homeTeamId: serializer.fromJson<int?>(json['homeTeamId']),
      awayTeamId: serializer.fromJson<int?>(json['awayTeamId']),
      homeScore: serializer.fromJson<int?>(json['homeScore']),
      awayScore: serializer.fromJson<int?>(json['awayScore']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      phase: serializer.fromJson<String>(json['phase']),
      round: serializer.fromJson<int>(json['round']),
      isBye: serializer.fromJson<bool>(json['isBye']),
      groupNumber: serializer.fromJson<int?>(json['groupNumber']),
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
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'phase': serializer.toJson<String>(phase),
      'round': serializer.toJson<int>(round),
      'isBye': serializer.toJson<bool>(isBye),
      'groupNumber': serializer.toJson<int?>(groupNumber),
      'scheduledAt': serializer.toJson<DateTime?>(scheduledAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TournamentMatch copyWith({
    int? id,
    int? tournamentId,
    Value<int?> homeTeamId = const Value.absent(),
    Value<int?> awayTeamId = const Value.absent(),
    Value<int?> homeScore = const Value.absent(),
    Value<int?> awayScore = const Value.absent(),
    bool? isCompleted,
    String? phase,
    int? round,
    bool? isBye,
    Value<int?> groupNumber = const Value.absent(),
    Value<DateTime?> scheduledAt = const Value.absent(),
    DateTime? createdAt,
  }) => TournamentMatch(
    id: id ?? this.id,
    tournamentId: tournamentId ?? this.tournamentId,
    homeTeamId: homeTeamId.present ? homeTeamId.value : this.homeTeamId,
    awayTeamId: awayTeamId.present ? awayTeamId.value : this.awayTeamId,
    homeScore: homeScore.present ? homeScore.value : this.homeScore,
    awayScore: awayScore.present ? awayScore.value : this.awayScore,
    isCompleted: isCompleted ?? this.isCompleted,
    phase: phase ?? this.phase,
    round: round ?? this.round,
    isBye: isBye ?? this.isBye,
    groupNumber: groupNumber.present ? groupNumber.value : this.groupNumber,
    scheduledAt: scheduledAt.present ? scheduledAt.value : this.scheduledAt,
    createdAt: createdAt ?? this.createdAt,
  );
  TournamentMatch copyWithCompanion(MatchesCompanion data) {
    return TournamentMatch(
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
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      phase: data.phase.present ? data.phase.value : this.phase,
      round: data.round.present ? data.round.value : this.round,
      isBye: data.isBye.present ? data.isBye.value : this.isBye,
      groupNumber: data.groupNumber.present
          ? data.groupNumber.value
          : this.groupNumber,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TournamentMatch(')
          ..write('id: $id, ')
          ..write('tournamentId: $tournamentId, ')
          ..write('homeTeamId: $homeTeamId, ')
          ..write('awayTeamId: $awayTeamId, ')
          ..write('homeScore: $homeScore, ')
          ..write('awayScore: $awayScore, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('phase: $phase, ')
          ..write('round: $round, ')
          ..write('isBye: $isBye, ')
          ..write('groupNumber: $groupNumber, ')
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
    isCompleted,
    phase,
    round,
    isBye,
    groupNumber,
    scheduledAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TournamentMatch &&
          other.id == this.id &&
          other.tournamentId == this.tournamentId &&
          other.homeTeamId == this.homeTeamId &&
          other.awayTeamId == this.awayTeamId &&
          other.homeScore == this.homeScore &&
          other.awayScore == this.awayScore &&
          other.isCompleted == this.isCompleted &&
          other.phase == this.phase &&
          other.round == this.round &&
          other.isBye == this.isBye &&
          other.groupNumber == this.groupNumber &&
          other.scheduledAt == this.scheduledAt &&
          other.createdAt == this.createdAt);
}

class MatchesCompanion extends UpdateCompanion<TournamentMatch> {
  final Value<int> id;
  final Value<int> tournamentId;
  final Value<int?> homeTeamId;
  final Value<int?> awayTeamId;
  final Value<int?> homeScore;
  final Value<int?> awayScore;
  final Value<bool> isCompleted;
  final Value<String> phase;
  final Value<int> round;
  final Value<bool> isBye;
  final Value<int?> groupNumber;
  final Value<DateTime?> scheduledAt;
  final Value<DateTime> createdAt;
  const MatchesCompanion({
    this.id = const Value.absent(),
    this.tournamentId = const Value.absent(),
    this.homeTeamId = const Value.absent(),
    this.awayTeamId = const Value.absent(),
    this.homeScore = const Value.absent(),
    this.awayScore = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.phase = const Value.absent(),
    this.round = const Value.absent(),
    this.isBye = const Value.absent(),
    this.groupNumber = const Value.absent(),
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
    this.isCompleted = const Value.absent(),
    this.phase = const Value.absent(),
    this.round = const Value.absent(),
    this.isBye = const Value.absent(),
    this.groupNumber = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : tournamentId = Value(tournamentId);
  static Insertable<TournamentMatch> custom({
    Expression<int>? id,
    Expression<int>? tournamentId,
    Expression<int>? homeTeamId,
    Expression<int>? awayTeamId,
    Expression<int>? homeScore,
    Expression<int>? awayScore,
    Expression<bool>? isCompleted,
    Expression<String>? phase,
    Expression<int>? round,
    Expression<bool>? isBye,
    Expression<int>? groupNumber,
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
      if (isCompleted != null) 'is_completed': isCompleted,
      if (phase != null) 'phase': phase,
      if (round != null) 'round': round,
      if (isBye != null) 'is_bye': isBye,
      if (groupNumber != null) 'group_number': groupNumber,
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
    Value<bool>? isCompleted,
    Value<String>? phase,
    Value<int>? round,
    Value<bool>? isBye,
    Value<int?>? groupNumber,
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
      isCompleted: isCompleted ?? this.isCompleted,
      phase: phase ?? this.phase,
      round: round ?? this.round,
      isBye: isBye ?? this.isBye,
      groupNumber: groupNumber ?? this.groupNumber,
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
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (phase.present) {
      map['phase'] = Variable<String>(phase.value);
    }
    if (round.present) {
      map['round'] = Variable<int>(round.value);
    }
    if (isBye.present) {
      map['is_bye'] = Variable<bool>(isBye.value);
    }
    if (groupNumber.present) {
      map['group_number'] = Variable<int>(groupNumber.value);
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
          ..write('isCompleted: $isCompleted, ')
          ..write('phase: $phase, ')
          ..write('round: $round, ')
          ..write('isBye: $isBye, ')
          ..write('groupNumber: $groupNumber, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CourtsTable extends Courts with TableInfo<$CourtsTable, Court> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CourtsTable(this.attachedDatabase, [this._alias]);
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
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tournaments (id) ON DELETE CASCADE',
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hoopsMeta = const VerificationMeta('hoops');
  @override
  late final GeneratedColumn<int> hoops = GeneratedColumn<int>(
    'hoops',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _netsStatusMeta = const VerificationMeta(
    'netsStatus',
  );
  @override
  late final GeneratedColumn<String> netsStatus = GeneratedColumn<String>(
    'nets_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('stoffa'),
  );
  static const VerificationMeta _courtStatusMeta = const VerificationMeta(
    'courtStatus',
  );
  @override
  late final GeneratedColumn<String> courtStatus = GeneratedColumn<String>(
    'court_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('giocabile'),
  );
  static const VerificationMeta _linesStatusMeta = const VerificationMeta(
    'linesStatus',
  );
  @override
  late final GeneratedColumn<String> linesStatus = GeneratedColumn<String>(
    'lines_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('visibili'),
  );
  static const VerificationMeta _hasLightsMeta = const VerificationMeta(
    'hasLights',
  );
  @override
  late final GeneratedColumn<bool> hasLights = GeneratedColumn<bool>(
    'has_lights',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_lights" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _starsMeta = const VerificationMeta('stars');
  @override
  late final GeneratedColumn<int> stars = GeneratedColumn<int>(
    'stars',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('trnmnt'),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
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
  List<GeneratedColumn> get $columns => [
    id,
    tournamentId,
    name,
    description,
    latitude,
    longitude,
    hoops,
    netsStatus,
    courtStatus,
    linesStatus,
    hasLights,
    stars,
    cloudId,
    source,
    sourceId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'courts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Court> instance, {
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
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('hoops')) {
      context.handle(
        _hoopsMeta,
        hoops.isAcceptableOrUnknown(data['hoops']!, _hoopsMeta),
      );
    }
    if (data.containsKey('nets_status')) {
      context.handle(
        _netsStatusMeta,
        netsStatus.isAcceptableOrUnknown(data['nets_status']!, _netsStatusMeta),
      );
    }
    if (data.containsKey('court_status')) {
      context.handle(
        _courtStatusMeta,
        courtStatus.isAcceptableOrUnknown(
          data['court_status']!,
          _courtStatusMeta,
        ),
      );
    }
    if (data.containsKey('lines_status')) {
      context.handle(
        _linesStatusMeta,
        linesStatus.isAcceptableOrUnknown(
          data['lines_status']!,
          _linesStatusMeta,
        ),
      );
    }
    if (data.containsKey('has_lights')) {
      context.handle(
        _hasLightsMeta,
        hasLights.isAcceptableOrUnknown(data['has_lights']!, _hasLightsMeta),
      );
    }
    if (data.containsKey('stars')) {
      context.handle(
        _starsMeta,
        stars.isAcceptableOrUnknown(data['stars']!, _starsMeta),
      );
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
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
  Court map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Court(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tournamentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tournament_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      hoops: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hoops'],
      )!,
      netsStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nets_status'],
      )!,
      courtStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}court_status'],
      )!,
      linesStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lines_status'],
      )!,
      hasLights: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_lights'],
      )!,
      stars: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stars'],
      )!,
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CourtsTable createAlias(String alias) {
    return $CourtsTable(attachedDatabase, alias);
  }
}

class Court extends DataClass implements Insertable<Court> {
  final int id;
  final int? tournamentId;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final int hoops;
  final String netsStatus;
  final String courtStatus;
  final String linesStatus;
  final bool hasLights;
  final int stars;
  final String? cloudId;
  final String source;
  final String? sourceId;
  final DateTime createdAt;
  const Court({
    required this.id,
    this.tournamentId,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.hoops,
    required this.netsStatus,
    required this.courtStatus,
    required this.linesStatus,
    required this.hasLights,
    required this.stars,
    this.cloudId,
    required this.source,
    this.sourceId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || tournamentId != null) {
      map['tournament_id'] = Variable<int>(tournamentId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['hoops'] = Variable<int>(hoops);
    map['nets_status'] = Variable<String>(netsStatus);
    map['court_status'] = Variable<String>(courtStatus);
    map['lines_status'] = Variable<String>(linesStatus);
    map['has_lights'] = Variable<bool>(hasLights);
    map['stars'] = Variable<int>(stars);
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CourtsCompanion toCompanion(bool nullToAbsent) {
    return CourtsCompanion(
      id: Value(id),
      tournamentId: tournamentId == null && nullToAbsent
          ? const Value.absent()
          : Value(tournamentId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      latitude: Value(latitude),
      longitude: Value(longitude),
      hoops: Value(hoops),
      netsStatus: Value(netsStatus),
      courtStatus: Value(courtStatus),
      linesStatus: Value(linesStatus),
      hasLights: Value(hasLights),
      stars: Value(stars),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
      source: Value(source),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      createdAt: Value(createdAt),
    );
  }

  factory Court.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Court(
      id: serializer.fromJson<int>(json['id']),
      tournamentId: serializer.fromJson<int?>(json['tournamentId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      hoops: serializer.fromJson<int>(json['hoops']),
      netsStatus: serializer.fromJson<String>(json['netsStatus']),
      courtStatus: serializer.fromJson<String>(json['courtStatus']),
      linesStatus: serializer.fromJson<String>(json['linesStatus']),
      hasLights: serializer.fromJson<bool>(json['hasLights']),
      stars: serializer.fromJson<int>(json['stars']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
      source: serializer.fromJson<String>(json['source']),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tournamentId': serializer.toJson<int?>(tournamentId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'hoops': serializer.toJson<int>(hoops),
      'netsStatus': serializer.toJson<String>(netsStatus),
      'courtStatus': serializer.toJson<String>(courtStatus),
      'linesStatus': serializer.toJson<String>(linesStatus),
      'hasLights': serializer.toJson<bool>(hasLights),
      'stars': serializer.toJson<int>(stars),
      'cloudId': serializer.toJson<String?>(cloudId),
      'source': serializer.toJson<String>(source),
      'sourceId': serializer.toJson<String?>(sourceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Court copyWith({
    int? id,
    Value<int?> tournamentId = const Value.absent(),
    String? name,
    Value<String?> description = const Value.absent(),
    double? latitude,
    double? longitude,
    int? hoops,
    String? netsStatus,
    String? courtStatus,
    String? linesStatus,
    bool? hasLights,
    int? stars,
    Value<String?> cloudId = const Value.absent(),
    String? source,
    Value<String?> sourceId = const Value.absent(),
    DateTime? createdAt,
  }) => Court(
    id: id ?? this.id,
    tournamentId: tournamentId.present ? tournamentId.value : this.tournamentId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    hoops: hoops ?? this.hoops,
    netsStatus: netsStatus ?? this.netsStatus,
    courtStatus: courtStatus ?? this.courtStatus,
    linesStatus: linesStatus ?? this.linesStatus,
    hasLights: hasLights ?? this.hasLights,
    stars: stars ?? this.stars,
    cloudId: cloudId.present ? cloudId.value : this.cloudId,
    source: source ?? this.source,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
    createdAt: createdAt ?? this.createdAt,
  );
  Court copyWithCompanion(CourtsCompanion data) {
    return Court(
      id: data.id.present ? data.id.value : this.id,
      tournamentId: data.tournamentId.present
          ? data.tournamentId.value
          : this.tournamentId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      hoops: data.hoops.present ? data.hoops.value : this.hoops,
      netsStatus: data.netsStatus.present
          ? data.netsStatus.value
          : this.netsStatus,
      courtStatus: data.courtStatus.present
          ? data.courtStatus.value
          : this.courtStatus,
      linesStatus: data.linesStatus.present
          ? data.linesStatus.value
          : this.linesStatus,
      hasLights: data.hasLights.present ? data.hasLights.value : this.hasLights,
      stars: data.stars.present ? data.stars.value : this.stars,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      source: data.source.present ? data.source.value : this.source,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Court(')
          ..write('id: $id, ')
          ..write('tournamentId: $tournamentId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('hoops: $hoops, ')
          ..write('netsStatus: $netsStatus, ')
          ..write('courtStatus: $courtStatus, ')
          ..write('linesStatus: $linesStatus, ')
          ..write('hasLights: $hasLights, ')
          ..write('stars: $stars, ')
          ..write('cloudId: $cloudId, ')
          ..write('source: $source, ')
          ..write('sourceId: $sourceId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tournamentId,
    name,
    description,
    latitude,
    longitude,
    hoops,
    netsStatus,
    courtStatus,
    linesStatus,
    hasLights,
    stars,
    cloudId,
    source,
    sourceId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Court &&
          other.id == this.id &&
          other.tournamentId == this.tournamentId &&
          other.name == this.name &&
          other.description == this.description &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.hoops == this.hoops &&
          other.netsStatus == this.netsStatus &&
          other.courtStatus == this.courtStatus &&
          other.linesStatus == this.linesStatus &&
          other.hasLights == this.hasLights &&
          other.stars == this.stars &&
          other.cloudId == this.cloudId &&
          other.source == this.source &&
          other.sourceId == this.sourceId &&
          other.createdAt == this.createdAt);
}

class CourtsCompanion extends UpdateCompanion<Court> {
  final Value<int> id;
  final Value<int?> tournamentId;
  final Value<String> name;
  final Value<String?> description;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<int> hoops;
  final Value<String> netsStatus;
  final Value<String> courtStatus;
  final Value<String> linesStatus;
  final Value<bool> hasLights;
  final Value<int> stars;
  final Value<String?> cloudId;
  final Value<String> source;
  final Value<String?> sourceId;
  final Value<DateTime> createdAt;
  const CourtsCompanion({
    this.id = const Value.absent(),
    this.tournamentId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.hoops = const Value.absent(),
    this.netsStatus = const Value.absent(),
    this.courtStatus = const Value.absent(),
    this.linesStatus = const Value.absent(),
    this.hasLights = const Value.absent(),
    this.stars = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CourtsCompanion.insert({
    this.id = const Value.absent(),
    this.tournamentId = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    required double latitude,
    required double longitude,
    this.hoops = const Value.absent(),
    this.netsStatus = const Value.absent(),
    this.courtStatus = const Value.absent(),
    this.linesStatus = const Value.absent(),
    this.hasLights = const Value.absent(),
    this.stars = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       latitude = Value(latitude),
       longitude = Value(longitude);
  static Insertable<Court> custom({
    Expression<int>? id,
    Expression<int>? tournamentId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? hoops,
    Expression<String>? netsStatus,
    Expression<String>? courtStatus,
    Expression<String>? linesStatus,
    Expression<bool>? hasLights,
    Expression<int>? stars,
    Expression<String>? cloudId,
    Expression<String>? source,
    Expression<String>? sourceId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tournamentId != null) 'tournament_id': tournamentId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (hoops != null) 'hoops': hoops,
      if (netsStatus != null) 'nets_status': netsStatus,
      if (courtStatus != null) 'court_status': courtStatus,
      if (linesStatus != null) 'lines_status': linesStatus,
      if (hasLights != null) 'has_lights': hasLights,
      if (stars != null) 'stars': stars,
      if (cloudId != null) 'cloud_id': cloudId,
      if (source != null) 'source': source,
      if (sourceId != null) 'source_id': sourceId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CourtsCompanion copyWith({
    Value<int>? id,
    Value<int?>? tournamentId,
    Value<String>? name,
    Value<String?>? description,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<int>? hoops,
    Value<String>? netsStatus,
    Value<String>? courtStatus,
    Value<String>? linesStatus,
    Value<bool>? hasLights,
    Value<int>? stars,
    Value<String?>? cloudId,
    Value<String>? source,
    Value<String?>? sourceId,
    Value<DateTime>? createdAt,
  }) {
    return CourtsCompanion(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      hoops: hoops ?? this.hoops,
      netsStatus: netsStatus ?? this.netsStatus,
      courtStatus: courtStatus ?? this.courtStatus,
      linesStatus: linesStatus ?? this.linesStatus,
      hasLights: hasLights ?? this.hasLights,
      stars: stars ?? this.stars,
      cloudId: cloudId ?? this.cloudId,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (hoops.present) {
      map['hoops'] = Variable<int>(hoops.value);
    }
    if (netsStatus.present) {
      map['nets_status'] = Variable<String>(netsStatus.value);
    }
    if (courtStatus.present) {
      map['court_status'] = Variable<String>(courtStatus.value);
    }
    if (linesStatus.present) {
      map['lines_status'] = Variable<String>(linesStatus.value);
    }
    if (hasLights.present) {
      map['has_lights'] = Variable<bool>(hasLights.value);
    }
    if (stars.present) {
      map['stars'] = Variable<int>(stars.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CourtsCompanion(')
          ..write('id: $id, ')
          ..write('tournamentId: $tournamentId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('hoops: $hoops, ')
          ..write('netsStatus: $netsStatus, ')
          ..write('courtStatus: $courtStatus, ')
          ..write('linesStatus: $linesStatus, ')
          ..write('hasLights: $hasLights, ')
          ..write('stars: $stars, ')
          ..write('cloudId: $cloudId, ')
          ..write('source: $source, ')
          ..write('sourceId: $sourceId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CommunitiesTable communities = $CommunitiesTable(this);
  late final $TeamsTable teams = $TeamsTable(this);
  late final $TournamentsTable tournaments = $TournamentsTable(this);
  late final $TournamentTeamsTable tournamentTeams = $TournamentTeamsTable(
    this,
  );
  late final $MatchesTable matches = $MatchesTable(this);
  late final $CourtsTable courts = $CourtsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    communities,
    teams,
    tournaments,
    tournamentTeams,
    matches,
    courts,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tournaments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('courts', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CommunitiesTableCreateCompanionBuilder =
    CommunitiesCompanion Function({
      required String id,
      required String name,
      required String slug,
      Value<String?> logoUrl,
      Value<String?> inviteToken,
      Value<DateTime?> inviteTokenExpiresAt,
      Value<String?> location,
      Value<String?> instagramUrl,
      Value<String?> tiktokUrl,
      Value<bool> isOwner,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$CommunitiesTableUpdateCompanionBuilder =
    CommunitiesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> slug,
      Value<String?> logoUrl,
      Value<String?> inviteToken,
      Value<DateTime?> inviteTokenExpiresAt,
      Value<String?> location,
      Value<String?> instagramUrl,
      Value<String?> tiktokUrl,
      Value<bool> isOwner,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$CommunitiesTableReferences
    extends BaseReferences<_$AppDatabase, $CommunitiesTable, Community> {
  $$CommunitiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TeamsTable, List<Team>> _teamsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.teams,
    aliasName: $_aliasNameGenerator(db.communities.id, db.teams.communityId),
  );

  $$TeamsTableProcessedTableManager get teamsRefs {
    final manager = $$TeamsTableTableManager(
      $_db,
      $_db.teams,
    ).filter((f) => f.communityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_teamsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TournamentsTable, List<Tournament>>
  _tournamentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tournaments,
    aliasName: $_aliasNameGenerator(
      db.communities.id,
      db.tournaments.communityId,
    ),
  );

  $$TournamentsTableProcessedTableManager get tournamentsRefs {
    final manager = $$TournamentsTableTableManager(
      $_db,
      $_db.tournaments,
    ).filter((f) => f.communityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tournamentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CommunitiesTableFilterComposer
    extends Composer<_$AppDatabase, $CommunitiesTable> {
  $$CommunitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inviteToken => $composableBuilder(
    column: $table.inviteToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get inviteTokenExpiresAt => $composableBuilder(
    column: $table.inviteTokenExpiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instagramUrl => $composableBuilder(
    column: $table.instagramUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tiktokUrl => $composableBuilder(
    column: $table.tiktokUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOwner => $composableBuilder(
    column: $table.isOwner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> teamsRefs(
    Expression<bool> Function($$TeamsTableFilterComposer f) f,
  ) {
    final $$TeamsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.teams,
      getReferencedColumn: (t) => t.communityId,
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
    return f(composer);
  }

  Expression<bool> tournamentsRefs(
    Expression<bool> Function($$TournamentsTableFilterComposer f) f,
  ) {
    final $$TournamentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tournaments,
      getReferencedColumn: (t) => t.communityId,
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
    return f(composer);
  }
}

class $$CommunitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $CommunitiesTable> {
  $$CommunitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inviteToken => $composableBuilder(
    column: $table.inviteToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get inviteTokenExpiresAt => $composableBuilder(
    column: $table.inviteTokenExpiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instagramUrl => $composableBuilder(
    column: $table.instagramUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tiktokUrl => $composableBuilder(
    column: $table.tiktokUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOwner => $composableBuilder(
    column: $table.isOwner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CommunitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CommunitiesTable> {
  $$CommunitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get logoUrl =>
      $composableBuilder(column: $table.logoUrl, builder: (column) => column);

  GeneratedColumn<String> get inviteToken => $composableBuilder(
    column: $table.inviteToken,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get inviteTokenExpiresAt => $composableBuilder(
    column: $table.inviteTokenExpiresAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get instagramUrl => $composableBuilder(
    column: $table.instagramUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tiktokUrl =>
      $composableBuilder(column: $table.tiktokUrl, builder: (column) => column);

  GeneratedColumn<bool> get isOwner =>
      $composableBuilder(column: $table.isOwner, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> teamsRefs<T extends Object>(
    Expression<T> Function($$TeamsTableAnnotationComposer a) f,
  ) {
    final $$TeamsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.teams,
      getReferencedColumn: (t) => t.communityId,
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
    return f(composer);
  }

  Expression<T> tournamentsRefs<T extends Object>(
    Expression<T> Function($$TournamentsTableAnnotationComposer a) f,
  ) {
    final $$TournamentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tournaments,
      getReferencedColumn: (t) => t.communityId,
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
    return f(composer);
  }
}

class $$CommunitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CommunitiesTable,
          Community,
          $$CommunitiesTableFilterComposer,
          $$CommunitiesTableOrderingComposer,
          $$CommunitiesTableAnnotationComposer,
          $$CommunitiesTableCreateCompanionBuilder,
          $$CommunitiesTableUpdateCompanionBuilder,
          (Community, $$CommunitiesTableReferences),
          Community,
          PrefetchHooks Function({bool teamsRefs, bool tournamentsRefs})
        > {
  $$CommunitiesTableTableManager(_$AppDatabase db, $CommunitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommunitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CommunitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CommunitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> slug = const Value.absent(),
                Value<String?> logoUrl = const Value.absent(),
                Value<String?> inviteToken = const Value.absent(),
                Value<DateTime?> inviteTokenExpiresAt = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> instagramUrl = const Value.absent(),
                Value<String?> tiktokUrl = const Value.absent(),
                Value<bool> isOwner = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CommunitiesCompanion(
                id: id,
                name: name,
                slug: slug,
                logoUrl: logoUrl,
                inviteToken: inviteToken,
                inviteTokenExpiresAt: inviteTokenExpiresAt,
                location: location,
                instagramUrl: instagramUrl,
                tiktokUrl: tiktokUrl,
                isOwner: isOwner,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String slug,
                Value<String?> logoUrl = const Value.absent(),
                Value<String?> inviteToken = const Value.absent(),
                Value<DateTime?> inviteTokenExpiresAt = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> instagramUrl = const Value.absent(),
                Value<String?> tiktokUrl = const Value.absent(),
                Value<bool> isOwner = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CommunitiesCompanion.insert(
                id: id,
                name: name,
                slug: slug,
                logoUrl: logoUrl,
                inviteToken: inviteToken,
                inviteTokenExpiresAt: inviteTokenExpiresAt,
                location: location,
                instagramUrl: instagramUrl,
                tiktokUrl: tiktokUrl,
                isOwner: isOwner,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CommunitiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({teamsRefs = false, tournamentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (teamsRefs) db.teams,
                    if (tournamentsRefs) db.tournaments,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (teamsRefs)
                        await $_getPrefetchedData<
                          Community,
                          $CommunitiesTable,
                          Team
                        >(
                          currentTable: table,
                          referencedTable: $$CommunitiesTableReferences
                              ._teamsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CommunitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).teamsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.communityId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tournamentsRefs)
                        await $_getPrefetchedData<
                          Community,
                          $CommunitiesTable,
                          Tournament
                        >(
                          currentTable: table,
                          referencedTable: $$CommunitiesTableReferences
                              ._tournamentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CommunitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).tournamentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.communityId == item.id,
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

typedef $$CommunitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CommunitiesTable,
      Community,
      $$CommunitiesTableFilterComposer,
      $$CommunitiesTableOrderingComposer,
      $$CommunitiesTableAnnotationComposer,
      $$CommunitiesTableCreateCompanionBuilder,
      $$CommunitiesTableUpdateCompanionBuilder,
      (Community, $$CommunitiesTableReferences),
      Community,
      PrefetchHooks Function({bool teamsRefs, bool tournamentsRefs})
    >;
typedef $$TeamsTableCreateCompanionBuilder =
    TeamsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> logoPath,
      Value<String?> communityId,
      Value<DateTime> createdAt,
    });
typedef $$TeamsTableUpdateCompanionBuilder =
    TeamsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> logoPath,
      Value<String?> communityId,
      Value<DateTime> createdAt,
    });

final class $$TeamsTableReferences
    extends BaseReferences<_$AppDatabase, $TeamsTable, Team> {
  $$TeamsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CommunitiesTable _communityIdTable(_$AppDatabase db) =>
      db.communities.createAlias(
        $_aliasNameGenerator(db.teams.communityId, db.communities.id),
      );

  $$CommunitiesTableProcessedTableManager? get communityId {
    final $_column = $_itemColumn<String>('community_id');
    if ($_column == null) return null;
    final manager = $$CommunitiesTableTableManager(
      $_db,
      $_db.communities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_communityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TournamentsTable, List<Tournament>>
  _tournamentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tournaments,
    aliasName: $_aliasNameGenerator(db.teams.id, db.tournaments.winnerTeamId),
  );

  $$TournamentsTableProcessedTableManager get tournamentsRefs {
    final manager = $$TournamentsTableTableManager(
      $_db,
      $_db.tournaments,
    ).filter((f) => f.winnerTeamId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tournamentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

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

  static MultiTypedResultKey<$MatchesTable, List<TournamentMatch>>
  _homeMatchesTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.matches,
    aliasName: $_aliasNameGenerator(db.teams.id, db.matches.homeTeamId),
  );

  $$MatchesTableProcessedTableManager get homeMatches {
    final manager = $$MatchesTableTableManager(
      $_db,
      $_db.matches,
    ).filter((f) => f.homeTeamId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_homeMatchesTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MatchesTable, List<TournamentMatch>>
  _awayMatchesTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.matches,
    aliasName: $_aliasNameGenerator(db.teams.id, db.matches.awayTeamId),
  );

  $$MatchesTableProcessedTableManager get awayMatches {
    final manager = $$MatchesTableTableManager(
      $_db,
      $_db.matches,
    ).filter((f) => f.awayTeamId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_awayMatchesTable($_db));
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

  $$CommunitiesTableFilterComposer get communityId {
    final $$CommunitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.communityId,
      referencedTable: $db.communities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommunitiesTableFilterComposer(
            $db: $db,
            $table: $db.communities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tournamentsRefs(
    Expression<bool> Function($$TournamentsTableFilterComposer f) f,
  ) {
    final $$TournamentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tournaments,
      getReferencedColumn: (t) => t.winnerTeamId,
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
    return f(composer);
  }

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

  Expression<bool> homeMatches(
    Expression<bool> Function($$MatchesTableFilterComposer f) f,
  ) {
    final $$MatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.homeTeamId,
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

  Expression<bool> awayMatches(
    Expression<bool> Function($$MatchesTableFilterComposer f) f,
  ) {
    final $$MatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.awayTeamId,
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

  $$CommunitiesTableOrderingComposer get communityId {
    final $$CommunitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.communityId,
      referencedTable: $db.communities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommunitiesTableOrderingComposer(
            $db: $db,
            $table: $db.communities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  $$CommunitiesTableAnnotationComposer get communityId {
    final $$CommunitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.communityId,
      referencedTable: $db.communities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommunitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.communities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> tournamentsRefs<T extends Object>(
    Expression<T> Function($$TournamentsTableAnnotationComposer a) f,
  ) {
    final $$TournamentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tournaments,
      getReferencedColumn: (t) => t.winnerTeamId,
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
    return f(composer);
  }

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

  Expression<T> homeMatches<T extends Object>(
    Expression<T> Function($$MatchesTableAnnotationComposer a) f,
  ) {
    final $$MatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.homeTeamId,
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

  Expression<T> awayMatches<T extends Object>(
    Expression<T> Function($$MatchesTableAnnotationComposer a) f,
  ) {
    final $$MatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.awayTeamId,
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
          PrefetchHooks Function({
            bool communityId,
            bool tournamentsRefs,
            bool tournamentTeamsRefs,
            bool homeMatches,
            bool awayMatches,
          })
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
                Value<String?> communityId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TeamsCompanion(
                id: id,
                name: name,
                logoPath: logoPath,
                communityId: communityId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> logoPath = const Value.absent(),
                Value<String?> communityId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TeamsCompanion.insert(
                id: id,
                name: name,
                logoPath: logoPath,
                communityId: communityId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TeamsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                communityId = false,
                tournamentsRefs = false,
                tournamentTeamsRefs = false,
                homeMatches = false,
                awayMatches = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tournamentsRefs) db.tournaments,
                    if (tournamentTeamsRefs) db.tournamentTeams,
                    if (homeMatches) db.matches,
                    if (awayMatches) db.matches,
                  ],
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
                        if (communityId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.communityId,
                                    referencedTable: $$TeamsTableReferences
                                        ._communityIdTable(db),
                                    referencedColumn: $$TeamsTableReferences
                                        ._communityIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tournamentsRefs)
                        await $_getPrefetchedData<
                          Team,
                          $TeamsTable,
                          Tournament
                        >(
                          currentTable: table,
                          referencedTable: $$TeamsTableReferences
                              ._tournamentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TeamsTableReferences(
                                db,
                                table,
                                p0,
                              ).tournamentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.winnerTeamId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tournamentTeamsRefs)
                        await $_getPrefetchedData<
                          Team,
                          $TeamsTable,
                          TournamentTeam
                        >(
                          currentTable: table,
                          referencedTable: $$TeamsTableReferences
                              ._tournamentTeamsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TeamsTableReferences(
                                db,
                                table,
                                p0,
                              ).tournamentTeamsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.teamId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (homeMatches)
                        await $_getPrefetchedData<
                          Team,
                          $TeamsTable,
                          TournamentMatch
                        >(
                          currentTable: table,
                          referencedTable: $$TeamsTableReferences
                              ._homeMatchesTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TeamsTableReferences(db, table, p0).homeMatches,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.homeTeamId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (awayMatches)
                        await $_getPrefetchedData<
                          Team,
                          $TeamsTable,
                          TournamentMatch
                        >(
                          currentTable: table,
                          referencedTable: $$TeamsTableReferences
                              ._awayMatchesTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TeamsTableReferences(db, table, p0).awayMatches,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.awayTeamId == item.id,
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
      PrefetchHooks Function({
        bool communityId,
        bool tournamentsRefs,
        bool tournamentTeamsRefs,
        bool homeMatches,
        bool awayMatches,
      })
    >;
typedef $$TournamentsTableCreateCompanionBuilder =
    TournamentsCompanion Function({
      Value<int> id,
      required String name,
      required String location,
      Value<DateTime?> startDate,
      Value<String> mode,
      Value<bool> isActive,
      Value<bool> isPublished,
      Value<DateTime?> publishedAt,
      Value<String?> webUrl,
      Value<String?> cloudId,
      Value<bool> isReadOnly,
      Value<int> groupCount,
      Value<int> qualifiersPerGroup,
      Value<bool> hasPlayIn,
      Value<String?> groupNames,
      Value<String?> twitchChannel,
      Value<String?> youtubeVideoId,
      Value<String?> customTicker,
      Value<int> winPoints,
      Value<int> drawPoints,
      Value<int> lossPoints,
      Value<String> scoringSystem,
      Value<bool> includeConsolationFinals,
      Value<int> timerMinutes,
      Value<bool> isWebRegistrationEnabled,
      Value<int?> winnerTeamId,
      Value<String?> communityId,
      Value<String?> communityName,
      Value<int> courtCount,
      Value<int> lunchDuration,
      Value<DateTime?> endDate,
      Value<int?> venueCourtId,
      Value<DateTime> createdAt,
    });
typedef $$TournamentsTableUpdateCompanionBuilder =
    TournamentsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> location,
      Value<DateTime?> startDate,
      Value<String> mode,
      Value<bool> isActive,
      Value<bool> isPublished,
      Value<DateTime?> publishedAt,
      Value<String?> webUrl,
      Value<String?> cloudId,
      Value<bool> isReadOnly,
      Value<int> groupCount,
      Value<int> qualifiersPerGroup,
      Value<bool> hasPlayIn,
      Value<String?> groupNames,
      Value<String?> twitchChannel,
      Value<String?> youtubeVideoId,
      Value<String?> customTicker,
      Value<int> winPoints,
      Value<int> drawPoints,
      Value<int> lossPoints,
      Value<String> scoringSystem,
      Value<bool> includeConsolationFinals,
      Value<int> timerMinutes,
      Value<bool> isWebRegistrationEnabled,
      Value<int?> winnerTeamId,
      Value<String?> communityId,
      Value<String?> communityName,
      Value<int> courtCount,
      Value<int> lunchDuration,
      Value<DateTime?> endDate,
      Value<int?> venueCourtId,
      Value<DateTime> createdAt,
    });

final class $$TournamentsTableReferences
    extends BaseReferences<_$AppDatabase, $TournamentsTable, Tournament> {
  $$TournamentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TeamsTable _winnerTeamIdTable(_$AppDatabase db) =>
      db.teams.createAlias(
        $_aliasNameGenerator(db.tournaments.winnerTeamId, db.teams.id),
      );

  $$TeamsTableProcessedTableManager? get winnerTeamId {
    final $_column = $_itemColumn<int>('winner_team_id');
    if ($_column == null) return null;
    final manager = $$TeamsTableTableManager(
      $_db,
      $_db.teams,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_winnerTeamIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CommunitiesTable _communityIdTable(_$AppDatabase db) =>
      db.communities.createAlias(
        $_aliasNameGenerator(db.tournaments.communityId, db.communities.id),
      );

  $$CommunitiesTableProcessedTableManager? get communityId {
    final $_column = $_itemColumn<String>('community_id');
    if ($_column == null) return null;
    final manager = $$CommunitiesTableTableManager(
      $_db,
      $_db.communities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_communityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

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

  static MultiTypedResultKey<$MatchesTable, List<TournamentMatch>>
  _matchesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
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

  static MultiTypedResultKey<$CourtsTable, List<Court>> _tournamentCourtsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.courts,
    aliasName: $_aliasNameGenerator(db.tournaments.id, db.courts.tournamentId),
  );

  $$CourtsTableProcessedTableManager get tournamentCourts {
    final manager = $$CourtsTableTableManager(
      $_db,
      $_db.courts,
    ).filter((f) => f.tournamentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tournamentCourtsTable($_db));
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

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPublished => $composableBuilder(
    column: $table.isPublished,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get webUrl => $composableBuilder(
    column: $table.webUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isReadOnly => $composableBuilder(
    column: $table.isReadOnly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get groupCount => $composableBuilder(
    column: $table.groupCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qualifiersPerGroup => $composableBuilder(
    column: $table.qualifiersPerGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasPlayIn => $composableBuilder(
    column: $table.hasPlayIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupNames => $composableBuilder(
    column: $table.groupNames,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get twitchChannel => $composableBuilder(
    column: $table.twitchChannel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get youtubeVideoId => $composableBuilder(
    column: $table.youtubeVideoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customTicker => $composableBuilder(
    column: $table.customTicker,
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

  ColumnFilters<String> get scoringSystem => $composableBuilder(
    column: $table.scoringSystem,
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

  ColumnFilters<bool> get isWebRegistrationEnabled => $composableBuilder(
    column: $table.isWebRegistrationEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get communityName => $composableBuilder(
    column: $table.communityName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get courtCount => $composableBuilder(
    column: $table.courtCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lunchDuration => $composableBuilder(
    column: $table.lunchDuration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get venueCourtId => $composableBuilder(
    column: $table.venueCourtId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TeamsTableFilterComposer get winnerTeamId {
    final $$TeamsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.winnerTeamId,
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

  $$CommunitiesTableFilterComposer get communityId {
    final $$CommunitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.communityId,
      referencedTable: $db.communities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommunitiesTableFilterComposer(
            $db: $db,
            $table: $db.communities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

  Expression<bool> tournamentCourts(
    Expression<bool> Function($$CourtsTableFilterComposer f) f,
  ) {
    final $$CourtsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courts,
      getReferencedColumn: (t) => t.tournamentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourtsTableFilterComposer(
            $db: $db,
            $table: $db.courts,
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

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPublished => $composableBuilder(
    column: $table.isPublished,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get webUrl => $composableBuilder(
    column: $table.webUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isReadOnly => $composableBuilder(
    column: $table.isReadOnly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get groupCount => $composableBuilder(
    column: $table.groupCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qualifiersPerGroup => $composableBuilder(
    column: $table.qualifiersPerGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasPlayIn => $composableBuilder(
    column: $table.hasPlayIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupNames => $composableBuilder(
    column: $table.groupNames,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get twitchChannel => $composableBuilder(
    column: $table.twitchChannel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get youtubeVideoId => $composableBuilder(
    column: $table.youtubeVideoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customTicker => $composableBuilder(
    column: $table.customTicker,
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

  ColumnOrderings<String> get scoringSystem => $composableBuilder(
    column: $table.scoringSystem,
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

  ColumnOrderings<bool> get isWebRegistrationEnabled => $composableBuilder(
    column: $table.isWebRegistrationEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get communityName => $composableBuilder(
    column: $table.communityName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get courtCount => $composableBuilder(
    column: $table.courtCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lunchDuration => $composableBuilder(
    column: $table.lunchDuration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get venueCourtId => $composableBuilder(
    column: $table.venueCourtId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TeamsTableOrderingComposer get winnerTeamId {
    final $$TeamsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.winnerTeamId,
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

  $$CommunitiesTableOrderingComposer get communityId {
    final $$CommunitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.communityId,
      referencedTable: $db.communities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommunitiesTableOrderingComposer(
            $db: $db,
            $table: $db.communities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isPublished => $composableBuilder(
    column: $table.isPublished,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get webUrl =>
      $composableBuilder(column: $table.webUrl, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumn<bool> get isReadOnly => $composableBuilder(
    column: $table.isReadOnly,
    builder: (column) => column,
  );

  GeneratedColumn<int> get groupCount => $composableBuilder(
    column: $table.groupCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get qualifiersPerGroup => $composableBuilder(
    column: $table.qualifiersPerGroup,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasPlayIn =>
      $composableBuilder(column: $table.hasPlayIn, builder: (column) => column);

  GeneratedColumn<String> get groupNames => $composableBuilder(
    column: $table.groupNames,
    builder: (column) => column,
  );

  GeneratedColumn<String> get twitchChannel => $composableBuilder(
    column: $table.twitchChannel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get youtubeVideoId => $composableBuilder(
    column: $table.youtubeVideoId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customTicker => $composableBuilder(
    column: $table.customTicker,
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

  GeneratedColumn<String> get scoringSystem => $composableBuilder(
    column: $table.scoringSystem,
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

  GeneratedColumn<bool> get isWebRegistrationEnabled => $composableBuilder(
    column: $table.isWebRegistrationEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get communityName => $composableBuilder(
    column: $table.communityName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get courtCount => $composableBuilder(
    column: $table.courtCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lunchDuration => $composableBuilder(
    column: $table.lunchDuration,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<int> get venueCourtId => $composableBuilder(
    column: $table.venueCourtId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TeamsTableAnnotationComposer get winnerTeamId {
    final $$TeamsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.winnerTeamId,
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

  $$CommunitiesTableAnnotationComposer get communityId {
    final $$CommunitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.communityId,
      referencedTable: $db.communities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommunitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.communities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

  Expression<T> tournamentCourts<T extends Object>(
    Expression<T> Function($$CourtsTableAnnotationComposer a) f,
  ) {
    final $$CourtsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courts,
      getReferencedColumn: (t) => t.tournamentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourtsTableAnnotationComposer(
            $db: $db,
            $table: $db.courts,
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
          PrefetchHooks Function({
            bool winnerTeamId,
            bool communityId,
            bool tournamentTeamsRefs,
            bool matchesRefs,
            bool tournamentCourts,
          })
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
                Value<DateTime?> startDate = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isPublished = const Value.absent(),
                Value<DateTime?> publishedAt = const Value.absent(),
                Value<String?> webUrl = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                Value<bool> isReadOnly = const Value.absent(),
                Value<int> groupCount = const Value.absent(),
                Value<int> qualifiersPerGroup = const Value.absent(),
                Value<bool> hasPlayIn = const Value.absent(),
                Value<String?> groupNames = const Value.absent(),
                Value<String?> twitchChannel = const Value.absent(),
                Value<String?> youtubeVideoId = const Value.absent(),
                Value<String?> customTicker = const Value.absent(),
                Value<int> winPoints = const Value.absent(),
                Value<int> drawPoints = const Value.absent(),
                Value<int> lossPoints = const Value.absent(),
                Value<String> scoringSystem = const Value.absent(),
                Value<bool> includeConsolationFinals = const Value.absent(),
                Value<int> timerMinutes = const Value.absent(),
                Value<bool> isWebRegistrationEnabled = const Value.absent(),
                Value<int?> winnerTeamId = const Value.absent(),
                Value<String?> communityId = const Value.absent(),
                Value<String?> communityName = const Value.absent(),
                Value<int> courtCount = const Value.absent(),
                Value<int> lunchDuration = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<int?> venueCourtId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TournamentsCompanion(
                id: id,
                name: name,
                location: location,
                startDate: startDate,
                mode: mode,
                isActive: isActive,
                isPublished: isPublished,
                publishedAt: publishedAt,
                webUrl: webUrl,
                cloudId: cloudId,
                isReadOnly: isReadOnly,
                groupCount: groupCount,
                qualifiersPerGroup: qualifiersPerGroup,
                hasPlayIn: hasPlayIn,
                groupNames: groupNames,
                twitchChannel: twitchChannel,
                youtubeVideoId: youtubeVideoId,
                customTicker: customTicker,
                winPoints: winPoints,
                drawPoints: drawPoints,
                lossPoints: lossPoints,
                scoringSystem: scoringSystem,
                includeConsolationFinals: includeConsolationFinals,
                timerMinutes: timerMinutes,
                isWebRegistrationEnabled: isWebRegistrationEnabled,
                winnerTeamId: winnerTeamId,
                communityId: communityId,
                communityName: communityName,
                courtCount: courtCount,
                lunchDuration: lunchDuration,
                endDate: endDate,
                venueCourtId: venueCourtId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String location,
                Value<DateTime?> startDate = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isPublished = const Value.absent(),
                Value<DateTime?> publishedAt = const Value.absent(),
                Value<String?> webUrl = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                Value<bool> isReadOnly = const Value.absent(),
                Value<int> groupCount = const Value.absent(),
                Value<int> qualifiersPerGroup = const Value.absent(),
                Value<bool> hasPlayIn = const Value.absent(),
                Value<String?> groupNames = const Value.absent(),
                Value<String?> twitchChannel = const Value.absent(),
                Value<String?> youtubeVideoId = const Value.absent(),
                Value<String?> customTicker = const Value.absent(),
                Value<int> winPoints = const Value.absent(),
                Value<int> drawPoints = const Value.absent(),
                Value<int> lossPoints = const Value.absent(),
                Value<String> scoringSystem = const Value.absent(),
                Value<bool> includeConsolationFinals = const Value.absent(),
                Value<int> timerMinutes = const Value.absent(),
                Value<bool> isWebRegistrationEnabled = const Value.absent(),
                Value<int?> winnerTeamId = const Value.absent(),
                Value<String?> communityId = const Value.absent(),
                Value<String?> communityName = const Value.absent(),
                Value<int> courtCount = const Value.absent(),
                Value<int> lunchDuration = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<int?> venueCourtId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TournamentsCompanion.insert(
                id: id,
                name: name,
                location: location,
                startDate: startDate,
                mode: mode,
                isActive: isActive,
                isPublished: isPublished,
                publishedAt: publishedAt,
                webUrl: webUrl,
                cloudId: cloudId,
                isReadOnly: isReadOnly,
                groupCount: groupCount,
                qualifiersPerGroup: qualifiersPerGroup,
                hasPlayIn: hasPlayIn,
                groupNames: groupNames,
                twitchChannel: twitchChannel,
                youtubeVideoId: youtubeVideoId,
                customTicker: customTicker,
                winPoints: winPoints,
                drawPoints: drawPoints,
                lossPoints: lossPoints,
                scoringSystem: scoringSystem,
                includeConsolationFinals: includeConsolationFinals,
                timerMinutes: timerMinutes,
                isWebRegistrationEnabled: isWebRegistrationEnabled,
                winnerTeamId: winnerTeamId,
                communityId: communityId,
                communityName: communityName,
                courtCount: courtCount,
                lunchDuration: lunchDuration,
                endDate: endDate,
                venueCourtId: venueCourtId,
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
              ({
                winnerTeamId = false,
                communityId = false,
                tournamentTeamsRefs = false,
                matchesRefs = false,
                tournamentCourts = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tournamentTeamsRefs) db.tournamentTeams,
                    if (matchesRefs) db.matches,
                    if (tournamentCourts) db.courts,
                  ],
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
                        if (winnerTeamId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.winnerTeamId,
                                    referencedTable:
                                        $$TournamentsTableReferences
                                            ._winnerTeamIdTable(db),
                                    referencedColumn:
                                        $$TournamentsTableReferences
                                            ._winnerTeamIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (communityId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.communityId,
                                    referencedTable:
                                        $$TournamentsTableReferences
                                            ._communityIdTable(db),
                                    referencedColumn:
                                        $$TournamentsTableReferences
                                            ._communityIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
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
                          TournamentMatch
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
                      if (tournamentCourts)
                        await $_getPrefetchedData<
                          Tournament,
                          $TournamentsTable,
                          Court
                        >(
                          currentTable: table,
                          referencedTable: $$TournamentsTableReferences
                              ._tournamentCourtsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TournamentsTableReferences(
                                db,
                                table,
                                p0,
                              ).tournamentCourts,
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
      PrefetchHooks Function({
        bool winnerTeamId,
        bool communityId,
        bool tournamentTeamsRefs,
        bool matchesRefs,
        bool tournamentCourts,
      })
    >;
typedef $$TournamentTeamsTableCreateCompanionBuilder =
    TournamentTeamsCompanion Function({
      required int tournamentId,
      required int teamId,
      Value<int> groupNumber,
      Value<int?> seed,
      Value<int> rowid,
    });
typedef $$TournamentTeamsTableUpdateCompanionBuilder =
    TournamentTeamsCompanion Function({
      Value<int> tournamentId,
      Value<int> teamId,
      Value<int> groupNumber,
      Value<int?> seed,
      Value<int> rowid,
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
                Value<int> tournamentId = const Value.absent(),
                Value<int> teamId = const Value.absent(),
                Value<int> groupNumber = const Value.absent(),
                Value<int?> seed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TournamentTeamsCompanion(
                tournamentId: tournamentId,
                teamId: teamId,
                groupNumber: groupNumber,
                seed: seed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int tournamentId,
                required int teamId,
                Value<int> groupNumber = const Value.absent(),
                Value<int?> seed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TournamentTeamsCompanion.insert(
                tournamentId: tournamentId,
                teamId: teamId,
                groupNumber: groupNumber,
                seed: seed,
                rowid: rowid,
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
      Value<bool> isCompleted,
      Value<String> phase,
      Value<int> round,
      Value<bool> isBye,
      Value<int?> groupNumber,
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
      Value<bool> isCompleted,
      Value<String> phase,
      Value<int> round,
      Value<bool> isBye,
      Value<int?> groupNumber,
      Value<DateTime?> scheduledAt,
      Value<DateTime> createdAt,
    });

final class $$MatchesTableReferences
    extends BaseReferences<_$AppDatabase, $MatchesTable, TournamentMatch> {
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

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get round => $composableBuilder(
    column: $table.round,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBye => $composableBuilder(
    column: $table.isBye,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get groupNumber => $composableBuilder(
    column: $table.groupNumber,
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

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get round => $composableBuilder(
    column: $table.round,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBye => $composableBuilder(
    column: $table.isBye,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get groupNumber => $composableBuilder(
    column: $table.groupNumber,
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

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phase =>
      $composableBuilder(column: $table.phase, builder: (column) => column);

  GeneratedColumn<int> get round =>
      $composableBuilder(column: $table.round, builder: (column) => column);

  GeneratedColumn<bool> get isBye =>
      $composableBuilder(column: $table.isBye, builder: (column) => column);

  GeneratedColumn<int> get groupNumber => $composableBuilder(
    column: $table.groupNumber,
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
          TournamentMatch,
          $$MatchesTableFilterComposer,
          $$MatchesTableOrderingComposer,
          $$MatchesTableAnnotationComposer,
          $$MatchesTableCreateCompanionBuilder,
          $$MatchesTableUpdateCompanionBuilder,
          (TournamentMatch, $$MatchesTableReferences),
          TournamentMatch,
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
                Value<bool> isCompleted = const Value.absent(),
                Value<String> phase = const Value.absent(),
                Value<int> round = const Value.absent(),
                Value<bool> isBye = const Value.absent(),
                Value<int?> groupNumber = const Value.absent(),
                Value<DateTime?> scheduledAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MatchesCompanion(
                id: id,
                tournamentId: tournamentId,
                homeTeamId: homeTeamId,
                awayTeamId: awayTeamId,
                homeScore: homeScore,
                awayScore: awayScore,
                isCompleted: isCompleted,
                phase: phase,
                round: round,
                isBye: isBye,
                groupNumber: groupNumber,
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
                Value<bool> isCompleted = const Value.absent(),
                Value<String> phase = const Value.absent(),
                Value<int> round = const Value.absent(),
                Value<bool> isBye = const Value.absent(),
                Value<int?> groupNumber = const Value.absent(),
                Value<DateTime?> scheduledAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MatchesCompanion.insert(
                id: id,
                tournamentId: tournamentId,
                homeTeamId: homeTeamId,
                awayTeamId: awayTeamId,
                homeScore: homeScore,
                awayScore: awayScore,
                isCompleted: isCompleted,
                phase: phase,
                round: round,
                isBye: isBye,
                groupNumber: groupNumber,
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
      TournamentMatch,
      $$MatchesTableFilterComposer,
      $$MatchesTableOrderingComposer,
      $$MatchesTableAnnotationComposer,
      $$MatchesTableCreateCompanionBuilder,
      $$MatchesTableUpdateCompanionBuilder,
      (TournamentMatch, $$MatchesTableReferences),
      TournamentMatch,
      PrefetchHooks Function({
        bool tournamentId,
        bool homeTeamId,
        bool awayTeamId,
      })
    >;
typedef $$CourtsTableCreateCompanionBuilder =
    CourtsCompanion Function({
      Value<int> id,
      Value<int?> tournamentId,
      required String name,
      Value<String?> description,
      required double latitude,
      required double longitude,
      Value<int> hoops,
      Value<String> netsStatus,
      Value<String> courtStatus,
      Value<String> linesStatus,
      Value<bool> hasLights,
      Value<int> stars,
      Value<String?> cloudId,
      Value<String> source,
      Value<String?> sourceId,
      Value<DateTime> createdAt,
    });
typedef $$CourtsTableUpdateCompanionBuilder =
    CourtsCompanion Function({
      Value<int> id,
      Value<int?> tournamentId,
      Value<String> name,
      Value<String?> description,
      Value<double> latitude,
      Value<double> longitude,
      Value<int> hoops,
      Value<String> netsStatus,
      Value<String> courtStatus,
      Value<String> linesStatus,
      Value<bool> hasLights,
      Value<int> stars,
      Value<String?> cloudId,
      Value<String> source,
      Value<String?> sourceId,
      Value<DateTime> createdAt,
    });

final class $$CourtsTableReferences
    extends BaseReferences<_$AppDatabase, $CourtsTable, Court> {
  $$CourtsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TournamentsTable _tournamentIdTable(_$AppDatabase db) =>
      db.tournaments.createAlias(
        $_aliasNameGenerator(db.courts.tournamentId, db.tournaments.id),
      );

  $$TournamentsTableProcessedTableManager? get tournamentId {
    final $_column = $_itemColumn<int>('tournament_id');
    if ($_column == null) return null;
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
}

class $$CourtsTableFilterComposer
    extends Composer<_$AppDatabase, $CourtsTable> {
  $$CourtsTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hoops => $composableBuilder(
    column: $table.hoops,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get netsStatus => $composableBuilder(
    column: $table.netsStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courtStatus => $composableBuilder(
    column: $table.courtStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linesStatus => $composableBuilder(
    column: $table.linesStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasLights => $composableBuilder(
    column: $table.hasLights,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stars => $composableBuilder(
    column: $table.stars,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
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
}

class $$CourtsTableOrderingComposer
    extends Composer<_$AppDatabase, $CourtsTable> {
  $$CourtsTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hoops => $composableBuilder(
    column: $table.hoops,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get netsStatus => $composableBuilder(
    column: $table.netsStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courtStatus => $composableBuilder(
    column: $table.courtStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linesStatus => $composableBuilder(
    column: $table.linesStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasLights => $composableBuilder(
    column: $table.hasLights,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stars => $composableBuilder(
    column: $table.stars,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
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
}

class $$CourtsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CourtsTable> {
  $$CourtsTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<int> get hoops =>
      $composableBuilder(column: $table.hoops, builder: (column) => column);

  GeneratedColumn<String> get netsStatus => $composableBuilder(
    column: $table.netsStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get courtStatus => $composableBuilder(
    column: $table.courtStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get linesStatus => $composableBuilder(
    column: $table.linesStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasLights =>
      $composableBuilder(column: $table.hasLights, builder: (column) => column);

  GeneratedColumn<int> get stars =>
      $composableBuilder(column: $table.stars, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

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
}

class $$CourtsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CourtsTable,
          Court,
          $$CourtsTableFilterComposer,
          $$CourtsTableOrderingComposer,
          $$CourtsTableAnnotationComposer,
          $$CourtsTableCreateCompanionBuilder,
          $$CourtsTableUpdateCompanionBuilder,
          (Court, $$CourtsTableReferences),
          Court,
          PrefetchHooks Function({bool tournamentId})
        > {
  $$CourtsTableTableManager(_$AppDatabase db, $CourtsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CourtsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CourtsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CourtsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> tournamentId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<int> hoops = const Value.absent(),
                Value<String> netsStatus = const Value.absent(),
                Value<String> courtStatus = const Value.absent(),
                Value<String> linesStatus = const Value.absent(),
                Value<bool> hasLights = const Value.absent(),
                Value<int> stars = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CourtsCompanion(
                id: id,
                tournamentId: tournamentId,
                name: name,
                description: description,
                latitude: latitude,
                longitude: longitude,
                hoops: hoops,
                netsStatus: netsStatus,
                courtStatus: courtStatus,
                linesStatus: linesStatus,
                hasLights: hasLights,
                stars: stars,
                cloudId: cloudId,
                source: source,
                sourceId: sourceId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> tournamentId = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                required double latitude,
                required double longitude,
                Value<int> hoops = const Value.absent(),
                Value<String> netsStatus = const Value.absent(),
                Value<String> courtStatus = const Value.absent(),
                Value<String> linesStatus = const Value.absent(),
                Value<bool> hasLights = const Value.absent(),
                Value<int> stars = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CourtsCompanion.insert(
                id: id,
                tournamentId: tournamentId,
                name: name,
                description: description,
                latitude: latitude,
                longitude: longitude,
                hoops: hoops,
                netsStatus: netsStatus,
                courtStatus: courtStatus,
                linesStatus: linesStatus,
                hasLights: hasLights,
                stars: stars,
                cloudId: cloudId,
                source: source,
                sourceId: sourceId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$CourtsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({tournamentId = false}) {
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
                                referencedTable: $$CourtsTableReferences
                                    ._tournamentIdTable(db),
                                referencedColumn: $$CourtsTableReferences
                                    ._tournamentIdTable(db)
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

typedef $$CourtsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CourtsTable,
      Court,
      $$CourtsTableFilterComposer,
      $$CourtsTableOrderingComposer,
      $$CourtsTableAnnotationComposer,
      $$CourtsTableCreateCompanionBuilder,
      $$CourtsTableUpdateCompanionBuilder,
      (Court, $$CourtsTableReferences),
      Court,
      PrefetchHooks Function({bool tournamentId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CommunitiesTableTableManager get communities =>
      $$CommunitiesTableTableManager(_db, _db.communities);
  $$TeamsTableTableManager get teams =>
      $$TeamsTableTableManager(_db, _db.teams);
  $$TournamentsTableTableManager get tournaments =>
      $$TournamentsTableTableManager(_db, _db.tournaments);
  $$TournamentTeamsTableTableManager get tournamentTeams =>
      $$TournamentTeamsTableTableManager(_db, _db.tournamentTeams);
  $$MatchesTableTableManager get matches =>
      $$MatchesTableTableManager(_db, _db.matches);
  $$CourtsTableTableManager get courts =>
      $$CourtsTableTableManager(_db, _db.courts);
}
