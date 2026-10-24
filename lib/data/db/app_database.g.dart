// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SettingsEntriesTable extends SettingsEntries with TableInfo<$SettingsEntriesTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings_entries';
  @override
  VerificationContext validateIntegrity(Insertable<SettingRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SettingsEntriesTable createAlias(String alias) {
    return $SettingsEntriesTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsEntriesCompanion toCompanion(bool nullToAbsent) {
    return SettingsEntriesCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(key: serializer.fromJson<String>(json['key']), value: serializer.fromJson<String>(json['value']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'key': serializer.toJson<String>(key), 'value': serializer.toJson<String>(value)};
  }

  SettingRow copyWith({String? key, String? value}) => SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingsEntriesCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SettingRow && other.key == this.key && other.value == this.value);
}

class SettingsEntriesCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsEntriesCompanion.insert({required String key, required String value, this.rowid = const Value.absent()})
    : key = Value(key),
      value = Value(value);
  static Insertable<SettingRow> custom({Expression<String>? key, Expression<String>? value, Expression<int>? rowid}) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsEntriesCompanion copyWith({Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SettingsEntriesCompanion(key: key ?? this.key, value: value ?? this.value, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CountersTable extends Counters with TableInfo<$CountersTable, CounterRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CountersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'counters';
  @override
  VerificationContext validateIntegrity(Insertable<CounterRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  CounterRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CounterRow(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $CountersTable createAlias(String alias) {
    return $CountersTable(attachedDatabase, alias);
  }
}

class CounterRow extends DataClass implements Insertable<CounterRow> {
  final String key;
  final int value;
  const CounterRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<int>(value);
    return map;
  }

  CountersCompanion toCompanion(bool nullToAbsent) {
    return CountersCompanion(key: Value(key), value: Value(value));
  }

  factory CounterRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CounterRow(key: serializer.fromJson<String>(json['key']), value: serializer.fromJson<int>(json['value']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'key': serializer.toJson<String>(key), 'value': serializer.toJson<int>(value)};
  }

  CounterRow copyWith({String? key, int? value}) => CounterRow(key: key ?? this.key, value: value ?? this.value);
  CounterRow copyWithCompanion(CountersCompanion data) {
    return CounterRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CounterRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CounterRow && other.key == this.key && other.value == this.value);
}

class CountersCompanion extends UpdateCompanion<CounterRow> {
  final Value<String> key;
  final Value<int> value;
  final Value<int> rowid;
  const CountersCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CountersCompanion.insert({required String key, this.value = const Value.absent(), this.rowid = const Value.absent()})
    : key = Value(key);
  static Insertable<CounterRow> custom({Expression<String>? key, Expression<int>? value, Expression<int>? rowid}) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CountersCompanion copyWith({Value<String>? key, Value<int>? value, Value<int>? rowid}) {
    return CountersCompanion(key: key ?? this.key, value: value ?? this.value, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CountersCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuestsTable extends Quests with TableInfo<$QuestsTable, QuestRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _repeatMeta = const VerificationMeta('repeat');
  @override
  late final GeneratedColumn<String> repeat = GeneratedColumn<String>(
    'repeat',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekdaysMeta = const VerificationMeta('weekdays');
  @override
  late final GeneratedColumn<String> weekdays = GeneratedColumn<String>(
    'weekdays',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _premadeKeyMeta = const VerificationMeta('premadeKey');
  @override
  late final GeneratedColumn<String> premadeKey = GeneratedColumn<String>(
    'premade_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _showOnTodayMeta = const VerificationMeta('showOnToday');
  @override
  late final GeneratedColumn<bool> showOnToday = GeneratedColumn<bool>(
    'show_on_today',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("show_on_today" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta('archived');
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("archived" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reminderOnMeta = const VerificationMeta('reminderOn');
  @override
  late final GeneratedColumn<bool> reminderOn = GeneratedColumn<bool>(
    'reminder_on',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("reminder_on" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reminderMinutesMeta = const VerificationMeta('reminderMinutes');
  @override
  late final GeneratedColumn<int> reminderMinutes = GeneratedColumn<int>(
    'reminder_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    category,
    difficulty,
    notes,
    repeat,
    weekdays,
    premadeKey,
    showOnToday,
    archived,
    reminderOn,
    reminderMinutes,
    createdAt,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quests';
  @override
  VerificationContext validateIntegrity(Insertable<QuestRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta, category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(_difficultyMeta, difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta));
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('repeat')) {
      context.handle(_repeatMeta, repeat.isAcceptableOrUnknown(data['repeat']!, _repeatMeta));
    } else if (isInserting) {
      context.missing(_repeatMeta);
    }
    if (data.containsKey('weekdays')) {
      context.handle(_weekdaysMeta, weekdays.isAcceptableOrUnknown(data['weekdays']!, _weekdaysMeta));
    }
    if (data.containsKey('premade_key')) {
      context.handle(_premadeKeyMeta, premadeKey.isAcceptableOrUnknown(data['premade_key']!, _premadeKeyMeta));
    }
    if (data.containsKey('show_on_today')) {
      context.handle(_showOnTodayMeta, showOnToday.isAcceptableOrUnknown(data['show_on_today']!, _showOnTodayMeta));
    }
    if (data.containsKey('archived')) {
      context.handle(_archivedMeta, archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta));
    }
    if (data.containsKey('reminder_on')) {
      context.handle(_reminderOnMeta, reminderOn.isAcceptableOrUnknown(data['reminder_on']!, _reminderOnMeta));
    }
    if (data.containsKey('reminder_minutes')) {
      context.handle(
        _reminderMinutesMeta,
        reminderMinutes.isAcceptableOrUnknown(data['reminder_minutes']!, _reminderMinutesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta, sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuestRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      category: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      difficulty: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}difficulty'])!,
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      repeat: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}repeat'])!,
      weekdays: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}weekdays'])!,
      premadeKey: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}premade_key']),
      showOnToday: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}show_on_today'])!,
      archived: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}archived'])!,
      reminderOn: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}reminder_on'])!,
      reminderMinutes: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}reminder_minutes']),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      sortOrder: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $QuestsTable createAlias(String alias) {
    return $QuestsTable(attachedDatabase, alias);
  }
}

class QuestRow extends DataClass implements Insertable<QuestRow> {
  final String id;
  final String title;
  final String category;
  final String difficulty;
  final String notes;
  final String repeat;

  /// Comma-separated ISO weekdays, e.g. "1,3,5".
  final String weekdays;
  final String? premadeKey;
  final bool showOnToday;
  final bool archived;
  final bool reminderOn;
  final int? reminderMinutes;
  final DateTime createdAt;
  final int sortOrder;
  const QuestRow({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.notes,
    required this.repeat,
    required this.weekdays,
    this.premadeKey,
    required this.showOnToday,
    required this.archived,
    required this.reminderOn,
    this.reminderMinutes,
    required this.createdAt,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['category'] = Variable<String>(category);
    map['difficulty'] = Variable<String>(difficulty);
    map['notes'] = Variable<String>(notes);
    map['repeat'] = Variable<String>(repeat);
    map['weekdays'] = Variable<String>(weekdays);
    if (!nullToAbsent || premadeKey != null) {
      map['premade_key'] = Variable<String>(premadeKey);
    }
    map['show_on_today'] = Variable<bool>(showOnToday);
    map['archived'] = Variable<bool>(archived);
    map['reminder_on'] = Variable<bool>(reminderOn);
    if (!nullToAbsent || reminderMinutes != null) {
      map['reminder_minutes'] = Variable<int>(reminderMinutes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  QuestsCompanion toCompanion(bool nullToAbsent) {
    return QuestsCompanion(
      id: Value(id),
      title: Value(title),
      category: Value(category),
      difficulty: Value(difficulty),
      notes: Value(notes),
      repeat: Value(repeat),
      weekdays: Value(weekdays),
      premadeKey: premadeKey == null && nullToAbsent ? const Value.absent() : Value(premadeKey),
      showOnToday: Value(showOnToday),
      archived: Value(archived),
      reminderOn: Value(reminderOn),
      reminderMinutes: reminderMinutes == null && nullToAbsent ? const Value.absent() : Value(reminderMinutes),
      createdAt: Value(createdAt),
      sortOrder: Value(sortOrder),
    );
  }

  factory QuestRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      category: serializer.fromJson<String>(json['category']),
      difficulty: serializer.fromJson<String>(json['difficulty']),
      notes: serializer.fromJson<String>(json['notes']),
      repeat: serializer.fromJson<String>(json['repeat']),
      weekdays: serializer.fromJson<String>(json['weekdays']),
      premadeKey: serializer.fromJson<String?>(json['premadeKey']),
      showOnToday: serializer.fromJson<bool>(json['showOnToday']),
      archived: serializer.fromJson<bool>(json['archived']),
      reminderOn: serializer.fromJson<bool>(json['reminderOn']),
      reminderMinutes: serializer.fromJson<int?>(json['reminderMinutes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'category': serializer.toJson<String>(category),
      'difficulty': serializer.toJson<String>(difficulty),
      'notes': serializer.toJson<String>(notes),
      'repeat': serializer.toJson<String>(repeat),
      'weekdays': serializer.toJson<String>(weekdays),
      'premadeKey': serializer.toJson<String?>(premadeKey),
      'showOnToday': serializer.toJson<bool>(showOnToday),
      'archived': serializer.toJson<bool>(archived),
      'reminderOn': serializer.toJson<bool>(reminderOn),
      'reminderMinutes': serializer.toJson<int?>(reminderMinutes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  QuestRow copyWith({
    String? id,
    String? title,
    String? category,
    String? difficulty,
    String? notes,
    String? repeat,
    String? weekdays,
    Value<String?> premadeKey = const Value.absent(),
    bool? showOnToday,
    bool? archived,
    bool? reminderOn,
    Value<int?> reminderMinutes = const Value.absent(),
    DateTime? createdAt,
    int? sortOrder,
  }) => QuestRow(
    id: id ?? this.id,
    title: title ?? this.title,
    category: category ?? this.category,
    difficulty: difficulty ?? this.difficulty,
    notes: notes ?? this.notes,
    repeat: repeat ?? this.repeat,
    weekdays: weekdays ?? this.weekdays,
    premadeKey: premadeKey.present ? premadeKey.value : this.premadeKey,
    showOnToday: showOnToday ?? this.showOnToday,
    archived: archived ?? this.archived,
    reminderOn: reminderOn ?? this.reminderOn,
    reminderMinutes: reminderMinutes.present ? reminderMinutes.value : this.reminderMinutes,
    createdAt: createdAt ?? this.createdAt,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  QuestRow copyWithCompanion(QuestsCompanion data) {
    return QuestRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      category: data.category.present ? data.category.value : this.category,
      difficulty: data.difficulty.present ? data.difficulty.value : this.difficulty,
      notes: data.notes.present ? data.notes.value : this.notes,
      repeat: data.repeat.present ? data.repeat.value : this.repeat,
      weekdays: data.weekdays.present ? data.weekdays.value : this.weekdays,
      premadeKey: data.premadeKey.present ? data.premadeKey.value : this.premadeKey,
      showOnToday: data.showOnToday.present ? data.showOnToday.value : this.showOnToday,
      archived: data.archived.present ? data.archived.value : this.archived,
      reminderOn: data.reminderOn.present ? data.reminderOn.value : this.reminderOn,
      reminderMinutes: data.reminderMinutes.present ? data.reminderMinutes.value : this.reminderMinutes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('difficulty: $difficulty, ')
          ..write('notes: $notes, ')
          ..write('repeat: $repeat, ')
          ..write('weekdays: $weekdays, ')
          ..write('premadeKey: $premadeKey, ')
          ..write('showOnToday: $showOnToday, ')
          ..write('archived: $archived, ')
          ..write('reminderOn: $reminderOn, ')
          ..write('reminderMinutes: $reminderMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    category,
    difficulty,
    notes,
    repeat,
    weekdays,
    premadeKey,
    showOnToday,
    archived,
    reminderOn,
    reminderMinutes,
    createdAt,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.category == this.category &&
          other.difficulty == this.difficulty &&
          other.notes == this.notes &&
          other.repeat == this.repeat &&
          other.weekdays == this.weekdays &&
          other.premadeKey == this.premadeKey &&
          other.showOnToday == this.showOnToday &&
          other.archived == this.archived &&
          other.reminderOn == this.reminderOn &&
          other.reminderMinutes == this.reminderMinutes &&
          other.createdAt == this.createdAt &&
          other.sortOrder == this.sortOrder);
}

class QuestsCompanion extends UpdateCompanion<QuestRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> category;
  final Value<String> difficulty;
  final Value<String> notes;
  final Value<String> repeat;
  final Value<String> weekdays;
  final Value<String?> premadeKey;
  final Value<bool> showOnToday;
  final Value<bool> archived;
  final Value<bool> reminderOn;
  final Value<int?> reminderMinutes;
  final Value<DateTime> createdAt;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const QuestsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.notes = const Value.absent(),
    this.repeat = const Value.absent(),
    this.weekdays = const Value.absent(),
    this.premadeKey = const Value.absent(),
    this.showOnToday = const Value.absent(),
    this.archived = const Value.absent(),
    this.reminderOn = const Value.absent(),
    this.reminderMinutes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestsCompanion.insert({
    required String id,
    required String title,
    required String category,
    required String difficulty,
    this.notes = const Value.absent(),
    required String repeat,
    this.weekdays = const Value.absent(),
    this.premadeKey = const Value.absent(),
    this.showOnToday = const Value.absent(),
    this.archived = const Value.absent(),
    this.reminderOn = const Value.absent(),
    this.reminderMinutes = const Value.absent(),
    required DateTime createdAt,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       category = Value(category),
       difficulty = Value(difficulty),
       repeat = Value(repeat),
       createdAt = Value(createdAt);
  static Insertable<QuestRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? category,
    Expression<String>? difficulty,
    Expression<String>? notes,
    Expression<String>? repeat,
    Expression<String>? weekdays,
    Expression<String>? premadeKey,
    Expression<bool>? showOnToday,
    Expression<bool>? archived,
    Expression<bool>? reminderOn,
    Expression<int>? reminderMinutes,
    Expression<DateTime>? createdAt,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (difficulty != null) 'difficulty': difficulty,
      if (notes != null) 'notes': notes,
      if (repeat != null) 'repeat': repeat,
      if (weekdays != null) 'weekdays': weekdays,
      if (premadeKey != null) 'premade_key': premadeKey,
      if (showOnToday != null) 'show_on_today': showOnToday,
      if (archived != null) 'archived': archived,
      if (reminderOn != null) 'reminder_on': reminderOn,
      if (reminderMinutes != null) 'reminder_minutes': reminderMinutes,
      if (createdAt != null) 'created_at': createdAt,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? category,
    Value<String>? difficulty,
    Value<String>? notes,
    Value<String>? repeat,
    Value<String>? weekdays,
    Value<String?>? premadeKey,
    Value<bool>? showOnToday,
    Value<bool>? archived,
    Value<bool>? reminderOn,
    Value<int?>? reminderMinutes,
    Value<DateTime>? createdAt,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return QuestsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      notes: notes ?? this.notes,
      repeat: repeat ?? this.repeat,
      weekdays: weekdays ?? this.weekdays,
      premadeKey: premadeKey ?? this.premadeKey,
      showOnToday: showOnToday ?? this.showOnToday,
      archived: archived ?? this.archived,
      reminderOn: reminderOn ?? this.reminderOn,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      createdAt: createdAt ?? this.createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (repeat.present) {
      map['repeat'] = Variable<String>(repeat.value);
    }
    if (weekdays.present) {
      map['weekdays'] = Variable<String>(weekdays.value);
    }
    if (premadeKey.present) {
      map['premade_key'] = Variable<String>(premadeKey.value);
    }
    if (showOnToday.present) {
      map['show_on_today'] = Variable<bool>(showOnToday.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (reminderOn.present) {
      map['reminder_on'] = Variable<bool>(reminderOn.value);
    }
    if (reminderMinutes.present) {
      map['reminder_minutes'] = Variable<int>(reminderMinutes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('difficulty: $difficulty, ')
          ..write('notes: $notes, ')
          ..write('repeat: $repeat, ')
          ..write('weekdays: $weekdays, ')
          ..write('premadeKey: $premadeKey, ')
          ..write('showOnToday: $showOnToday, ')
          ..write('archived: $archived, ')
          ..write('reminderOn: $reminderOn, ')
          ..write('reminderMinutes: $reminderMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompletionsTable extends Completions with TableInfo<$CompletionsTable, CompletionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questIdMeta = const VerificationMeta('questId');
  @override
  late final GeneratedColumn<String> questId = GeneratedColumn<String>(
    'quest_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countedMeta = const VerificationMeta('counted');
  @override
  late final GeneratedColumn<bool> counted = GeneratedColumn<bool>(
    'counted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("counted" IN (0, 1))'),
  );
  static const VerificationMeta _seedIdMeta = const VerificationMeta('seedId');
  @override
  late final GeneratedColumn<String> seedId = GeneratedColumn<String>(
    'seed_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, questId, title, category, difficulty, completedAt, day, counted, seedId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'completions';
  @override
  VerificationContext validateIntegrity(Insertable<CompletionRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('quest_id')) {
      context.handle(_questIdMeta, questId.isAcceptableOrUnknown(data['quest_id']!, _questIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta, category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(_difficultyMeta, difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta));
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(_completedAtMeta, completedAt.isAcceptableOrUnknown(data['completed_at']!, _completedAtMeta));
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('day')) {
      context.handle(_dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('counted')) {
      context.handle(_countedMeta, counted.isAcceptableOrUnknown(data['counted']!, _countedMeta));
    } else if (isInserting) {
      context.missing(_countedMeta);
    }
    if (data.containsKey('seed_id')) {
      context.handle(_seedIdMeta, seedId.isAcceptableOrUnknown(data['seed_id']!, _seedIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompletionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompletionRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      questId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}quest_id']),
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      category: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      difficulty: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}difficulty'])!,
      completedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at'])!,
      day: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}day'])!,
      counted: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}counted'])!,
      seedId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}seed_id']),
    );
  }

  @override
  $CompletionsTable createAlias(String alias) {
    return $CompletionsTable(attachedDatabase, alias);
  }
}

class CompletionRow extends DataClass implements Insertable<CompletionRow> {
  final String id;
  final String? questId;
  final String title;
  final String category;
  final String difficulty;
  final DateTime completedAt;
  final String day;
  final bool counted;
  final String? seedId;
  const CompletionRow({
    required this.id,
    this.questId,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.completedAt,
    required this.day,
    required this.counted,
    this.seedId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || questId != null) {
      map['quest_id'] = Variable<String>(questId);
    }
    map['title'] = Variable<String>(title);
    map['category'] = Variable<String>(category);
    map['difficulty'] = Variable<String>(difficulty);
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['day'] = Variable<String>(day);
    map['counted'] = Variable<bool>(counted);
    if (!nullToAbsent || seedId != null) {
      map['seed_id'] = Variable<String>(seedId);
    }
    return map;
  }

  CompletionsCompanion toCompanion(bool nullToAbsent) {
    return CompletionsCompanion(
      id: Value(id),
      questId: questId == null && nullToAbsent ? const Value.absent() : Value(questId),
      title: Value(title),
      category: Value(category),
      difficulty: Value(difficulty),
      completedAt: Value(completedAt),
      day: Value(day),
      counted: Value(counted),
      seedId: seedId == null && nullToAbsent ? const Value.absent() : Value(seedId),
    );
  }

  factory CompletionRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompletionRow(
      id: serializer.fromJson<String>(json['id']),
      questId: serializer.fromJson<String?>(json['questId']),
      title: serializer.fromJson<String>(json['title']),
      category: serializer.fromJson<String>(json['category']),
      difficulty: serializer.fromJson<String>(json['difficulty']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      day: serializer.fromJson<String>(json['day']),
      counted: serializer.fromJson<bool>(json['counted']),
      seedId: serializer.fromJson<String?>(json['seedId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'questId': serializer.toJson<String?>(questId),
      'title': serializer.toJson<String>(title),
      'category': serializer.toJson<String>(category),
      'difficulty': serializer.toJson<String>(difficulty),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'day': serializer.toJson<String>(day),
      'counted': serializer.toJson<bool>(counted),
      'seedId': serializer.toJson<String?>(seedId),
    };
  }

  CompletionRow copyWith({
    String? id,
    Value<String?> questId = const Value.absent(),
    String? title,
    String? category,
    String? difficulty,
    DateTime? completedAt,
    String? day,
    bool? counted,
    Value<String?> seedId = const Value.absent(),
  }) => CompletionRow(
    id: id ?? this.id,
    questId: questId.present ? questId.value : this.questId,
    title: title ?? this.title,
    category: category ?? this.category,
    difficulty: difficulty ?? this.difficulty,
    completedAt: completedAt ?? this.completedAt,
    day: day ?? this.day,
    counted: counted ?? this.counted,
    seedId: seedId.present ? seedId.value : this.seedId,
  );
  CompletionRow copyWithCompanion(CompletionsCompanion data) {
    return CompletionRow(
      id: data.id.present ? data.id.value : this.id,
      questId: data.questId.present ? data.questId.value : this.questId,
      title: data.title.present ? data.title.value : this.title,
      category: data.category.present ? data.category.value : this.category,
      difficulty: data.difficulty.present ? data.difficulty.value : this.difficulty,
      completedAt: data.completedAt.present ? data.completedAt.value : this.completedAt,
      day: data.day.present ? data.day.value : this.day,
      counted: data.counted.present ? data.counted.value : this.counted,
      seedId: data.seedId.present ? data.seedId.value : this.seedId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompletionRow(')
          ..write('id: $id, ')
          ..write('questId: $questId, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('difficulty: $difficulty, ')
          ..write('completedAt: $completedAt, ')
          ..write('day: $day, ')
          ..write('counted: $counted, ')
          ..write('seedId: $seedId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, questId, title, category, difficulty, completedAt, day, counted, seedId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompletionRow &&
          other.id == this.id &&
          other.questId == this.questId &&
          other.title == this.title &&
          other.category == this.category &&
          other.difficulty == this.difficulty &&
          other.completedAt == this.completedAt &&
          other.day == this.day &&
          other.counted == this.counted &&
          other.seedId == this.seedId);
}

class CompletionsCompanion extends UpdateCompanion<CompletionRow> {
  final Value<String> id;
  final Value<String?> questId;
  final Value<String> title;
  final Value<String> category;
  final Value<String> difficulty;
  final Value<DateTime> completedAt;
  final Value<String> day;
  final Value<bool> counted;
  final Value<String?> seedId;
  final Value<int> rowid;
  const CompletionsCompanion({
    this.id = const Value.absent(),
    this.questId = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.day = const Value.absent(),
    this.counted = const Value.absent(),
    this.seedId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompletionsCompanion.insert({
    required String id,
    this.questId = const Value.absent(),
    required String title,
    required String category,
    required String difficulty,
    required DateTime completedAt,
    required String day,
    required bool counted,
    this.seedId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       category = Value(category),
       difficulty = Value(difficulty),
       completedAt = Value(completedAt),
       day = Value(day),
       counted = Value(counted);
  static Insertable<CompletionRow> custom({
    Expression<String>? id,
    Expression<String>? questId,
    Expression<String>? title,
    Expression<String>? category,
    Expression<String>? difficulty,
    Expression<DateTime>? completedAt,
    Expression<String>? day,
    Expression<bool>? counted,
    Expression<String>? seedId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (questId != null) 'quest_id': questId,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (difficulty != null) 'difficulty': difficulty,
      if (completedAt != null) 'completed_at': completedAt,
      if (day != null) 'day': day,
      if (counted != null) 'counted': counted,
      if (seedId != null) 'seed_id': seedId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompletionsCompanion copyWith({
    Value<String>? id,
    Value<String?>? questId,
    Value<String>? title,
    Value<String>? category,
    Value<String>? difficulty,
    Value<DateTime>? completedAt,
    Value<String>? day,
    Value<bool>? counted,
    Value<String?>? seedId,
    Value<int>? rowid,
  }) {
    return CompletionsCompanion(
      id: id ?? this.id,
      questId: questId ?? this.questId,
      title: title ?? this.title,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      completedAt: completedAt ?? this.completedAt,
      day: day ?? this.day,
      counted: counted ?? this.counted,
      seedId: seedId ?? this.seedId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (questId.present) {
      map['quest_id'] = Variable<String>(questId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (counted.present) {
      map['counted'] = Variable<bool>(counted.value);
    }
    if (seedId.present) {
      map['seed_id'] = Variable<String>(seedId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompletionsCompanion(')
          ..write('id: $id, ')
          ..write('questId: $questId, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('difficulty: $difficulty, ')
          ..write('completedAt: $completedAt, ')
          ..write('day: $day, ')
          ..write('counted: $counted, ')
          ..write('seedId: $seedId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DayMarksTable extends DayMarks with TableInfo<$DayMarksTable, DayMarkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayMarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _questIdMeta = const VerificationMeta('questId');
  @override
  late final GeneratedColumn<String> questId = GeneratedColumn<String>(
    'quest_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [questId, day, kind];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_marks';
  @override
  VerificationContext validateIntegrity(Insertable<DayMarkRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('quest_id')) {
      context.handle(_questIdMeta, questId.isAcceptableOrUnknown(data['quest_id']!, _questIdMeta));
    } else if (isInserting) {
      context.missing(_questIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(_dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(_kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {questId, day};
  @override
  DayMarkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayMarkRow(
      questId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}quest_id'])!,
      day: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}day'])!,
      kind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
    );
  }

  @override
  $DayMarksTable createAlias(String alias) {
    return $DayMarksTable(attachedDatabase, alias);
  }
}

class DayMarkRow extends DataClass implements Insertable<DayMarkRow> {
  final String questId;
  final String day;
  final String kind;
  const DayMarkRow({required this.questId, required this.day, required this.kind});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['quest_id'] = Variable<String>(questId);
    map['day'] = Variable<String>(day);
    map['kind'] = Variable<String>(kind);
    return map;
  }

  DayMarksCompanion toCompanion(bool nullToAbsent) {
    return DayMarksCompanion(questId: Value(questId), day: Value(day), kind: Value(kind));
  }

  factory DayMarkRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayMarkRow(
      questId: serializer.fromJson<String>(json['questId']),
      day: serializer.fromJson<String>(json['day']),
      kind: serializer.fromJson<String>(json['kind']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'questId': serializer.toJson<String>(questId),
      'day': serializer.toJson<String>(day),
      'kind': serializer.toJson<String>(kind),
    };
  }

  DayMarkRow copyWith({String? questId, String? day, String? kind}) =>
      DayMarkRow(questId: questId ?? this.questId, day: day ?? this.day, kind: kind ?? this.kind);
  DayMarkRow copyWithCompanion(DayMarksCompanion data) {
    return DayMarkRow(
      questId: data.questId.present ? data.questId.value : this.questId,
      day: data.day.present ? data.day.value : this.day,
      kind: data.kind.present ? data.kind.value : this.kind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayMarkRow(')
          ..write('questId: $questId, ')
          ..write('day: $day, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(questId, day, kind);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayMarkRow && other.questId == this.questId && other.day == this.day && other.kind == this.kind);
}

class DayMarksCompanion extends UpdateCompanion<DayMarkRow> {
  final Value<String> questId;
  final Value<String> day;
  final Value<String> kind;
  final Value<int> rowid;
  const DayMarksCompanion({
    this.questId = const Value.absent(),
    this.day = const Value.absent(),
    this.kind = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DayMarksCompanion.insert({
    required String questId,
    required String day,
    required String kind,
    this.rowid = const Value.absent(),
  }) : questId = Value(questId),
       day = Value(day),
       kind = Value(kind);
  static Insertable<DayMarkRow> custom({
    Expression<String>? questId,
    Expression<String>? day,
    Expression<String>? kind,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (questId != null) 'quest_id': questId,
      if (day != null) 'day': day,
      if (kind != null) 'kind': kind,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayMarksCompanion copyWith({Value<String>? questId, Value<String>? day, Value<String>? kind, Value<int>? rowid}) {
    return DayMarksCompanion(
      questId: questId ?? this.questId,
      day: day ?? this.day,
      kind: kind ?? this.kind,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (questId.present) {
      map['quest_id'] = Variable<String>(questId.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayMarksCompanion(')
          ..write('questId: $questId, ')
          ..write('day: $day, ')
          ..write('kind: $kind, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SeedsTable extends Seeds with TableInfo<$SeedsTable, SeedRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeedsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speciesIdMeta = const VerificationMeta('speciesId');
  @override
  late final GeneratedColumn<String> speciesId = GeneratedColumn<String>(
    'species_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rarityMeta = const VerificationMeta('rarity');
  @override
  late final GeneratedColumn<String> rarity = GeneratedColumn<String>(
    'rarity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _earnedAtMeta = const VerificationMeta('earnedAt');
  @override
  late final GeneratedColumn<DateTime> earnedAt = GeneratedColumn<DateTime>(
    'earned_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('bag'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, speciesId, rarity, source, earnedAt, state];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'seeds';
  @override
  VerificationContext validateIntegrity(Insertable<SeedRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('species_id')) {
      context.handle(_speciesIdMeta, speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta));
    } else if (isInserting) {
      context.missing(_speciesIdMeta);
    }
    if (data.containsKey('rarity')) {
      context.handle(_rarityMeta, rarity.isAcceptableOrUnknown(data['rarity']!, _rarityMeta));
    } else if (isInserting) {
      context.missing(_rarityMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta, source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('earned_at')) {
      context.handle(_earnedAtMeta, earnedAt.isAcceptableOrUnknown(data['earned_at']!, _earnedAtMeta));
    } else if (isInserting) {
      context.missing(_earnedAtMeta);
    }
    if (data.containsKey('state')) {
      context.handle(_stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SeedRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeedRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      speciesId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}species_id'])!,
      rarity: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}rarity'])!,
      source: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      earnedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}earned_at'])!,
      state: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}state'])!,
    );
  }

  @override
  $SeedsTable createAlias(String alias) {
    return $SeedsTable(attachedDatabase, alias);
  }
}

class SeedRow extends DataClass implements Insertable<SeedRow> {
  final String id;
  final String speciesId;
  final String rarity;
  final String source;
  final DateTime earnedAt;
  final String state;
  const SeedRow({
    required this.id,
    required this.speciesId,
    required this.rarity,
    required this.source,
    required this.earnedAt,
    required this.state,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['species_id'] = Variable<String>(speciesId);
    map['rarity'] = Variable<String>(rarity);
    map['source'] = Variable<String>(source);
    map['earned_at'] = Variable<DateTime>(earnedAt);
    map['state'] = Variable<String>(state);
    return map;
  }

  SeedsCompanion toCompanion(bool nullToAbsent) {
    return SeedsCompanion(
      id: Value(id),
      speciesId: Value(speciesId),
      rarity: Value(rarity),
      source: Value(source),
      earnedAt: Value(earnedAt),
      state: Value(state),
    );
  }

  factory SeedRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeedRow(
      id: serializer.fromJson<String>(json['id']),
      speciesId: serializer.fromJson<String>(json['speciesId']),
      rarity: serializer.fromJson<String>(json['rarity']),
      source: serializer.fromJson<String>(json['source']),
      earnedAt: serializer.fromJson<DateTime>(json['earnedAt']),
      state: serializer.fromJson<String>(json['state']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'speciesId': serializer.toJson<String>(speciesId),
      'rarity': serializer.toJson<String>(rarity),
      'source': serializer.toJson<String>(source),
      'earnedAt': serializer.toJson<DateTime>(earnedAt),
      'state': serializer.toJson<String>(state),
    };
  }

  SeedRow copyWith({
    String? id,
    String? speciesId,
    String? rarity,
    String? source,
    DateTime? earnedAt,
    String? state,
  }) => SeedRow(
    id: id ?? this.id,
    speciesId: speciesId ?? this.speciesId,
    rarity: rarity ?? this.rarity,
    source: source ?? this.source,
    earnedAt: earnedAt ?? this.earnedAt,
    state: state ?? this.state,
  );
  SeedRow copyWithCompanion(SeedsCompanion data) {
    return SeedRow(
      id: data.id.present ? data.id.value : this.id,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      rarity: data.rarity.present ? data.rarity.value : this.rarity,
      source: data.source.present ? data.source.value : this.source,
      earnedAt: data.earnedAt.present ? data.earnedAt.value : this.earnedAt,
      state: data.state.present ? data.state.value : this.state,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeedRow(')
          ..write('id: $id, ')
          ..write('speciesId: $speciesId, ')
          ..write('rarity: $rarity, ')
          ..write('source: $source, ')
          ..write('earnedAt: $earnedAt, ')
          ..write('state: $state')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, speciesId, rarity, source, earnedAt, state);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeedRow &&
          other.id == this.id &&
          other.speciesId == this.speciesId &&
          other.rarity == this.rarity &&
          other.source == this.source &&
          other.earnedAt == this.earnedAt &&
          other.state == this.state);
}

class SeedsCompanion extends UpdateCompanion<SeedRow> {
  final Value<String> id;
  final Value<String> speciesId;
  final Value<String> rarity;
  final Value<String> source;
  final Value<DateTime> earnedAt;
  final Value<String> state;
  final Value<int> rowid;
  const SeedsCompanion({
    this.id = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.rarity = const Value.absent(),
    this.source = const Value.absent(),
    this.earnedAt = const Value.absent(),
    this.state = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeedsCompanion.insert({
    required String id,
    required String speciesId,
    required String rarity,
    required String source,
    required DateTime earnedAt,
    this.state = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       speciesId = Value(speciesId),
       rarity = Value(rarity),
       source = Value(source),
       earnedAt = Value(earnedAt);
  static Insertable<SeedRow> custom({
    Expression<String>? id,
    Expression<String>? speciesId,
    Expression<String>? rarity,
    Expression<String>? source,
    Expression<DateTime>? earnedAt,
    Expression<String>? state,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (speciesId != null) 'species_id': speciesId,
      if (rarity != null) 'rarity': rarity,
      if (source != null) 'source': source,
      if (earnedAt != null) 'earned_at': earnedAt,
      if (state != null) 'state': state,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeedsCompanion copyWith({
    Value<String>? id,
    Value<String>? speciesId,
    Value<String>? rarity,
    Value<String>? source,
    Value<DateTime>? earnedAt,
    Value<String>? state,
    Value<int>? rowid,
  }) {
    return SeedsCompanion(
      id: id ?? this.id,
      speciesId: speciesId ?? this.speciesId,
      rarity: rarity ?? this.rarity,
      source: source ?? this.source,
      earnedAt: earnedAt ?? this.earnedAt,
      state: state ?? this.state,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (speciesId.present) {
      map['species_id'] = Variable<String>(speciesId.value);
    }
    if (rarity.present) {
      map['rarity'] = Variable<String>(rarity.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (earnedAt.present) {
      map['earned_at'] = Variable<DateTime>(earnedAt.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeedsCompanion(')
          ..write('id: $id, ')
          ..write('speciesId: $speciesId, ')
          ..write('rarity: $rarity, ')
          ..write('source: $source, ')
          ..write('earnedAt: $earnedAt, ')
          ..write('state: $state, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlotsTable extends Plots with TableInfo<$PlotsTable, PlotRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _envIdMeta = const VerificationMeta('envId');
  @override
  late final GeneratedColumn<String> envId = GeneratedColumn<String>(
    'env_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta('unlockedAt');
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [envId, unlockedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plots';
  @override
  VerificationContext validateIntegrity(Insertable<PlotRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('env_id')) {
      context.handle(_envIdMeta, envId.isAcceptableOrUnknown(data['env_id']!, _envIdMeta));
    } else if (isInserting) {
      context.missing(_envIdMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(_unlockedAtMeta, unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta));
    } else if (isInserting) {
      context.missing(_unlockedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {envId};
  @override
  PlotRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlotRow(
      envId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}env_id'])!,
      unlockedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}unlocked_at'])!,
    );
  }

  @override
  $PlotsTable createAlias(String alias) {
    return $PlotsTable(attachedDatabase, alias);
  }
}

class PlotRow extends DataClass implements Insertable<PlotRow> {
  final String envId;
  final DateTime unlockedAt;
  const PlotRow({required this.envId, required this.unlockedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['env_id'] = Variable<String>(envId);
    map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    return map;
  }

  PlotsCompanion toCompanion(bool nullToAbsent) {
    return PlotsCompanion(envId: Value(envId), unlockedAt: Value(unlockedAt));
  }

  factory PlotRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlotRow(
      envId: serializer.fromJson<String>(json['envId']),
      unlockedAt: serializer.fromJson<DateTime>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'envId': serializer.toJson<String>(envId),
      'unlockedAt': serializer.toJson<DateTime>(unlockedAt),
    };
  }

  PlotRow copyWith({String? envId, DateTime? unlockedAt}) =>
      PlotRow(envId: envId ?? this.envId, unlockedAt: unlockedAt ?? this.unlockedAt);
  PlotRow copyWithCompanion(PlotsCompanion data) {
    return PlotRow(
      envId: data.envId.present ? data.envId.value : this.envId,
      unlockedAt: data.unlockedAt.present ? data.unlockedAt.value : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlotRow(')
          ..write('envId: $envId, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(envId, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is PlotRow && other.envId == this.envId && other.unlockedAt == this.unlockedAt);
}

class PlotsCompanion extends UpdateCompanion<PlotRow> {
  final Value<String> envId;
  final Value<DateTime> unlockedAt;
  final Value<int> rowid;
  const PlotsCompanion({
    this.envId = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlotsCompanion.insert({required String envId, required DateTime unlockedAt, this.rowid = const Value.absent()})
    : envId = Value(envId),
      unlockedAt = Value(unlockedAt);
  static Insertable<PlotRow> custom({
    Expression<String>? envId,
    Expression<DateTime>? unlockedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (envId != null) 'env_id': envId,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlotsCompanion copyWith({Value<String>? envId, Value<DateTime>? unlockedAt, Value<int>? rowid}) {
    return PlotsCompanion(
      envId: envId ?? this.envId,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (envId.present) {
      map['env_id'] = Variable<String>(envId.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlotsCompanion(')
          ..write('envId: $envId, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlantsTable extends Plants with TableInfo<$PlantsTable, PlantRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _envIdMeta = const VerificationMeta('envId');
  @override
  late final GeneratedColumn<String> envId = GeneratedColumn<String>(
    'env_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<int> slot = GeneratedColumn<int>(
    'slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speciesIdMeta = const VerificationMeta('speciesId');
  @override
  late final GeneratedColumn<String> speciesId = GeneratedColumn<String>(
    'species_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rarityMeta = const VerificationMeta('rarity');
  @override
  late final GeneratedColumn<String> rarity = GeneratedColumn<String>(
    'rarity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plantedAtMeta = const VerificationMeta('plantedAt');
  @override
  late final GeneratedColumn<DateTime> plantedAt = GeneratedColumn<DateTime>(
    'planted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fruitAnchorAtMeta = const VerificationMeta('fruitAnchorAt');
  @override
  late final GeneratedColumn<DateTime> fruitAnchorAt = GeneratedColumn<DateTime>(
    'fruit_anchor_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _harvestsMeta = const VerificationMeta('harvests');
  @override
  late final GeneratedColumn<int> harvests = GeneratedColumn<int>(
    'harvests',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _uprootedAtMeta = const VerificationMeta('uprootedAt');
  @override
  late final GeneratedColumn<DateTime> uprootedAt = GeneratedColumn<DateTime>(
    'uprooted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    envId,
    slot,
    speciesId,
    rarity,
    plantedAt,
    fruitAnchorAt,
    harvests,
    uprootedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plants';
  @override
  VerificationContext validateIntegrity(Insertable<PlantRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('env_id')) {
      context.handle(_envIdMeta, envId.isAcceptableOrUnknown(data['env_id']!, _envIdMeta));
    } else if (isInserting) {
      context.missing(_envIdMeta);
    }
    if (data.containsKey('slot')) {
      context.handle(_slotMeta, slot.isAcceptableOrUnknown(data['slot']!, _slotMeta));
    } else if (isInserting) {
      context.missing(_slotMeta);
    }
    if (data.containsKey('species_id')) {
      context.handle(_speciesIdMeta, speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta));
    } else if (isInserting) {
      context.missing(_speciesIdMeta);
    }
    if (data.containsKey('rarity')) {
      context.handle(_rarityMeta, rarity.isAcceptableOrUnknown(data['rarity']!, _rarityMeta));
    } else if (isInserting) {
      context.missing(_rarityMeta);
    }
    if (data.containsKey('planted_at')) {
      context.handle(_plantedAtMeta, plantedAt.isAcceptableOrUnknown(data['planted_at']!, _plantedAtMeta));
    } else if (isInserting) {
      context.missing(_plantedAtMeta);
    }
    if (data.containsKey('fruit_anchor_at')) {
      context.handle(
        _fruitAnchorAtMeta,
        fruitAnchorAt.isAcceptableOrUnknown(data['fruit_anchor_at']!, _fruitAnchorAtMeta),
      );
    }
    if (data.containsKey('harvests')) {
      context.handle(_harvestsMeta, harvests.isAcceptableOrUnknown(data['harvests']!, _harvestsMeta));
    }
    if (data.containsKey('uprooted_at')) {
      context.handle(_uprootedAtMeta, uprootedAt.isAcceptableOrUnknown(data['uprooted_at']!, _uprootedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlantRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlantRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      envId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}env_id'])!,
      slot: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}slot'])!,
      speciesId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}species_id'])!,
      rarity: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}rarity'])!,
      plantedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}planted_at'])!,
      fruitAnchorAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fruit_anchor_at'],
      ),
      harvests: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}harvests'])!,
      uprootedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}uprooted_at']),
    );
  }

  @override
  $PlantsTable createAlias(String alias) {
    return $PlantsTable(attachedDatabase, alias);
  }
}

class PlantRow extends DataClass implements Insertable<PlantRow> {
  final String id;
  final String envId;
  final int slot;
  final String speciesId;
  final String rarity;
  final DateTime plantedAt;

  /// When the current fruit timer started. Null until the plant first matures.
  final DateTime? fruitAnchorAt;
  final int harvests;
  final DateTime? uprootedAt;
  const PlantRow({
    required this.id,
    required this.envId,
    required this.slot,
    required this.speciesId,
    required this.rarity,
    required this.plantedAt,
    this.fruitAnchorAt,
    required this.harvests,
    this.uprootedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['env_id'] = Variable<String>(envId);
    map['slot'] = Variable<int>(slot);
    map['species_id'] = Variable<String>(speciesId);
    map['rarity'] = Variable<String>(rarity);
    map['planted_at'] = Variable<DateTime>(plantedAt);
    if (!nullToAbsent || fruitAnchorAt != null) {
      map['fruit_anchor_at'] = Variable<DateTime>(fruitAnchorAt);
    }
    map['harvests'] = Variable<int>(harvests);
    if (!nullToAbsent || uprootedAt != null) {
      map['uprooted_at'] = Variable<DateTime>(uprootedAt);
    }
    return map;
  }

  PlantsCompanion toCompanion(bool nullToAbsent) {
    return PlantsCompanion(
      id: Value(id),
      envId: Value(envId),
      slot: Value(slot),
      speciesId: Value(speciesId),
      rarity: Value(rarity),
      plantedAt: Value(plantedAt),
      fruitAnchorAt: fruitAnchorAt == null && nullToAbsent ? const Value.absent() : Value(fruitAnchorAt),
      harvests: Value(harvests),
      uprootedAt: uprootedAt == null && nullToAbsent ? const Value.absent() : Value(uprootedAt),
    );
  }

  factory PlantRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlantRow(
      id: serializer.fromJson<String>(json['id']),
      envId: serializer.fromJson<String>(json['envId']),
      slot: serializer.fromJson<int>(json['slot']),
      speciesId: serializer.fromJson<String>(json['speciesId']),
      rarity: serializer.fromJson<String>(json['rarity']),
      plantedAt: serializer.fromJson<DateTime>(json['plantedAt']),
      fruitAnchorAt: serializer.fromJson<DateTime?>(json['fruitAnchorAt']),
      harvests: serializer.fromJson<int>(json['harvests']),
      uprootedAt: serializer.fromJson<DateTime?>(json['uprootedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'envId': serializer.toJson<String>(envId),
      'slot': serializer.toJson<int>(slot),
      'speciesId': serializer.toJson<String>(speciesId),
      'rarity': serializer.toJson<String>(rarity),
      'plantedAt': serializer.toJson<DateTime>(plantedAt),
      'fruitAnchorAt': serializer.toJson<DateTime?>(fruitAnchorAt),
      'harvests': serializer.toJson<int>(harvests),
      'uprootedAt': serializer.toJson<DateTime?>(uprootedAt),
    };
  }

  PlantRow copyWith({
    String? id,
    String? envId,
    int? slot,
    String? speciesId,
    String? rarity,
    DateTime? plantedAt,
    Value<DateTime?> fruitAnchorAt = const Value.absent(),
    int? harvests,
    Value<DateTime?> uprootedAt = const Value.absent(),
  }) => PlantRow(
    id: id ?? this.id,
    envId: envId ?? this.envId,
    slot: slot ?? this.slot,
    speciesId: speciesId ?? this.speciesId,
    rarity: rarity ?? this.rarity,
    plantedAt: plantedAt ?? this.plantedAt,
    fruitAnchorAt: fruitAnchorAt.present ? fruitAnchorAt.value : this.fruitAnchorAt,
    harvests: harvests ?? this.harvests,
    uprootedAt: uprootedAt.present ? uprootedAt.value : this.uprootedAt,
  );
  PlantRow copyWithCompanion(PlantsCompanion data) {
    return PlantRow(
      id: data.id.present ? data.id.value : this.id,
      envId: data.envId.present ? data.envId.value : this.envId,
      slot: data.slot.present ? data.slot.value : this.slot,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      rarity: data.rarity.present ? data.rarity.value : this.rarity,
      plantedAt: data.plantedAt.present ? data.plantedAt.value : this.plantedAt,
      fruitAnchorAt: data.fruitAnchorAt.present ? data.fruitAnchorAt.value : this.fruitAnchorAt,
      harvests: data.harvests.present ? data.harvests.value : this.harvests,
      uprootedAt: data.uprootedAt.present ? data.uprootedAt.value : this.uprootedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlantRow(')
          ..write('id: $id, ')
          ..write('envId: $envId, ')
          ..write('slot: $slot, ')
          ..write('speciesId: $speciesId, ')
          ..write('rarity: $rarity, ')
          ..write('plantedAt: $plantedAt, ')
          ..write('fruitAnchorAt: $fruitAnchorAt, ')
          ..write('harvests: $harvests, ')
          ..write('uprootedAt: $uprootedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, envId, slot, speciesId, rarity, plantedAt, fruitAnchorAt, harvests, uprootedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlantRow &&
          other.id == this.id &&
          other.envId == this.envId &&
          other.slot == this.slot &&
          other.speciesId == this.speciesId &&
          other.rarity == this.rarity &&
          other.plantedAt == this.plantedAt &&
          other.fruitAnchorAt == this.fruitAnchorAt &&
          other.harvests == this.harvests &&
          other.uprootedAt == this.uprootedAt);
}

class PlantsCompanion extends UpdateCompanion<PlantRow> {
  final Value<String> id;
  final Value<String> envId;
  final Value<int> slot;
  final Value<String> speciesId;
  final Value<String> rarity;
  final Value<DateTime> plantedAt;
  final Value<DateTime?> fruitAnchorAt;
  final Value<int> harvests;
  final Value<DateTime?> uprootedAt;
  final Value<int> rowid;
  const PlantsCompanion({
    this.id = const Value.absent(),
    this.envId = const Value.absent(),
    this.slot = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.rarity = const Value.absent(),
    this.plantedAt = const Value.absent(),
    this.fruitAnchorAt = const Value.absent(),
    this.harvests = const Value.absent(),
    this.uprootedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlantsCompanion.insert({
    required String id,
    required String envId,
    required int slot,
    required String speciesId,
    required String rarity,
    required DateTime plantedAt,
    this.fruitAnchorAt = const Value.absent(),
    this.harvests = const Value.absent(),
    this.uprootedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       envId = Value(envId),
       slot = Value(slot),
       speciesId = Value(speciesId),
       rarity = Value(rarity),
       plantedAt = Value(plantedAt);
  static Insertable<PlantRow> custom({
    Expression<String>? id,
    Expression<String>? envId,
    Expression<int>? slot,
    Expression<String>? speciesId,
    Expression<String>? rarity,
    Expression<DateTime>? plantedAt,
    Expression<DateTime>? fruitAnchorAt,
    Expression<int>? harvests,
    Expression<DateTime>? uprootedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (envId != null) 'env_id': envId,
      if (slot != null) 'slot': slot,
      if (speciesId != null) 'species_id': speciesId,
      if (rarity != null) 'rarity': rarity,
      if (plantedAt != null) 'planted_at': plantedAt,
      if (fruitAnchorAt != null) 'fruit_anchor_at': fruitAnchorAt,
      if (harvests != null) 'harvests': harvests,
      if (uprootedAt != null) 'uprooted_at': uprootedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlantsCompanion copyWith({
    Value<String>? id,
    Value<String>? envId,
    Value<int>? slot,
    Value<String>? speciesId,
    Value<String>? rarity,
    Value<DateTime>? plantedAt,
    Value<DateTime?>? fruitAnchorAt,
    Value<int>? harvests,
    Value<DateTime?>? uprootedAt,
    Value<int>? rowid,
  }) {
    return PlantsCompanion(
      id: id ?? this.id,
      envId: envId ?? this.envId,
      slot: slot ?? this.slot,
      speciesId: speciesId ?? this.speciesId,
      rarity: rarity ?? this.rarity,
      plantedAt: plantedAt ?? this.plantedAt,
      fruitAnchorAt: fruitAnchorAt ?? this.fruitAnchorAt,
      harvests: harvests ?? this.harvests,
      uprootedAt: uprootedAt ?? this.uprootedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (envId.present) {
      map['env_id'] = Variable<String>(envId.value);
    }
    if (slot.present) {
      map['slot'] = Variable<int>(slot.value);
    }
    if (speciesId.present) {
      map['species_id'] = Variable<String>(speciesId.value);
    }
    if (rarity.present) {
      map['rarity'] = Variable<String>(rarity.value);
    }
    if (plantedAt.present) {
      map['planted_at'] = Variable<DateTime>(plantedAt.value);
    }
    if (fruitAnchorAt.present) {
      map['fruit_anchor_at'] = Variable<DateTime>(fruitAnchorAt.value);
    }
    if (harvests.present) {
      map['harvests'] = Variable<int>(harvests.value);
    }
    if (uprootedAt.present) {
      map['uprooted_at'] = Variable<DateTime>(uprootedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlantsCompanion(')
          ..write('id: $id, ')
          ..write('envId: $envId, ')
          ..write('slot: $slot, ')
          ..write('speciesId: $speciesId, ')
          ..write('rarity: $rarity, ')
          ..write('plantedAt: $plantedAt, ')
          ..write('fruitAnchorAt: $fruitAnchorAt, ')
          ..write('harvests: $harvests, ')
          ..write('uprootedAt: $uprootedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryTable extends Inventory with TableInfo<$InventoryTable, InventoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [itemId, quantity];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory';
  @override
  VerificationContext validateIntegrity(Insertable<InventoryRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta, itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta, quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  InventoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryRow(
      itemId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      quantity: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
    );
  }

  @override
  $InventoryTable createAlias(String alias) {
    return $InventoryTable(attachedDatabase, alias);
  }
}

class InventoryRow extends DataClass implements Insertable<InventoryRow> {
  final String itemId;
  final int quantity;
  const InventoryRow({required this.itemId, required this.quantity});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['quantity'] = Variable<int>(quantity);
    return map;
  }

  InventoryCompanion toCompanion(bool nullToAbsent) {
    return InventoryCompanion(itemId: Value(itemId), quantity: Value(quantity));
  }

  factory InventoryRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryRow(
      itemId: serializer.fromJson<String>(json['itemId']),
      quantity: serializer.fromJson<int>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'itemId': serializer.toJson<String>(itemId), 'quantity': serializer.toJson<int>(quantity)};
  }

  InventoryRow copyWith({String? itemId, int? quantity}) =>
      InventoryRow(itemId: itemId ?? this.itemId, quantity: quantity ?? this.quantity);
  InventoryRow copyWithCompanion(InventoryCompanion data) {
    return InventoryRow(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryRow(')
          ..write('itemId: $itemId, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(itemId, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryRow && other.itemId == this.itemId && other.quantity == this.quantity);
}

class InventoryCompanion extends UpdateCompanion<InventoryRow> {
  final Value<String> itemId;
  final Value<int> quantity;
  final Value<int> rowid;
  const InventoryCompanion({
    this.itemId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryCompanion.insert({required String itemId, required int quantity, this.rowid = const Value.absent()})
    : itemId = Value(itemId),
      quantity = Value(quantity);
  static Insertable<InventoryRow> custom({
    Expression<String>? itemId,
    Expression<int>? quantity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (quantity != null) 'quantity': quantity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryCompanion copyWith({Value<String>? itemId, Value<int>? quantity, Value<int>? rowid}) {
    return InventoryCompanion(
      itemId: itemId ?? this.itemId,
      quantity: quantity ?? this.quantity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryCompanion(')
          ..write('itemId: $itemId, ')
          ..write('quantity: $quantity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OwnedCosmeticsTable extends OwnedCosmetics with TableInfo<$OwnedCosmeticsTable, OwnedCosmeticRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OwnedCosmeticsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cosmeticIdMeta = const VerificationMeta('cosmeticId');
  @override
  late final GeneratedColumn<String> cosmeticId = GeneratedColumn<String>(
    'cosmetic_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _boughtAtMeta = const VerificationMeta('boughtAt');
  @override
  late final GeneratedColumn<DateTime> boughtAt = GeneratedColumn<DateTime>(
    'bought_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [cosmeticId, boughtAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'owned_cosmetics';
  @override
  VerificationContext validateIntegrity(Insertable<OwnedCosmeticRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cosmetic_id')) {
      context.handle(_cosmeticIdMeta, cosmeticId.isAcceptableOrUnknown(data['cosmetic_id']!, _cosmeticIdMeta));
    } else if (isInserting) {
      context.missing(_cosmeticIdMeta);
    }
    if (data.containsKey('bought_at')) {
      context.handle(_boughtAtMeta, boughtAt.isAcceptableOrUnknown(data['bought_at']!, _boughtAtMeta));
    } else if (isInserting) {
      context.missing(_boughtAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cosmeticId};
  @override
  OwnedCosmeticRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OwnedCosmeticRow(
      cosmeticId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}cosmetic_id'])!,
      boughtAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}bought_at'])!,
    );
  }

  @override
  $OwnedCosmeticsTable createAlias(String alias) {
    return $OwnedCosmeticsTable(attachedDatabase, alias);
  }
}

class OwnedCosmeticRow extends DataClass implements Insertable<OwnedCosmeticRow> {
  final String cosmeticId;
  final DateTime boughtAt;
  const OwnedCosmeticRow({required this.cosmeticId, required this.boughtAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cosmetic_id'] = Variable<String>(cosmeticId);
    map['bought_at'] = Variable<DateTime>(boughtAt);
    return map;
  }

  OwnedCosmeticsCompanion toCompanion(bool nullToAbsent) {
    return OwnedCosmeticsCompanion(cosmeticId: Value(cosmeticId), boughtAt: Value(boughtAt));
  }

  factory OwnedCosmeticRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OwnedCosmeticRow(
      cosmeticId: serializer.fromJson<String>(json['cosmeticId']),
      boughtAt: serializer.fromJson<DateTime>(json['boughtAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cosmeticId': serializer.toJson<String>(cosmeticId),
      'boughtAt': serializer.toJson<DateTime>(boughtAt),
    };
  }

  OwnedCosmeticRow copyWith({String? cosmeticId, DateTime? boughtAt}) =>
      OwnedCosmeticRow(cosmeticId: cosmeticId ?? this.cosmeticId, boughtAt: boughtAt ?? this.boughtAt);
  OwnedCosmeticRow copyWithCompanion(OwnedCosmeticsCompanion data) {
    return OwnedCosmeticRow(
      cosmeticId: data.cosmeticId.present ? data.cosmeticId.value : this.cosmeticId,
      boughtAt: data.boughtAt.present ? data.boughtAt.value : this.boughtAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OwnedCosmeticRow(')
          ..write('cosmeticId: $cosmeticId, ')
          ..write('boughtAt: $boughtAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cosmeticId, boughtAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OwnedCosmeticRow && other.cosmeticId == this.cosmeticId && other.boughtAt == this.boughtAt);
}

class OwnedCosmeticsCompanion extends UpdateCompanion<OwnedCosmeticRow> {
  final Value<String> cosmeticId;
  final Value<DateTime> boughtAt;
  final Value<int> rowid;
  const OwnedCosmeticsCompanion({
    this.cosmeticId = const Value.absent(),
    this.boughtAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OwnedCosmeticsCompanion.insert({
    required String cosmeticId,
    required DateTime boughtAt,
    this.rowid = const Value.absent(),
  }) : cosmeticId = Value(cosmeticId),
       boughtAt = Value(boughtAt);
  static Insertable<OwnedCosmeticRow> custom({
    Expression<String>? cosmeticId,
    Expression<DateTime>? boughtAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cosmeticId != null) 'cosmetic_id': cosmeticId,
      if (boughtAt != null) 'bought_at': boughtAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OwnedCosmeticsCompanion copyWith({Value<String>? cosmeticId, Value<DateTime>? boughtAt, Value<int>? rowid}) {
    return OwnedCosmeticsCompanion(
      cosmeticId: cosmeticId ?? this.cosmeticId,
      boughtAt: boughtAt ?? this.boughtAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cosmeticId.present) {
      map['cosmetic_id'] = Variable<String>(cosmeticId.value);
    }
    if (boughtAt.present) {
      map['bought_at'] = Variable<DateTime>(boughtAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OwnedCosmeticsCompanion(')
          ..write('cosmeticId: $cosmeticId, ')
          ..write('boughtAt: $boughtAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlotCosmeticsTable extends PlotCosmetics with TableInfo<$PlotCosmeticsTable, PlotCosmeticRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlotCosmeticsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _envIdMeta = const VerificationMeta('envId');
  @override
  late final GeneratedColumn<String> envId = GeneratedColumn<String>(
    'env_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cosmeticIdMeta = const VerificationMeta('cosmeticId');
  @override
  late final GeneratedColumn<String> cosmeticId = GeneratedColumn<String>(
    'cosmetic_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [envId, kind, cosmeticId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plot_cosmetics';
  @override
  VerificationContext validateIntegrity(Insertable<PlotCosmeticRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('env_id')) {
      context.handle(_envIdMeta, envId.isAcceptableOrUnknown(data['env_id']!, _envIdMeta));
    } else if (isInserting) {
      context.missing(_envIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(_kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('cosmetic_id')) {
      context.handle(_cosmeticIdMeta, cosmeticId.isAcceptableOrUnknown(data['cosmetic_id']!, _cosmeticIdMeta));
    } else if (isInserting) {
      context.missing(_cosmeticIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {envId, kind};
  @override
  PlotCosmeticRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlotCosmeticRow(
      envId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}env_id'])!,
      kind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      cosmeticId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}cosmetic_id'])!,
    );
  }

  @override
  $PlotCosmeticsTable createAlias(String alias) {
    return $PlotCosmeticsTable(attachedDatabase, alias);
  }
}

class PlotCosmeticRow extends DataClass implements Insertable<PlotCosmeticRow> {
  final String envId;
  final String kind;
  final String cosmeticId;
  const PlotCosmeticRow({required this.envId, required this.kind, required this.cosmeticId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['env_id'] = Variable<String>(envId);
    map['kind'] = Variable<String>(kind);
    map['cosmetic_id'] = Variable<String>(cosmeticId);
    return map;
  }

  PlotCosmeticsCompanion toCompanion(bool nullToAbsent) {
    return PlotCosmeticsCompanion(envId: Value(envId), kind: Value(kind), cosmeticId: Value(cosmeticId));
  }

  factory PlotCosmeticRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlotCosmeticRow(
      envId: serializer.fromJson<String>(json['envId']),
      kind: serializer.fromJson<String>(json['kind']),
      cosmeticId: serializer.fromJson<String>(json['cosmeticId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'envId': serializer.toJson<String>(envId),
      'kind': serializer.toJson<String>(kind),
      'cosmeticId': serializer.toJson<String>(cosmeticId),
    };
  }

  PlotCosmeticRow copyWith({String? envId, String? kind, String? cosmeticId}) =>
      PlotCosmeticRow(envId: envId ?? this.envId, kind: kind ?? this.kind, cosmeticId: cosmeticId ?? this.cosmeticId);
  PlotCosmeticRow copyWithCompanion(PlotCosmeticsCompanion data) {
    return PlotCosmeticRow(
      envId: data.envId.present ? data.envId.value : this.envId,
      kind: data.kind.present ? data.kind.value : this.kind,
      cosmeticId: data.cosmeticId.present ? data.cosmeticId.value : this.cosmeticId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlotCosmeticRow(')
          ..write('envId: $envId, ')
          ..write('kind: $kind, ')
          ..write('cosmeticId: $cosmeticId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(envId, kind, cosmeticId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlotCosmeticRow &&
          other.envId == this.envId &&
          other.kind == this.kind &&
          other.cosmeticId == this.cosmeticId);
}

class PlotCosmeticsCompanion extends UpdateCompanion<PlotCosmeticRow> {
  final Value<String> envId;
  final Value<String> kind;
  final Value<String> cosmeticId;
  final Value<int> rowid;
  const PlotCosmeticsCompanion({
    this.envId = const Value.absent(),
    this.kind = const Value.absent(),
    this.cosmeticId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlotCosmeticsCompanion.insert({
    required String envId,
    required String kind,
    required String cosmeticId,
    this.rowid = const Value.absent(),
  }) : envId = Value(envId),
       kind = Value(kind),
       cosmeticId = Value(cosmeticId);
  static Insertable<PlotCosmeticRow> custom({
    Expression<String>? envId,
    Expression<String>? kind,
    Expression<String>? cosmeticId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (envId != null) 'env_id': envId,
      if (kind != null) 'kind': kind,
      if (cosmeticId != null) 'cosmetic_id': cosmeticId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlotCosmeticsCompanion copyWith({
    Value<String>? envId,
    Value<String>? kind,
    Value<String>? cosmeticId,
    Value<int>? rowid,
  }) {
    return PlotCosmeticsCompanion(
      envId: envId ?? this.envId,
      kind: kind ?? this.kind,
      cosmeticId: cosmeticId ?? this.cosmeticId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (envId.present) {
      map['env_id'] = Variable<String>(envId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (cosmeticId.present) {
      map['cosmetic_id'] = Variable<String>(cosmeticId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlotCosmeticsCompanion(')
          ..write('envId: $envId, ')
          ..write('kind: $kind, ')
          ..write('cosmeticId: $cosmeticId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VisitorsSeenTable extends VisitorsSeen with TableInfo<$VisitorsSeenTable, VisitorSeenRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitorsSeenTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _visitorIdMeta = const VerificationMeta('visitorId');
  @override
  late final GeneratedColumn<String> visitorId = GeneratedColumn<String>(
    'visitor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstSeenAtMeta = const VerificationMeta('firstSeenAt');
  @override
  late final GeneratedColumn<DateTime> firstSeenAt = GeneratedColumn<DateTime>(
    'first_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timesSeenMeta = const VerificationMeta('timesSeen');
  @override
  late final GeneratedColumn<int> timesSeen = GeneratedColumn<int>(
    'times_seen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _timesFedMeta = const VerificationMeta('timesFed');
  @override
  late final GeneratedColumn<int> timesFed = GeneratedColumn<int>(
    'times_fed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [visitorId, firstSeenAt, timesSeen, timesFed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visitors_seen';
  @override
  VerificationContext validateIntegrity(Insertable<VisitorSeenRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('visitor_id')) {
      context.handle(_visitorIdMeta, visitorId.isAcceptableOrUnknown(data['visitor_id']!, _visitorIdMeta));
    } else if (isInserting) {
      context.missing(_visitorIdMeta);
    }
    if (data.containsKey('first_seen_at')) {
      context.handle(_firstSeenAtMeta, firstSeenAt.isAcceptableOrUnknown(data['first_seen_at']!, _firstSeenAtMeta));
    } else if (isInserting) {
      context.missing(_firstSeenAtMeta);
    }
    if (data.containsKey('times_seen')) {
      context.handle(_timesSeenMeta, timesSeen.isAcceptableOrUnknown(data['times_seen']!, _timesSeenMeta));
    }
    if (data.containsKey('times_fed')) {
      context.handle(_timesFedMeta, timesFed.isAcceptableOrUnknown(data['times_fed']!, _timesFedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {visitorId};
  @override
  VisitorSeenRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VisitorSeenRow(
      visitorId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}visitor_id'])!,
      firstSeenAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}first_seen_at'])!,
      timesSeen: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}times_seen'])!,
      timesFed: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}times_fed'])!,
    );
  }

  @override
  $VisitorsSeenTable createAlias(String alias) {
    return $VisitorsSeenTable(attachedDatabase, alias);
  }
}

class VisitorSeenRow extends DataClass implements Insertable<VisitorSeenRow> {
  final String visitorId;
  final DateTime firstSeenAt;
  final int timesSeen;
  final int timesFed;
  const VisitorSeenRow({
    required this.visitorId,
    required this.firstSeenAt,
    required this.timesSeen,
    required this.timesFed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['visitor_id'] = Variable<String>(visitorId);
    map['first_seen_at'] = Variable<DateTime>(firstSeenAt);
    map['times_seen'] = Variable<int>(timesSeen);
    map['times_fed'] = Variable<int>(timesFed);
    return map;
  }

  VisitorsSeenCompanion toCompanion(bool nullToAbsent) {
    return VisitorsSeenCompanion(
      visitorId: Value(visitorId),
      firstSeenAt: Value(firstSeenAt),
      timesSeen: Value(timesSeen),
      timesFed: Value(timesFed),
    );
  }

  factory VisitorSeenRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VisitorSeenRow(
      visitorId: serializer.fromJson<String>(json['visitorId']),
      firstSeenAt: serializer.fromJson<DateTime>(json['firstSeenAt']),
      timesSeen: serializer.fromJson<int>(json['timesSeen']),
      timesFed: serializer.fromJson<int>(json['timesFed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'visitorId': serializer.toJson<String>(visitorId),
      'firstSeenAt': serializer.toJson<DateTime>(firstSeenAt),
      'timesSeen': serializer.toJson<int>(timesSeen),
      'timesFed': serializer.toJson<int>(timesFed),
    };
  }

  VisitorSeenRow copyWith({String? visitorId, DateTime? firstSeenAt, int? timesSeen, int? timesFed}) => VisitorSeenRow(
    visitorId: visitorId ?? this.visitorId,
    firstSeenAt: firstSeenAt ?? this.firstSeenAt,
    timesSeen: timesSeen ?? this.timesSeen,
    timesFed: timesFed ?? this.timesFed,
  );
  VisitorSeenRow copyWithCompanion(VisitorsSeenCompanion data) {
    return VisitorSeenRow(
      visitorId: data.visitorId.present ? data.visitorId.value : this.visitorId,
      firstSeenAt: data.firstSeenAt.present ? data.firstSeenAt.value : this.firstSeenAt,
      timesSeen: data.timesSeen.present ? data.timesSeen.value : this.timesSeen,
      timesFed: data.timesFed.present ? data.timesFed.value : this.timesFed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VisitorSeenRow(')
          ..write('visitorId: $visitorId, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('timesSeen: $timesSeen, ')
          ..write('timesFed: $timesFed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(visitorId, firstSeenAt, timesSeen, timesFed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VisitorSeenRow &&
          other.visitorId == this.visitorId &&
          other.firstSeenAt == this.firstSeenAt &&
          other.timesSeen == this.timesSeen &&
          other.timesFed == this.timesFed);
}

class VisitorsSeenCompanion extends UpdateCompanion<VisitorSeenRow> {
  final Value<String> visitorId;
  final Value<DateTime> firstSeenAt;
  final Value<int> timesSeen;
  final Value<int> timesFed;
  final Value<int> rowid;
  const VisitorsSeenCompanion({
    this.visitorId = const Value.absent(),
    this.firstSeenAt = const Value.absent(),
    this.timesSeen = const Value.absent(),
    this.timesFed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VisitorsSeenCompanion.insert({
    required String visitorId,
    required DateTime firstSeenAt,
    this.timesSeen = const Value.absent(),
    this.timesFed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : visitorId = Value(visitorId),
       firstSeenAt = Value(firstSeenAt);
  static Insertable<VisitorSeenRow> custom({
    Expression<String>? visitorId,
    Expression<DateTime>? firstSeenAt,
    Expression<int>? timesSeen,
    Expression<int>? timesFed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (visitorId != null) 'visitor_id': visitorId,
      if (firstSeenAt != null) 'first_seen_at': firstSeenAt,
      if (timesSeen != null) 'times_seen': timesSeen,
      if (timesFed != null) 'times_fed': timesFed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VisitorsSeenCompanion copyWith({
    Value<String>? visitorId,
    Value<DateTime>? firstSeenAt,
    Value<int>? timesSeen,
    Value<int>? timesFed,
    Value<int>? rowid,
  }) {
    return VisitorsSeenCompanion(
      visitorId: visitorId ?? this.visitorId,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      timesSeen: timesSeen ?? this.timesSeen,
      timesFed: timesFed ?? this.timesFed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (visitorId.present) {
      map['visitor_id'] = Variable<String>(visitorId.value);
    }
    if (firstSeenAt.present) {
      map['first_seen_at'] = Variable<DateTime>(firstSeenAt.value);
    }
    if (timesSeen.present) {
      map['times_seen'] = Variable<int>(timesSeen.value);
    }
    if (timesFed.present) {
      map['times_fed'] = Variable<int>(timesFed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitorsSeenCompanion(')
          ..write('visitorId: $visitorId, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('timesSeen: $timesSeen, ')
          ..write('timesFed: $timesFed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MoodsTable extends Moods with TableInfo<$MoodsTable, MoodRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [day, value, note, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'moods';
  @override
  VerificationContext validateIntegrity(Insertable<MoodRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(_dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('note')) {
      context.handle(_noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  MoodRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoodRow(
      day: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}day'])!,
      value: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}value'])!,
      note: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MoodsTable createAlias(String alias) {
    return $MoodsTable(attachedDatabase, alias);
  }
}

class MoodRow extends DataClass implements Insertable<MoodRow> {
  final String day;
  final int value;
  final String note;
  final DateTime createdAt;
  const MoodRow({required this.day, required this.value, required this.note, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    map['value'] = Variable<int>(value);
    map['note'] = Variable<String>(note);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MoodsCompanion toCompanion(bool nullToAbsent) {
    return MoodsCompanion(day: Value(day), value: Value(value), note: Value(note), createdAt: Value(createdAt));
  }

  factory MoodRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoodRow(
      day: serializer.fromJson<String>(json['day']),
      value: serializer.fromJson<int>(json['value']),
      note: serializer.fromJson<String>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<String>(day),
      'value': serializer.toJson<int>(value),
      'note': serializer.toJson<String>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MoodRow copyWith({String? day, int? value, String? note, DateTime? createdAt}) => MoodRow(
    day: day ?? this.day,
    value: value ?? this.value,
    note: note ?? this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  MoodRow copyWithCompanion(MoodsCompanion data) {
    return MoodRow(
      day: data.day.present ? data.day.value : this.day,
      value: data.value.present ? data.value.value : this.value,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoodRow(')
          ..write('day: $day, ')
          ..write('value: $value, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, value, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoodRow &&
          other.day == this.day &&
          other.value == this.value &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class MoodsCompanion extends UpdateCompanion<MoodRow> {
  final Value<String> day;
  final Value<int> value;
  final Value<String> note;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MoodsCompanion({
    this.day = const Value.absent(),
    this.value = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MoodsCompanion.insert({
    required String day,
    required int value,
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : day = Value(day),
       value = Value(value),
       createdAt = Value(createdAt);
  static Insertable<MoodRow> custom({
    Expression<String>? day,
    Expression<int>? value,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (value != null) 'value': value,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MoodsCompanion copyWith({
    Value<String>? day,
    Value<int>? value,
    Value<String>? note,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MoodsCompanion(
      day: day ?? this.day,
      value: value ?? this.value,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
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
    return (StringBuffer('MoodsCompanion(')
          ..write('day: $day, ')
          ..write('value: $value, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContactsTable extends Contacts with TableInfo<$ContactsTable, ContactRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
    'detail',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, detail, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contacts';
  @override
  VerificationContext validateIntegrity(Insertable<ContactRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('detail')) {
      context.handle(_detailMeta, detail.isAcceptableOrUnknown(data['detail']!, _detailMeta));
    }
    if (data.containsKey('note')) {
      context.handle(_noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContactRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContactRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      detail: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}detail'])!,
      note: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}note'])!,
    );
  }

  @override
  $ContactsTable createAlias(String alias) {
    return $ContactsTable(attachedDatabase, alias);
  }
}

class ContactRow extends DataClass implements Insertable<ContactRow> {
  final int id;
  final String name;
  final String detail;
  final String note;
  const ContactRow({required this.id, required this.name, required this.detail, required this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['detail'] = Variable<String>(detail);
    map['note'] = Variable<String>(note);
    return map;
  }

  ContactsCompanion toCompanion(bool nullToAbsent) {
    return ContactsCompanion(id: Value(id), name: Value(name), detail: Value(detail), note: Value(note));
  }

  factory ContactRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContactRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      detail: serializer.fromJson<String>(json['detail']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'detail': serializer.toJson<String>(detail),
      'note': serializer.toJson<String>(note),
    };
  }

  ContactRow copyWith({int? id, String? name, String? detail, String? note}) =>
      ContactRow(id: id ?? this.id, name: name ?? this.name, detail: detail ?? this.detail, note: note ?? this.note);
  ContactRow copyWithCompanion(ContactsCompanion data) {
    return ContactRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      detail: data.detail.present ? data.detail.value : this.detail,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContactRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('detail: $detail, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, detail, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.detail == this.detail &&
          other.note == this.note);
}

class ContactsCompanion extends UpdateCompanion<ContactRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> detail;
  final Value<String> note;
  const ContactsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.detail = const Value.absent(),
    this.note = const Value.absent(),
  });
  ContactsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.detail = const Value.absent(),
    this.note = const Value.absent(),
  }) : name = Value(name);
  static Insertable<ContactRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? detail,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (detail != null) 'detail': detail,
      if (note != null) 'note': note,
    });
  }

  ContactsCompanion copyWith({Value<int>? id, Value<String>? name, Value<String>? detail, Value<String>? note}) {
    return ContactsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      detail: detail ?? this.detail,
      note: note ?? this.note,
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
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('detail: $detail, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $RestDaysTable extends RestDays with TableInfo<$RestDaysTable, RestDayRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RestDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [day];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rest_days';
  @override
  VerificationContext validateIntegrity(Insertable<RestDayRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(_dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  RestDayRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RestDayRow(day: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}day'])!);
  }

  @override
  $RestDaysTable createAlias(String alias) {
    return $RestDaysTable(attachedDatabase, alias);
  }
}

class RestDayRow extends DataClass implements Insertable<RestDayRow> {
  final String day;
  const RestDayRow({required this.day});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    return map;
  }

  RestDaysCompanion toCompanion(bool nullToAbsent) {
    return RestDaysCompanion(day: Value(day));
  }

  factory RestDayRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RestDayRow(day: serializer.fromJson<String>(json['day']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'day': serializer.toJson<String>(day)};
  }

  RestDayRow copyWith({String? day}) => RestDayRow(day: day ?? this.day);
  RestDayRow copyWithCompanion(RestDaysCompanion data) {
    return RestDayRow(day: data.day.present ? data.day.value : this.day);
  }

  @override
  String toString() {
    return (StringBuffer('RestDayRow(')
          ..write('day: $day')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => day.hashCode;
  @override
  bool operator ==(Object other) => identical(this, other) || (other is RestDayRow && other.day == this.day);
}

class RestDaysCompanion extends UpdateCompanion<RestDayRow> {
  final Value<String> day;
  final Value<int> rowid;
  const RestDaysCompanion({this.day = const Value.absent(), this.rowid = const Value.absent()});
  RestDaysCompanion.insert({required String day, this.rowid = const Value.absent()}) : day = Value(day);
  static Insertable<RestDayRow> custom({Expression<String>? day, Expression<int>? rowid}) {
    return RawValuesInsertable({if (day != null) 'day': day, if (rowid != null) 'rowid': rowid});
  }

  RestDaysCompanion copyWith({Value<String>? day, Value<int>? rowid}) {
    return RestDaysCompanion(day: day ?? this.day, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RestDaysCompanion(')
          ..write('day: $day, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SettingsEntriesTable settingsEntries = $SettingsEntriesTable(this);
  late final $CountersTable counters = $CountersTable(this);
  late final $QuestsTable quests = $QuestsTable(this);
  late final $CompletionsTable completions = $CompletionsTable(this);
  late final $DayMarksTable dayMarks = $DayMarksTable(this);
  late final $SeedsTable seeds = $SeedsTable(this);
  late final $PlotsTable plots = $PlotsTable(this);
  late final $PlantsTable plants = $PlantsTable(this);
  late final $InventoryTable inventory = $InventoryTable(this);
  late final $OwnedCosmeticsTable ownedCosmetics = $OwnedCosmeticsTable(this);
  late final $PlotCosmeticsTable plotCosmetics = $PlotCosmeticsTable(this);
  late final $VisitorsSeenTable visitorsSeen = $VisitorsSeenTable(this);
  late final $MoodsTable moods = $MoodsTable(this);
  late final $ContactsTable contacts = $ContactsTable(this);
  late final $RestDaysTable restDays = $RestDaysTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    settingsEntries,
    counters,
    quests,
    completions,
    dayMarks,
    seeds,
    plots,
    plants,
    inventory,
    ownedCosmetics,
    plotCosmetics,
    visitorsSeen,
    moods,
    contacts,
    restDays,
  ];
}

typedef $$SettingsEntriesTableCreateCompanionBuilder = SettingsEntriesCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsEntriesTableUpdateCompanionBuilder = SettingsEntriesCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsEntriesTableFilterComposer extends Composer<_$AppDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SettingsEntriesTableOrderingComposer extends Composer<_$AppDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SettingsEntriesTableAnnotationComposer extends Composer<_$AppDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key => $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value => $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsEntriesTable,
          SettingRow,
          $$SettingsEntriesTableFilterComposer,
          $$SettingsEntriesTableOrderingComposer,
          $$SettingsEntriesTableAnnotationComposer,
          $$SettingsEntriesTableCreateCompanionBuilder,
          $$SettingsEntriesTableUpdateCompanionBuilder,
          (SettingRow, BaseReferences<_$AppDatabase, $SettingsEntriesTable, SettingRow>),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsEntriesTableTableManager(_$AppDatabase db, $SettingsEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SettingsEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SettingsEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SettingsEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsEntriesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsEntriesCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsEntriesTable, SettingRow>(table),
                  BaseReferences<_$AppDatabase, $SettingsEntriesTable, SettingRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsEntriesTable,
      SettingRow,
      $$SettingsEntriesTableFilterComposer,
      $$SettingsEntriesTableOrderingComposer,
      $$SettingsEntriesTableAnnotationComposer,
      $$SettingsEntriesTableCreateCompanionBuilder,
      $$SettingsEntriesTableUpdateCompanionBuilder,
      (SettingRow, BaseReferences<_$AppDatabase, $SettingsEntriesTable, SettingRow>),
      SettingRow,
      PrefetchHooks Function()
    >;
typedef $$CountersTableCreateCompanionBuilder = CountersCompanion Function({
  required String key,
  Value<int> value,
  Value<int> rowid,
});
typedef $$CountersTableUpdateCompanionBuilder = CountersCompanion Function({
  Value<String> key,
  Value<int> value,
  Value<int> rowid,
});

class $$CountersTableFilterComposer extends Composer<_$AppDatabase, $CountersTable> {
  $$CountersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get value => $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$CountersTableOrderingComposer extends Composer<_$AppDatabase, $CountersTable> {
  $$CountersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$CountersTableAnnotationComposer extends Composer<_$AppDatabase, $CountersTable> {
  $$CountersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key => $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<int> get value => $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$CountersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CountersTable,
          CounterRow,
          $$CountersTableFilterComposer,
          $$CountersTableOrderingComposer,
          $$CountersTableAnnotationComposer,
          $$CountersTableCreateCompanionBuilder,
          $$CountersTableUpdateCompanionBuilder,
          (CounterRow, BaseReferences<_$AppDatabase, $CountersTable, CounterRow>),
          CounterRow,
          PrefetchHooks Function()
        > {
  $$CountersTableTableManager(_$AppDatabase db, $CountersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$CountersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$CountersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$CountersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<int> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => CountersCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            Value<int> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => CountersCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CountersTable, CounterRow>(table),
                  BaseReferences<_$AppDatabase, $CountersTable, CounterRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CountersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CountersTable,
      CounterRow,
      $$CountersTableFilterComposer,
      $$CountersTableOrderingComposer,
      $$CountersTableAnnotationComposer,
      $$CountersTableCreateCompanionBuilder,
      $$CountersTableUpdateCompanionBuilder,
      (CounterRow, BaseReferences<_$AppDatabase, $CountersTable, CounterRow>),
      CounterRow,
      PrefetchHooks Function()
    >;
typedef $$QuestsTableCreateCompanionBuilder = QuestsCompanion Function({
  required String id,
  required String title,
  required String category,
  required String difficulty,
  Value<String> notes,
  required String repeat,
  Value<String> weekdays,
  Value<String?> premadeKey,
  Value<bool> showOnToday,
  Value<bool> archived,
  Value<bool> reminderOn,
  Value<int?> reminderMinutes,
  required DateTime createdAt,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$QuestsTableUpdateCompanionBuilder = QuestsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> category,
  Value<String> difficulty,
  Value<String> notes,
  Value<String> repeat,
  Value<String> weekdays,
  Value<String?> premadeKey,
  Value<bool> showOnToday,
  Value<bool> archived,
  Value<bool> reminderOn,
  Value<int?> reminderMinutes,
  Value<DateTime> createdAt,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$QuestsTableFilterComposer extends Composer<_$AppDatabase, $QuestsTable> {
  $$QuestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get difficulty =>
      $composableBuilder(column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get repeat =>
      $composableBuilder(column: $table.repeat, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get weekdays =>
      $composableBuilder(column: $table.weekdays, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get premadeKey =>
      $composableBuilder(column: $table.premadeKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get showOnToday =>
      $composableBuilder(column: $table.showOnToday, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get reminderOn =>
      $composableBuilder(column: $table.reminderOn, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reminderMinutes =>
      $composableBuilder(column: $table.reminderMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$QuestsTableOrderingComposer extends Composer<_$AppDatabase, $QuestsTable> {
  $$QuestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get difficulty =>
      $composableBuilder(column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get repeat =>
      $composableBuilder(column: $table.repeat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get weekdays =>
      $composableBuilder(column: $table.weekdays, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get premadeKey =>
      $composableBuilder(column: $table.premadeKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get showOnToday =>
      $composableBuilder(column: $table.showOnToday, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get reminderOn =>
      $composableBuilder(column: $table.reminderOn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reminderMinutes =>
      $composableBuilder(column: $table.reminderMinutes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$QuestsTableAnnotationComposer extends Composer<_$AppDatabase, $QuestsTable> {
  $$QuestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get category => $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get repeat => $composableBuilder(column: $table.repeat, builder: (column) => column);

  GeneratedColumn<String> get weekdays => $composableBuilder(column: $table.weekdays, builder: (column) => column);

  GeneratedColumn<String> get premadeKey => $composableBuilder(column: $table.premadeKey, builder: (column) => column);

  GeneratedColumn<bool> get showOnToday => $composableBuilder(column: $table.showOnToday, builder: (column) => column);

  GeneratedColumn<bool> get archived => $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<bool> get reminderOn => $composableBuilder(column: $table.reminderOn, builder: (column) => column);

  GeneratedColumn<int> get reminderMinutes =>
      $composableBuilder(column: $table.reminderMinutes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get sortOrder => $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$QuestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuestsTable,
          QuestRow,
          $$QuestsTableFilterComposer,
          $$QuestsTableOrderingComposer,
          $$QuestsTableAnnotationComposer,
          $$QuestsTableCreateCompanionBuilder,
          $$QuestsTableUpdateCompanionBuilder,
          (QuestRow, BaseReferences<_$AppDatabase, $QuestsTable, QuestRow>),
          QuestRow,
          PrefetchHooks Function()
        > {
  $$QuestsTableTableManager(_$AppDatabase db, $QuestsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$QuestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$QuestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$QuestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> difficulty = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> repeat = const Value.absent(),
                Value<String> weekdays = const Value.absent(),
                Value<String?> premadeKey = const Value.absent(),
                Value<bool> showOnToday = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<bool> reminderOn = const Value.absent(),
                Value<int?> reminderMinutes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestsCompanion(
                id: id,
                title: title,
                category: category,
                difficulty: difficulty,
                notes: notes,
                repeat: repeat,
                weekdays: weekdays,
                premadeKey: premadeKey,
                showOnToday: showOnToday,
                archived: archived,
                reminderOn: reminderOn,
                reminderMinutes: reminderMinutes,
                createdAt: createdAt,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String category,
                required String difficulty,
                Value<String> notes = const Value.absent(),
                required String repeat,
                Value<String> weekdays = const Value.absent(),
                Value<String?> premadeKey = const Value.absent(),
                Value<bool> showOnToday = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<bool> reminderOn = const Value.absent(),
                Value<int?> reminderMinutes = const Value.absent(),
                required DateTime createdAt,
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestsCompanion.insert(
                id: id,
                title: title,
                category: category,
                difficulty: difficulty,
                notes: notes,
                repeat: repeat,
                weekdays: weekdays,
                premadeKey: premadeKey,
                showOnToday: showOnToday,
                archived: archived,
                reminderOn: reminderOn,
                reminderMinutes: reminderMinutes,
                createdAt: createdAt,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QuestsTable, QuestRow>(table),
                  BaseReferences<_$AppDatabase, $QuestsTable, QuestRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuestsTable,
      QuestRow,
      $$QuestsTableFilterComposer,
      $$QuestsTableOrderingComposer,
      $$QuestsTableAnnotationComposer,
      $$QuestsTableCreateCompanionBuilder,
      $$QuestsTableUpdateCompanionBuilder,
      (QuestRow, BaseReferences<_$AppDatabase, $QuestsTable, QuestRow>),
      QuestRow,
      PrefetchHooks Function()
    >;
typedef $$CompletionsTableCreateCompanionBuilder = CompletionsCompanion Function({
  required String id,
  Value<String?> questId,
  required String title,
  required String category,
  required String difficulty,
  required DateTime completedAt,
  required String day,
  required bool counted,
  Value<String?> seedId,
  Value<int> rowid,
});
typedef $$CompletionsTableUpdateCompanionBuilder = CompletionsCompanion Function({
  Value<String> id,
  Value<String?> questId,
  Value<String> title,
  Value<String> category,
  Value<String> difficulty,
  Value<DateTime> completedAt,
  Value<String> day,
  Value<bool> counted,
  Value<String?> seedId,
  Value<int> rowid,
});

class $$CompletionsTableFilterComposer extends Composer<_$AppDatabase, $CompletionsTable> {
  $$CompletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get questId =>
      $composableBuilder(column: $table.questId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get difficulty =>
      $composableBuilder(column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get day => $composableBuilder(column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get counted =>
      $composableBuilder(column: $table.counted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get seedId =>
      $composableBuilder(column: $table.seedId, builder: (column) => ColumnFilters(column));
}

class $$CompletionsTableOrderingComposer extends Composer<_$AppDatabase, $CompletionsTable> {
  $$CompletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get questId =>
      $composableBuilder(column: $table.questId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get difficulty =>
      $composableBuilder(column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get counted =>
      $composableBuilder(column: $table.counted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get seedId =>
      $composableBuilder(column: $table.seedId, builder: (column) => ColumnOrderings(column));
}

class $$CompletionsTableAnnotationComposer extends Composer<_$AppDatabase, $CompletionsTable> {
  $$CompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get questId => $composableBuilder(column: $table.questId, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get category => $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<String> get day => $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<bool> get counted => $composableBuilder(column: $table.counted, builder: (column) => column);

  GeneratedColumn<String> get seedId => $composableBuilder(column: $table.seedId, builder: (column) => column);
}

class $$CompletionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompletionsTable,
          CompletionRow,
          $$CompletionsTableFilterComposer,
          $$CompletionsTableOrderingComposer,
          $$CompletionsTableAnnotationComposer,
          $$CompletionsTableCreateCompanionBuilder,
          $$CompletionsTableUpdateCompanionBuilder,
          (CompletionRow, BaseReferences<_$AppDatabase, $CompletionsTable, CompletionRow>),
          CompletionRow,
          PrefetchHooks Function()
        > {
  $$CompletionsTableTableManager(_$AppDatabase db, $CompletionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$CompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$CompletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$CompletionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> questId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> difficulty = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<bool> counted = const Value.absent(),
                Value<String?> seedId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompletionsCompanion(
                id: id,
                questId: questId,
                title: title,
                category: category,
                difficulty: difficulty,
                completedAt: completedAt,
                day: day,
                counted: counted,
                seedId: seedId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> questId = const Value.absent(),
                required String title,
                required String category,
                required String difficulty,
                required DateTime completedAt,
                required String day,
                required bool counted,
                Value<String?> seedId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompletionsCompanion.insert(
                id: id,
                questId: questId,
                title: title,
                category: category,
                difficulty: difficulty,
                completedAt: completedAt,
                day: day,
                counted: counted,
                seedId: seedId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CompletionsTable, CompletionRow>(table),
                  BaseReferences<_$AppDatabase, $CompletionsTable, CompletionRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CompletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompletionsTable,
      CompletionRow,
      $$CompletionsTableFilterComposer,
      $$CompletionsTableOrderingComposer,
      $$CompletionsTableAnnotationComposer,
      $$CompletionsTableCreateCompanionBuilder,
      $$CompletionsTableUpdateCompanionBuilder,
      (CompletionRow, BaseReferences<_$AppDatabase, $CompletionsTable, CompletionRow>),
      CompletionRow,
      PrefetchHooks Function()
    >;
typedef $$DayMarksTableCreateCompanionBuilder = DayMarksCompanion Function({
  required String questId,
  required String day,
  required String kind,
  Value<int> rowid,
});
typedef $$DayMarksTableUpdateCompanionBuilder = DayMarksCompanion Function({
  Value<String> questId,
  Value<String> day,
  Value<String> kind,
  Value<int> rowid,
});

class $$DayMarksTableFilterComposer extends Composer<_$AppDatabase, $DayMarksTable> {
  $$DayMarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get questId =>
      $composableBuilder(column: $table.questId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get day => $composableBuilder(column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => ColumnFilters(column));
}

class $$DayMarksTableOrderingComposer extends Composer<_$AppDatabase, $DayMarksTable> {
  $$DayMarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get questId =>
      $composableBuilder(column: $table.questId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnOrderings(column));
}

class $$DayMarksTableAnnotationComposer extends Composer<_$AppDatabase, $DayMarksTable> {
  $$DayMarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get questId => $composableBuilder(column: $table.questId, builder: (column) => column);

  GeneratedColumn<String> get day => $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => column);
}

class $$DayMarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DayMarksTable,
          DayMarkRow,
          $$DayMarksTableFilterComposer,
          $$DayMarksTableOrderingComposer,
          $$DayMarksTableAnnotationComposer,
          $$DayMarksTableCreateCompanionBuilder,
          $$DayMarksTableUpdateCompanionBuilder,
          (DayMarkRow, BaseReferences<_$AppDatabase, $DayMarksTable, DayMarkRow>),
          DayMarkRow,
          PrefetchHooks Function()
        > {
  $$DayMarksTableTableManager(_$AppDatabase db, $DayMarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$DayMarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$DayMarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$DayMarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> questId = const Value.absent(),
            Value<String> day = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => DayMarksCompanion(questId: questId, day: day, kind: kind, rowid: rowid),
          createCompanionCallback: ({
            required String questId,
            required String day,
            required String kind,
            Value<int> rowid = const Value.absent(),
          }) => DayMarksCompanion.insert(questId: questId, day: day, kind: kind, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DayMarksTable, DayMarkRow>(table),
                  BaseReferences<_$AppDatabase, $DayMarksTable, DayMarkRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DayMarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DayMarksTable,
      DayMarkRow,
      $$DayMarksTableFilterComposer,
      $$DayMarksTableOrderingComposer,
      $$DayMarksTableAnnotationComposer,
      $$DayMarksTableCreateCompanionBuilder,
      $$DayMarksTableUpdateCompanionBuilder,
      (DayMarkRow, BaseReferences<_$AppDatabase, $DayMarksTable, DayMarkRow>),
      DayMarkRow,
      PrefetchHooks Function()
    >;
typedef $$SeedsTableCreateCompanionBuilder = SeedsCompanion Function({
  required String id,
  required String speciesId,
  required String rarity,
  required String source,
  required DateTime earnedAt,
  Value<String> state,
  Value<int> rowid,
});
typedef $$SeedsTableUpdateCompanionBuilder = SeedsCompanion Function({
  Value<String> id,
  Value<String> speciesId,
  Value<String> rarity,
  Value<String> source,
  Value<DateTime> earnedAt,
  Value<String> state,
  Value<int> rowid,
});

class $$SeedsTableFilterComposer extends Composer<_$AppDatabase, $SeedsTable> {
  $$SeedsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rarity =>
      $composableBuilder(column: $table.rarity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get earnedAt =>
      $composableBuilder(column: $table.earnedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => ColumnFilters(column));
}

class $$SeedsTableOrderingComposer extends Composer<_$AppDatabase, $SeedsTable> {
  $$SeedsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rarity =>
      $composableBuilder(column: $table.rarity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get earnedAt =>
      $composableBuilder(column: $table.earnedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => ColumnOrderings(column));
}

class $$SeedsTableAnnotationComposer extends Composer<_$AppDatabase, $SeedsTable> {
  $$SeedsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get speciesId => $composableBuilder(column: $table.speciesId, builder: (column) => column);

  GeneratedColumn<String> get rarity => $composableBuilder(column: $table.rarity, builder: (column) => column);

  GeneratedColumn<String> get source => $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get earnedAt => $composableBuilder(column: $table.earnedAt, builder: (column) => column);

  GeneratedColumn<String> get state => $composableBuilder(column: $table.state, builder: (column) => column);
}

class $$SeedsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeedsTable,
          SeedRow,
          $$SeedsTableFilterComposer,
          $$SeedsTableOrderingComposer,
          $$SeedsTableAnnotationComposer,
          $$SeedsTableCreateCompanionBuilder,
          $$SeedsTableUpdateCompanionBuilder,
          (SeedRow, BaseReferences<_$AppDatabase, $SeedsTable, SeedRow>),
          SeedRow,
          PrefetchHooks Function()
        > {
  $$SeedsTableTableManager(_$AppDatabase db, $SeedsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SeedsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SeedsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SeedsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> speciesId = const Value.absent(),
                Value<String> rarity = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> earnedAt = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeedsCompanion(
                id: id,
                speciesId: speciesId,
                rarity: rarity,
                source: source,
                earnedAt: earnedAt,
                state: state,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String speciesId,
                required String rarity,
                required String source,
                required DateTime earnedAt,
                Value<String> state = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeedsCompanion.insert(
                id: id,
                speciesId: speciesId,
                rarity: rarity,
                source: source,
                earnedAt: earnedAt,
                state: state,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SeedsTable, SeedRow>(table),
                  BaseReferences<_$AppDatabase, $SeedsTable, SeedRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SeedsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeedsTable,
      SeedRow,
      $$SeedsTableFilterComposer,
      $$SeedsTableOrderingComposer,
      $$SeedsTableAnnotationComposer,
      $$SeedsTableCreateCompanionBuilder,
      $$SeedsTableUpdateCompanionBuilder,
      (SeedRow, BaseReferences<_$AppDatabase, $SeedsTable, SeedRow>),
      SeedRow,
      PrefetchHooks Function()
    >;
typedef $$PlotsTableCreateCompanionBuilder = PlotsCompanion Function({
  required String envId,
  required DateTime unlockedAt,
  Value<int> rowid,
});
typedef $$PlotsTableUpdateCompanionBuilder = PlotsCompanion Function({
  Value<String> envId,
  Value<DateTime> unlockedAt,
  Value<int> rowid,
});

class $$PlotsTableFilterComposer extends Composer<_$AppDatabase, $PlotsTable> {
  $$PlotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get envId =>
      $composableBuilder(column: $table.envId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get unlockedAt =>
      $composableBuilder(column: $table.unlockedAt, builder: (column) => ColumnFilters(column));
}

class $$PlotsTableOrderingComposer extends Composer<_$AppDatabase, $PlotsTable> {
  $$PlotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get envId =>
      $composableBuilder(column: $table.envId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get unlockedAt =>
      $composableBuilder(column: $table.unlockedAt, builder: (column) => ColumnOrderings(column));
}

class $$PlotsTableAnnotationComposer extends Composer<_$AppDatabase, $PlotsTable> {
  $$PlotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get envId => $composableBuilder(column: $table.envId, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt =>
      $composableBuilder(column: $table.unlockedAt, builder: (column) => column);
}

class $$PlotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlotsTable,
          PlotRow,
          $$PlotsTableFilterComposer,
          $$PlotsTableOrderingComposer,
          $$PlotsTableAnnotationComposer,
          $$PlotsTableCreateCompanionBuilder,
          $$PlotsTableUpdateCompanionBuilder,
          (PlotRow, BaseReferences<_$AppDatabase, $PlotsTable, PlotRow>),
          PlotRow,
          PrefetchHooks Function()
        > {
  $$PlotsTableTableManager(_$AppDatabase db, $PlotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$PlotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$PlotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$PlotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> envId = const Value.absent(),
            Value<DateTime> unlockedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => PlotsCompanion(envId: envId, unlockedAt: unlockedAt, rowid: rowid),
          createCompanionCallback: ({
            required String envId,
            required DateTime unlockedAt,
            Value<int> rowid = const Value.absent(),
          }) => PlotsCompanion.insert(envId: envId, unlockedAt: unlockedAt, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlotsTable, PlotRow>(table),
                  BaseReferences<_$AppDatabase, $PlotsTable, PlotRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlotsTable,
      PlotRow,
      $$PlotsTableFilterComposer,
      $$PlotsTableOrderingComposer,
      $$PlotsTableAnnotationComposer,
      $$PlotsTableCreateCompanionBuilder,
      $$PlotsTableUpdateCompanionBuilder,
      (PlotRow, BaseReferences<_$AppDatabase, $PlotsTable, PlotRow>),
      PlotRow,
      PrefetchHooks Function()
    >;
typedef $$PlantsTableCreateCompanionBuilder = PlantsCompanion Function({
  required String id,
  required String envId,
  required int slot,
  required String speciesId,
  required String rarity,
  required DateTime plantedAt,
  Value<DateTime?> fruitAnchorAt,
  Value<int> harvests,
  Value<DateTime?> uprootedAt,
  Value<int> rowid,
});
typedef $$PlantsTableUpdateCompanionBuilder = PlantsCompanion Function({
  Value<String> id,
  Value<String> envId,
  Value<int> slot,
  Value<String> speciesId,
  Value<String> rarity,
  Value<DateTime> plantedAt,
  Value<DateTime?> fruitAnchorAt,
  Value<int> harvests,
  Value<DateTime?> uprootedAt,
  Value<int> rowid,
});

class $$PlantsTableFilterComposer extends Composer<_$AppDatabase, $PlantsTable> {
  $$PlantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get envId =>
      $composableBuilder(column: $table.envId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get slot => $composableBuilder(column: $table.slot, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rarity =>
      $composableBuilder(column: $table.rarity, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get plantedAt =>
      $composableBuilder(column: $table.plantedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fruitAnchorAt =>
      $composableBuilder(column: $table.fruitAnchorAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get harvests =>
      $composableBuilder(column: $table.harvests, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get uprootedAt =>
      $composableBuilder(column: $table.uprootedAt, builder: (column) => ColumnFilters(column));
}

class $$PlantsTableOrderingComposer extends Composer<_$AppDatabase, $PlantsTable> {
  $$PlantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get envId =>
      $composableBuilder(column: $table.envId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rarity =>
      $composableBuilder(column: $table.rarity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get plantedAt =>
      $composableBuilder(column: $table.plantedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fruitAnchorAt =>
      $composableBuilder(column: $table.fruitAnchorAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get harvests =>
      $composableBuilder(column: $table.harvests, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get uprootedAt =>
      $composableBuilder(column: $table.uprootedAt, builder: (column) => ColumnOrderings(column));
}

class $$PlantsTableAnnotationComposer extends Composer<_$AppDatabase, $PlantsTable> {
  $$PlantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get envId => $composableBuilder(column: $table.envId, builder: (column) => column);

  GeneratedColumn<int> get slot => $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumn<String> get speciesId => $composableBuilder(column: $table.speciesId, builder: (column) => column);

  GeneratedColumn<String> get rarity => $composableBuilder(column: $table.rarity, builder: (column) => column);

  GeneratedColumn<DateTime> get plantedAt => $composableBuilder(column: $table.plantedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get fruitAnchorAt =>
      $composableBuilder(column: $table.fruitAnchorAt, builder: (column) => column);

  GeneratedColumn<int> get harvests => $composableBuilder(column: $table.harvests, builder: (column) => column);

  GeneratedColumn<DateTime> get uprootedAt =>
      $composableBuilder(column: $table.uprootedAt, builder: (column) => column);
}

class $$PlantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlantsTable,
          PlantRow,
          $$PlantsTableFilterComposer,
          $$PlantsTableOrderingComposer,
          $$PlantsTableAnnotationComposer,
          $$PlantsTableCreateCompanionBuilder,
          $$PlantsTableUpdateCompanionBuilder,
          (PlantRow, BaseReferences<_$AppDatabase, $PlantsTable, PlantRow>),
          PlantRow,
          PrefetchHooks Function()
        > {
  $$PlantsTableTableManager(_$AppDatabase db, $PlantsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$PlantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$PlantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$PlantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> envId = const Value.absent(),
                Value<int> slot = const Value.absent(),
                Value<String> speciesId = const Value.absent(),
                Value<String> rarity = const Value.absent(),
                Value<DateTime> plantedAt = const Value.absent(),
                Value<DateTime?> fruitAnchorAt = const Value.absent(),
                Value<int> harvests = const Value.absent(),
                Value<DateTime?> uprootedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlantsCompanion(
                id: id,
                envId: envId,
                slot: slot,
                speciesId: speciesId,
                rarity: rarity,
                plantedAt: plantedAt,
                fruitAnchorAt: fruitAnchorAt,
                harvests: harvests,
                uprootedAt: uprootedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String envId,
                required int slot,
                required String speciesId,
                required String rarity,
                required DateTime plantedAt,
                Value<DateTime?> fruitAnchorAt = const Value.absent(),
                Value<int> harvests = const Value.absent(),
                Value<DateTime?> uprootedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlantsCompanion.insert(
                id: id,
                envId: envId,
                slot: slot,
                speciesId: speciesId,
                rarity: rarity,
                plantedAt: plantedAt,
                fruitAnchorAt: fruitAnchorAt,
                harvests: harvests,
                uprootedAt: uprootedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlantsTable, PlantRow>(table),
                  BaseReferences<_$AppDatabase, $PlantsTable, PlantRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlantsTable,
      PlantRow,
      $$PlantsTableFilterComposer,
      $$PlantsTableOrderingComposer,
      $$PlantsTableAnnotationComposer,
      $$PlantsTableCreateCompanionBuilder,
      $$PlantsTableUpdateCompanionBuilder,
      (PlantRow, BaseReferences<_$AppDatabase, $PlantsTable, PlantRow>),
      PlantRow,
      PrefetchHooks Function()
    >;
typedef $$InventoryTableCreateCompanionBuilder = InventoryCompanion Function({
  required String itemId,
  required int quantity,
  Value<int> rowid,
});
typedef $$InventoryTableUpdateCompanionBuilder = InventoryCompanion Function({
  Value<String> itemId,
  Value<int> quantity,
  Value<int> rowid,
});

class $$InventoryTableFilterComposer extends Composer<_$AppDatabase, $InventoryTable> {
  $$InventoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => ColumnFilters(column));
}

class $$InventoryTableOrderingComposer extends Composer<_$AppDatabase, $InventoryTable> {
  $$InventoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => ColumnOrderings(column));
}

class $$InventoryTableAnnotationComposer extends Composer<_$AppDatabase, $InventoryTable> {
  $$InventoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemId => $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<int> get quantity => $composableBuilder(column: $table.quantity, builder: (column) => column);
}

class $$InventoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InventoryTable,
          InventoryRow,
          $$InventoryTableFilterComposer,
          $$InventoryTableOrderingComposer,
          $$InventoryTableAnnotationComposer,
          $$InventoryTableCreateCompanionBuilder,
          $$InventoryTableUpdateCompanionBuilder,
          (InventoryRow, BaseReferences<_$AppDatabase, $InventoryTable, InventoryRow>),
          InventoryRow,
          PrefetchHooks Function()
        > {
  $$InventoryTableTableManager(_$AppDatabase db, $InventoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$InventoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$InventoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$InventoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> itemId = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => InventoryCompanion(itemId: itemId, quantity: quantity, rowid: rowid),
          createCompanionCallback: ({
            required String itemId,
            required int quantity,
            Value<int> rowid = const Value.absent(),
          }) => InventoryCompanion.insert(itemId: itemId, quantity: quantity, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InventoryTable, InventoryRow>(table),
                  BaseReferences<_$AppDatabase, $InventoryTable, InventoryRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InventoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InventoryTable,
      InventoryRow,
      $$InventoryTableFilterComposer,
      $$InventoryTableOrderingComposer,
      $$InventoryTableAnnotationComposer,
      $$InventoryTableCreateCompanionBuilder,
      $$InventoryTableUpdateCompanionBuilder,
      (InventoryRow, BaseReferences<_$AppDatabase, $InventoryTable, InventoryRow>),
      InventoryRow,
      PrefetchHooks Function()
    >;
typedef $$OwnedCosmeticsTableCreateCompanionBuilder = OwnedCosmeticsCompanion Function({
  required String cosmeticId,
  required DateTime boughtAt,
  Value<int> rowid,
});
typedef $$OwnedCosmeticsTableUpdateCompanionBuilder = OwnedCosmeticsCompanion Function({
  Value<String> cosmeticId,
  Value<DateTime> boughtAt,
  Value<int> rowid,
});

class $$OwnedCosmeticsTableFilterComposer extends Composer<_$AppDatabase, $OwnedCosmeticsTable> {
  $$OwnedCosmeticsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cosmeticId =>
      $composableBuilder(column: $table.cosmeticId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get boughtAt =>
      $composableBuilder(column: $table.boughtAt, builder: (column) => ColumnFilters(column));
}

class $$OwnedCosmeticsTableOrderingComposer extends Composer<_$AppDatabase, $OwnedCosmeticsTable> {
  $$OwnedCosmeticsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cosmeticId =>
      $composableBuilder(column: $table.cosmeticId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get boughtAt =>
      $composableBuilder(column: $table.boughtAt, builder: (column) => ColumnOrderings(column));
}

class $$OwnedCosmeticsTableAnnotationComposer extends Composer<_$AppDatabase, $OwnedCosmeticsTable> {
  $$OwnedCosmeticsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cosmeticId => $composableBuilder(column: $table.cosmeticId, builder: (column) => column);

  GeneratedColumn<DateTime> get boughtAt => $composableBuilder(column: $table.boughtAt, builder: (column) => column);
}

class $$OwnedCosmeticsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OwnedCosmeticsTable,
          OwnedCosmeticRow,
          $$OwnedCosmeticsTableFilterComposer,
          $$OwnedCosmeticsTableOrderingComposer,
          $$OwnedCosmeticsTableAnnotationComposer,
          $$OwnedCosmeticsTableCreateCompanionBuilder,
          $$OwnedCosmeticsTableUpdateCompanionBuilder,
          (OwnedCosmeticRow, BaseReferences<_$AppDatabase, $OwnedCosmeticsTable, OwnedCosmeticRow>),
          OwnedCosmeticRow,
          PrefetchHooks Function()
        > {
  $$OwnedCosmeticsTableTableManager(_$AppDatabase db, $OwnedCosmeticsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$OwnedCosmeticsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$OwnedCosmeticsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$OwnedCosmeticsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> cosmeticId = const Value.absent(),
            Value<DateTime> boughtAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => OwnedCosmeticsCompanion(cosmeticId: cosmeticId, boughtAt: boughtAt, rowid: rowid),
          createCompanionCallback: ({
            required String cosmeticId,
            required DateTime boughtAt,
            Value<int> rowid = const Value.absent(),
          }) => OwnedCosmeticsCompanion.insert(cosmeticId: cosmeticId, boughtAt: boughtAt, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OwnedCosmeticsTable, OwnedCosmeticRow>(table),
                  BaseReferences<_$AppDatabase, $OwnedCosmeticsTable, OwnedCosmeticRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OwnedCosmeticsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OwnedCosmeticsTable,
      OwnedCosmeticRow,
      $$OwnedCosmeticsTableFilterComposer,
      $$OwnedCosmeticsTableOrderingComposer,
      $$OwnedCosmeticsTableAnnotationComposer,
      $$OwnedCosmeticsTableCreateCompanionBuilder,
      $$OwnedCosmeticsTableUpdateCompanionBuilder,
      (OwnedCosmeticRow, BaseReferences<_$AppDatabase, $OwnedCosmeticsTable, OwnedCosmeticRow>),
      OwnedCosmeticRow,
      PrefetchHooks Function()
    >;
typedef $$PlotCosmeticsTableCreateCompanionBuilder = PlotCosmeticsCompanion Function({
  required String envId,
  required String kind,
  required String cosmeticId,
  Value<int> rowid,
});
typedef $$PlotCosmeticsTableUpdateCompanionBuilder = PlotCosmeticsCompanion Function({
  Value<String> envId,
  Value<String> kind,
  Value<String> cosmeticId,
  Value<int> rowid,
});

class $$PlotCosmeticsTableFilterComposer extends Composer<_$AppDatabase, $PlotCosmeticsTable> {
  $$PlotCosmeticsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get envId =>
      $composableBuilder(column: $table.envId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cosmeticId =>
      $composableBuilder(column: $table.cosmeticId, builder: (column) => ColumnFilters(column));
}

class $$PlotCosmeticsTableOrderingComposer extends Composer<_$AppDatabase, $PlotCosmeticsTable> {
  $$PlotCosmeticsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get envId =>
      $composableBuilder(column: $table.envId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cosmeticId =>
      $composableBuilder(column: $table.cosmeticId, builder: (column) => ColumnOrderings(column));
}

class $$PlotCosmeticsTableAnnotationComposer extends Composer<_$AppDatabase, $PlotCosmeticsTable> {
  $$PlotCosmeticsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get envId => $composableBuilder(column: $table.envId, builder: (column) => column);

  GeneratedColumn<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get cosmeticId => $composableBuilder(column: $table.cosmeticId, builder: (column) => column);
}

class $$PlotCosmeticsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlotCosmeticsTable,
          PlotCosmeticRow,
          $$PlotCosmeticsTableFilterComposer,
          $$PlotCosmeticsTableOrderingComposer,
          $$PlotCosmeticsTableAnnotationComposer,
          $$PlotCosmeticsTableCreateCompanionBuilder,
          $$PlotCosmeticsTableUpdateCompanionBuilder,
          (PlotCosmeticRow, BaseReferences<_$AppDatabase, $PlotCosmeticsTable, PlotCosmeticRow>),
          PlotCosmeticRow,
          PrefetchHooks Function()
        > {
  $$PlotCosmeticsTableTableManager(_$AppDatabase db, $PlotCosmeticsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$PlotCosmeticsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$PlotCosmeticsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$PlotCosmeticsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> envId = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> cosmeticId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => PlotCosmeticsCompanion(envId: envId, kind: kind, cosmeticId: cosmeticId, rowid: rowid),
          createCompanionCallback: ({
            required String envId,
            required String kind,
            required String cosmeticId,
            Value<int> rowid = const Value.absent(),
          }) => PlotCosmeticsCompanion.insert(envId: envId, kind: kind, cosmeticId: cosmeticId, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlotCosmeticsTable, PlotCosmeticRow>(table),
                  BaseReferences<_$AppDatabase, $PlotCosmeticsTable, PlotCosmeticRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlotCosmeticsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlotCosmeticsTable,
      PlotCosmeticRow,
      $$PlotCosmeticsTableFilterComposer,
      $$PlotCosmeticsTableOrderingComposer,
      $$PlotCosmeticsTableAnnotationComposer,
      $$PlotCosmeticsTableCreateCompanionBuilder,
      $$PlotCosmeticsTableUpdateCompanionBuilder,
      (PlotCosmeticRow, BaseReferences<_$AppDatabase, $PlotCosmeticsTable, PlotCosmeticRow>),
      PlotCosmeticRow,
      PrefetchHooks Function()
    >;
typedef $$VisitorsSeenTableCreateCompanionBuilder = VisitorsSeenCompanion Function({
  required String visitorId,
  required DateTime firstSeenAt,
  Value<int> timesSeen,
  Value<int> timesFed,
  Value<int> rowid,
});
typedef $$VisitorsSeenTableUpdateCompanionBuilder = VisitorsSeenCompanion Function({
  Value<String> visitorId,
  Value<DateTime> firstSeenAt,
  Value<int> timesSeen,
  Value<int> timesFed,
  Value<int> rowid,
});

class $$VisitorsSeenTableFilterComposer extends Composer<_$AppDatabase, $VisitorsSeenTable> {
  $$VisitorsSeenTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get visitorId =>
      $composableBuilder(column: $table.visitorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get firstSeenAt =>
      $composableBuilder(column: $table.firstSeenAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timesSeen =>
      $composableBuilder(column: $table.timesSeen, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timesFed =>
      $composableBuilder(column: $table.timesFed, builder: (column) => ColumnFilters(column));
}

class $$VisitorsSeenTableOrderingComposer extends Composer<_$AppDatabase, $VisitorsSeenTable> {
  $$VisitorsSeenTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get visitorId =>
      $composableBuilder(column: $table.visitorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get firstSeenAt =>
      $composableBuilder(column: $table.firstSeenAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timesSeen =>
      $composableBuilder(column: $table.timesSeen, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timesFed =>
      $composableBuilder(column: $table.timesFed, builder: (column) => ColumnOrderings(column));
}

class $$VisitorsSeenTableAnnotationComposer extends Composer<_$AppDatabase, $VisitorsSeenTable> {
  $$VisitorsSeenTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get visitorId => $composableBuilder(column: $table.visitorId, builder: (column) => column);

  GeneratedColumn<DateTime> get firstSeenAt =>
      $composableBuilder(column: $table.firstSeenAt, builder: (column) => column);

  GeneratedColumn<int> get timesSeen => $composableBuilder(column: $table.timesSeen, builder: (column) => column);

  GeneratedColumn<int> get timesFed => $composableBuilder(column: $table.timesFed, builder: (column) => column);
}

class $$VisitorsSeenTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VisitorsSeenTable,
          VisitorSeenRow,
          $$VisitorsSeenTableFilterComposer,
          $$VisitorsSeenTableOrderingComposer,
          $$VisitorsSeenTableAnnotationComposer,
          $$VisitorsSeenTableCreateCompanionBuilder,
          $$VisitorsSeenTableUpdateCompanionBuilder,
          (VisitorSeenRow, BaseReferences<_$AppDatabase, $VisitorsSeenTable, VisitorSeenRow>),
          VisitorSeenRow,
          PrefetchHooks Function()
        > {
  $$VisitorsSeenTableTableManager(_$AppDatabase db, $VisitorsSeenTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$VisitorsSeenTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$VisitorsSeenTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$VisitorsSeenTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> visitorId = const Value.absent(),
                Value<DateTime> firstSeenAt = const Value.absent(),
                Value<int> timesSeen = const Value.absent(),
                Value<int> timesFed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitorsSeenCompanion(
                visitorId: visitorId,
                firstSeenAt: firstSeenAt,
                timesSeen: timesSeen,
                timesFed: timesFed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String visitorId,
                required DateTime firstSeenAt,
                Value<int> timesSeen = const Value.absent(),
                Value<int> timesFed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitorsSeenCompanion.insert(
                visitorId: visitorId,
                firstSeenAt: firstSeenAt,
                timesSeen: timesSeen,
                timesFed: timesFed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VisitorsSeenTable, VisitorSeenRow>(table),
                  BaseReferences<_$AppDatabase, $VisitorsSeenTable, VisitorSeenRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VisitorsSeenTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VisitorsSeenTable,
      VisitorSeenRow,
      $$VisitorsSeenTableFilterComposer,
      $$VisitorsSeenTableOrderingComposer,
      $$VisitorsSeenTableAnnotationComposer,
      $$VisitorsSeenTableCreateCompanionBuilder,
      $$VisitorsSeenTableUpdateCompanionBuilder,
      (VisitorSeenRow, BaseReferences<_$AppDatabase, $VisitorsSeenTable, VisitorSeenRow>),
      VisitorSeenRow,
      PrefetchHooks Function()
    >;
typedef $$MoodsTableCreateCompanionBuilder = MoodsCompanion Function({
  required String day,
  required int value,
  Value<String> note,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$MoodsTableUpdateCompanionBuilder = MoodsCompanion Function({
  Value<String> day,
  Value<int> value,
  Value<String> note,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$MoodsTableFilterComposer extends Composer<_$AppDatabase, $MoodsTable> {
  $$MoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get value => $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$MoodsTableOrderingComposer extends Composer<_$AppDatabase, $MoodsTable> {
  $$MoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$MoodsTableAnnotationComposer extends Composer<_$AppDatabase, $MoodsTable> {
  $$MoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day => $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get value => $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get note => $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MoodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MoodsTable,
          MoodRow,
          $$MoodsTableFilterComposer,
          $$MoodsTableOrderingComposer,
          $$MoodsTableAnnotationComposer,
          $$MoodsTableCreateCompanionBuilder,
          $$MoodsTableUpdateCompanionBuilder,
          (MoodRow, BaseReferences<_$AppDatabase, $MoodsTable, MoodRow>),
          MoodRow,
          PrefetchHooks Function()
        > {
  $$MoodsTableTableManager(_$AppDatabase db, $MoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$MoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$MoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$MoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> day = const Value.absent(),
            Value<int> value = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => MoodsCompanion(day: day, value: value, note: note, createdAt: createdAt, rowid: rowid),
          createCompanionCallback: ({
            required String day,
            required int value,
            Value<String> note = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) => MoodsCompanion.insert(day: day, value: value, note: note, createdAt: createdAt, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MoodsTable, MoodRow>(table),
                  BaseReferences<_$AppDatabase, $MoodsTable, MoodRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MoodsTable,
      MoodRow,
      $$MoodsTableFilterComposer,
      $$MoodsTableOrderingComposer,
      $$MoodsTableAnnotationComposer,
      $$MoodsTableCreateCompanionBuilder,
      $$MoodsTableUpdateCompanionBuilder,
      (MoodRow, BaseReferences<_$AppDatabase, $MoodsTable, MoodRow>),
      MoodRow,
      PrefetchHooks Function()
    >;
typedef $$ContactsTableCreateCompanionBuilder = ContactsCompanion Function({
  Value<int> id,
  required String name,
  Value<String> detail,
  Value<String> note,
});
typedef $$ContactsTableUpdateCompanionBuilder = ContactsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> detail,
  Value<String> note,
});

class $$ContactsTableFilterComposer extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(column: $table.note, builder: (column) => ColumnFilters(column));
}

class $$ContactsTableOrderingComposer extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnOrderings(column));
}

class $$ContactsTableAnnotationComposer extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get detail => $composableBuilder(column: $table.detail, builder: (column) => column);

  GeneratedColumn<String> get note => $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$ContactsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContactsTable,
          ContactRow,
          $$ContactsTableFilterComposer,
          $$ContactsTableOrderingComposer,
          $$ContactsTableAnnotationComposer,
          $$ContactsTableCreateCompanionBuilder,
          $$ContactsTableUpdateCompanionBuilder,
          (ContactRow, BaseReferences<_$AppDatabase, $ContactsTable, ContactRow>),
          ContactRow,
          PrefetchHooks Function()
        > {
  $$ContactsTableTableManager(_$AppDatabase db, $ContactsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> detail = const Value.absent(),
            Value<String> note = const Value.absent(),
          }) => ContactsCompanion(id: id, name: name, detail: detail, note: note),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String> detail = const Value.absent(),
            Value<String> note = const Value.absent(),
          }) => ContactsCompanion.insert(id: id, name: name, detail: detail, note: note),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ContactsTable, ContactRow>(table),
                  BaseReferences<_$AppDatabase, $ContactsTable, ContactRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContactsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContactsTable,
      ContactRow,
      $$ContactsTableFilterComposer,
      $$ContactsTableOrderingComposer,
      $$ContactsTableAnnotationComposer,
      $$ContactsTableCreateCompanionBuilder,
      $$ContactsTableUpdateCompanionBuilder,
      (ContactRow, BaseReferences<_$AppDatabase, $ContactsTable, ContactRow>),
      ContactRow,
      PrefetchHooks Function()
    >;
typedef $$RestDaysTableCreateCompanionBuilder = RestDaysCompanion Function({required String day, Value<int> rowid});
typedef $$RestDaysTableUpdateCompanionBuilder = RestDaysCompanion Function({Value<String> day, Value<int> rowid});

class $$RestDaysTableFilterComposer extends Composer<_$AppDatabase, $RestDaysTable> {
  $$RestDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(column: $table.day, builder: (column) => ColumnFilters(column));
}

class $$RestDaysTableOrderingComposer extends Composer<_$AppDatabase, $RestDaysTable> {
  $$RestDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => ColumnOrderings(column));
}

class $$RestDaysTableAnnotationComposer extends Composer<_$AppDatabase, $RestDaysTable> {
  $$RestDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day => $composableBuilder(column: $table.day, builder: (column) => column);
}

class $$RestDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RestDaysTable,
          RestDayRow,
          $$RestDaysTableFilterComposer,
          $$RestDaysTableOrderingComposer,
          $$RestDaysTableAnnotationComposer,
          $$RestDaysTableCreateCompanionBuilder,
          $$RestDaysTableUpdateCompanionBuilder,
          (RestDayRow, BaseReferences<_$AppDatabase, $RestDaysTable, RestDayRow>),
          RestDayRow,
          PrefetchHooks Function()
        > {
  $$RestDaysTableTableManager(_$AppDatabase db, $RestDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$RestDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$RestDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$RestDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> day = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => RestDaysCompanion(day: day, rowid: rowid),
          createCompanionCallback: ({required String day, Value<int> rowid = const Value.absent()}) =>
              RestDaysCompanion.insert(day: day, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RestDaysTable, RestDayRow>(table),
                  BaseReferences<_$AppDatabase, $RestDaysTable, RestDayRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RestDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RestDaysTable,
      RestDayRow,
      $$RestDaysTableFilterComposer,
      $$RestDaysTableOrderingComposer,
      $$RestDaysTableAnnotationComposer,
      $$RestDaysTableCreateCompanionBuilder,
      $$RestDaysTableUpdateCompanionBuilder,
      (RestDayRow, BaseReferences<_$AppDatabase, $RestDaysTable, RestDayRow>),
      RestDayRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SettingsEntriesTableTableManager get settingsEntries =>
      $$SettingsEntriesTableTableManager(_db, _db.settingsEntries);
  $$CountersTableTableManager get counters => $$CountersTableTableManager(_db, _db.counters);
  $$QuestsTableTableManager get quests => $$QuestsTableTableManager(_db, _db.quests);
  $$CompletionsTableTableManager get completions => $$CompletionsTableTableManager(_db, _db.completions);
  $$DayMarksTableTableManager get dayMarks => $$DayMarksTableTableManager(_db, _db.dayMarks);
  $$SeedsTableTableManager get seeds => $$SeedsTableTableManager(_db, _db.seeds);
  $$PlotsTableTableManager get plots => $$PlotsTableTableManager(_db, _db.plots);
  $$PlantsTableTableManager get plants => $$PlantsTableTableManager(_db, _db.plants);
  $$InventoryTableTableManager get inventory => $$InventoryTableTableManager(_db, _db.inventory);
  $$OwnedCosmeticsTableTableManager get ownedCosmetics => $$OwnedCosmeticsTableTableManager(_db, _db.ownedCosmetics);
  $$PlotCosmeticsTableTableManager get plotCosmetics => $$PlotCosmeticsTableTableManager(_db, _db.plotCosmetics);
  $$VisitorsSeenTableTableManager get visitorsSeen => $$VisitorsSeenTableTableManager(_db, _db.visitorsSeen);
  $$MoodsTableTableManager get moods => $$MoodsTableTableManager(_db, _db.moods);
  $$ContactsTableTableManager get contacts => $$ContactsTableTableManager(_db, _db.contacts);
  $$RestDaysTableTableManager get restDays => $$RestDaysTableTableManager(_db, _db.restDays);
}
