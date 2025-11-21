import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'database_tables.dart';

part 'app_database.g.dart';

/// Main database class for the GZCLP Tracker app
///
/// This database handles all local data persistence for the application,
/// including workout sessions, progression state, user preferences, and more.
///
/// The database uses Drift (formerly Moor) for type-safe SQL operations
/// and includes comprehensive DAOs for each table.
@DriftDatabase(
  tables: [
    Lifts,
    CycleStates,
    WorkoutSessions,
    WorkoutSets,
    UserPreferences,
    AccessoryExercises,
  ],
  daos: [
    LiftsDao,
    CycleStatesDao,
    WorkoutSessionsDao,
    WorkoutSetsDao,
    UserPreferencesDao,
    AccessoryExercisesDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Create database instance
  AppDatabase() : super(_openConnection());

  /// Constructor for testing with custom query executor
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Create indexes on new database
        await _createIndexes();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Migration from version 1 to 2: Add exerciseName column to WorkoutSets
        if (from < 2) {
          await m.addColumn(workoutSets, workoutSets.exerciseName);
        }
        // Migration from version 2 to 3: Add performance indexes
        if (from < 3) {
          await _createIndexes();
        }
      },
      beforeOpen: (details) async {
        // Enable foreign key constraints
        await customStatement('PRAGMA foreign_keys = ON;');
      },
    );
  }

  /// Create database indexes for improved query performance
  Future<void> _createIndexes() async {
    // Index for finding in-progress sessions (CheckInProgressWorkout query)
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_workout_sessions_is_finalized '
      'ON workout_sessions(is_finalized)',
    );

    // Index for finding sessions by date (used in history and dashboard)
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_workout_sessions_date_started '
      'ON workout_sessions(date_started DESC)',
    );

    // Index for finding sets by session (very common query)
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_workout_sets_session_id '
      'ON workout_sets(session_id)',
    );

    // Index for finding sets by lift and tier (used in progression calculation)
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_workout_sets_lift_tier '
      'ON workout_sets(lift_id, tier)',
    );

    // Index for finding cycle states by lift (very common query)
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_cycle_states_lift_id '
      'ON cycle_states(lift_id)',
    );

    // Index for finding accessories by day type (used in workout generation)
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_accessory_exercises_day_type '
      'ON accessory_exercises(day_type, order_index)',
    );
  }
}

/// Opens the database connection
///
/// For Flutter apps, this creates or opens the SQLite database file
/// in the application's documents directory.
/// For web, uses SQLite via WebAssembly with IndexedDB storage.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Mobile: SQLite in app documents directory
    // Web: SQLite WASM with IndexedDB storage
    return driftDatabase(
      name: 'gzclp_tracker',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.dart.js'),
      ),
    );
  });
}

/// Data Access Object for Lifts table
///
/// Handles all CRUD operations for the main compound lifts.
@DriftAccessor(tables: [Lifts])
class LiftsDao extends DatabaseAccessor<AppDatabase> with _$LiftsDaoMixin {
  LiftsDao(super.db);

  /// Get all lifts
  Future<List<Lift>> getAllLifts() => select(lifts).get();

  /// Get a single lift by ID
  Future<Lift?> getLiftById(int id) {
    return (select(lifts)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  /// Get a lift by name
  Future<Lift?> getLiftByName(String name) {
    return (select(lifts)..where((tbl) => tbl.name.equals(name))).getSingleOrNull();
  }

  /// Get lifts by category (lower/upper)
  Future<List<Lift>> getLiftsByCategory(String category) {
    return (select(lifts)..where((tbl) => tbl.category.equals(category))).get();
  }

  /// Insert a new lift
  Future<int> insertLift(LiftCompanion lift) {
    return into(lifts).insert(lift);
  }

  /// Insert multiple lifts
  Future<void> insertLifts(List<LiftCompanion> liftList) {
    return batch((batch) {
      batch.insertAll(lifts, liftList);
    });
  }

  /// Update a lift
  Future<bool> updateLift(Lift lift) {
    return update(lifts).replace(lift);
  }

  /// Delete a lift
  Future<int> deleteLift(int id) {
    return (delete(lifts)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Check if lifts have been initialized
  Future<bool> hasLifts() async {
    final count = await (selectOnly(lifts)..addColumns([lifts.id.count()])).getSingle();
    return count.read(lifts.id.count())! > 0;
  }
}

/// Data Access Object for CycleStates table
///
/// CRITICAL DAO - Manages progression state for all lifts.
/// This is the heart of the GZCLP progression algorithm.
@DriftAccessor(tables: [CycleStates, Lifts])
class CycleStatesDao extends DatabaseAccessor<AppDatabase> with _$CycleStatesDaoMixin {
  CycleStatesDao(super.db);

  /// Get all cycle states
  Future<List<CycleState>> getAllCycleStates() => select(cycleStates).get();

  /// Get cycle state by ID
  Future<CycleState?> getCycleStateById(int id) {
    return (select(cycleStates)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  /// Get cycle state for a specific lift and tier
  /// This is the most commonly used query for progression logic
  Future<CycleState?> getCycleStateByLiftAndTier(int liftId, String tier) {
    return (select(cycleStates)
      ..where((tbl) => tbl.liftId.equals(liftId) & tbl.currentTier.equals(tier)))
        .getSingleOrNull();
  }

  /// Get all cycle states for a specific lift
  Future<List<CycleState>> getCycleStatesForLift(int liftId) {
    return (select(cycleStates)..where((tbl) => tbl.liftId.equals(liftId))).get();
  }

  /// Insert a new cycle state
  Future<int> insertCycleState(CycleStateCompanion state) {
    return into(cycleStates).insert(state);
  }

  /// Insert multiple cycle states
  Future<void> insertCycleStates(List<CycleStateCompanion> states) {
    return batch((batch) {
      batch.insertAll(cycleStates, states);
    });
  }

  /// Update a cycle state
  Future<bool> updateCycleState(CycleState state) {
    return update(cycleStates).replace(state);
  }

  /// Update cycle state with transaction support
  /// CRITICAL: Use this for atomic updates during session finalization
  Future<void> updateCycleStateInTransaction(CycleState state) async {
    await transaction(() async {
      await update(cycleStates).replace(state);
    });
  }

  /// Update multiple cycle states atomically
  /// CRITICAL: Used during session finalization to update all affected lifts
  Future<void> updateCycleStatesInTransaction(List<CycleState> states) async {
    await transaction(() async {
      for (final state in states) {
        await update(cycleStates).replace(state);
      }
    });
  }

  /// Delete a cycle state
  Future<int> deleteCycleState(int id) {
    return (delete(cycleStates)..where((tbl) => tbl.id.equals(id))).go();
  }
}

/// Data Access Object for WorkoutSessions table
///
/// Manages workout sessions from start to finalization.
@DriftAccessor(tables: [WorkoutSessions])
class WorkoutSessionsDao extends DatabaseAccessor<AppDatabase> with _$WorkoutSessionsDaoMixin {
  WorkoutSessionsDao(super.db);

  /// Get all workout sessions, ordered by most recent first
  Future<List<WorkoutSession>> getAllSessions() {
    return (select(workoutSessions)..orderBy([(t) => OrderingTerm.desc(t.dateStarted)])).get();
  }

  /// Get a single session by ID
  Future<WorkoutSession?> getSessionById(int id) {
    return (select(workoutSessions)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  /// Get the most recent session
  Future<WorkoutSession?> getLastSession() {
    return (select(workoutSessions)
      ..orderBy([(t) => OrderingTerm.desc(t.dateStarted)])
      ..limit(1))
        .getSingleOrNull();
  }

  /// Get the most recent finalized session
  Future<WorkoutSession?> getLastFinalizedSession() {
    return (select(workoutSessions)
      ..where((tbl) => tbl.isFinalized.equals(true))
      ..orderBy([(t) => OrderingTerm.desc(t.dateStarted)])
      ..limit(1))
        .getSingleOrNull();
  }

  /// Get any in-progress (non-finalized) session
  Future<WorkoutSession?> getInProgressSession() {
    return (select(workoutSessions)
      ..where((tbl) => tbl.isFinalized.equals(false)))
        .getSingleOrNull();
  }

  /// Get sessions by day type
  Future<List<WorkoutSession>> getSessionsByDayType(String dayType) {
    return (select(workoutSessions)
      ..where((tbl) => tbl.dayType.equals(dayType))
      ..orderBy([(t) => OrderingTerm.desc(t.dateStarted)]))
        .get();
  }

  /// Get finalized sessions
  Future<List<WorkoutSession>> getFinalizedSessions() {
    return (select(workoutSessions)
      ..where((tbl) => tbl.isFinalized.equals(true))
      ..orderBy([(t) => OrderingTerm.desc(t.dateStarted)]))
        .get();
  }

  /// Insert a new workout session
  Future<int> insertSession(WorkoutSessionCompanion session) {
    return into(workoutSessions).insert(session);
  }

  /// Update a workout session
  Future<bool> updateSession(WorkoutSession session) {
    return update(workoutSessions).replace(session);
  }

  /// Finalize a session (mark as completed)
  Future<void> finalizeSession(int sessionId, DateTime completedAt) async {
    await (update(workoutSessions)..where((tbl) => tbl.id.equals(sessionId)))
        .write(WorkoutSessionCompanion(
          dateCompleted: Value(completedAt),
          isFinalized: const Value(true),
        ));
  }

  /// Delete a session
  Future<int> deleteSession(int id) {
    return (delete(workoutSessions)..where((tbl) => tbl.id.equals(id))).go();
  }
}

/// Data Access Object for WorkoutSets table
///
/// Manages individual sets within workout sessions.
@DriftAccessor(tables: [WorkoutSets, WorkoutSessions, Lifts])
class WorkoutSetsDao extends DatabaseAccessor<AppDatabase> with _$WorkoutSetsDaoMixin {
  WorkoutSetsDao(super.db);

  /// Get all sets for a specific session, ordered by tier then set number
  Future<List<WorkoutSet>> getSetsForSession(int sessionId) {
    return (select(workoutSets)
      ..where((tbl) => tbl.sessionId.equals(sessionId))
      ..orderBy([
        (t) => OrderingTerm.asc(t.tier),
        (t) => OrderingTerm.asc(t.setNumber),
      ]))
        .get();
  }

  /// Get sets for a specific lift in a session
  Future<List<WorkoutSet>> getSetsForLiftInSession(int sessionId, int liftId) {
    return (select(workoutSets)
      ..where((tbl) => tbl.sessionId.equals(sessionId) & tbl.liftId.equals(liftId))
      ..orderBy([(t) => OrderingTerm.asc(t.setNumber)]))
        .get();
  }

  /// Get sets for a specific tier in a session
  Future<List<WorkoutSet>> getSetsForTierInSession(int sessionId, String tier) {
    return (select(workoutSets)
      ..where((tbl) => tbl.sessionId.equals(sessionId) & tbl.tier.equals(tier))
      ..orderBy([(t) => OrderingTerm.asc(t.setNumber)]))
        .get();
  }

  /// Insert a new workout set
  Future<int> insertSet(WorkoutSetCompanion set) {
    return into(workoutSets).insert(set);
  }

  /// Insert multiple sets (batch operation)
  Future<void> insertSets(List<WorkoutSetCompanion> sets) {
    return batch((batch) {
      batch.insertAll(workoutSets, sets);
    });
  }

  /// Update a workout set
  Future<bool> updateSet(WorkoutSet set) {
    return update(workoutSets).replace(set);
  }

  /// Delete a set
  Future<int> deleteSet(int id) {
    return (delete(workoutSets)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Delete all sets for a session
  Future<int> deleteSetsForSession(int sessionId) {
    return (delete(workoutSets)..where((tbl) => tbl.sessionId.equals(sessionId))).go();
  }
}

/// Data Access Object for UserPreferences table
///
/// Manages app-wide user preferences and settings.
@DriftAccessor(tables: [UserPreferences])
class UserPreferencesDao extends DatabaseAccessor<AppDatabase> with _$UserPreferencesDaoMixin {
  UserPreferencesDao(super.db);

  /// Get user preferences (should only be one row)
  Future<UserPreference?> getPreferences() {
    return select(userPreferences).getSingleOrNull();
  }

  /// Initialize default preferences
  Future<int> initializePreferences() {
    return into(userPreferences).insert(
      UserPreferenceCompanion.insert(),
    );
  }

  /// Update user preferences
  Future<bool> updatePreferences(UserPreference prefs) {
    return update(userPreferences).replace(prefs);
  }

  /// Update specific preference fields
  Future<void> updatePreferenceFields({
    String? unitSystem,
    int? t1RestSeconds,
    int? t2RestSeconds,
    int? t3RestSeconds,
    int? minimumRestHours,
    bool? hasCompletedOnboarding,
  }) async {
    await (update(userPreferences)..where((tbl) => tbl.id.equals(1)))
        .write(UserPreferenceCompanion(
          unitSystem: unitSystem != null ? Value(unitSystem) : const Value.absent(),
          t1RestSeconds: t1RestSeconds != null ? Value(t1RestSeconds) : const Value.absent(),
          t2RestSeconds: t2RestSeconds != null ? Value(t2RestSeconds) : const Value.absent(),
          t3RestSeconds: t3RestSeconds != null ? Value(t3RestSeconds) : const Value.absent(),
          minimumRestHours: minimumRestHours != null ? Value(minimumRestHours) : const Value.absent(),
          hasCompletedOnboarding: hasCompletedOnboarding != null ? Value(hasCompletedOnboarding) : const Value.absent(),
        ));
  }

  /// Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding() async {
    final prefs = await getPreferences();
    return prefs?.hasCompletedOnboarding ?? false;
  }
}

/// Data Access Object for AccessoryExercises table
///
/// Manages T3 accessory exercises for each workout day.
@DriftAccessor(tables: [AccessoryExercises])
class AccessoryExercisesDao extends DatabaseAccessor<AppDatabase> with _$AccessoryExercisesDaoMixin {
  AccessoryExercisesDao(super.db);

  /// Get all accessory exercises for a specific day
  Future<List<AccessoryExercise>> getAccessoriesForDay(String dayType) {
    return (select(accessoryExercises)
      ..where((tbl) => tbl.dayType.equals(dayType))
      ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .get();
  }

  /// Get all accessory exercises
  Future<List<AccessoryExercise>> getAllAccessories() {
    return (select(accessoryExercises)
      ..orderBy([(t) => OrderingTerm.asc(t.dayType), (t) => OrderingTerm.asc(t.orderIndex)]))
        .get();
  }

  /// Insert a new accessory exercise
  Future<int> insertAccessory(AccessoryExerciseCompanion exercise) {
    return into(accessoryExercises).insert(exercise);
  }

  /// Insert multiple accessories
  Future<void> insertAccessories(List<AccessoryExerciseCompanion> exercises) {
    return batch((batch) {
      batch.insertAll(accessoryExercises, exercises);
    });
  }

  /// Update an accessory exercise
  Future<bool> updateAccessory(AccessoryExercise exercise) {
    return update(accessoryExercises).replace(exercise);
  }

  /// Delete an accessory exercise
  Future<int> deleteAccessory(int id) {
    return (delete(accessoryExercises)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Delete all accessories for a specific day
  Future<int> deleteAccessoriesForDay(String dayType) {
    return (delete(accessoryExercises)..where((tbl) => tbl.dayType.equals(dayType))).go();
  }

  /// Reorder accessories for a day
  Future<void> reorderAccessories(String dayType, List<int> exerciseIds) async {
    await transaction(() async {
      // First pass: Set all to temporary negative indices to avoid constraint violations
      for (var i = 0; i < exerciseIds.length; i++) {
        await (update(accessoryExercises)..where((tbl) => tbl.id.equals(exerciseIds[i])))
            .write(AccessoryExerciseCompanion(orderIndex: Value(-(i + 1))));
      }
      // Second pass: Set to actual indices
      for (var i = 0; i < exerciseIds.length; i++) {
        await (update(accessoryExercises)..where((tbl) => tbl.id.equals(exerciseIds[i])))
            .write(AccessoryExerciseCompanion(orderIndex: Value(i)));
      }
    });
  }
}
