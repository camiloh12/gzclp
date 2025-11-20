// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LiftsTable extends Lifts with TableInfo<$LiftsTable, Lift> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LiftsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, category];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lifts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Lift> instance, {
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
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Lift map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Lift(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
    );
  }

  @override
  $LiftsTable createAlias(String alias) {
    return $LiftsTable(attachedDatabase, alias);
  }
}

class Lift extends DataClass implements Insertable<Lift> {
  final int id;

  /// Name of the lift (e.g., "Squat", "Bench Press", "Deadlift", "Overhead Press")
  final String name;

  /// Category determines weight increments
  /// - "lower": Lower body (Squat, Deadlift) - 10 lbs / 5 kg increments
  /// - "upper": Upper body (Bench, OHP) - 5 lbs / 2.5 kg increments
  final String category;
  const Lift({required this.id, required this.name, required this.category});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    return map;
  }

  LiftCompanion toCompanion(bool nullToAbsent) {
    return LiftCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
    );
  }

  factory Lift.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Lift(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
    };
  }

  Lift copyWith({int? id, String? name, String? category}) => Lift(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
  );
  Lift copyWithCompanion(LiftCompanion data) {
    return Lift(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Lift(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, category);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lift &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category);
}

class LiftCompanion extends UpdateCompanion<Lift> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> category;
  const LiftCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
  });
  LiftCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String category,
  }) : name = Value(name),
       category = Value(category);
  static Insertable<Lift> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? category,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
    });
  }

  LiftCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? category,
  }) {
    return LiftCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
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
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LiftCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category')
          ..write(')'))
        .toString();
  }
}

class $CycleStatesTable extends CycleStates
    with TableInfo<$CycleStatesTable, CycleState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CycleStatesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _liftIdMeta = const VerificationMeta('liftId');
  @override
  late final GeneratedColumn<int> liftId = GeneratedColumn<int>(
    'lift_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES lifts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _currentTierMeta = const VerificationMeta(
    'currentTier',
  );
  @override
  late final GeneratedColumn<String> currentTier = GeneratedColumn<String>(
    'current_tier',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 2,
      maxTextLength: 2,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentStageMeta = const VerificationMeta(
    'currentStage',
  );
  @override
  late final GeneratedColumn<int> currentStage = GeneratedColumn<int>(
    'current_stage',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextTargetWeightMeta = const VerificationMeta(
    'nextTargetWeight',
  );
  @override
  late final GeneratedColumn<double> nextTargetWeight = GeneratedColumn<double>(
    'next_target_weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastStage1SuccessWeightMeta =
      const VerificationMeta('lastStage1SuccessWeight');
  @override
  late final GeneratedColumn<double> lastStage1SuccessWeight =
      GeneratedColumn<double>(
        'last_stage1_success_weight',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _currentT3AmrapVolumeMeta =
      const VerificationMeta('currentT3AmrapVolume');
  @override
  late final GeneratedColumn<int> currentT3AmrapVolume = GeneratedColumn<int>(
    'current_t3_amrap_volume',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    liftId,
    currentTier,
    currentStage,
    nextTargetWeight,
    lastStage1SuccessWeight,
    currentT3AmrapVolume,
    lastUpdated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cycle_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<CycleState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('lift_id')) {
      context.handle(
        _liftIdMeta,
        liftId.isAcceptableOrUnknown(data['lift_id']!, _liftIdMeta),
      );
    } else if (isInserting) {
      context.missing(_liftIdMeta);
    }
    if (data.containsKey('current_tier')) {
      context.handle(
        _currentTierMeta,
        currentTier.isAcceptableOrUnknown(
          data['current_tier']!,
          _currentTierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentTierMeta);
    }
    if (data.containsKey('current_stage')) {
      context.handle(
        _currentStageMeta,
        currentStage.isAcceptableOrUnknown(
          data['current_stage']!,
          _currentStageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentStageMeta);
    }
    if (data.containsKey('next_target_weight')) {
      context.handle(
        _nextTargetWeightMeta,
        nextTargetWeight.isAcceptableOrUnknown(
          data['next_target_weight']!,
          _nextTargetWeightMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextTargetWeightMeta);
    }
    if (data.containsKey('last_stage1_success_weight')) {
      context.handle(
        _lastStage1SuccessWeightMeta,
        lastStage1SuccessWeight.isAcceptableOrUnknown(
          data['last_stage1_success_weight']!,
          _lastStage1SuccessWeightMeta,
        ),
      );
    }
    if (data.containsKey('current_t3_amrap_volume')) {
      context.handle(
        _currentT3AmrapVolumeMeta,
        currentT3AmrapVolume.isAcceptableOrUnknown(
          data['current_t3_amrap_volume']!,
          _currentT3AmrapVolumeMeta,
        ),
      );
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {liftId, currentTier},
  ];
  @override
  CycleState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CycleState(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      liftId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lift_id'],
      )!,
      currentTier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_tier'],
      )!,
      currentStage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_stage'],
      )!,
      nextTargetWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}next_target_weight'],
      )!,
      lastStage1SuccessWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}last_stage1_success_weight'],
      ),
      currentT3AmrapVolume: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_t3_amrap_volume'],
      )!,
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      )!,
    );
  }

  @override
  $CycleStatesTable createAlias(String alias) {
    return $CycleStatesTable(attachedDatabase, alias);
  }
}

class CycleState extends DataClass implements Insertable<CycleState> {
  final int id;

  /// Foreign key to Lifts table
  final int liftId;

  /// Current tier: 'T1', 'T2', or 'T3'
  final String currentTier;

  /// Current stage: 1, 2, or 3
  /// T1: Stage 1 (5x3+), Stage 2 (6x2+), Stage 3 (10x1+)
  /// T2: Stage 1 (3x10), Stage 2 (3x8), Stage 3 (3x6)
  /// T3: Only Stage 1 (3x15+)
  /// Validated at application layer (must be 1-3)
  final int currentStage;

  /// The weight target for the next workout of this lift at this tier
  /// Validated at application layer (must be >= 0)
  final double nextTargetWeight;

  /// CRITICAL FIELD for T2 resets
  /// Records the weight used during the last successful T2 Stage 1 (3x10) session
  /// Used to calculate reset weight: lastStage1SuccessWeight + 15-20 lbs / 7.5-10 kg
  final double? lastStage1SuccessWeight;

  /// For T3 progression tracking
  /// Tracks the reps achieved on the last AMRAP set
  /// Weight increases only if this value reaches 25+
  final int currentT3AmrapVolume;

  /// Timestamp of last update to this cycle state
  final DateTime lastUpdated;
  const CycleState({
    required this.id,
    required this.liftId,
    required this.currentTier,
    required this.currentStage,
    required this.nextTargetWeight,
    this.lastStage1SuccessWeight,
    required this.currentT3AmrapVolume,
    required this.lastUpdated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['lift_id'] = Variable<int>(liftId);
    map['current_tier'] = Variable<String>(currentTier);
    map['current_stage'] = Variable<int>(currentStage);
    map['next_target_weight'] = Variable<double>(nextTargetWeight);
    if (!nullToAbsent || lastStage1SuccessWeight != null) {
      map['last_stage1_success_weight'] = Variable<double>(
        lastStage1SuccessWeight,
      );
    }
    map['current_t3_amrap_volume'] = Variable<int>(currentT3AmrapVolume);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    return map;
  }

  CycleStateCompanion toCompanion(bool nullToAbsent) {
    return CycleStateCompanion(
      id: Value(id),
      liftId: Value(liftId),
      currentTier: Value(currentTier),
      currentStage: Value(currentStage),
      nextTargetWeight: Value(nextTargetWeight),
      lastStage1SuccessWeight: lastStage1SuccessWeight == null && nullToAbsent
          ? const Value.absent()
          : Value(lastStage1SuccessWeight),
      currentT3AmrapVolume: Value(currentT3AmrapVolume),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory CycleState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CycleState(
      id: serializer.fromJson<int>(json['id']),
      liftId: serializer.fromJson<int>(json['liftId']),
      currentTier: serializer.fromJson<String>(json['currentTier']),
      currentStage: serializer.fromJson<int>(json['currentStage']),
      nextTargetWeight: serializer.fromJson<double>(json['nextTargetWeight']),
      lastStage1SuccessWeight: serializer.fromJson<double?>(
        json['lastStage1SuccessWeight'],
      ),
      currentT3AmrapVolume: serializer.fromJson<int>(
        json['currentT3AmrapVolume'],
      ),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'liftId': serializer.toJson<int>(liftId),
      'currentTier': serializer.toJson<String>(currentTier),
      'currentStage': serializer.toJson<int>(currentStage),
      'nextTargetWeight': serializer.toJson<double>(nextTargetWeight),
      'lastStage1SuccessWeight': serializer.toJson<double?>(
        lastStage1SuccessWeight,
      ),
      'currentT3AmrapVolume': serializer.toJson<int>(currentT3AmrapVolume),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
    };
  }

  CycleState copyWith({
    int? id,
    int? liftId,
    String? currentTier,
    int? currentStage,
    double? nextTargetWeight,
    Value<double?> lastStage1SuccessWeight = const Value.absent(),
    int? currentT3AmrapVolume,
    DateTime? lastUpdated,
  }) => CycleState(
    id: id ?? this.id,
    liftId: liftId ?? this.liftId,
    currentTier: currentTier ?? this.currentTier,
    currentStage: currentStage ?? this.currentStage,
    nextTargetWeight: nextTargetWeight ?? this.nextTargetWeight,
    lastStage1SuccessWeight: lastStage1SuccessWeight.present
        ? lastStage1SuccessWeight.value
        : this.lastStage1SuccessWeight,
    currentT3AmrapVolume: currentT3AmrapVolume ?? this.currentT3AmrapVolume,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
  CycleState copyWithCompanion(CycleStateCompanion data) {
    return CycleState(
      id: data.id.present ? data.id.value : this.id,
      liftId: data.liftId.present ? data.liftId.value : this.liftId,
      currentTier: data.currentTier.present
          ? data.currentTier.value
          : this.currentTier,
      currentStage: data.currentStage.present
          ? data.currentStage.value
          : this.currentStage,
      nextTargetWeight: data.nextTargetWeight.present
          ? data.nextTargetWeight.value
          : this.nextTargetWeight,
      lastStage1SuccessWeight: data.lastStage1SuccessWeight.present
          ? data.lastStage1SuccessWeight.value
          : this.lastStage1SuccessWeight,
      currentT3AmrapVolume: data.currentT3AmrapVolume.present
          ? data.currentT3AmrapVolume.value
          : this.currentT3AmrapVolume,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CycleState(')
          ..write('id: $id, ')
          ..write('liftId: $liftId, ')
          ..write('currentTier: $currentTier, ')
          ..write('currentStage: $currentStage, ')
          ..write('nextTargetWeight: $nextTargetWeight, ')
          ..write('lastStage1SuccessWeight: $lastStage1SuccessWeight, ')
          ..write('currentT3AmrapVolume: $currentT3AmrapVolume, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    liftId,
    currentTier,
    currentStage,
    nextTargetWeight,
    lastStage1SuccessWeight,
    currentT3AmrapVolume,
    lastUpdated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CycleState &&
          other.id == this.id &&
          other.liftId == this.liftId &&
          other.currentTier == this.currentTier &&
          other.currentStage == this.currentStage &&
          other.nextTargetWeight == this.nextTargetWeight &&
          other.lastStage1SuccessWeight == this.lastStage1SuccessWeight &&
          other.currentT3AmrapVolume == this.currentT3AmrapVolume &&
          other.lastUpdated == this.lastUpdated);
}

class CycleStateCompanion extends UpdateCompanion<CycleState> {
  final Value<int> id;
  final Value<int> liftId;
  final Value<String> currentTier;
  final Value<int> currentStage;
  final Value<double> nextTargetWeight;
  final Value<double?> lastStage1SuccessWeight;
  final Value<int> currentT3AmrapVolume;
  final Value<DateTime> lastUpdated;
  const CycleStateCompanion({
    this.id = const Value.absent(),
    this.liftId = const Value.absent(),
    this.currentTier = const Value.absent(),
    this.currentStage = const Value.absent(),
    this.nextTargetWeight = const Value.absent(),
    this.lastStage1SuccessWeight = const Value.absent(),
    this.currentT3AmrapVolume = const Value.absent(),
    this.lastUpdated = const Value.absent(),
  });
  CycleStateCompanion.insert({
    this.id = const Value.absent(),
    required int liftId,
    required String currentTier,
    required int currentStage,
    required double nextTargetWeight,
    this.lastStage1SuccessWeight = const Value.absent(),
    this.currentT3AmrapVolume = const Value.absent(),
    this.lastUpdated = const Value.absent(),
  }) : liftId = Value(liftId),
       currentTier = Value(currentTier),
       currentStage = Value(currentStage),
       nextTargetWeight = Value(nextTargetWeight);
  static Insertable<CycleState> custom({
    Expression<int>? id,
    Expression<int>? liftId,
    Expression<String>? currentTier,
    Expression<int>? currentStage,
    Expression<double>? nextTargetWeight,
    Expression<double>? lastStage1SuccessWeight,
    Expression<int>? currentT3AmrapVolume,
    Expression<DateTime>? lastUpdated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (liftId != null) 'lift_id': liftId,
      if (currentTier != null) 'current_tier': currentTier,
      if (currentStage != null) 'current_stage': currentStage,
      if (nextTargetWeight != null) 'next_target_weight': nextTargetWeight,
      if (lastStage1SuccessWeight != null)
        'last_stage1_success_weight': lastStage1SuccessWeight,
      if (currentT3AmrapVolume != null)
        'current_t3_amrap_volume': currentT3AmrapVolume,
      if (lastUpdated != null) 'last_updated': lastUpdated,
    });
  }

  CycleStateCompanion copyWith({
    Value<int>? id,
    Value<int>? liftId,
    Value<String>? currentTier,
    Value<int>? currentStage,
    Value<double>? nextTargetWeight,
    Value<double?>? lastStage1SuccessWeight,
    Value<int>? currentT3AmrapVolume,
    Value<DateTime>? lastUpdated,
  }) {
    return CycleStateCompanion(
      id: id ?? this.id,
      liftId: liftId ?? this.liftId,
      currentTier: currentTier ?? this.currentTier,
      currentStage: currentStage ?? this.currentStage,
      nextTargetWeight: nextTargetWeight ?? this.nextTargetWeight,
      lastStage1SuccessWeight:
          lastStage1SuccessWeight ?? this.lastStage1SuccessWeight,
      currentT3AmrapVolume: currentT3AmrapVolume ?? this.currentT3AmrapVolume,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (liftId.present) {
      map['lift_id'] = Variable<int>(liftId.value);
    }
    if (currentTier.present) {
      map['current_tier'] = Variable<String>(currentTier.value);
    }
    if (currentStage.present) {
      map['current_stage'] = Variable<int>(currentStage.value);
    }
    if (nextTargetWeight.present) {
      map['next_target_weight'] = Variable<double>(nextTargetWeight.value);
    }
    if (lastStage1SuccessWeight.present) {
      map['last_stage1_success_weight'] = Variable<double>(
        lastStage1SuccessWeight.value,
      );
    }
    if (currentT3AmrapVolume.present) {
      map['current_t3_amrap_volume'] = Variable<int>(
        currentT3AmrapVolume.value,
      );
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CycleStateCompanion(')
          ..write('id: $id, ')
          ..write('liftId: $liftId, ')
          ..write('currentTier: $currentTier, ')
          ..write('currentStage: $currentStage, ')
          ..write('nextTargetWeight: $nextTargetWeight, ')
          ..write('lastStage1SuccessWeight: $lastStage1SuccessWeight, ')
          ..write('currentT3AmrapVolume: $currentT3AmrapVolume, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSessionsTable extends WorkoutSessions
    with TableInfo<$WorkoutSessionsTable, WorkoutSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dayTypeMeta = const VerificationMeta(
    'dayType',
  );
  @override
  late final GeneratedColumn<String> dayType = GeneratedColumn<String>(
    'day_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 1,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateStartedMeta = const VerificationMeta(
    'dateStarted',
  );
  @override
  late final GeneratedColumn<DateTime> dateStarted = GeneratedColumn<DateTime>(
    'date_started',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateCompletedMeta = const VerificationMeta(
    'dateCompleted',
  );
  @override
  late final GeneratedColumn<DateTime> dateCompleted =
      GeneratedColumn<DateTime>(
        'date_completed',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isFinalizedMeta = const VerificationMeta(
    'isFinalized',
  );
  @override
  late final GeneratedColumn<bool> isFinalized = GeneratedColumn<bool>(
    'is_finalized',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_finalized" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sessionNotesMeta = const VerificationMeta(
    'sessionNotes',
  );
  @override
  late final GeneratedColumn<String> sessionNotes = GeneratedColumn<String>(
    'session_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dayType,
    dateStarted,
    dateCompleted,
    isFinalized,
    sessionNotes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day_type')) {
      context.handle(
        _dayTypeMeta,
        dayType.isAcceptableOrUnknown(data['day_type']!, _dayTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_dayTypeMeta);
    }
    if (data.containsKey('date_started')) {
      context.handle(
        _dateStartedMeta,
        dateStarted.isAcceptableOrUnknown(
          data['date_started']!,
          _dateStartedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateStartedMeta);
    }
    if (data.containsKey('date_completed')) {
      context.handle(
        _dateCompletedMeta,
        dateCompleted.isAcceptableOrUnknown(
          data['date_completed']!,
          _dateCompletedMeta,
        ),
      );
    }
    if (data.containsKey('is_finalized')) {
      context.handle(
        _isFinalizedMeta,
        isFinalized.isAcceptableOrUnknown(
          data['is_finalized']!,
          _isFinalizedMeta,
        ),
      );
    }
    if (data.containsKey('session_notes')) {
      context.handle(
        _sessionNotesMeta,
        sessionNotes.isAcceptableOrUnknown(
          data['session_notes']!,
          _sessionNotesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dayType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_type'],
      )!,
      dateStarted: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_started'],
      )!,
      dateCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_completed'],
      ),
      isFinalized: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_finalized'],
      )!,
      sessionNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_notes'],
      ),
    );
  }

  @override
  $WorkoutSessionsTable createAlias(String alias) {
    return $WorkoutSessionsTable(attachedDatabase, alias);
  }
}

class WorkoutSession extends DataClass implements Insertable<WorkoutSession> {
  final int id;

  /// Day type: 'A', 'B', 'C', or 'D'
  /// Determines which lifts are performed
  final String dayType;

  /// When the workout was started
  final DateTime dateStarted;

  /// When the workout was completed (null if in progress)
  final DateTime? dateCompleted;

  /// Critical flag: Has the progression logic been applied?
  /// Must be true before starting next workout
  final bool isFinalized;

  /// Optional notes about the entire session
  final String? sessionNotes;
  const WorkoutSession({
    required this.id,
    required this.dayType,
    required this.dateStarted,
    this.dateCompleted,
    required this.isFinalized,
    this.sessionNotes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day_type'] = Variable<String>(dayType);
    map['date_started'] = Variable<DateTime>(dateStarted);
    if (!nullToAbsent || dateCompleted != null) {
      map['date_completed'] = Variable<DateTime>(dateCompleted);
    }
    map['is_finalized'] = Variable<bool>(isFinalized);
    if (!nullToAbsent || sessionNotes != null) {
      map['session_notes'] = Variable<String>(sessionNotes);
    }
    return map;
  }

  WorkoutSessionCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSessionCompanion(
      id: Value(id),
      dayType: Value(dayType),
      dateStarted: Value(dateStarted),
      dateCompleted: dateCompleted == null && nullToAbsent
          ? const Value.absent()
          : Value(dateCompleted),
      isFinalized: Value(isFinalized),
      sessionNotes: sessionNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionNotes),
    );
  }

  factory WorkoutSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSession(
      id: serializer.fromJson<int>(json['id']),
      dayType: serializer.fromJson<String>(json['dayType']),
      dateStarted: serializer.fromJson<DateTime>(json['dateStarted']),
      dateCompleted: serializer.fromJson<DateTime?>(json['dateCompleted']),
      isFinalized: serializer.fromJson<bool>(json['isFinalized']),
      sessionNotes: serializer.fromJson<String?>(json['sessionNotes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dayType': serializer.toJson<String>(dayType),
      'dateStarted': serializer.toJson<DateTime>(dateStarted),
      'dateCompleted': serializer.toJson<DateTime?>(dateCompleted),
      'isFinalized': serializer.toJson<bool>(isFinalized),
      'sessionNotes': serializer.toJson<String?>(sessionNotes),
    };
  }

  WorkoutSession copyWith({
    int? id,
    String? dayType,
    DateTime? dateStarted,
    Value<DateTime?> dateCompleted = const Value.absent(),
    bool? isFinalized,
    Value<String?> sessionNotes = const Value.absent(),
  }) => WorkoutSession(
    id: id ?? this.id,
    dayType: dayType ?? this.dayType,
    dateStarted: dateStarted ?? this.dateStarted,
    dateCompleted: dateCompleted.present
        ? dateCompleted.value
        : this.dateCompleted,
    isFinalized: isFinalized ?? this.isFinalized,
    sessionNotes: sessionNotes.present ? sessionNotes.value : this.sessionNotes,
  );
  WorkoutSession copyWithCompanion(WorkoutSessionCompanion data) {
    return WorkoutSession(
      id: data.id.present ? data.id.value : this.id,
      dayType: data.dayType.present ? data.dayType.value : this.dayType,
      dateStarted: data.dateStarted.present
          ? data.dateStarted.value
          : this.dateStarted,
      dateCompleted: data.dateCompleted.present
          ? data.dateCompleted.value
          : this.dateCompleted,
      isFinalized: data.isFinalized.present
          ? data.isFinalized.value
          : this.isFinalized,
      sessionNotes: data.sessionNotes.present
          ? data.sessionNotes.value
          : this.sessionNotes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSession(')
          ..write('id: $id, ')
          ..write('dayType: $dayType, ')
          ..write('dateStarted: $dateStarted, ')
          ..write('dateCompleted: $dateCompleted, ')
          ..write('isFinalized: $isFinalized, ')
          ..write('sessionNotes: $sessionNotes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dayType,
    dateStarted,
    dateCompleted,
    isFinalized,
    sessionNotes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSession &&
          other.id == this.id &&
          other.dayType == this.dayType &&
          other.dateStarted == this.dateStarted &&
          other.dateCompleted == this.dateCompleted &&
          other.isFinalized == this.isFinalized &&
          other.sessionNotes == this.sessionNotes);
}

class WorkoutSessionCompanion extends UpdateCompanion<WorkoutSession> {
  final Value<int> id;
  final Value<String> dayType;
  final Value<DateTime> dateStarted;
  final Value<DateTime?> dateCompleted;
  final Value<bool> isFinalized;
  final Value<String?> sessionNotes;
  const WorkoutSessionCompanion({
    this.id = const Value.absent(),
    this.dayType = const Value.absent(),
    this.dateStarted = const Value.absent(),
    this.dateCompleted = const Value.absent(),
    this.isFinalized = const Value.absent(),
    this.sessionNotes = const Value.absent(),
  });
  WorkoutSessionCompanion.insert({
    this.id = const Value.absent(),
    required String dayType,
    required DateTime dateStarted,
    this.dateCompleted = const Value.absent(),
    this.isFinalized = const Value.absent(),
    this.sessionNotes = const Value.absent(),
  }) : dayType = Value(dayType),
       dateStarted = Value(dateStarted);
  static Insertable<WorkoutSession> custom({
    Expression<int>? id,
    Expression<String>? dayType,
    Expression<DateTime>? dateStarted,
    Expression<DateTime>? dateCompleted,
    Expression<bool>? isFinalized,
    Expression<String>? sessionNotes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dayType != null) 'day_type': dayType,
      if (dateStarted != null) 'date_started': dateStarted,
      if (dateCompleted != null) 'date_completed': dateCompleted,
      if (isFinalized != null) 'is_finalized': isFinalized,
      if (sessionNotes != null) 'session_notes': sessionNotes,
    });
  }

  WorkoutSessionCompanion copyWith({
    Value<int>? id,
    Value<String>? dayType,
    Value<DateTime>? dateStarted,
    Value<DateTime?>? dateCompleted,
    Value<bool>? isFinalized,
    Value<String?>? sessionNotes,
  }) {
    return WorkoutSessionCompanion(
      id: id ?? this.id,
      dayType: dayType ?? this.dayType,
      dateStarted: dateStarted ?? this.dateStarted,
      dateCompleted: dateCompleted ?? this.dateCompleted,
      isFinalized: isFinalized ?? this.isFinalized,
      sessionNotes: sessionNotes ?? this.sessionNotes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dayType.present) {
      map['day_type'] = Variable<String>(dayType.value);
    }
    if (dateStarted.present) {
      map['date_started'] = Variable<DateTime>(dateStarted.value);
    }
    if (dateCompleted.present) {
      map['date_completed'] = Variable<DateTime>(dateCompleted.value);
    }
    if (isFinalized.present) {
      map['is_finalized'] = Variable<bool>(isFinalized.value);
    }
    if (sessionNotes.present) {
      map['session_notes'] = Variable<String>(sessionNotes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionCompanion(')
          ..write('id: $id, ')
          ..write('dayType: $dayType, ')
          ..write('dateStarted: $dateStarted, ')
          ..write('dateCompleted: $dateCompleted, ')
          ..write('isFinalized: $isFinalized, ')
          ..write('sessionNotes: $sessionNotes')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSetsTable extends WorkoutSets
    with TableInfo<$WorkoutSetsTable, WorkoutSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSetsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _liftIdMeta = const VerificationMeta('liftId');
  @override
  late final GeneratedColumn<int> liftId = GeneratedColumn<int>(
    'lift_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES lifts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tierMeta = const VerificationMeta('tier');
  @override
  late final GeneratedColumn<String> tier = GeneratedColumn<String>(
    'tier',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 2,
      maxTextLength: 2,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setNumberMeta = const VerificationMeta(
    'setNumber',
  );
  @override
  late final GeneratedColumn<int> setNumber = GeneratedColumn<int>(
    'set_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetRepsMeta = const VerificationMeta(
    'targetReps',
  );
  @override
  late final GeneratedColumn<int> targetReps = GeneratedColumn<int>(
    'target_reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualRepsMeta = const VerificationMeta(
    'actualReps',
  );
  @override
  late final GeneratedColumn<int> actualReps = GeneratedColumn<int>(
    'actual_reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetWeightMeta = const VerificationMeta(
    'targetWeight',
  );
  @override
  late final GeneratedColumn<double> targetWeight = GeneratedColumn<double>(
    'target_weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualWeightMeta = const VerificationMeta(
    'actualWeight',
  );
  @override
  late final GeneratedColumn<double> actualWeight = GeneratedColumn<double>(
    'actual_weight',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isAmrapMeta = const VerificationMeta(
    'isAmrap',
  );
  @override
  late final GeneratedColumn<bool> isAmrap = GeneratedColumn<bool>(
    'is_amrap',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_amrap" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _setNotesMeta = const VerificationMeta(
    'setNotes',
  );
  @override
  late final GeneratedColumn<String> setNotes = GeneratedColumn<String>(
    'set_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exerciseNameMeta = const VerificationMeta(
    'exerciseName',
  );
  @override
  late final GeneratedColumn<String> exerciseName = GeneratedColumn<String>(
    'exercise_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    liftId,
    tier,
    setNumber,
    targetReps,
    actualReps,
    targetWeight,
    actualWeight,
    isAmrap,
    setNotes,
    exerciseName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('lift_id')) {
      context.handle(
        _liftIdMeta,
        liftId.isAcceptableOrUnknown(data['lift_id']!, _liftIdMeta),
      );
    } else if (isInserting) {
      context.missing(_liftIdMeta);
    }
    if (data.containsKey('tier')) {
      context.handle(
        _tierMeta,
        tier.isAcceptableOrUnknown(data['tier']!, _tierMeta),
      );
    } else if (isInserting) {
      context.missing(_tierMeta);
    }
    if (data.containsKey('set_number')) {
      context.handle(
        _setNumberMeta,
        setNumber.isAcceptableOrUnknown(data['set_number']!, _setNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_setNumberMeta);
    }
    if (data.containsKey('target_reps')) {
      context.handle(
        _targetRepsMeta,
        targetReps.isAcceptableOrUnknown(data['target_reps']!, _targetRepsMeta),
      );
    } else if (isInserting) {
      context.missing(_targetRepsMeta);
    }
    if (data.containsKey('actual_reps')) {
      context.handle(
        _actualRepsMeta,
        actualReps.isAcceptableOrUnknown(data['actual_reps']!, _actualRepsMeta),
      );
    }
    if (data.containsKey('target_weight')) {
      context.handle(
        _targetWeightMeta,
        targetWeight.isAcceptableOrUnknown(
          data['target_weight']!,
          _targetWeightMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetWeightMeta);
    }
    if (data.containsKey('actual_weight')) {
      context.handle(
        _actualWeightMeta,
        actualWeight.isAcceptableOrUnknown(
          data['actual_weight']!,
          _actualWeightMeta,
        ),
      );
    }
    if (data.containsKey('is_amrap')) {
      context.handle(
        _isAmrapMeta,
        isAmrap.isAcceptableOrUnknown(data['is_amrap']!, _isAmrapMeta),
      );
    }
    if (data.containsKey('set_notes')) {
      context.handle(
        _setNotesMeta,
        setNotes.isAcceptableOrUnknown(data['set_notes']!, _setNotesMeta),
      );
    }
    if (data.containsKey('exercise_name')) {
      context.handle(
        _exerciseNameMeta,
        exerciseName.isAcceptableOrUnknown(
          data['exercise_name']!,
          _exerciseNameMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      liftId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lift_id'],
      )!,
      tier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tier'],
      )!,
      setNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_number'],
      )!,
      targetReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_reps'],
      )!,
      actualReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_reps'],
      ),
      targetWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_weight'],
      )!,
      actualWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_weight'],
      ),
      isAmrap: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_amrap'],
      )!,
      setNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_notes'],
      ),
      exerciseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_name'],
      ),
    );
  }

  @override
  $WorkoutSetsTable createAlias(String alias) {
    return $WorkoutSetsTable(attachedDatabase, alias);
  }
}

class WorkoutSet extends DataClass implements Insertable<WorkoutSet> {
  final int id;

  /// Foreign key to WorkoutSessions
  final int sessionId;

  /// Foreign key to Lifts
  final int liftId;

  /// Tier for this set: 'T1', 'T2', or 'T3'
  final String tier;

  /// Set number within this lift (1, 2, 3, etc.)
  /// Validated at application layer (must be > 0)
  final int setNumber;

  /// Target (programmed) reps for this set
  /// Validated at application layer (must be > 0)
  final int targetReps;

  /// Actual reps performed (null if not yet logged)
  final int? actualReps;

  /// Target (programmed) weight for this set
  /// Validated at application layer (must be >= 0)
  final double targetWeight;

  /// Actual weight used (null if not yet logged)
  /// Allows for user adjustments (e.g., bar was heavier than expected)
  final double? actualWeight;

  /// Is this an AMRAP (As Many Reps As Possible) set?
  /// These sets are crucial for progression decisions
  final bool isAmrap;

  /// Optional notes about this specific set
  final String? setNotes;

  /// Exercise name (used for T3 accessory exercises)
  /// For T1/T2, this is null and liftId is used to determine name
  final String? exerciseName;
  const WorkoutSet({
    required this.id,
    required this.sessionId,
    required this.liftId,
    required this.tier,
    required this.setNumber,
    required this.targetReps,
    this.actualReps,
    required this.targetWeight,
    this.actualWeight,
    required this.isAmrap,
    this.setNotes,
    this.exerciseName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['lift_id'] = Variable<int>(liftId);
    map['tier'] = Variable<String>(tier);
    map['set_number'] = Variable<int>(setNumber);
    map['target_reps'] = Variable<int>(targetReps);
    if (!nullToAbsent || actualReps != null) {
      map['actual_reps'] = Variable<int>(actualReps);
    }
    map['target_weight'] = Variable<double>(targetWeight);
    if (!nullToAbsent || actualWeight != null) {
      map['actual_weight'] = Variable<double>(actualWeight);
    }
    map['is_amrap'] = Variable<bool>(isAmrap);
    if (!nullToAbsent || setNotes != null) {
      map['set_notes'] = Variable<String>(setNotes);
    }
    if (!nullToAbsent || exerciseName != null) {
      map['exercise_name'] = Variable<String>(exerciseName);
    }
    return map;
  }

  WorkoutSetCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSetCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      liftId: Value(liftId),
      tier: Value(tier),
      setNumber: Value(setNumber),
      targetReps: Value(targetReps),
      actualReps: actualReps == null && nullToAbsent
          ? const Value.absent()
          : Value(actualReps),
      targetWeight: Value(targetWeight),
      actualWeight: actualWeight == null && nullToAbsent
          ? const Value.absent()
          : Value(actualWeight),
      isAmrap: Value(isAmrap),
      setNotes: setNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(setNotes),
      exerciseName: exerciseName == null && nullToAbsent
          ? const Value.absent()
          : Value(exerciseName),
    );
  }

  factory WorkoutSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSet(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      liftId: serializer.fromJson<int>(json['liftId']),
      tier: serializer.fromJson<String>(json['tier']),
      setNumber: serializer.fromJson<int>(json['setNumber']),
      targetReps: serializer.fromJson<int>(json['targetReps']),
      actualReps: serializer.fromJson<int?>(json['actualReps']),
      targetWeight: serializer.fromJson<double>(json['targetWeight']),
      actualWeight: serializer.fromJson<double?>(json['actualWeight']),
      isAmrap: serializer.fromJson<bool>(json['isAmrap']),
      setNotes: serializer.fromJson<String?>(json['setNotes']),
      exerciseName: serializer.fromJson<String?>(json['exerciseName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'liftId': serializer.toJson<int>(liftId),
      'tier': serializer.toJson<String>(tier),
      'setNumber': serializer.toJson<int>(setNumber),
      'targetReps': serializer.toJson<int>(targetReps),
      'actualReps': serializer.toJson<int?>(actualReps),
      'targetWeight': serializer.toJson<double>(targetWeight),
      'actualWeight': serializer.toJson<double?>(actualWeight),
      'isAmrap': serializer.toJson<bool>(isAmrap),
      'setNotes': serializer.toJson<String?>(setNotes),
      'exerciseName': serializer.toJson<String?>(exerciseName),
    };
  }

  WorkoutSet copyWith({
    int? id,
    int? sessionId,
    int? liftId,
    String? tier,
    int? setNumber,
    int? targetReps,
    Value<int?> actualReps = const Value.absent(),
    double? targetWeight,
    Value<double?> actualWeight = const Value.absent(),
    bool? isAmrap,
    Value<String?> setNotes = const Value.absent(),
    Value<String?> exerciseName = const Value.absent(),
  }) => WorkoutSet(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    liftId: liftId ?? this.liftId,
    tier: tier ?? this.tier,
    setNumber: setNumber ?? this.setNumber,
    targetReps: targetReps ?? this.targetReps,
    actualReps: actualReps.present ? actualReps.value : this.actualReps,
    targetWeight: targetWeight ?? this.targetWeight,
    actualWeight: actualWeight.present ? actualWeight.value : this.actualWeight,
    isAmrap: isAmrap ?? this.isAmrap,
    setNotes: setNotes.present ? setNotes.value : this.setNotes,
    exerciseName: exerciseName.present ? exerciseName.value : this.exerciseName,
  );
  WorkoutSet copyWithCompanion(WorkoutSetCompanion data) {
    return WorkoutSet(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      liftId: data.liftId.present ? data.liftId.value : this.liftId,
      tier: data.tier.present ? data.tier.value : this.tier,
      setNumber: data.setNumber.present ? data.setNumber.value : this.setNumber,
      targetReps: data.targetReps.present
          ? data.targetReps.value
          : this.targetReps,
      actualReps: data.actualReps.present
          ? data.actualReps.value
          : this.actualReps,
      targetWeight: data.targetWeight.present
          ? data.targetWeight.value
          : this.targetWeight,
      actualWeight: data.actualWeight.present
          ? data.actualWeight.value
          : this.actualWeight,
      isAmrap: data.isAmrap.present ? data.isAmrap.value : this.isAmrap,
      setNotes: data.setNotes.present ? data.setNotes.value : this.setNotes,
      exerciseName: data.exerciseName.present
          ? data.exerciseName.value
          : this.exerciseName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSet(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('liftId: $liftId, ')
          ..write('tier: $tier, ')
          ..write('setNumber: $setNumber, ')
          ..write('targetReps: $targetReps, ')
          ..write('actualReps: $actualReps, ')
          ..write('targetWeight: $targetWeight, ')
          ..write('actualWeight: $actualWeight, ')
          ..write('isAmrap: $isAmrap, ')
          ..write('setNotes: $setNotes, ')
          ..write('exerciseName: $exerciseName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    liftId,
    tier,
    setNumber,
    targetReps,
    actualReps,
    targetWeight,
    actualWeight,
    isAmrap,
    setNotes,
    exerciseName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSet &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.liftId == this.liftId &&
          other.tier == this.tier &&
          other.setNumber == this.setNumber &&
          other.targetReps == this.targetReps &&
          other.actualReps == this.actualReps &&
          other.targetWeight == this.targetWeight &&
          other.actualWeight == this.actualWeight &&
          other.isAmrap == this.isAmrap &&
          other.setNotes == this.setNotes &&
          other.exerciseName == this.exerciseName);
}

class WorkoutSetCompanion extends UpdateCompanion<WorkoutSet> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> liftId;
  final Value<String> tier;
  final Value<int> setNumber;
  final Value<int> targetReps;
  final Value<int?> actualReps;
  final Value<double> targetWeight;
  final Value<double?> actualWeight;
  final Value<bool> isAmrap;
  final Value<String?> setNotes;
  final Value<String?> exerciseName;
  const WorkoutSetCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.liftId = const Value.absent(),
    this.tier = const Value.absent(),
    this.setNumber = const Value.absent(),
    this.targetReps = const Value.absent(),
    this.actualReps = const Value.absent(),
    this.targetWeight = const Value.absent(),
    this.actualWeight = const Value.absent(),
    this.isAmrap = const Value.absent(),
    this.setNotes = const Value.absent(),
    this.exerciseName = const Value.absent(),
  });
  WorkoutSetCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int liftId,
    required String tier,
    required int setNumber,
    required int targetReps,
    this.actualReps = const Value.absent(),
    required double targetWeight,
    this.actualWeight = const Value.absent(),
    this.isAmrap = const Value.absent(),
    this.setNotes = const Value.absent(),
    this.exerciseName = const Value.absent(),
  }) : sessionId = Value(sessionId),
       liftId = Value(liftId),
       tier = Value(tier),
       setNumber = Value(setNumber),
       targetReps = Value(targetReps),
       targetWeight = Value(targetWeight);
  static Insertable<WorkoutSet> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? liftId,
    Expression<String>? tier,
    Expression<int>? setNumber,
    Expression<int>? targetReps,
    Expression<int>? actualReps,
    Expression<double>? targetWeight,
    Expression<double>? actualWeight,
    Expression<bool>? isAmrap,
    Expression<String>? setNotes,
    Expression<String>? exerciseName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (liftId != null) 'lift_id': liftId,
      if (tier != null) 'tier': tier,
      if (setNumber != null) 'set_number': setNumber,
      if (targetReps != null) 'target_reps': targetReps,
      if (actualReps != null) 'actual_reps': actualReps,
      if (targetWeight != null) 'target_weight': targetWeight,
      if (actualWeight != null) 'actual_weight': actualWeight,
      if (isAmrap != null) 'is_amrap': isAmrap,
      if (setNotes != null) 'set_notes': setNotes,
      if (exerciseName != null) 'exercise_name': exerciseName,
    });
  }

  WorkoutSetCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int>? liftId,
    Value<String>? tier,
    Value<int>? setNumber,
    Value<int>? targetReps,
    Value<int?>? actualReps,
    Value<double>? targetWeight,
    Value<double?>? actualWeight,
    Value<bool>? isAmrap,
    Value<String?>? setNotes,
    Value<String?>? exerciseName,
  }) {
    return WorkoutSetCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      liftId: liftId ?? this.liftId,
      tier: tier ?? this.tier,
      setNumber: setNumber ?? this.setNumber,
      targetReps: targetReps ?? this.targetReps,
      actualReps: actualReps ?? this.actualReps,
      targetWeight: targetWeight ?? this.targetWeight,
      actualWeight: actualWeight ?? this.actualWeight,
      isAmrap: isAmrap ?? this.isAmrap,
      setNotes: setNotes ?? this.setNotes,
      exerciseName: exerciseName ?? this.exerciseName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (liftId.present) {
      map['lift_id'] = Variable<int>(liftId.value);
    }
    if (tier.present) {
      map['tier'] = Variable<String>(tier.value);
    }
    if (setNumber.present) {
      map['set_number'] = Variable<int>(setNumber.value);
    }
    if (targetReps.present) {
      map['target_reps'] = Variable<int>(targetReps.value);
    }
    if (actualReps.present) {
      map['actual_reps'] = Variable<int>(actualReps.value);
    }
    if (targetWeight.present) {
      map['target_weight'] = Variable<double>(targetWeight.value);
    }
    if (actualWeight.present) {
      map['actual_weight'] = Variable<double>(actualWeight.value);
    }
    if (isAmrap.present) {
      map['is_amrap'] = Variable<bool>(isAmrap.value);
    }
    if (setNotes.present) {
      map['set_notes'] = Variable<String>(setNotes.value);
    }
    if (exerciseName.present) {
      map['exercise_name'] = Variable<String>(exerciseName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSetCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('liftId: $liftId, ')
          ..write('tier: $tier, ')
          ..write('setNumber: $setNumber, ')
          ..write('targetReps: $targetReps, ')
          ..write('actualReps: $actualReps, ')
          ..write('targetWeight: $targetWeight, ')
          ..write('actualWeight: $actualWeight, ')
          ..write('isAmrap: $isAmrap, ')
          ..write('setNotes: $setNotes, ')
          ..write('exerciseName: $exerciseName')
          ..write(')'))
        .toString();
  }
}

class $UserPreferencesTable extends UserPreferences
    with TableInfo<$UserPreferencesTable, UserPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPreferencesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _unitSystemMeta = const VerificationMeta(
    'unitSystem',
  );
  @override
  late final GeneratedColumn<String> unitSystem = GeneratedColumn<String>(
    'unit_system',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 6,
      maxTextLength: 8,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('imperial'),
  );
  static const VerificationMeta _t1RestSecondsMeta = const VerificationMeta(
    't1RestSeconds',
  );
  @override
  late final GeneratedColumn<int> t1RestSeconds = GeneratedColumn<int>(
    't1_rest_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(240),
  );
  static const VerificationMeta _t2RestSecondsMeta = const VerificationMeta(
    't2RestSeconds',
  );
  @override
  late final GeneratedColumn<int> t2RestSeconds = GeneratedColumn<int>(
    't2_rest_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(150),
  );
  static const VerificationMeta _t3RestSecondsMeta = const VerificationMeta(
    't3RestSeconds',
  );
  @override
  late final GeneratedColumn<int> t3RestSeconds = GeneratedColumn<int>(
    't3_rest_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(75),
  );
  static const VerificationMeta _minimumRestHoursMeta = const VerificationMeta(
    'minimumRestHours',
  );
  @override
  late final GeneratedColumn<int> minimumRestHours = GeneratedColumn<int>(
    'minimum_rest_hours',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(24),
  );
  static const VerificationMeta _hasCompletedOnboardingMeta =
      const VerificationMeta('hasCompletedOnboarding');
  @override
  late final GeneratedColumn<bool> hasCompletedOnboarding =
      GeneratedColumn<bool>(
        'has_completed_onboarding',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_completed_onboarding" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    unitSystem,
    t1RestSeconds,
    t2RestSeconds,
    t3RestSeconds,
    minimumRestHours,
    hasCompletedOnboarding,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('unit_system')) {
      context.handle(
        _unitSystemMeta,
        unitSystem.isAcceptableOrUnknown(data['unit_system']!, _unitSystemMeta),
      );
    }
    if (data.containsKey('t1_rest_seconds')) {
      context.handle(
        _t1RestSecondsMeta,
        t1RestSeconds.isAcceptableOrUnknown(
          data['t1_rest_seconds']!,
          _t1RestSecondsMeta,
        ),
      );
    }
    if (data.containsKey('t2_rest_seconds')) {
      context.handle(
        _t2RestSecondsMeta,
        t2RestSeconds.isAcceptableOrUnknown(
          data['t2_rest_seconds']!,
          _t2RestSecondsMeta,
        ),
      );
    }
    if (data.containsKey('t3_rest_seconds')) {
      context.handle(
        _t3RestSecondsMeta,
        t3RestSeconds.isAcceptableOrUnknown(
          data['t3_rest_seconds']!,
          _t3RestSecondsMeta,
        ),
      );
    }
    if (data.containsKey('minimum_rest_hours')) {
      context.handle(
        _minimumRestHoursMeta,
        minimumRestHours.isAcceptableOrUnknown(
          data['minimum_rest_hours']!,
          _minimumRestHoursMeta,
        ),
      );
    }
    if (data.containsKey('has_completed_onboarding')) {
      context.handle(
        _hasCompletedOnboardingMeta,
        hasCompletedOnboarding.isAcceptableOrUnknown(
          data['has_completed_onboarding']!,
          _hasCompletedOnboardingMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPreference(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      unitSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_system'],
      )!,
      t1RestSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}t1_rest_seconds'],
      )!,
      t2RestSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}t2_rest_seconds'],
      )!,
      t3RestSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}t3_rest_seconds'],
      )!,
      minimumRestHours: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minimum_rest_hours'],
      )!,
      hasCompletedOnboarding: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_completed_onboarding'],
      )!,
    );
  }

  @override
  $UserPreferencesTable createAlias(String alias) {
    return $UserPreferencesTable(attachedDatabase, alias);
  }
}

class UserPreference extends DataClass implements Insertable<UserPreference> {
  final int id;

  /// Unit system: 'imperial' (lbs) or 'metric' (kg)
  final String unitSystem;

  /// Default rest time for T1 lifts (seconds)
  final int t1RestSeconds;

  /// Default rest time for T2 lifts (seconds)
  final int t2RestSeconds;

  /// Default rest time for T3 lifts (seconds)
  final int t3RestSeconds;

  /// Minimum rest hours required between workouts
  final int minimumRestHours;

  /// Has the user completed the onboarding flow?
  final bool hasCompletedOnboarding;
  const UserPreference({
    required this.id,
    required this.unitSystem,
    required this.t1RestSeconds,
    required this.t2RestSeconds,
    required this.t3RestSeconds,
    required this.minimumRestHours,
    required this.hasCompletedOnboarding,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['unit_system'] = Variable<String>(unitSystem);
    map['t1_rest_seconds'] = Variable<int>(t1RestSeconds);
    map['t2_rest_seconds'] = Variable<int>(t2RestSeconds);
    map['t3_rest_seconds'] = Variable<int>(t3RestSeconds);
    map['minimum_rest_hours'] = Variable<int>(minimumRestHours);
    map['has_completed_onboarding'] = Variable<bool>(hasCompletedOnboarding);
    return map;
  }

  UserPreferenceCompanion toCompanion(bool nullToAbsent) {
    return UserPreferenceCompanion(
      id: Value(id),
      unitSystem: Value(unitSystem),
      t1RestSeconds: Value(t1RestSeconds),
      t2RestSeconds: Value(t2RestSeconds),
      t3RestSeconds: Value(t3RestSeconds),
      minimumRestHours: Value(minimumRestHours),
      hasCompletedOnboarding: Value(hasCompletedOnboarding),
    );
  }

  factory UserPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPreference(
      id: serializer.fromJson<int>(json['id']),
      unitSystem: serializer.fromJson<String>(json['unitSystem']),
      t1RestSeconds: serializer.fromJson<int>(json['t1RestSeconds']),
      t2RestSeconds: serializer.fromJson<int>(json['t2RestSeconds']),
      t3RestSeconds: serializer.fromJson<int>(json['t3RestSeconds']),
      minimumRestHours: serializer.fromJson<int>(json['minimumRestHours']),
      hasCompletedOnboarding: serializer.fromJson<bool>(
        json['hasCompletedOnboarding'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'unitSystem': serializer.toJson<String>(unitSystem),
      't1RestSeconds': serializer.toJson<int>(t1RestSeconds),
      't2RestSeconds': serializer.toJson<int>(t2RestSeconds),
      't3RestSeconds': serializer.toJson<int>(t3RestSeconds),
      'minimumRestHours': serializer.toJson<int>(minimumRestHours),
      'hasCompletedOnboarding': serializer.toJson<bool>(hasCompletedOnboarding),
    };
  }

  UserPreference copyWith({
    int? id,
    String? unitSystem,
    int? t1RestSeconds,
    int? t2RestSeconds,
    int? t3RestSeconds,
    int? minimumRestHours,
    bool? hasCompletedOnboarding,
  }) => UserPreference(
    id: id ?? this.id,
    unitSystem: unitSystem ?? this.unitSystem,
    t1RestSeconds: t1RestSeconds ?? this.t1RestSeconds,
    t2RestSeconds: t2RestSeconds ?? this.t2RestSeconds,
    t3RestSeconds: t3RestSeconds ?? this.t3RestSeconds,
    minimumRestHours: minimumRestHours ?? this.minimumRestHours,
    hasCompletedOnboarding:
        hasCompletedOnboarding ?? this.hasCompletedOnboarding,
  );
  UserPreference copyWithCompanion(UserPreferenceCompanion data) {
    return UserPreference(
      id: data.id.present ? data.id.value : this.id,
      unitSystem: data.unitSystem.present
          ? data.unitSystem.value
          : this.unitSystem,
      t1RestSeconds: data.t1RestSeconds.present
          ? data.t1RestSeconds.value
          : this.t1RestSeconds,
      t2RestSeconds: data.t2RestSeconds.present
          ? data.t2RestSeconds.value
          : this.t2RestSeconds,
      t3RestSeconds: data.t3RestSeconds.present
          ? data.t3RestSeconds.value
          : this.t3RestSeconds,
      minimumRestHours: data.minimumRestHours.present
          ? data.minimumRestHours.value
          : this.minimumRestHours,
      hasCompletedOnboarding: data.hasCompletedOnboarding.present
          ? data.hasCompletedOnboarding.value
          : this.hasCompletedOnboarding,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPreference(')
          ..write('id: $id, ')
          ..write('unitSystem: $unitSystem, ')
          ..write('t1RestSeconds: $t1RestSeconds, ')
          ..write('t2RestSeconds: $t2RestSeconds, ')
          ..write('t3RestSeconds: $t3RestSeconds, ')
          ..write('minimumRestHours: $minimumRestHours, ')
          ..write('hasCompletedOnboarding: $hasCompletedOnboarding')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    unitSystem,
    t1RestSeconds,
    t2RestSeconds,
    t3RestSeconds,
    minimumRestHours,
    hasCompletedOnboarding,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPreference &&
          other.id == this.id &&
          other.unitSystem == this.unitSystem &&
          other.t1RestSeconds == this.t1RestSeconds &&
          other.t2RestSeconds == this.t2RestSeconds &&
          other.t3RestSeconds == this.t3RestSeconds &&
          other.minimumRestHours == this.minimumRestHours &&
          other.hasCompletedOnboarding == this.hasCompletedOnboarding);
}

class UserPreferenceCompanion extends UpdateCompanion<UserPreference> {
  final Value<int> id;
  final Value<String> unitSystem;
  final Value<int> t1RestSeconds;
  final Value<int> t2RestSeconds;
  final Value<int> t3RestSeconds;
  final Value<int> minimumRestHours;
  final Value<bool> hasCompletedOnboarding;
  const UserPreferenceCompanion({
    this.id = const Value.absent(),
    this.unitSystem = const Value.absent(),
    this.t1RestSeconds = const Value.absent(),
    this.t2RestSeconds = const Value.absent(),
    this.t3RestSeconds = const Value.absent(),
    this.minimumRestHours = const Value.absent(),
    this.hasCompletedOnboarding = const Value.absent(),
  });
  UserPreferenceCompanion.insert({
    this.id = const Value.absent(),
    this.unitSystem = const Value.absent(),
    this.t1RestSeconds = const Value.absent(),
    this.t2RestSeconds = const Value.absent(),
    this.t3RestSeconds = const Value.absent(),
    this.minimumRestHours = const Value.absent(),
    this.hasCompletedOnboarding = const Value.absent(),
  });
  static Insertable<UserPreference> custom({
    Expression<int>? id,
    Expression<String>? unitSystem,
    Expression<int>? t1RestSeconds,
    Expression<int>? t2RestSeconds,
    Expression<int>? t3RestSeconds,
    Expression<int>? minimumRestHours,
    Expression<bool>? hasCompletedOnboarding,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (unitSystem != null) 'unit_system': unitSystem,
      if (t1RestSeconds != null) 't1_rest_seconds': t1RestSeconds,
      if (t2RestSeconds != null) 't2_rest_seconds': t2RestSeconds,
      if (t3RestSeconds != null) 't3_rest_seconds': t3RestSeconds,
      if (minimumRestHours != null) 'minimum_rest_hours': minimumRestHours,
      if (hasCompletedOnboarding != null)
        'has_completed_onboarding': hasCompletedOnboarding,
    });
  }

  UserPreferenceCompanion copyWith({
    Value<int>? id,
    Value<String>? unitSystem,
    Value<int>? t1RestSeconds,
    Value<int>? t2RestSeconds,
    Value<int>? t3RestSeconds,
    Value<int>? minimumRestHours,
    Value<bool>? hasCompletedOnboarding,
  }) {
    return UserPreferenceCompanion(
      id: id ?? this.id,
      unitSystem: unitSystem ?? this.unitSystem,
      t1RestSeconds: t1RestSeconds ?? this.t1RestSeconds,
      t2RestSeconds: t2RestSeconds ?? this.t2RestSeconds,
      t3RestSeconds: t3RestSeconds ?? this.t3RestSeconds,
      minimumRestHours: minimumRestHours ?? this.minimumRestHours,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (unitSystem.present) {
      map['unit_system'] = Variable<String>(unitSystem.value);
    }
    if (t1RestSeconds.present) {
      map['t1_rest_seconds'] = Variable<int>(t1RestSeconds.value);
    }
    if (t2RestSeconds.present) {
      map['t2_rest_seconds'] = Variable<int>(t2RestSeconds.value);
    }
    if (t3RestSeconds.present) {
      map['t3_rest_seconds'] = Variable<int>(t3RestSeconds.value);
    }
    if (minimumRestHours.present) {
      map['minimum_rest_hours'] = Variable<int>(minimumRestHours.value);
    }
    if (hasCompletedOnboarding.present) {
      map['has_completed_onboarding'] = Variable<bool>(
        hasCompletedOnboarding.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPreferenceCompanion(')
          ..write('id: $id, ')
          ..write('unitSystem: $unitSystem, ')
          ..write('t1RestSeconds: $t1RestSeconds, ')
          ..write('t2RestSeconds: $t2RestSeconds, ')
          ..write('t3RestSeconds: $t3RestSeconds, ')
          ..write('minimumRestHours: $minimumRestHours, ')
          ..write('hasCompletedOnboarding: $hasCompletedOnboarding')
          ..write(')'))
        .toString();
  }
}

class $AccessoryExercisesTable extends AccessoryExercises
    with TableInfo<$AccessoryExercisesTable, AccessoryExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccessoryExercisesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dayTypeMeta = const VerificationMeta(
    'dayType',
  );
  @override
  late final GeneratedColumn<String> dayType = GeneratedColumn<String>(
    'day_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 1,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, dayType, orderIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accessory_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccessoryExercise> instance, {
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
    if (data.containsKey('day_type')) {
      context.handle(
        _dayTypeMeta,
        dayType.isAcceptableOrUnknown(data['day_type']!, _dayTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_dayTypeMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {dayType, orderIndex},
  ];
  @override
  AccessoryExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccessoryExercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      dayType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_type'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
    );
  }

  @override
  $AccessoryExercisesTable createAlias(String alias) {
    return $AccessoryExercisesTable(attachedDatabase, alias);
  }
}

class AccessoryExercise extends DataClass
    implements Insertable<AccessoryExercise> {
  final int id;

  /// Name of the accessory exercise (e.g., "Lat Pulldown", "Dumbbell Row")
  final String name;

  /// Which day this exercise is performed: 'A', 'B', 'C', or 'D'
  final String dayType;

  /// Order in which this exercise appears in the workout
  /// Lower numbers appear first
  final int orderIndex;
  const AccessoryExercise({
    required this.id,
    required this.name,
    required this.dayType,
    required this.orderIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['day_type'] = Variable<String>(dayType);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  AccessoryExerciseCompanion toCompanion(bool nullToAbsent) {
    return AccessoryExerciseCompanion(
      id: Value(id),
      name: Value(name),
      dayType: Value(dayType),
      orderIndex: Value(orderIndex),
    );
  }

  factory AccessoryExercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccessoryExercise(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      dayType: serializer.fromJson<String>(json['dayType']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'dayType': serializer.toJson<String>(dayType),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  AccessoryExercise copyWith({
    int? id,
    String? name,
    String? dayType,
    int? orderIndex,
  }) => AccessoryExercise(
    id: id ?? this.id,
    name: name ?? this.name,
    dayType: dayType ?? this.dayType,
    orderIndex: orderIndex ?? this.orderIndex,
  );
  AccessoryExercise copyWithCompanion(AccessoryExerciseCompanion data) {
    return AccessoryExercise(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      dayType: data.dayType.present ? data.dayType.value : this.dayType,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccessoryExercise(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dayType: $dayType, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, dayType, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccessoryExercise &&
          other.id == this.id &&
          other.name == this.name &&
          other.dayType == this.dayType &&
          other.orderIndex == this.orderIndex);
}

class AccessoryExerciseCompanion extends UpdateCompanion<AccessoryExercise> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> dayType;
  final Value<int> orderIndex;
  const AccessoryExerciseCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.dayType = const Value.absent(),
    this.orderIndex = const Value.absent(),
  });
  AccessoryExerciseCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String dayType,
    required int orderIndex,
  }) : name = Value(name),
       dayType = Value(dayType),
       orderIndex = Value(orderIndex);
  static Insertable<AccessoryExercise> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? dayType,
    Expression<int>? orderIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (dayType != null) 'day_type': dayType,
      if (orderIndex != null) 'order_index': orderIndex,
    });
  }

  AccessoryExerciseCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? dayType,
    Value<int>? orderIndex,
  }) {
    return AccessoryExerciseCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      dayType: dayType ?? this.dayType,
      orderIndex: orderIndex ?? this.orderIndex,
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
    if (dayType.present) {
      map['day_type'] = Variable<String>(dayType.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccessoryExerciseCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dayType: $dayType, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LiftsTable lifts = $LiftsTable(this);
  late final $CycleStatesTable cycleStates = $CycleStatesTable(this);
  late final $WorkoutSessionsTable workoutSessions = $WorkoutSessionsTable(
    this,
  );
  late final $WorkoutSetsTable workoutSets = $WorkoutSetsTable(this);
  late final $UserPreferencesTable userPreferences = $UserPreferencesTable(
    this,
  );
  late final $AccessoryExercisesTable accessoryExercises =
      $AccessoryExercisesTable(this);
  late final LiftsDao liftsDao = LiftsDao(this as AppDatabase);
  late final CycleStatesDao cycleStatesDao = CycleStatesDao(
    this as AppDatabase,
  );
  late final WorkoutSessionsDao workoutSessionsDao = WorkoutSessionsDao(
    this as AppDatabase,
  );
  late final WorkoutSetsDao workoutSetsDao = WorkoutSetsDao(
    this as AppDatabase,
  );
  late final UserPreferencesDao userPreferencesDao = UserPreferencesDao(
    this as AppDatabase,
  );
  late final AccessoryExercisesDao accessoryExercisesDao =
      AccessoryExercisesDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    lifts,
    cycleStates,
    workoutSessions,
    workoutSets,
    userPreferences,
    accessoryExercises,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'lifts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cycle_states', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workout_sets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'lifts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workout_sets', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$LiftsTableCreateCompanionBuilder =
    LiftCompanion Function({
      Value<int> id,
      required String name,
      required String category,
    });
typedef $$LiftsTableUpdateCompanionBuilder =
    LiftCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> category,
    });

final class $$LiftsTableReferences
    extends BaseReferences<_$AppDatabase, $LiftsTable, Lift> {
  $$LiftsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CycleStatesTable, List<CycleState>>
  _cycleStatesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cycleStates,
    aliasName: $_aliasNameGenerator(db.lifts.id, db.cycleStates.liftId),
  );

  $$CycleStatesTableProcessedTableManager get cycleStatesRefs {
    final manager = $$CycleStatesTableTableManager(
      $_db,
      $_db.cycleStates,
    ).filter((f) => f.liftId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cycleStatesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkoutSetsTable, List<WorkoutSet>>
  _workoutSetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutSets,
    aliasName: $_aliasNameGenerator(db.lifts.id, db.workoutSets.liftId),
  );

  $$WorkoutSetsTableProcessedTableManager get workoutSetsRefs {
    final manager = $$WorkoutSetsTableTableManager(
      $_db,
      $_db.workoutSets,
    ).filter((f) => f.liftId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutSetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LiftsTableFilterComposer extends Composer<_$AppDatabase, $LiftsTable> {
  $$LiftsTableFilterComposer({
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

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cycleStatesRefs(
    Expression<bool> Function($$CycleStatesTableFilterComposer f) f,
  ) {
    final $$CycleStatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cycleStates,
      getReferencedColumn: (t) => t.liftId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CycleStatesTableFilterComposer(
            $db: $db,
            $table: $db.cycleStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workoutSetsRefs(
    Expression<bool> Function($$WorkoutSetsTableFilterComposer f) f,
  ) {
    final $$WorkoutSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSets,
      getReferencedColumn: (t) => t.liftId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSetsTableFilterComposer(
            $db: $db,
            $table: $db.workoutSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LiftsTableOrderingComposer
    extends Composer<_$AppDatabase, $LiftsTable> {
  $$LiftsTableOrderingComposer({
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

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LiftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LiftsTable> {
  $$LiftsTableAnnotationComposer({
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

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  Expression<T> cycleStatesRefs<T extends Object>(
    Expression<T> Function($$CycleStatesTableAnnotationComposer a) f,
  ) {
    final $$CycleStatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cycleStates,
      getReferencedColumn: (t) => t.liftId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CycleStatesTableAnnotationComposer(
            $db: $db,
            $table: $db.cycleStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workoutSetsRefs<T extends Object>(
    Expression<T> Function($$WorkoutSetsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSets,
      getReferencedColumn: (t) => t.liftId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LiftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LiftsTable,
          Lift,
          $$LiftsTableFilterComposer,
          $$LiftsTableOrderingComposer,
          $$LiftsTableAnnotationComposer,
          $$LiftsTableCreateCompanionBuilder,
          $$LiftsTableUpdateCompanionBuilder,
          (Lift, $$LiftsTableReferences),
          Lift,
          PrefetchHooks Function({bool cycleStatesRefs, bool workoutSetsRefs})
        > {
  $$LiftsTableTableManager(_$AppDatabase db, $LiftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LiftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LiftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LiftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
              }) => LiftCompanion(id: id, name: name, category: category),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String category,
              }) =>
                  LiftCompanion.insert(id: id, name: name, category: category),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$LiftsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({cycleStatesRefs = false, workoutSetsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (cycleStatesRefs) db.cycleStates,
                    if (workoutSetsRefs) db.workoutSets,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (cycleStatesRefs)
                        await $_getPrefetchedData<
                          Lift,
                          $LiftsTable,
                          CycleState
                        >(
                          currentTable: table,
                          referencedTable: $$LiftsTableReferences
                              ._cycleStatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LiftsTableReferences(
                                db,
                                table,
                                p0,
                              ).cycleStatesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.liftId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workoutSetsRefs)
                        await $_getPrefetchedData<
                          Lift,
                          $LiftsTable,
                          WorkoutSet
                        >(
                          currentTable: table,
                          referencedTable: $$LiftsTableReferences
                              ._workoutSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LiftsTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutSetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.liftId == item.id,
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

typedef $$LiftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LiftsTable,
      Lift,
      $$LiftsTableFilterComposer,
      $$LiftsTableOrderingComposer,
      $$LiftsTableAnnotationComposer,
      $$LiftsTableCreateCompanionBuilder,
      $$LiftsTableUpdateCompanionBuilder,
      (Lift, $$LiftsTableReferences),
      Lift,
      PrefetchHooks Function({bool cycleStatesRefs, bool workoutSetsRefs})
    >;
typedef $$CycleStatesTableCreateCompanionBuilder =
    CycleStateCompanion Function({
      Value<int> id,
      required int liftId,
      required String currentTier,
      required int currentStage,
      required double nextTargetWeight,
      Value<double?> lastStage1SuccessWeight,
      Value<int> currentT3AmrapVolume,
      Value<DateTime> lastUpdated,
    });
typedef $$CycleStatesTableUpdateCompanionBuilder =
    CycleStateCompanion Function({
      Value<int> id,
      Value<int> liftId,
      Value<String> currentTier,
      Value<int> currentStage,
      Value<double> nextTargetWeight,
      Value<double?> lastStage1SuccessWeight,
      Value<int> currentT3AmrapVolume,
      Value<DateTime> lastUpdated,
    });

final class $$CycleStatesTableReferences
    extends BaseReferences<_$AppDatabase, $CycleStatesTable, CycleState> {
  $$CycleStatesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LiftsTable _liftIdTable(_$AppDatabase db) => db.lifts.createAlias(
    $_aliasNameGenerator(db.cycleStates.liftId, db.lifts.id),
  );

  $$LiftsTableProcessedTableManager get liftId {
    final $_column = $_itemColumn<int>('lift_id')!;

    final manager = $$LiftsTableTableManager(
      $_db,
      $_db.lifts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_liftIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CycleStatesTableFilterComposer
    extends Composer<_$AppDatabase, $CycleStatesTable> {
  $$CycleStatesTableFilterComposer({
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

  ColumnFilters<String> get currentTier => $composableBuilder(
    column: $table.currentTier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentStage => $composableBuilder(
    column: $table.currentStage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get nextTargetWeight => $composableBuilder(
    column: $table.nextTargetWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lastStage1SuccessWeight => $composableBuilder(
    column: $table.lastStage1SuccessWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentT3AmrapVolume => $composableBuilder(
    column: $table.currentT3AmrapVolume,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );

  $$LiftsTableFilterComposer get liftId {
    final $$LiftsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.liftId,
      referencedTable: $db.lifts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LiftsTableFilterComposer(
            $db: $db,
            $table: $db.lifts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CycleStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $CycleStatesTable> {
  $$CycleStatesTableOrderingComposer({
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

  ColumnOrderings<String> get currentTier => $composableBuilder(
    column: $table.currentTier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentStage => $composableBuilder(
    column: $table.currentStage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get nextTargetWeight => $composableBuilder(
    column: $table.nextTargetWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lastStage1SuccessWeight => $composableBuilder(
    column: $table.lastStage1SuccessWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentT3AmrapVolume => $composableBuilder(
    column: $table.currentT3AmrapVolume,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  $$LiftsTableOrderingComposer get liftId {
    final $$LiftsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.liftId,
      referencedTable: $db.lifts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LiftsTableOrderingComposer(
            $db: $db,
            $table: $db.lifts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CycleStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CycleStatesTable> {
  $$CycleStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get currentTier => $composableBuilder(
    column: $table.currentTier,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentStage => $composableBuilder(
    column: $table.currentStage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get nextTargetWeight => $composableBuilder(
    column: $table.nextTargetWeight,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lastStage1SuccessWeight => $composableBuilder(
    column: $table.lastStage1SuccessWeight,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentT3AmrapVolume => $composableBuilder(
    column: $table.currentT3AmrapVolume,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );

  $$LiftsTableAnnotationComposer get liftId {
    final $$LiftsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.liftId,
      referencedTable: $db.lifts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LiftsTableAnnotationComposer(
            $db: $db,
            $table: $db.lifts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CycleStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CycleStatesTable,
          CycleState,
          $$CycleStatesTableFilterComposer,
          $$CycleStatesTableOrderingComposer,
          $$CycleStatesTableAnnotationComposer,
          $$CycleStatesTableCreateCompanionBuilder,
          $$CycleStatesTableUpdateCompanionBuilder,
          (CycleState, $$CycleStatesTableReferences),
          CycleState,
          PrefetchHooks Function({bool liftId})
        > {
  $$CycleStatesTableTableManager(_$AppDatabase db, $CycleStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CycleStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CycleStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CycleStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> liftId = const Value.absent(),
                Value<String> currentTier = const Value.absent(),
                Value<int> currentStage = const Value.absent(),
                Value<double> nextTargetWeight = const Value.absent(),
                Value<double?> lastStage1SuccessWeight = const Value.absent(),
                Value<int> currentT3AmrapVolume = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
              }) => CycleStateCompanion(
                id: id,
                liftId: liftId,
                currentTier: currentTier,
                currentStage: currentStage,
                nextTargetWeight: nextTargetWeight,
                lastStage1SuccessWeight: lastStage1SuccessWeight,
                currentT3AmrapVolume: currentT3AmrapVolume,
                lastUpdated: lastUpdated,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int liftId,
                required String currentTier,
                required int currentStage,
                required double nextTargetWeight,
                Value<double?> lastStage1SuccessWeight = const Value.absent(),
                Value<int> currentT3AmrapVolume = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
              }) => CycleStateCompanion.insert(
                id: id,
                liftId: liftId,
                currentTier: currentTier,
                currentStage: currentStage,
                nextTargetWeight: nextTargetWeight,
                lastStage1SuccessWeight: lastStage1SuccessWeight,
                currentT3AmrapVolume: currentT3AmrapVolume,
                lastUpdated: lastUpdated,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CycleStatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({liftId = false}) {
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
                    if (liftId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.liftId,
                                referencedTable: $$CycleStatesTableReferences
                                    ._liftIdTable(db),
                                referencedColumn: $$CycleStatesTableReferences
                                    ._liftIdTable(db)
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

typedef $$CycleStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CycleStatesTable,
      CycleState,
      $$CycleStatesTableFilterComposer,
      $$CycleStatesTableOrderingComposer,
      $$CycleStatesTableAnnotationComposer,
      $$CycleStatesTableCreateCompanionBuilder,
      $$CycleStatesTableUpdateCompanionBuilder,
      (CycleState, $$CycleStatesTableReferences),
      CycleState,
      PrefetchHooks Function({bool liftId})
    >;
typedef $$WorkoutSessionsTableCreateCompanionBuilder =
    WorkoutSessionCompanion Function({
      Value<int> id,
      required String dayType,
      required DateTime dateStarted,
      Value<DateTime?> dateCompleted,
      Value<bool> isFinalized,
      Value<String?> sessionNotes,
    });
typedef $$WorkoutSessionsTableUpdateCompanionBuilder =
    WorkoutSessionCompanion Function({
      Value<int> id,
      Value<String> dayType,
      Value<DateTime> dateStarted,
      Value<DateTime?> dateCompleted,
      Value<bool> isFinalized,
      Value<String?> sessionNotes,
    });

final class $$WorkoutSessionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $WorkoutSessionsTable, WorkoutSession> {
  $$WorkoutSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$WorkoutSetsTable, List<WorkoutSet>>
  _workoutSetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutSets,
    aliasName: $_aliasNameGenerator(
      db.workoutSessions.id,
      db.workoutSets.sessionId,
    ),
  );

  $$WorkoutSetsTableProcessedTableManager get workoutSetsRefs {
    final manager = $$WorkoutSetsTableTableManager(
      $_db,
      $_db.workoutSets,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutSetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableFilterComposer({
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

  ColumnFilters<String> get dayType => $composableBuilder(
    column: $table.dayType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateStarted => $composableBuilder(
    column: $table.dateStarted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateCompleted => $composableBuilder(
    column: $table.dateCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFinalized => $composableBuilder(
    column: $table.isFinalized,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionNotes => $composableBuilder(
    column: $table.sessionNotes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> workoutSetsRefs(
    Expression<bool> Function($$WorkoutSetsTableFilterComposer f) f,
  ) {
    final $$WorkoutSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSets,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSetsTableFilterComposer(
            $db: $db,
            $table: $db.workoutSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get dayType => $composableBuilder(
    column: $table.dayType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateStarted => $composableBuilder(
    column: $table.dateStarted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateCompleted => $composableBuilder(
    column: $table.dateCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFinalized => $composableBuilder(
    column: $table.isFinalized,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionNotes => $composableBuilder(
    column: $table.sessionNotes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dayType =>
      $composableBuilder(column: $table.dayType, builder: (column) => column);

  GeneratedColumn<DateTime> get dateStarted => $composableBuilder(
    column: $table.dateStarted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateCompleted => $composableBuilder(
    column: $table.dateCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFinalized => $composableBuilder(
    column: $table.isFinalized,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sessionNotes => $composableBuilder(
    column: $table.sessionNotes,
    builder: (column) => column,
  );

  Expression<T> workoutSetsRefs<T extends Object>(
    Expression<T> Function($$WorkoutSetsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSets,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSessionsTable,
          WorkoutSession,
          $$WorkoutSessionsTableFilterComposer,
          $$WorkoutSessionsTableOrderingComposer,
          $$WorkoutSessionsTableAnnotationComposer,
          $$WorkoutSessionsTableCreateCompanionBuilder,
          $$WorkoutSessionsTableUpdateCompanionBuilder,
          (WorkoutSession, $$WorkoutSessionsTableReferences),
          WorkoutSession,
          PrefetchHooks Function({bool workoutSetsRefs})
        > {
  $$WorkoutSessionsTableTableManager(
    _$AppDatabase db,
    $WorkoutSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> dayType = const Value.absent(),
                Value<DateTime> dateStarted = const Value.absent(),
                Value<DateTime?> dateCompleted = const Value.absent(),
                Value<bool> isFinalized = const Value.absent(),
                Value<String?> sessionNotes = const Value.absent(),
              }) => WorkoutSessionCompanion(
                id: id,
                dayType: dayType,
                dateStarted: dateStarted,
                dateCompleted: dateCompleted,
                isFinalized: isFinalized,
                sessionNotes: sessionNotes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String dayType,
                required DateTime dateStarted,
                Value<DateTime?> dateCompleted = const Value.absent(),
                Value<bool> isFinalized = const Value.absent(),
                Value<String?> sessionNotes = const Value.absent(),
              }) => WorkoutSessionCompanion.insert(
                id: id,
                dayType: dayType,
                dateStarted: dateStarted,
                dateCompleted: dateCompleted,
                isFinalized: isFinalized,
                sessionNotes: sessionNotes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkoutSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workoutSetsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (workoutSetsRefs) db.workoutSets],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workoutSetsRefs)
                    await $_getPrefetchedData<
                      WorkoutSession,
                      $WorkoutSessionsTable,
                      WorkoutSet
                    >(
                      currentTable: table,
                      referencedTable: $$WorkoutSessionsTableReferences
                          ._workoutSetsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WorkoutSessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).workoutSetsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WorkoutSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSessionsTable,
      WorkoutSession,
      $$WorkoutSessionsTableFilterComposer,
      $$WorkoutSessionsTableOrderingComposer,
      $$WorkoutSessionsTableAnnotationComposer,
      $$WorkoutSessionsTableCreateCompanionBuilder,
      $$WorkoutSessionsTableUpdateCompanionBuilder,
      (WorkoutSession, $$WorkoutSessionsTableReferences),
      WorkoutSession,
      PrefetchHooks Function({bool workoutSetsRefs})
    >;
typedef $$WorkoutSetsTableCreateCompanionBuilder =
    WorkoutSetCompanion Function({
      Value<int> id,
      required int sessionId,
      required int liftId,
      required String tier,
      required int setNumber,
      required int targetReps,
      Value<int?> actualReps,
      required double targetWeight,
      Value<double?> actualWeight,
      Value<bool> isAmrap,
      Value<String?> setNotes,
      Value<String?> exerciseName,
    });
typedef $$WorkoutSetsTableUpdateCompanionBuilder =
    WorkoutSetCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<int> liftId,
      Value<String> tier,
      Value<int> setNumber,
      Value<int> targetReps,
      Value<int?> actualReps,
      Value<double> targetWeight,
      Value<double?> actualWeight,
      Value<bool> isAmrap,
      Value<String?> setNotes,
      Value<String?> exerciseName,
    });

final class $$WorkoutSetsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutSetsTable, WorkoutSet> {
  $$WorkoutSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkoutSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.workoutSessions.createAlias(
        $_aliasNameGenerator(db.workoutSets.sessionId, db.workoutSessions.id),
      );

  $$WorkoutSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$WorkoutSessionsTableTableManager(
      $_db,
      $_db.workoutSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $LiftsTable _liftIdTable(_$AppDatabase db) => db.lifts.createAlias(
    $_aliasNameGenerator(db.workoutSets.liftId, db.lifts.id),
  );

  $$LiftsTableProcessedTableManager get liftId {
    final $_column = $_itemColumn<int>('lift_id')!;

    final manager = $$LiftsTableTableManager(
      $_db,
      $_db.lifts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_liftIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkoutSetsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableFilterComposer({
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

  ColumnFilters<String> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setNumber => $composableBuilder(
    column: $table.setNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetReps => $composableBuilder(
    column: $table.targetReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualReps => $composableBuilder(
    column: $table.actualReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetWeight => $composableBuilder(
    column: $table.targetWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualWeight => $composableBuilder(
    column: $table.actualWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAmrap => $composableBuilder(
    column: $table.isAmrap,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setNotes => $composableBuilder(
    column: $table.setNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutSessionsTableFilterComposer get sessionId {
    final $$WorkoutSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableFilterComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LiftsTableFilterComposer get liftId {
    final $$LiftsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.liftId,
      referencedTable: $db.lifts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LiftsTableFilterComposer(
            $db: $db,
            $table: $db.lifts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableOrderingComposer({
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

  ColumnOrderings<String> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setNumber => $composableBuilder(
    column: $table.setNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetReps => $composableBuilder(
    column: $table.targetReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualReps => $composableBuilder(
    column: $table.actualReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetWeight => $composableBuilder(
    column: $table.targetWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualWeight => $composableBuilder(
    column: $table.actualWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAmrap => $composableBuilder(
    column: $table.isAmrap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setNotes => $composableBuilder(
    column: $table.setNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutSessionsTableOrderingComposer get sessionId {
    final $$WorkoutSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LiftsTableOrderingComposer get liftId {
    final $$LiftsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.liftId,
      referencedTable: $db.lifts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LiftsTableOrderingComposer(
            $db: $db,
            $table: $db.lifts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => column);

  GeneratedColumn<int> get setNumber =>
      $composableBuilder(column: $table.setNumber, builder: (column) => column);

  GeneratedColumn<int> get targetReps => $composableBuilder(
    column: $table.targetReps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualReps => $composableBuilder(
    column: $table.actualReps,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetWeight => $composableBuilder(
    column: $table.targetWeight,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualWeight => $composableBuilder(
    column: $table.actualWeight,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAmrap =>
      $composableBuilder(column: $table.isAmrap, builder: (column) => column);

  GeneratedColumn<String> get setNotes =>
      $composableBuilder(column: $table.setNotes, builder: (column) => column);

  GeneratedColumn<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => column,
  );

  $$WorkoutSessionsTableAnnotationComposer get sessionId {
    final $$WorkoutSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LiftsTableAnnotationComposer get liftId {
    final $$LiftsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.liftId,
      referencedTable: $db.lifts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LiftsTableAnnotationComposer(
            $db: $db,
            $table: $db.lifts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSetsTable,
          WorkoutSet,
          $$WorkoutSetsTableFilterComposer,
          $$WorkoutSetsTableOrderingComposer,
          $$WorkoutSetsTableAnnotationComposer,
          $$WorkoutSetsTableCreateCompanionBuilder,
          $$WorkoutSetsTableUpdateCompanionBuilder,
          (WorkoutSet, $$WorkoutSetsTableReferences),
          WorkoutSet,
          PrefetchHooks Function({bool sessionId, bool liftId})
        > {
  $$WorkoutSetsTableTableManager(_$AppDatabase db, $WorkoutSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int> liftId = const Value.absent(),
                Value<String> tier = const Value.absent(),
                Value<int> setNumber = const Value.absent(),
                Value<int> targetReps = const Value.absent(),
                Value<int?> actualReps = const Value.absent(),
                Value<double> targetWeight = const Value.absent(),
                Value<double?> actualWeight = const Value.absent(),
                Value<bool> isAmrap = const Value.absent(),
                Value<String?> setNotes = const Value.absent(),
                Value<String?> exerciseName = const Value.absent(),
              }) => WorkoutSetCompanion(
                id: id,
                sessionId: sessionId,
                liftId: liftId,
                tier: tier,
                setNumber: setNumber,
                targetReps: targetReps,
                actualReps: actualReps,
                targetWeight: targetWeight,
                actualWeight: actualWeight,
                isAmrap: isAmrap,
                setNotes: setNotes,
                exerciseName: exerciseName,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required int liftId,
                required String tier,
                required int setNumber,
                required int targetReps,
                Value<int?> actualReps = const Value.absent(),
                required double targetWeight,
                Value<double?> actualWeight = const Value.absent(),
                Value<bool> isAmrap = const Value.absent(),
                Value<String?> setNotes = const Value.absent(),
                Value<String?> exerciseName = const Value.absent(),
              }) => WorkoutSetCompanion.insert(
                id: id,
                sessionId: sessionId,
                liftId: liftId,
                tier: tier,
                setNumber: setNumber,
                targetReps: targetReps,
                actualReps: actualReps,
                targetWeight: targetWeight,
                actualWeight: actualWeight,
                isAmrap: isAmrap,
                setNotes: setNotes,
                exerciseName: exerciseName,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkoutSetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false, liftId = false}) {
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
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$WorkoutSetsTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$WorkoutSetsTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (liftId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.liftId,
                                referencedTable: $$WorkoutSetsTableReferences
                                    ._liftIdTable(db),
                                referencedColumn: $$WorkoutSetsTableReferences
                                    ._liftIdTable(db)
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

typedef $$WorkoutSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSetsTable,
      WorkoutSet,
      $$WorkoutSetsTableFilterComposer,
      $$WorkoutSetsTableOrderingComposer,
      $$WorkoutSetsTableAnnotationComposer,
      $$WorkoutSetsTableCreateCompanionBuilder,
      $$WorkoutSetsTableUpdateCompanionBuilder,
      (WorkoutSet, $$WorkoutSetsTableReferences),
      WorkoutSet,
      PrefetchHooks Function({bool sessionId, bool liftId})
    >;
typedef $$UserPreferencesTableCreateCompanionBuilder =
    UserPreferenceCompanion Function({
      Value<int> id,
      Value<String> unitSystem,
      Value<int> t1RestSeconds,
      Value<int> t2RestSeconds,
      Value<int> t3RestSeconds,
      Value<int> minimumRestHours,
      Value<bool> hasCompletedOnboarding,
    });
typedef $$UserPreferencesTableUpdateCompanionBuilder =
    UserPreferenceCompanion Function({
      Value<int> id,
      Value<String> unitSystem,
      Value<int> t1RestSeconds,
      Value<int> t2RestSeconds,
      Value<int> t3RestSeconds,
      Value<int> minimumRestHours,
      Value<bool> hasCompletedOnboarding,
    });

class $$UserPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableFilterComposer({
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

  ColumnFilters<String> get unitSystem => $composableBuilder(
    column: $table.unitSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get t1RestSeconds => $composableBuilder(
    column: $table.t1RestSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get t2RestSeconds => $composableBuilder(
    column: $table.t2RestSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get t3RestSeconds => $composableBuilder(
    column: $table.t3RestSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minimumRestHours => $composableBuilder(
    column: $table.minimumRestHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasCompletedOnboarding => $composableBuilder(
    column: $table.hasCompletedOnboarding,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableOrderingComposer({
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

  ColumnOrderings<String> get unitSystem => $composableBuilder(
    column: $table.unitSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get t1RestSeconds => $composableBuilder(
    column: $table.t1RestSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get t2RestSeconds => $composableBuilder(
    column: $table.t2RestSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get t3RestSeconds => $composableBuilder(
    column: $table.t3RestSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minimumRestHours => $composableBuilder(
    column: $table.minimumRestHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasCompletedOnboarding => $composableBuilder(
    column: $table.hasCompletedOnboarding,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get unitSystem => $composableBuilder(
    column: $table.unitSystem,
    builder: (column) => column,
  );

  GeneratedColumn<int> get t1RestSeconds => $composableBuilder(
    column: $table.t1RestSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get t2RestSeconds => $composableBuilder(
    column: $table.t2RestSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get t3RestSeconds => $composableBuilder(
    column: $table.t3RestSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minimumRestHours => $composableBuilder(
    column: $table.minimumRestHours,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasCompletedOnboarding => $composableBuilder(
    column: $table.hasCompletedOnboarding,
    builder: (column) => column,
  );
}

class $$UserPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserPreferencesTable,
          UserPreference,
          $$UserPreferencesTableFilterComposer,
          $$UserPreferencesTableOrderingComposer,
          $$UserPreferencesTableAnnotationComposer,
          $$UserPreferencesTableCreateCompanionBuilder,
          $$UserPreferencesTableUpdateCompanionBuilder,
          (
            UserPreference,
            BaseReferences<
              _$AppDatabase,
              $UserPreferencesTable,
              UserPreference
            >,
          ),
          UserPreference,
          PrefetchHooks Function()
        > {
  $$UserPreferencesTableTableManager(
    _$AppDatabase db,
    $UserPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> unitSystem = const Value.absent(),
                Value<int> t1RestSeconds = const Value.absent(),
                Value<int> t2RestSeconds = const Value.absent(),
                Value<int> t3RestSeconds = const Value.absent(),
                Value<int> minimumRestHours = const Value.absent(),
                Value<bool> hasCompletedOnboarding = const Value.absent(),
              }) => UserPreferenceCompanion(
                id: id,
                unitSystem: unitSystem,
                t1RestSeconds: t1RestSeconds,
                t2RestSeconds: t2RestSeconds,
                t3RestSeconds: t3RestSeconds,
                minimumRestHours: minimumRestHours,
                hasCompletedOnboarding: hasCompletedOnboarding,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> unitSystem = const Value.absent(),
                Value<int> t1RestSeconds = const Value.absent(),
                Value<int> t2RestSeconds = const Value.absent(),
                Value<int> t3RestSeconds = const Value.absent(),
                Value<int> minimumRestHours = const Value.absent(),
                Value<bool> hasCompletedOnboarding = const Value.absent(),
              }) => UserPreferenceCompanion.insert(
                id: id,
                unitSystem: unitSystem,
                t1RestSeconds: t1RestSeconds,
                t2RestSeconds: t2RestSeconds,
                t3RestSeconds: t3RestSeconds,
                minimumRestHours: minimumRestHours,
                hasCompletedOnboarding: hasCompletedOnboarding,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserPreferencesTable,
      UserPreference,
      $$UserPreferencesTableFilterComposer,
      $$UserPreferencesTableOrderingComposer,
      $$UserPreferencesTableAnnotationComposer,
      $$UserPreferencesTableCreateCompanionBuilder,
      $$UserPreferencesTableUpdateCompanionBuilder,
      (
        UserPreference,
        BaseReferences<_$AppDatabase, $UserPreferencesTable, UserPreference>,
      ),
      UserPreference,
      PrefetchHooks Function()
    >;
typedef $$AccessoryExercisesTableCreateCompanionBuilder =
    AccessoryExerciseCompanion Function({
      Value<int> id,
      required String name,
      required String dayType,
      required int orderIndex,
    });
typedef $$AccessoryExercisesTableUpdateCompanionBuilder =
    AccessoryExerciseCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> dayType,
      Value<int> orderIndex,
    });

class $$AccessoryExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $AccessoryExercisesTable> {
  $$AccessoryExercisesTableFilterComposer({
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

  ColumnFilters<String> get dayType => $composableBuilder(
    column: $table.dayType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AccessoryExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $AccessoryExercisesTable> {
  $$AccessoryExercisesTableOrderingComposer({
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

  ColumnOrderings<String> get dayType => $composableBuilder(
    column: $table.dayType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccessoryExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccessoryExercisesTable> {
  $$AccessoryExercisesTableAnnotationComposer({
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

  GeneratedColumn<String> get dayType =>
      $composableBuilder(column: $table.dayType, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );
}

class $$AccessoryExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccessoryExercisesTable,
          AccessoryExercise,
          $$AccessoryExercisesTableFilterComposer,
          $$AccessoryExercisesTableOrderingComposer,
          $$AccessoryExercisesTableAnnotationComposer,
          $$AccessoryExercisesTableCreateCompanionBuilder,
          $$AccessoryExercisesTableUpdateCompanionBuilder,
          (
            AccessoryExercise,
            BaseReferences<
              _$AppDatabase,
              $AccessoryExercisesTable,
              AccessoryExercise
            >,
          ),
          AccessoryExercise,
          PrefetchHooks Function()
        > {
  $$AccessoryExercisesTableTableManager(
    _$AppDatabase db,
    $AccessoryExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccessoryExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccessoryExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccessoryExercisesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> dayType = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
              }) => AccessoryExerciseCompanion(
                id: id,
                name: name,
                dayType: dayType,
                orderIndex: orderIndex,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String dayType,
                required int orderIndex,
              }) => AccessoryExerciseCompanion.insert(
                id: id,
                name: name,
                dayType: dayType,
                orderIndex: orderIndex,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccessoryExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccessoryExercisesTable,
      AccessoryExercise,
      $$AccessoryExercisesTableFilterComposer,
      $$AccessoryExercisesTableOrderingComposer,
      $$AccessoryExercisesTableAnnotationComposer,
      $$AccessoryExercisesTableCreateCompanionBuilder,
      $$AccessoryExercisesTableUpdateCompanionBuilder,
      (
        AccessoryExercise,
        BaseReferences<
          _$AppDatabase,
          $AccessoryExercisesTable,
          AccessoryExercise
        >,
      ),
      AccessoryExercise,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LiftsTableTableManager get lifts =>
      $$LiftsTableTableManager(_db, _db.lifts);
  $$CycleStatesTableTableManager get cycleStates =>
      $$CycleStatesTableTableManager(_db, _db.cycleStates);
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(_db, _db.workoutSessions);
  $$WorkoutSetsTableTableManager get workoutSets =>
      $$WorkoutSetsTableTableManager(_db, _db.workoutSets);
  $$UserPreferencesTableTableManager get userPreferences =>
      $$UserPreferencesTableTableManager(_db, _db.userPreferences);
  $$AccessoryExercisesTableTableManager get accessoryExercises =>
      $$AccessoryExercisesTableTableManager(_db, _db.accessoryExercises);
}

mixin _$LiftsDaoMixin on DatabaseAccessor<AppDatabase> {
  $LiftsTable get lifts => attachedDatabase.lifts;
}
mixin _$CycleStatesDaoMixin on DatabaseAccessor<AppDatabase> {
  $LiftsTable get lifts => attachedDatabase.lifts;
  $CycleStatesTable get cycleStates => attachedDatabase.cycleStates;
}
mixin _$WorkoutSessionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $WorkoutSessionsTable get workoutSessions => attachedDatabase.workoutSessions;
}
mixin _$WorkoutSetsDaoMixin on DatabaseAccessor<AppDatabase> {
  $WorkoutSessionsTable get workoutSessions => attachedDatabase.workoutSessions;
  $LiftsTable get lifts => attachedDatabase.lifts;
  $WorkoutSetsTable get workoutSets => attachedDatabase.workoutSets;
}
mixin _$UserPreferencesDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserPreferencesTable get userPreferences => attachedDatabase.userPreferences;
}
mixin _$AccessoryExercisesDaoMixin on DatabaseAccessor<AppDatabase> {
  $AccessoryExercisesTable get accessoryExercises =>
      attachedDatabase.accessoryExercises;
}
