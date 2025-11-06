import 'package:drift/drift.dart';

/// Lifts table - Stores the four main compound lifts
///
/// Each lift has a category (lower/upper) which determines
/// the weight increment used during progression.
@DataClassName('Lift')
class Lifts extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Name of the lift (e.g., "Squat", "Bench Press", "Deadlift", "Overhead Press")
  TextColumn get name => text().withLength(min: 1, max: 50)();

  /// Category determines weight increments
  /// - "lower": Lower body (Squat, Deadlift) - 10 lbs / 5 kg increments
  /// - "upper": Upper body (Bench, OHP) - 5 lbs / 2.5 kg increments
  TextColumn get category => text().withLength(min: 1, max: 10)();
}

/// CycleState table - CRITICAL for progression logic
///
/// Maintains the current state of each lift's progression through
/// the GZCLP program. This is the most important table for the
/// progression algorithm to function correctly.
@DataClassName('CycleState')
class CycleStates extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Foreign key to Lifts table
  IntColumn get liftId => integer().references(Lifts, #id, onDelete: KeyAction.cascade)();

  /// Current tier: 'T1', 'T2', or 'T3'
  TextColumn get currentTier => text().withLength(min: 2, max: 2)();

  /// Current stage: 1, 2, or 3
  /// T1: Stage 1 (5x3+), Stage 2 (6x2+), Stage 3 (10x1+)
  /// T2: Stage 1 (3x10), Stage 2 (3x8), Stage 3 (3x6)
  /// T3: Only Stage 1 (3x15+)
  /// Validated at application layer (must be 1-3)
  IntColumn get currentStage => integer()();

  /// The weight target for the next workout of this lift at this tier
  /// Validated at application layer (must be >= 0)
  RealColumn get nextTargetWeight => real()();

  /// CRITICAL FIELD for T2 resets
  /// Records the weight used during the last successful T2 Stage 1 (3x10) session
  /// Used to calculate reset weight: lastStage1SuccessWeight + 15-20 lbs / 7.5-10 kg
  RealColumn get lastStage1SuccessWeight => real().nullable()();

  /// For T3 progression tracking
  /// Tracks the reps achieved on the last AMRAP set
  /// Weight increases only if this value reaches 25+
  IntColumn get currentT3AmrapVolume => integer().withDefault(const Constant(0))();

  /// Timestamp of last update to this cycle state
  DateTimeColumn get lastUpdated => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {liftId, currentTier}, // Each lift can only have one state per tier
  ];
}

/// WorkoutSession table - Records each workout session
///
/// Represents a complete workout (e.g., Day A, Day B, etc.)
/// Sessions can be in-progress or finalized.
@DataClassName('WorkoutSession')
class WorkoutSessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Day type: 'A', 'B', 'C', or 'D'
  /// Determines which lifts are performed
  TextColumn get dayType => text().withLength(min: 1, max: 1)();

  /// When the workout was started
  DateTimeColumn get dateStarted => dateTime()();

  /// When the workout was completed (null if in progress)
  DateTimeColumn get dateCompleted => dateTime().nullable()();

  /// Critical flag: Has the progression logic been applied?
  /// Must be true before starting next workout
  BoolColumn get isFinalized => boolean().withDefault(const Constant(false))();

  /// Optional notes about the entire session
  TextColumn get sessionNotes => text().nullable()();
}

/// WorkoutSet table - Individual set within a workout
///
/// Records the details of each set performed during a workout.
/// Stores both target (programmed) and actual (performed) values.
@DataClassName('WorkoutSet')
class WorkoutSets extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Foreign key to WorkoutSessions
  IntColumn get sessionId => integer().references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();

  /// Foreign key to Lifts
  IntColumn get liftId => integer().references(Lifts, #id, onDelete: KeyAction.cascade)();

  /// Tier for this set: 'T1', 'T2', or 'T3'
  TextColumn get tier => text().withLength(min: 2, max: 2)();

  /// Set number within this lift (1, 2, 3, etc.)
  /// Validated at application layer (must be > 0)
  IntColumn get setNumber => integer()();

  /// Target (programmed) reps for this set
  /// Validated at application layer (must be > 0)
  IntColumn get targetReps => integer()();

  /// Actual reps performed (null if not yet logged)
  IntColumn get actualReps => integer().nullable()();

  /// Target (programmed) weight for this set
  /// Validated at application layer (must be >= 0)
  RealColumn get targetWeight => real()();

  /// Actual weight used (null if not yet logged)
  /// Allows for user adjustments (e.g., bar was heavier than expected)
  RealColumn get actualWeight => real().nullable()();

  /// Is this an AMRAP (As Many Reps As Possible) set?
  /// These sets are crucial for progression decisions
  BoolColumn get isAmrap => boolean().withDefault(const Constant(false))();

  /// Optional notes about this specific set
  TextColumn get setNotes => text().nullable()();
}

/// UserPreferences table - App settings and user preferences
///
/// Stores user-specific configuration that affects the entire app.
/// Should only have one row (singleton pattern).
@DataClassName('UserPreference')
class UserPreferences extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Unit system: 'imperial' (lbs) or 'metric' (kg)
  TextColumn get unitSystem => text().withLength(min: 6, max: 8).withDefault(const Constant('imperial'))();

  /// Default rest time for T1 lifts (seconds)
  IntColumn get t1RestSeconds => integer().withDefault(const Constant(240))(); // 4 min

  /// Default rest time for T2 lifts (seconds)
  IntColumn get t2RestSeconds => integer().withDefault(const Constant(150))(); // 2.5 min

  /// Default rest time for T3 lifts (seconds)
  IntColumn get t3RestSeconds => integer().withDefault(const Constant(75))(); // 1.25 min

  /// Minimum rest hours required between workouts
  IntColumn get minimumRestHours => integer().withDefault(const Constant(24))();

  /// Has the user completed the onboarding flow?
  BoolColumn get hasCompletedOnboarding => boolean().withDefault(const Constant(false))();
}

/// AccessoryExercise table - T3 accessory movements
///
/// Stores the user's selected accessory exercises for each workout day.
/// These are performed as T3 (high volume) work.
@DataClassName('AccessoryExercise')
class AccessoryExercises extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Name of the accessory exercise (e.g., "Lat Pulldown", "Dumbbell Row")
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// Which day this exercise is performed: 'A', 'B', 'C', or 'D'
  TextColumn get dayType => text().withLength(min: 1, max: 1)();

  /// Order in which this exercise appears in the workout
  /// Lower numbers appear first
  IntColumn get orderIndex => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {dayType, orderIndex}, // Each day can only have one exercise at each order position
  ];
}
