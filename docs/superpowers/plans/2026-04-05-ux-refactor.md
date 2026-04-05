# UX Refactor: Week/Cycle Flow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace A/B/C/D day letters with numbered days, surface weeks/cycles prominently throughout the app, replace onboarding with a cycle-creation flow, and add a new-cycle screen for end-of-cycle transitions.

**Architecture:** Schema migration renames `dayType` values from letters to numbers and drops the redundant `rotationPosition` column. The domain layer gains a `NewCycleWeightOption` type and a `getFinalizedDayTypesForRotation` query. UI is updated top-to-bottom — constants, use cases, BLoCs, then pages.

**Tech Stack:** Flutter/Dart, Drift ORM (SQLite), flutter_bloc, GetIt DI, dartz Either

---

## File Map

**Modify:**
- `lib/core/constants/app_constants.dart` — workoutDays list
- `lib/features/workout/data/datasources/local/database_tables.dart` — drop rotationPosition
- `lib/features/workout/data/datasources/local/app_database.dart` — schema v5 migration, new DAO method
- `lib/features/workout/domain/entities/workout_session_entity.dart` — drop rotationPosition
- `lib/features/workout/domain/repositories/workout_session_repository.dart` — add getFinalizedDayTypesForRotation
- `lib/features/workout/data/repositories/workout_session_repository_impl.dart` — implement, remove rotationPosition refs
- `lib/features/workout/domain/usecases/generate_workout_for_day.dart` — day switch cases
- `lib/features/workout/domain/usecases/finalize_workout_session.dart` — rotation completion check
- `lib/features/workout/domain/usecases/start_new_cycle.dart` — weight option parameter
- `lib/features/workout/presentation/bloc/active_workout/active_workout_bloc.dart` — remove rotationPosition
- `lib/features/workout/presentation/bloc/session_manager/session_manager_state.dart` — add cycle fields
- `lib/features/workout/presentation/bloc/session_manager/session_manager_bloc.dart` — load cycle info
- `lib/features/workout/presentation/bloc/onboarding/onboarding_bloc.dart` — splash check, day number keys
- `lib/features/workout/presentation/pages/splash_page.dart` — cycle-exists check
- `lib/features/workout/presentation/pages/home_page.dart` — cycle header, week status, new cycle CTA
- `lib/features/workout/presentation/pages/start_workout_page.dart` — day numbers, week title, badges
- `lib/features/workout/presentation/pages/active_workout_page.dart` — title format
- `lib/features/workout/presentation/pages/workout_history_page.dart` — filter values
- `lib/features/workout/presentation/pages/onboarding_page.dart` — copy reframe
- `lib/core/routes/app_routes.dart` — new cycle route
- `lib/main.dart` — new cycle route
- `lib/core/di/injection_container.dart` — register NewCycleCubit

**Create:**
- `lib/features/workout/presentation/bloc/new_cycle/new_cycle_cubit.dart`
- `lib/features/workout/presentation/bloc/new_cycle/new_cycle_state.dart`
- `lib/features/workout/presentation/pages/new_cycle_page.dart`

**Regenerate (auto-generated — do not edit manually):**
- `lib/features/workout/data/datasources/local/app_database.g.dart`

---

## Task 1: Update workoutDays constants

**Files:**
- Modify: `lib/core/constants/app_constants.dart`

- [ ] **Step 1: Update workoutDays list**

In `app_constants.dart`, replace:
```dart
static const List<String> workoutDays = ['A', 'B', 'C', 'D'];
```
With:
```dart
static const List<String> workoutDays = ['1', '2', '3', '4'];
```

- [ ] **Step 2: Verify no compile errors**

```bash
flutter analyze lib/core/constants/app_constants.dart
```
Expected: No issues.

- [ ] **Step 3: Commit**

```bash
git add lib/core/constants/app_constants.dart
git commit -m "refactor: rename workout days from letters to numbers in constants"
```

---

## Task 2: DB schema migration — remove rotationPosition, rename dayType values

**Files:**
- Modify: `lib/features/workout/data/datasources/local/database_tables.dart`
- Modify: `lib/features/workout/data/datasources/local/app_database.dart`

- [ ] **Step 1: Remove rotationPosition from WorkoutSessions table**

In `database_tables.dart`, remove this line from the `WorkoutSessions` class:
```dart
IntColumn get rotationPosition => integer()();
```

- [ ] **Step 2: Bump schema version and add migration in app_database.dart**

Change:
```dart
@override
int get schemaVersion => 4;
```
To:
```dart
@override
int get schemaVersion => 5;
```

Add this block inside `onUpgrade`, after the existing `if (from < 4)` block:
```dart
// Migration from version 4 to 5: rename dayType letters→numbers, drop rotationPosition
if (from < 5) {
  // Rename dayType values in workout_sessions
  await customStatement(
    "UPDATE workout_sessions SET day_type = CASE day_type "
    "WHEN 'A' THEN '1' WHEN 'B' THEN '2' "
    "WHEN 'C' THEN '3' WHEN 'D' THEN '4' "
    "ELSE day_type END",
  );

  // Rename dayType values in accessory_exercises
  await customStatement(
    "UPDATE accessory_exercises SET day_type = CASE day_type "
    "WHEN 'A' THEN '1' WHEN 'B' THEN '2' "
    "WHEN 'C' THEN '3' WHEN 'D' THEN '4' "
    "ELSE day_type END",
  );

  // Drop rotationPosition column (SQLite requires recreate-and-copy)
  await customStatement(
    'CREATE TABLE workout_sessions_new ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'cycle_id INTEGER NOT NULL REFERENCES cycles(id) ON DELETE CASCADE, '
    'day_type TEXT NOT NULL CHECK(LENGTH(day_type) >= 1 AND LENGTH(day_type) <= 1), '
    'rotation_number INTEGER NOT NULL, '
    'date_started INTEGER NOT NULL, '
    'date_completed INTEGER, '
    'is_finalized INTEGER NOT NULL DEFAULT 0, '
    'session_notes TEXT'
    ')',
  );
  await customStatement(
    'INSERT INTO workout_sessions_new '
    '(id, cycle_id, day_type, rotation_number, date_started, '
    'date_completed, is_finalized, session_notes) '
    'SELECT id, cycle_id, day_type, rotation_number, date_started, '
    'date_completed, is_finalized, session_notes '
    'FROM workout_sessions',
  );
  await customStatement('DROP TABLE workout_sessions');
  await customStatement(
    'ALTER TABLE workout_sessions_new RENAME TO workout_sessions',
  );

  // Recreate indexes dropped with the old table
  await customStatement(
    'CREATE INDEX IF NOT EXISTS idx_workout_sessions_is_finalized '
    'ON workout_sessions(is_finalized)',
  );
  await customStatement(
    'CREATE INDEX IF NOT EXISTS idx_workout_sessions_date_started '
    'ON workout_sessions(date_started DESC)',
  );
  await customStatement(
    'CREATE INDEX IF NOT EXISTS idx_workout_sessions_cycle_id '
    'ON workout_sessions(cycle_id)',
  );
}
```

Also update the v3→v4 migration so it no longer writes `rotationPosition`:

Find in the v3→v4 migration block:
```dart
await m.addColumn(workoutSessions, workoutSessions.rotationPosition);
```
Remove that line.

Find the loop that sets session rotation info:
```dart
await (update(workoutSessions)..where((t) => t.id.equals(sessions[i].id)))
  .write(WorkoutSessionCompanion(
    cycleId: Value(cycleId),
    rotationNumber: Value(rotation),
    rotationPosition: Value(position),
  ));
```
Change to:
```dart
await (update(workoutSessions)..where((t) => t.id.equals(sessions[i].id)))
  .write(WorkoutSessionCompanion(
    cycleId: Value(cycleId),
    rotationNumber: Value(rotation),
  ));
```

- [ ] **Step 3: Regenerate Drift code**

```bash
dart run build_runner build --delete-conflicting-outputs
```
Expected: `app_database.g.dart` regenerated with no errors.

- [ ] **Step 4: Verify compile**

```bash
flutter analyze lib/features/workout/data/datasources/local/
```
Expected: No issues.

- [ ] **Step 5: Commit**

```bash
git add lib/features/workout/data/datasources/local/database_tables.dart
git add lib/features/workout/data/datasources/local/app_database.dart
git add lib/features/workout/data/datasources/local/app_database.g.dart
git commit -m "refactor: schema v5 — rename dayType letters to numbers, drop rotationPosition"
```

---

## Task 3: Remove rotationPosition from domain entity and repository

**Files:**
- Modify: `lib/features/workout/domain/entities/workout_session_entity.dart`
- Modify: `lib/features/workout/data/repositories/workout_session_repository_impl.dart`

- [ ] **Step 1: Remove rotationPosition from WorkoutSessionEntity**

Replace the entire `WorkoutSessionEntity` class with:
```dart
import 'package:equatable/equatable.dart';

class WorkoutSessionEntity extends Equatable {
  final int id;
  final int cycleId;

  /// Day number: '1', '2', '3', or '4'
  final String dayType;

  /// Which rotation (week) this session belongs to (1–12)
  final int rotationNumber;

  final DateTime dateStarted;
  final DateTime? dateCompleted;
  final bool isFinalized;
  final String? sessionNotes;

  const WorkoutSessionEntity({
    required this.id,
    required this.cycleId,
    required this.dayType,
    required this.rotationNumber,
    required this.dateStarted,
    this.dateCompleted,
    this.isFinalized = false,
    this.sessionNotes,
  });

  bool get isInProgress => dateCompleted == null;
  bool get isCompletedNotFinalized => dateCompleted != null && !isFinalized;

  Duration? get duration {
    if (dateCompleted == null) return null;
    return dateCompleted!.difference(dateStarted);
  }

  WorkoutSessionEntity copyWith({
    int? id,
    int? cycleId,
    String? dayType,
    int? rotationNumber,
    DateTime? dateStarted,
    DateTime? dateCompleted,
    bool? isFinalized,
    String? sessionNotes,
  }) {
    return WorkoutSessionEntity(
      id: id ?? this.id,
      cycleId: cycleId ?? this.cycleId,
      dayType: dayType ?? this.dayType,
      rotationNumber: rotationNumber ?? this.rotationNumber,
      dateStarted: dateStarted ?? this.dateStarted,
      dateCompleted: dateCompleted ?? this.dateCompleted,
      isFinalized: isFinalized ?? this.isFinalized,
      sessionNotes: sessionNotes ?? this.sessionNotes,
    );
  }

  @override
  List<Object?> get props => [
        id, cycleId, dayType, rotationNumber,
        dateStarted, dateCompleted, isFinalized, sessionNotes,
      ];

  @override
  String toString() =>
      'WorkoutSessionEntity(id: $id, dayType: $dayType, '
      'rotation: $rotationNumber, finalized: $isFinalized)';
}
```

- [ ] **Step 2: Remove rotationPosition from repository impl**

In `workout_session_repository_impl.dart`:

Replace the `createSession` method:
```dart
@override
Future<Either<Failure, int>> createSession(WorkoutSessionEntity session) async {
  try {
    final companion = WorkoutSessionCompanion.insert(
      cycleId: session.cycleId,
      dayType: session.dayType,
      rotationNumber: session.rotationNumber,
      dateStarted: session.dateStarted,
      dateCompleted: drift.Value(session.dateCompleted),
      isFinalized: drift.Value(session.isFinalized),
      sessionNotes: drift.Value(session.sessionNotes),
    );
    final id = await database.workoutSessionsDao.insertSession(companion);
    return Right(id);
  } on DatabaseException catch (e) {
    return Left(DatabaseFailure(e.message));
  } catch (e) {
    return Left(DatabaseFailure(e.toString()));
  }
}
```

Replace `_sessionToEntity`:
```dart
WorkoutSessionEntity _sessionToEntity(WorkoutSession session) {
  return WorkoutSessionEntity(
    id: session.id,
    cycleId: session.cycleId,
    dayType: session.dayType,
    rotationNumber: session.rotationNumber,
    dateStarted: session.dateStarted,
    dateCompleted: session.dateCompleted,
    isFinalized: session.isFinalized,
    sessionNotes: session.sessionNotes,
  );
}
```

Replace `_entityToSession`:
```dart
WorkoutSession _entityToSession(WorkoutSessionEntity entity) {
  return WorkoutSession(
    id: entity.id,
    cycleId: entity.cycleId,
    dayType: entity.dayType,
    rotationNumber: entity.rotationNumber,
    dateStarted: entity.dateStarted,
    dateCompleted: entity.dateCompleted,
    isFinalized: entity.isFinalized,
    sessionNotes: entity.sessionNotes,
  );
}
```

- [ ] **Step 3: Fix any remaining compile errors**

```bash
flutter analyze lib/features/workout/domain/entities/workout_session_entity.dart lib/features/workout/data/repositories/workout_session_repository_impl.dart
```
Expected: No issues.

- [ ] **Step 4: Commit**

```bash
git add lib/features/workout/domain/entities/workout_session_entity.dart
git add lib/features/workout/data/repositories/workout_session_repository_impl.dart
git commit -m "refactor: remove rotationPosition from WorkoutSession entity and repository"
```

---

## Task 4: Update GenerateWorkoutForDay day assignments

**Files:**
- Modify: `lib/features/workout/domain/usecases/generate_workout_for_day.dart`

- [ ] **Step 1: Update day assignment switch and remove toUpperCase**

Replace `_getDayAssignment`:
```dart
_DayAssignment _getDayAssignment(String dayType) {
  switch (dayType) {
    case '1':
      return _DayAssignment(
        t1Lift: AppConstants.liftSquat,
        t2Lift: AppConstants.liftOhp,
      );
    case '2':
      return _DayAssignment(
        t1Lift: AppConstants.liftBench,
        t2Lift: AppConstants.liftDeadlift,
      );
    case '3':
      return _DayAssignment(
        t1Lift: AppConstants.liftBench,
        t2Lift: AppConstants.liftSquat,
      );
    case '4':
      return _DayAssignment(
        t1Lift: AppConstants.liftDeadlift,
        t2Lift: AppConstants.liftOhp,
      );
    default:
      throw ArgumentError('Invalid day type: $dayType');
  }
}
```

At the top of `call()`, replace:
```dart
final dayType = params.dayType.toUpperCase();
```
With:
```dart
final dayType = params.dayType;
```

Update the doc comment at the top of the class:
```dart
/// GZCLP 4-DAY ROTATION:
/// - Day 1: Squat (T1), Overhead Press (T2), + T3 accessories
/// - Day 2: Bench Press (T1), Deadlift (T2), + T3 accessories
/// - Day 3: Bench Press (T1), Squat (T2), + T3 accessories
/// - Day 4: Deadlift (T1), Overhead Press (T2), + T3 accessories
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/features/workout/domain/usecases/generate_workout_for_day.dart
```
Expected: No issues.

- [ ] **Step 3: Commit**

```bash
git add lib/features/workout/domain/usecases/generate_workout_for_day.dart
git commit -m "refactor: update day assignments from A/B/C/D to 1/2/3/4"
```

---

## Task 5: Add getFinalizedDayTypesForRotation to session DAO and repository

**Files:**
- Modify: `lib/features/workout/data/datasources/local/app_database.dart`
- Modify: `lib/features/workout/domain/repositories/workout_session_repository.dart`
- Modify: `lib/features/workout/data/repositories/workout_session_repository_impl.dart`

- [ ] **Step 1: Add DAO method**

In `app_database.dart`, inside `WorkoutSessionsDao`, add:
```dart
/// Get the set of distinct dayTypes that are finalized for a given rotation
/// Returns e.g. {'1', '3'} if days 1 and 3 are done in that rotation
Future<Set<String>> getFinalizedDayTypesForRotation(
  int cycleId,
  int rotationNumber,
) async {
  final results = await (select(workoutSessions)
    ..where((tbl) =>
        tbl.cycleId.equals(cycleId) &
        tbl.rotationNumber.equals(rotationNumber) &
        tbl.isFinalized.equals(true)))
      .get();
  return results.map((s) => s.dayType).toSet();
}
```

- [ ] **Step 2: Add method to repository interface**

In `workout_session_repository.dart`, add:
```dart
/// Get the set of distinct dayTypes finalized for a rotation within a cycle.
/// Returns {'1', '2'} if days 1 and 2 are done, for example.
Future<Either<Failure, Set<String>>> getFinalizedDayTypesForRotation(
  int cycleId,
  int rotationNumber,
);
```

- [ ] **Step 3: Implement in repository**

In `workout_session_repository_impl.dart`, add:
```dart
@override
Future<Either<Failure, Set<String>>> getFinalizedDayTypesForRotation(
  int cycleId,
  int rotationNumber,
) async {
  try {
    final dayTypes = await database.workoutSessionsDao
        .getFinalizedDayTypesForRotation(cycleId, rotationNumber);
    return Right(dayTypes);
  } on DatabaseException catch (e) {
    return Left(DatabaseFailure(e.message));
  } catch (e) {
    return Left(DatabaseFailure(e.toString()));
  }
}
```

- [ ] **Step 4: Verify**

```bash
flutter analyze lib/features/workout/data/datasources/local/app_database.dart lib/features/workout/domain/repositories/workout_session_repository.dart lib/features/workout/data/repositories/workout_session_repository_impl.dart
```
Expected: No issues.

- [ ] **Step 5: Commit**

```bash
git add lib/features/workout/data/datasources/local/app_database.dart
git add lib/features/workout/domain/repositories/workout_session_repository.dart
git add lib/features/workout/data/repositories/workout_session_repository_impl.dart
git commit -m "feat: add getFinalizedDayTypesForRotation to session repository"
```

---

## Task 6: Update FinalizeWorkoutSession rotation completion check

**Files:**
- Modify: `lib/features/workout/domain/usecases/finalize_workout_session.dart`

- [ ] **Step 1: Replace rotationPosition check with day-type query**

In `finalize_workout_session.dart`, replace step 7 (lines starting with `// 7. Track rotation completion`) with:

```dart
// 7. Track rotation completion — check if all 4 days of this rotation are now finalized
final dayTypesResult = await sessionRepository.getFinalizedDayTypesForRotation(
  session.cycleId,
  session.rotationNumber,
);

if (dayTypesResult.isRight()) {
  final finalizedDays = (dayTypesResult as Right).value;
  if (finalizedDays.length == 4) {
    // All 4 days done — increment rotation count
    final incrementResult = await cycleRepository.incrementRotations(session.cycleId);
    if (incrementResult.isLeft()) {
      print('[FinalizeWorkoutSession] Warning: Failed to increment rotation count');
    }

    // Check if cycle is complete (12 rotations)
    final cycleResult = await cycleRepository.getCycleById(session.cycleId);
    if (cycleResult.isRight()) {
      final cycle = (cycleResult as Right).value;
      if (cycle.completedRotations >= 12) {
        final completeResult = await cycleRepository.completeCycle(cycle.id, DateTime.now());
        if (completeResult.isLeft()) {
          print('[FinalizeWorkoutSession] Warning: Failed to auto-complete cycle');
        } else {
          print('[FinalizeWorkoutSession] Cycle #${cycle.cycleNumber} completed!');
        }
      }
    }
  }
}
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/features/workout/domain/usecases/finalize_workout_session.dart
```
Expected: No issues.

- [ ] **Step 3: Commit**

```bash
git add lib/features/workout/domain/usecases/finalize_workout_session.dart
git commit -m "refactor: replace rotationPosition check with day-type query in FinalizeWorkoutSession"
```

---

## Task 7: Update ActiveWorkoutBloc session creation

**Files:**
- Modify: `lib/features/workout/presentation/bloc/active_workout/active_workout_bloc.dart`

- [ ] **Step 1: Simplify rotationNumber logic, remove rotationPosition**

In `_onStartWorkout`, replace the entire block that calculates `rotationNumber` and `rotationPosition` (from the `getLastFinalizedSession` call down to the `WorkoutSessionEntity` creation) with:

```dart
// rotationNumber = current active week = completedRotations + 1
final rotationNumber = activeCycle.completedRotations + 1;

// Create session
final session = WorkoutSessionEntity(
  id: 0,
  cycleId: activeCycle.id,
  dayType: event.dayType,
  rotationNumber: rotationNumber,
  dateStarted: DateTime.now(),
  dateCompleted: null,
  isFinalized: false,
);
```

Remove the `lastSessionResult` and `rotationPosition` variables entirely.

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/features/workout/presentation/bloc/active_workout/active_workout_bloc.dart
```
Expected: No issues.

- [ ] **Step 3: Commit**

```bash
git add lib/features/workout/presentation/bloc/active_workout/active_workout_bloc.dart
git commit -m "refactor: derive rotationNumber from completedRotations in ActiveWorkoutBloc"
```

---

## Task 8: Update StartNewCycle with weight options

**Files:**
- Modify: `lib/features/workout/domain/usecases/start_new_cycle.dart`

- [ ] **Step 1: Add NewCycleWeightOption sealed class and update use case**

Replace the entire file content:
```dart
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/cycle_repository.dart';
import '../repositories/cycle_state_repository.dart';
import '../repositories/lift_repository.dart';

/// Describes how starting weights for the new cycle are chosen
sealed class NewCycleWeightOption {
  const NewCycleWeightOption();
}

/// Use each lift's nextTargetWeight from the last cycle unchanged
class KeepWeights extends NewCycleWeightOption {
  const KeepWeights();
}

/// Use caller-supplied weights (pre-filled from last cycle, user may have edited)
class CustomWeights extends NewCycleWeightOption {
  /// Map of liftId → starting weight for the new cycle
  final Map<int, double> weights;
  const CustomWeights(this.weights);
}

/// Parameters for StartNewCycle
class NewCycleWeightParams {
  final NewCycleWeightOption weightOption;
  const NewCycleWeightParams({required this.weightOption});
}

/// Starts a new training cycle.
///
/// 1. Completes the current active cycle
/// 2. Creates a new cycle
/// 3. Creates new CycleStates at Stage 1 with chosen starting weights
class StartNewCycle implements UseCase<int, NewCycleWeightParams> {
  final CycleRepository cycleRepository;
  final CycleStateRepository cycleStateRepository;
  final LiftRepository liftRepository;

  StartNewCycle({
    required this.cycleRepository,
    required this.cycleStateRepository,
    required this.liftRepository,
  });

  @override
  Future<Either<Failure, int>> call(NewCycleWeightParams params) async {
    try {
      // 1. Get the current active cycle
      final activeCycleResult = await cycleRepository.getActiveCycle();
      if (activeCycleResult.isLeft()) {
        return Left((activeCycleResult as Left).value);
      }
      final currentCycle = (activeCycleResult as Right).value;

      // 2. Get all cycle states from the current cycle
      final cycleStatesResult =
          await cycleStateRepository.getCycleStatesForCycle(currentCycle.id);
      if (cycleStatesResult.isLeft()) {
        return Left((cycleStatesResult as Left).value);
      }
      final currentCycleStates = (cycleStatesResult as Right).value;

      if (currentCycleStates.isEmpty) {
        return Left(ValidationFailure('No cycle states found for current cycle'));
      }

      // 3. Complete the current cycle
      final now = DateTime.now();
      final completeCycleResult =
          await cycleRepository.completeCycle(currentCycle.id, now);
      if (completeCycleResult.isLeft()) {
        return Left((completeCycleResult as Left).value);
      }

      // 4. Create new cycle
      final maxCycleNumberResult = await cycleRepository.getMaxCycleNumber();
      if (maxCycleNumberResult.isLeft()) {
        return Left((maxCycleNumberResult as Left).value);
      }
      final newCycleNumber = (maxCycleNumberResult as Right).value + 1;

      final newCycleIdResult =
          await cycleRepository.createCycle(newCycleNumber, now);
      if (newCycleIdResult.isLeft()) {
        return Left((newCycleIdResult as Left).value);
      }
      final newCycleId = (newCycleIdResult as Right).value;

      // 5. Get all lifts
      final liftsResult = await liftRepository.getAllLifts();
      if (liftsResult.isLeft()) {
        return Left((liftsResult as Left).value);
      }
      final lifts = (liftsResult as Right).value;

      // 6. Build weight lookup from option
      final Map<int, double> customWeightMap =
          params.weightOption is CustomWeights
              ? (params.weightOption as CustomWeights).weights
              : {};

      // 7. Create new CycleStates — always Stage 1, weight from option
      for (final lift in lifts) {
        for (final tier in ['T1', 'T2', 'T3']) {
          final oldState = currentCycleStates.firstWhere(
            (s) => s.liftId == lift.id && s.currentTier == tier,
            orElse: () =>
                throw Exception('Missing state for lift ${lift.name} tier $tier'),
          );

          final double startWeight;
          if (params.weightOption is CustomWeights) {
            // Use caller-supplied weight if provided, else fall back to last weight
            startWeight = customWeightMap[lift.id] ?? oldState.nextTargetWeight;
          } else {
            // KeepWeights: use last cycle's nextTargetWeight unchanged
            startWeight = oldState.nextTargetWeight;
          }

          final createResult = await cycleStateRepository.createCycleStateFromParams(
            cycleId: newCycleId,
            liftId: lift.id,
            tier: tier,
            stage: 1,
            nextTargetWeight: startWeight,
            lastStage1SuccessWeight: null,
            currentT3AmrapVolume: 0,
          );

          if (createResult.isLeft()) {
            return Left((createResult as Left).value);
          }
        }
      }

      return Right(newCycleId);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/features/workout/domain/usecases/start_new_cycle.dart
```
Expected: No issues.

- [ ] **Step 3: Commit**

```bash
git add lib/features/workout/domain/usecases/start_new_cycle.dart
git commit -m "feat: add NewCycleWeightOption to StartNewCycle use case"
```

---

## Task 9: Update SessionManagerBloc to include cycle + week info

**Files:**
- Modify: `lib/features/workout/presentation/bloc/session_manager/session_manager_state.dart`
- Modify: `lib/features/workout/presentation/bloc/session_manager/session_manager_bloc.dart`

- [ ] **Step 1: Update SessionManagerState to carry cycle data**

Replace the entire `session_manager_state.dart`:
```dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/cycle_entity.dart';
import '../../../domain/entities/workout_session_entity.dart';

abstract class SessionManagerState extends Equatable {
  const SessionManagerState();

  @override
  List<Object?> get props => [];
}

class SessionManagerInitial extends SessionManagerState {
  const SessionManagerInitial();
}

class SessionManagerLoading extends SessionManagerState {
  const SessionManagerLoading();
}

class SessionManagerInProgress extends SessionManagerState {
  final WorkoutSessionEntity session;
  final CycleEntity? activeCycle;
  final int currentWeek;
  final Set<String> completedDaysThisWeek;

  const SessionManagerInProgress(
    this.session, {
    this.activeCycle,
    this.currentWeek = 1,
    this.completedDaysThisWeek = const {},
  });

  @override
  List<Object?> get props =>
      [session, activeCycle, currentWeek, completedDaysThisWeek];
}

class SessionManagerNoSession extends SessionManagerState {
  final WorkoutSessionEntity? lastSession;
  final CycleEntity? activeCycle;
  final int currentWeek;
  final Set<String> completedDaysThisWeek;

  const SessionManagerNoSession({
    this.lastSession,
    this.activeCycle,
    this.currentWeek = 1,
    this.completedDaysThisWeek = const {},
  });

  bool get isCycleComplete =>
      activeCycle != null && activeCycle!.completedRotations >= 12;

  @override
  List<Object?> get props =>
      [lastSession, activeCycle, currentWeek, completedDaysThisWeek];
}

class SessionManagerError extends SessionManagerState {
  final String message;

  const SessionManagerError(this.message);

  @override
  List<Object?> get props => [message];
}
```

- [ ] **Step 2: Update SessionManagerBloc to load cycle info**

Replace the entire `session_manager_bloc.dart`:
```dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/cycle_repository.dart';
import '../../../domain/repositories/workout_session_repository.dart';
import 'session_manager_event.dart';
import 'session_manager_state.dart';

class SessionManagerBloc
    extends Bloc<SessionManagerEvent, SessionManagerState> {
  final WorkoutSessionRepository sessionRepository;
  final CycleRepository cycleRepository;

  SessionManagerBloc({
    required this.sessionRepository,
    required this.cycleRepository,
  }) : super(const SessionManagerInitial()) {
    on<CheckInProgressSession>(_onCheckInProgressSession);
  }

  Future<void> _onCheckInProgressSession(
    CheckInProgressSession event,
    Emitter<SessionManagerState> emit,
  ) async {
    emit(const SessionManagerLoading());

    try {
      // Load active cycle
      final cycleResult = await cycleRepository.getActiveCycle();
      final activeCycle =
          cycleResult.fold((_) => null, (cycle) => cycle);

      final int currentWeek;
      final Set<String> completedDaysThisWeek;

      if (activeCycle != null) {
        currentWeek = activeCycle.completedRotations + 1;
        // Get finalized days for the current rotation
        final daysResult = await sessionRepository
            .getFinalizedDayTypesForRotation(
                activeCycle.id, currentWeek);
        completedDaysThisWeek =
            daysResult.fold((_) => <String>{}, (days) => days);
      } else {
        currentWeek = 1;
        completedDaysThisWeek = {};
      }

      // Check for in-progress session
      final result = await sessionRepository.getInProgressSession();

      await result.fold(
        (failure) async => emit(SessionManagerError(failure.message)),
        (session) async {
          if (session != null) {
            emit(SessionManagerInProgress(
              session,
              activeCycle: activeCycle,
              currentWeek: currentWeek,
              completedDaysThisWeek: completedDaysThisWeek,
            ));
          } else {
            final lastResult =
                await sessionRepository.getLastFinalizedSession();
            lastResult.fold(
              (_) => emit(SessionManagerNoSession(
                activeCycle: activeCycle,
                currentWeek: currentWeek,
                completedDaysThisWeek: completedDaysThisWeek,
              )),
              (lastSession) => emit(SessionManagerNoSession(
                lastSession: lastSession,
                activeCycle: activeCycle,
                currentWeek: currentWeek,
                completedDaysThisWeek: completedDaysThisWeek,
              )),
            );
          }
        },
      );
    } catch (e) {
      emit(SessionManagerError('Failed to check in-progress session: $e'));
    }
  }
}
```

- [ ] **Step 3: Update DI to inject CycleRepository into SessionManagerBloc**

In `lib/core/di/injection_container.dart`, find the `SessionManagerBloc` registration and add `cycleRepository`:
```dart
sl.registerFactory<features.SessionManagerBloc>(
  () => features.SessionManagerBloc(
    sessionRepository: sl(),
    cycleRepository: sl(),
  ),
);
```

- [ ] **Step 4: Verify**

```bash
flutter analyze lib/features/workout/presentation/bloc/session_manager/ lib/core/di/injection_container.dart
```
Expected: No issues.

- [ ] **Step 5: Commit**

```bash
git add lib/features/workout/presentation/bloc/session_manager/session_manager_state.dart
git add lib/features/workout/presentation/bloc/session_manager/session_manager_bloc.dart
git add lib/core/di/injection_container.dart
git commit -m "feat: add cycle and week info to SessionManagerBloc"
```

---

## Task 10: Update OnboardingBloc splash check + day number keys

**Files:**
- Modify: `lib/features/workout/presentation/bloc/onboarding/onboarding_bloc.dart`
- Modify: `lib/features/workout/presentation/pages/splash_page.dart`

- [ ] **Step 1: Change splash status check in OnboardingBloc**

In `onboarding_bloc.dart`, replace `_onCheckOnboardingStatus`:
```dart
Future<void> _onCheckOnboardingStatus(
  CheckOnboardingStatus event,
  Emitter<OnboardingState> emit,
) async {
  emit(const OnboardingCheckingStatus());

  try {
    // App is set up when an active cycle exists
    final activeCycle = await database.cyclesDao.getActiveCycle();
    if (activeCycle != null) {
      emit(const OnboardingAlreadyComplete());
    } else {
      emit(const OnboardingInProgress(currentStep: 0));
    }
  } catch (e) {
    emit(const OnboardingInProgress(currentStep: 0));
  }
}
```

- [ ] **Step 2: Update T3 exercise day keys to use numbers**

In `onboarding_bloc.dart`, find where T3 exercises are saved in `_onCompleteOnboarding`. The `selectedT3Exercises` map keys will now be '1'/'2'/'3'/'4' (set by the UI in Task 16). No code change needed here — the bloc stores whatever keys the UI provides.

Verify the T3 accessory save loop still works:
```dart
selectedT3Exercises.forEach((dayType, exerciseName) {
  t3Exercises.add(AccessoryExerciseEntity(
    id: 0,
    name: exerciseName,
    dayType: dayType, // will be '1', '2', '3', or '4'
    orderIndex: 0,
  ));
});
```
This is already correct — no change needed.

- [ ] **Step 3: Verify**

```bash
flutter analyze lib/features/workout/presentation/bloc/onboarding/onboarding_bloc.dart
```
Expected: No issues.

- [ ] **Step 4: Commit**

```bash
git add lib/features/workout/presentation/bloc/onboarding/onboarding_bloc.dart
git commit -m "refactor: check active cycle instead of onboarding flag in splash"
```

---

## Task 11: Create NewCycleCubit, NewCycleState, and NewCyclePage

**Files:**
- Create: `lib/features/workout/presentation/bloc/new_cycle/new_cycle_state.dart`
- Create: `lib/features/workout/presentation/bloc/new_cycle/new_cycle_cubit.dart`
- Create: `lib/features/workout/presentation/pages/new_cycle_page.dart`
- Modify: `lib/core/routes/app_routes.dart`
- Modify: `lib/main.dart`
- Modify: `lib/core/di/injection_container.dart`

- [ ] **Step 1: Create new_cycle_state.dart**

```dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/cycle_entity.dart';

abstract class NewCycleState extends Equatable {
  const NewCycleState();
  @override
  List<Object?> get props => [];
}

class NewCycleLoading extends NewCycleState {
  const NewCycleLoading();
}

class NewCycleReady extends NewCycleState {
  /// The cycle that just completed
  final CycleEntity completedCycle;
  final int totalWorkouts;

  /// Last cycle's weights, keyed by liftId. Used to pre-fill custom weight inputs.
  final Map<int, double> lastCycleWeights;

  /// null = not yet chosen; true = keepWeights; false = adjustWeights
  final bool? keepWeights;

  /// User-edited weights when adjusting (starts as copy of lastCycleWeights)
  final Map<int, double> editedWeights;

  const NewCycleReady({
    required this.completedCycle,
    required this.totalWorkouts,
    required this.lastCycleWeights,
    this.keepWeights,
    this.editedWeights = const {},
  });

  NewCycleReady copyWith({
    bool? keepWeights,
    Map<int, double>? editedWeights,
  }) {
    return NewCycleReady(
      completedCycle: completedCycle,
      totalWorkouts: totalWorkouts,
      lastCycleWeights: lastCycleWeights,
      keepWeights: keepWeights ?? this.keepWeights,
      editedWeights: editedWeights ?? this.editedWeights,
    );
  }

  @override
  List<Object?> get props =>
      [completedCycle, totalWorkouts, lastCycleWeights, keepWeights, editedWeights];
}

class NewCycleCreating extends NewCycleState {
  const NewCycleCreating();
}

class NewCycleCreated extends NewCycleState {
  const NewCycleCreated();
}

class NewCycleError extends NewCycleState {
  final String message;
  const NewCycleError(this.message);
  @override
  List<Object?> get props => [message];
}
```

- [ ] **Step 2: Create new_cycle_cubit.dart**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/usecases/usecase.dart';
import '../../../data/datasources/local/app_database.dart';
import '../../../domain/entities/cycle_entity.dart';
import '../../../domain/repositories/cycle_repository.dart';
import '../../../domain/repositories/cycle_state_repository.dart';
import '../../../domain/repositories/lift_repository.dart';
import '../../../domain/repositories/workout_session_repository.dart';
import '../../../domain/usecases/start_new_cycle.dart';
import 'new_cycle_state.dart';

class NewCycleCubit extends Cubit<NewCycleState> {
  final CycleRepository cycleRepository;
  final CycleStateRepository cycleStateRepository;
  final LiftRepository liftRepository;
  final WorkoutSessionRepository sessionRepository;
  final StartNewCycle startNewCycle;

  NewCycleCubit({
    required this.cycleRepository,
    required this.cycleStateRepository,
    required this.liftRepository,
    required this.sessionRepository,
    required this.startNewCycle,
  }) : super(const NewCycleLoading());

  Future<void> loadCompletedCycle() async {
    emit(const NewCycleLoading());

    try {
      // Get the most recently completed cycle
      final cyclesResult = await cycleRepository.getCompletedCycles();
      if (cyclesResult.isLeft()) {
        emit(const NewCycleError('Failed to load completed cycle'));
        return;
      }
      final completedCycles = (cyclesResult as Right).value as List<CycleEntity>;
      if (completedCycles.isEmpty) {
        emit(const NewCycleError('No completed cycle found'));
        return;
      }
      final completedCycle = completedCycles.first;

      // Get total workouts in that cycle
      final sessionsResult =
          await sessionRepository.getFinalizedSessionsForCycle(completedCycle.id);
      final totalWorkouts = sessionsResult.fold((_) => 0, (s) => s.length);

      // Get last cycle states to extract ending weights
      final statesResult =
          await cycleStateRepository.getCycleStatesForCycle(completedCycle.id);
      if (statesResult.isLeft()) {
        emit(const NewCycleError('Failed to load cycle weights'));
        return;
      }
      final states = (statesResult as Right).value;

      // Build weight map: liftId → T1 nextTargetWeight (primary lift weight)
      final Map<int, double> lastWeights = {};
      for (final state in states) {
        if (state.currentTier == 'T1') {
          lastWeights[state.liftId] = state.nextTargetWeight;
        }
      }

      emit(NewCycleReady(
        completedCycle: completedCycle,
        totalWorkouts: totalWorkouts,
        lastCycleWeights: lastWeights,
        editedWeights: Map.from(lastWeights),
      ));
    } catch (e) {
      emit(NewCycleError('Error: $e'));
    }
  }

  void selectKeepWeights() {
    if (state is! NewCycleReady) return;
    emit((state as NewCycleReady).copyWith(keepWeights: true));
  }

  void selectAdjustWeights() {
    if (state is! NewCycleReady) return;
    emit((state as NewCycleReady).copyWith(keepWeights: false));
  }

  void updateWeight(int liftId, double weight) {
    if (state is! NewCycleReady) return;
    final current = state as NewCycleReady;
    final updated = Map<int, double>.from(current.editedWeights);
    updated[liftId] = weight;
    emit(current.copyWith(editedWeights: updated));
  }

  Future<void> confirmNewCycle() async {
    if (state is! NewCycleReady) return;
    final current = state as NewCycleReady;
    emit(const NewCycleCreating());

    final weightOption = current.keepWeights == true
        ? const KeepWeights()
        : CustomWeights(current.editedWeights);

    final result = await startNewCycle(
      NewCycleWeightParams(weightOption: weightOption),
    );

    result.fold(
      (failure) => emit(NewCycleError(failure.message)),
      (_) => emit(const NewCycleCreated()),
    );
  }
}
```

- [ ] **Step 3: Add getFinalizedSessionsForCycle to WorkoutSessionRepository**

In `workout_session_repository.dart`, add:
```dart
/// Get all finalized sessions for a specific cycle
Future<Either<Failure, List<WorkoutSessionEntity>>> getFinalizedSessionsForCycle(
  int cycleId,
);
```

In `workout_session_repository_impl.dart`, add:
```dart
@override
Future<Either<Failure, List<WorkoutSessionEntity>>> getFinalizedSessionsForCycle(
  int cycleId,
) async {
  try {
    final sessions = await database.workoutSessionsDao
        .getLastFinalizedSessionForCycle(cycleId);
    // Use existing getSessionsForCycle and filter finalized
    final all = await database.workoutSessionsDao.getSessionsForCycle(cycleId);
    final finalized = all.where((s) => s.isFinalized).map(_sessionToEntity).toList();
    return Right(finalized);
  } on DatabaseException catch (e) {
    return Left(DatabaseFailure(e.message));
  } catch (e) {
    return Left(DatabaseFailure(e.toString()));
  }
}
```

Also add `getCompletedCycles` to `CycleRepository` if not present. In `lib/features/workout/domain/repositories/cycle_repository.dart`, check for this method and add if missing:
```dart
Future<Either<Failure, List<CycleEntity>>> getCompletedCycles();
```

In `lib/features/workout/data/repositories/cycle_repository_impl.dart`, implement it using `database.cyclesDao.getCompletedCycles()`.

- [ ] **Step 4: Create new_cycle_page.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/app_routes.dart';
import '../bloc/new_cycle/new_cycle_cubit.dart';
import '../bloc/new_cycle/new_cycle_state.dart';

class NewCyclePage extends StatelessWidget {
  const NewCyclePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NewCycleCubit>()..loadCompletedCycle(),
      child: BlocConsumer<NewCycleCubit, NewCycleState>(
        listener: (context, state) {
          if (state is NewCycleCreated) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.home,
              (route) => false,
            );
          } else if (state is NewCycleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NewCycleLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state is NewCycleCreating) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Starting new cycle...'),
                  ],
                ),
              ),
            );
          }
          if (state is NewCycleReady) {
            return _NewCycleReadyView(state: state);
          }
          return const Scaffold(
            body: Center(child: Text('Something went wrong')),
          );
        },
      ),
    );
  }
}

class _NewCycleReadyView extends StatelessWidget {
  final NewCycleReady state;
  const _NewCycleReadyView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Start New Cycle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Cycle ${state.completedCycle.cycleNumber} Complete!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '12 weeks • ${state.totalWorkouts} workouts',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Starting weights for Cycle ${state.completedCycle.cycleNumber + 1}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Weight option buttons
            _WeightOptionButton(
              label: 'Keep current weights',
              subtitle: 'Use the same weights you ended with',
              selected: state.keepWeights == true,
              onTap: () =>
                  context.read<NewCycleCubit>().selectKeepWeights(),
            ),
            const SizedBox(height: 12),
            _WeightOptionButton(
              label: 'Adjust weights',
              subtitle: 'Edit starting weights for the new cycle',
              selected: state.keepWeights == false,
              onTap: () =>
                  context.read<NewCycleCubit>().selectAdjustWeights(),
            ),
            // Weight inputs when adjusting
            if (state.keepWeights == false) ...[
              const SizedBox(height: 24),
              Text(
                'Starting weights (T1)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ...state.lastCycleWeights.entries.map((entry) {
                final liftId = entry.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _WeightInput(
                    liftId: liftId,
                    initialWeight: state.editedWeights[liftId] ?? entry.value,
                    onChanged: (w) =>
                        context.read<NewCycleCubit>().updateWeight(liftId, w),
                  ),
                );
              }),
            ],
            const SizedBox(height: 32),
            // Confirm button — only active once option is selected
            ElevatedButton(
              onPressed: state.keepWeights != null
                  ? () => context.read<NewCycleCubit>().confirmNewCycle()
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Start Cycle ${state.completedCycle.cycleNumber + 1}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightOptionButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _WeightOptionButton({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: selected
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: selected
            ? BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeightInput extends StatefulWidget {
  final int liftId;
  final double initialWeight;
  final ValueChanged<double> onChanged;

  const _WeightInput({
    required this.liftId,
    required this.initialWeight,
    required this.onChanged,
  });

  @override
  State<_WeightInput> createState() => _WeightInputState();
}

class _WeightInputState extends State<_WeightInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.initialWeight.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Lift #${widget.liftId} weight',
        border: const OutlineInputBorder(),
        suffixText: 'lbs',
      ),
      onChanged: (value) {
        final parsed = double.tryParse(value);
        if (parsed != null) widget.onChanged(parsed);
      },
    );
  }
}
```

> **Note on lift names in weight inputs:** The `_WeightInput` widget above uses `liftId` as a label placeholder. In a follow-up, pass lift names from the cubit state — the cubit knows `lastCycleWeights` keyed by liftId, but not the names. The cubit's `loadCompletedCycle` can be extended to also load lift names from `liftRepository.getAllLifts()` and expose them in `NewCycleReady`. For now, the feature is functional; lift names are a cosmetic improvement.

- [ ] **Step 5: Add route and register dependencies**

In `app_routes.dart`, add:
```dart
static const String newCycle = '/new-cycle';
```

In `main.dart`, add the import and route:
```dart
import 'features/workout/presentation/pages/new_cycle_page.dart';
// ...
AppRoutes.newCycle: (context) => const NewCyclePage(),
```

In `injection_container.dart`, add `NewCycleCubit` registration (add after the existing use case registrations):
```dart
import '../../features/workout/presentation/bloc/new_cycle/new_cycle_cubit.dart'
    as features;
// ...
sl.registerFactory<features.NewCycleCubit>(
  () => features.NewCycleCubit(
    cycleRepository: sl(),
    cycleStateRepository: sl(),
    liftRepository: sl(),
    sessionRepository: sl(),
    startNewCycle: sl(),
  ),
);
```

- [ ] **Step 6: Verify**

```bash
flutter analyze lib/features/workout/presentation/bloc/new_cycle/ lib/features/workout/presentation/pages/new_cycle_page.dart lib/core/routes/app_routes.dart lib/main.dart lib/core/di/injection_container.dart
```
Expected: No issues.

- [ ] **Step 7: Commit**

```bash
git add lib/features/workout/presentation/bloc/new_cycle/
git add lib/features/workout/presentation/pages/new_cycle_page.dart
git add lib/core/routes/app_routes.dart
git add lib/main.dart
git add lib/core/di/injection_container.dart
git add lib/features/workout/domain/repositories/workout_session_repository.dart
git add lib/features/workout/data/repositories/workout_session_repository_impl.dart
git commit -m "feat: add NewCycleCubit, NewCyclePage, and new-cycle route"
```

---

## Task 12: Update HomePage

**Files:**
- Modify: `lib/features/workout/presentation/pages/home_page.dart`

- [ ] **Step 1: Rewrite HomePage body to show cycle/week header and day status**

Replace the entire `HomePage` class with:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/app_routes.dart';
import '../bloc/session_manager/session_manager_bloc.dart';
import '../bloc/session_manager/session_manager_event.dart';
import '../bloc/session_manager/session_manager_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<SessionManagerBloc>()..add(const CheckInProgressSession()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('GZCLP Tracker'),
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.history),
              tooltip: 'History',
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.settings),
              tooltip: 'Settings',
            ),
          ],
        ),
        body: BlocBuilder<SessionManagerBloc, SessionManagerState>(
          builder: (context, state) {
            if (state is SessionManagerLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SessionManagerError) {
              return _ErrorView(
                message: state.message,
                onRetry: () => context
                    .read<SessionManagerBloc>()
                    .add(const CheckInProgressSession()),
              );
            }
            if (state is SessionManagerInProgress) {
              return _HomeBody(
                activeCycle: state.activeCycle,
                currentWeek: state.currentWeek,
                completedDaysThisWeek: state.completedDaysThisWeek,
                child: _ResumeWorkoutCard(dayType: state.session.dayType),
              );
            }
            // SessionManagerNoSession
            final noSession = state as SessionManagerNoSession;
            return _HomeBody(
              activeCycle: noSession.activeCycle,
              currentWeek: noSession.currentWeek,
              completedDaysThisWeek: noSession.completedDaysThisWeek,
              child: noSession.isCycleComplete
                  ? _NewCycleButton()
                  : _StartWorkoutButton(),
            );
          },
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final dynamic activeCycle;
  final int currentWeek;
  final Set<String> completedDaysThisWeek;
  final Widget child;

  const _HomeBody({
    required this.activeCycle,
    required this.currentWeek,
    required this.completedDaysThisWeek,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            if (activeCycle != null) ...[
              Text(
                'Cycle ${activeCycle.cycleNumber} • Week $currentWeek of 12',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              _WeekDayStatusRow(completedDays: completedDaysThisWeek),
              const SizedBox(height: 32),
            ],
            child,
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.dashboard),
              icon: const Icon(Icons.analytics),
              label: const Text('View Dashboard'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekDayStatusRow extends StatelessWidget {
  final Set<String> completedDays;
  const _WeekDayStatusRow({required this.completedDays});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ['1', '2', '3', '4'].map((day) {
        final done = completedDays.contains(day);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            children: [
              Icon(
                done ? Icons.check_circle : Icons.circle_outlined,
                color: done ? Colors.green : Colors.grey,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                'Day $day',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StartWorkoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () =>
          Navigator.of(context).pushNamed(AppRoutes.startWorkout),
      icon: const Icon(Icons.add),
      label: const Text('Start Workout'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
    );
  }
}

class _NewCycleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () =>
          Navigator.of(context).pushNamed(AppRoutes.newCycle),
      icon: const Icon(Icons.refresh),
      label: const Text('Start New Cycle'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _ResumeWorkoutCard extends StatelessWidget {
  final String dayType;
  const _ResumeWorkoutCard({required this.dayType});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Workout in Progress — Day $dayType',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.activeWorkout),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Continue Workout'),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/features/workout/presentation/pages/home_page.dart
```
Expected: No issues.

- [ ] **Step 3: Commit**

```bash
git add lib/features/workout/presentation/pages/home_page.dart
git commit -m "feat: show cycle/week header and day status on home page"
```

---

## Task 13: Update StartWorkoutPage — day numbers, week title, completion badges

**Files:**
- Modify: `lib/features/workout/presentation/pages/start_workout_page.dart`

- [ ] **Step 1: Update day data and week context**

Replace the `_buildDaySelection` method's title section and the `_buildDayCard` calls:

Replace the four `_buildDayCard` calls to use numbers:
```dart
_buildDayCard(context, '1', 'Squat', 'Overhead Press',
    _t3ExercisesByDay['1'] ?? [], _completedDaysThisWeek),
const SizedBox(height: 12),
_buildDayCard(context, '2', 'Bench Press', 'Deadlift',
    _t3ExercisesByDay['2'] ?? [], _completedDaysThisWeek),
const SizedBox(height: 12),
_buildDayCard(context, '3', 'Bench Press', 'Squat',
    _t3ExercisesByDay['3'] ?? [], _completedDaysThisWeek),
const SizedBox(height: 12),
_buildDayCard(context, '4', 'Deadlift', 'Overhead Press',
    _t3ExercisesByDay['4'] ?? [], _completedDaysThisWeek),
```

Add `_completedDaysThisWeek` and `_currentWeek` as state fields. Update `_loadT3Exercises` to also load cycle info from the `SessionManagerBloc` (or read `CyclesDao` directly, similar to how `DashboardPage` does it):

```dart
Set<String> _completedDaysThisWeek = {};
int _currentWeek = 1;
```

In `initState`, after `_loadT3Exercises()`, add `_loadCycleInfo()`:
```dart
Future<void> _loadCycleInfo() async {
  final db = sl<AppDatabase>();
  final activeCycle = await db.cyclesDao.getActiveCycle();
  if (activeCycle != null) {
    final currentWeek = activeCycle.completedRotations + 1;
    final sessions = await db.workoutSessionsDao
        .getFinalizedDayTypesForRotation(activeCycle.id, currentWeek);
    setState(() {
      _currentWeek = currentWeek;
      _completedDaysThisWeek = sessions;
    });
  }
}
```

Update the page title and subtitle in `_buildDaySelection`:
```dart
Text(
  'Week $_currentWeek of 12',
  style: Theme.of(context).textTheme.headlineMedium,
),
const SizedBox(height: 8),
Text(
  'Select a day to train',
  style: Theme.of(context).textTheme.bodyMedium,
),
```

Update `_buildDayCard` signature to accept `completedDays` and show badge:
```dart
Widget _buildDayCard(
  BuildContext context,
  String dayType,
  String t1Lift,
  String t2Lift,
  List<AccessoryExerciseEntity> t3Exercises,
  Set<String> completedDays,
) {
```

In the day badge circle, add a checkmark overlay when done:
```dart
Container(
  width: 48,
  height: 48,
  decoration: BoxDecoration(
    color: completedDays.contains(dayType)
        ? Colors.green
        : Theme.of(context).colorScheme.primaryContainer,
    borderRadius: BorderRadius.circular(24),
  ),
  child: Center(
    child: completedDays.contains(dayType)
        ? const Icon(Icons.check, color: Colors.white)
        : Text(
            dayType,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimaryContainer,
                ),
          ),
  ),
),
```

Update the card title:
```dart
Text(
  'Day $dayType',
  style: Theme.of(context).textTheme.titleLarge,
),
if (completedDays.contains(dayType))
  Text(
    'Done this week',
    style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.green,
        ),
  ),
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/features/workout/presentation/pages/start_workout_page.dart
```
Expected: No issues.

- [ ] **Step 3: Commit**

```bash
git add lib/features/workout/presentation/pages/start_workout_page.dart
git commit -m "feat: show week context and day completion badges in day picker"
```

---

## Task 14: Update ActiveWorkoutPage title

**Files:**
- Modify: `lib/features/workout/presentation/pages/active_workout_page.dart`

- [ ] **Step 1: Update AppBar title**

In `_buildActiveWorkoutView`, find:
```dart
title: Text('Day ${state.session.dayType} Workout'),
```

And we need the current week number. Load it similarly to StartWorkoutPage — add a quick read of the active cycle. However, since `ActiveWorkoutPage` gets its state from `ActiveWorkoutBloc`, the simplest approach is to pass the `rotationNumber` from `session`:

Replace with:
```dart
title: Text('Week ${state.session.rotationNumber} • Day ${state.session.dayType}'),
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/features/workout/presentation/pages/active_workout_page.dart
```
Expected: No issues.

- [ ] **Step 3: Commit**

```bash
git add lib/features/workout/presentation/pages/active_workout_page.dart
git commit -m "feat: show week and day number in active workout title"
```

---

## Task 15: Update WorkoutHistoryPage day filter values

**Files:**
- Modify: `lib/features/workout/presentation/pages/workout_history_page.dart`

- [ ] **Step 1: Replace A/B/C/D filter values with 1/2/3/4**

In `workout_history_page.dart`, replace the `PopupMenuButton` items:
```dart
const PopupMenuItem(value: null, child: Text('All Days')),
const PopupMenuDivider(),
const PopupMenuItem(value: '1', child: Text('Day 1')),
const PopupMenuItem(value: '2', child: Text('Day 2')),
const PopupMenuItem(value: '3', child: Text('Day 3')),
const PopupMenuItem(value: '4', child: Text('Day 4')),
```

Update the empty-state text:
```dart
_filterDayType == null
    ? 'No workout history yet'
    : 'No workouts for Day $_filterDayType',
```
(Already correct — no change needed since it uses `_filterDayType` directly.)

Update `_getDayTypeColor` in `_WorkoutSessionCard`:
```dart
Color _getDayTypeColor() {
  switch (session.dayType) {
    case '1': return Colors.red;
    case '2': return Colors.blue;
    case '3': return Colors.green;
    case '4': return Colors.orange;
    default: return Colors.grey;
  }
}
```

Update the day badge text:
Find `'Day ${session.dayType}'` and it's already correct (shows the number).

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/features/workout/presentation/pages/workout_history_page.dart
```
Expected: No issues.

- [ ] **Step 3: Commit**

```bash
git add lib/features/workout/presentation/pages/workout_history_page.dart
git commit -m "refactor: update workout history day filter from letters to numbers"
```

---

## Task 16: Reframe OnboardingPage as Cycle 1 creation

**Files:**
- Modify: `lib/features/workout/presentation/pages/onboarding_page.dart`

- [ ] **Step 1: Update day type keys and copy**

Open `lib/features/workout/presentation/pages/onboarding_page.dart`. Find all occurrences of `'A'`, `'B'`, `'C'`, `'D'` used as day type keys in T3 exercise selection and replace with `'1'`, `'2'`, `'3'`, `'4'` respectively.

Find and update any "onboarding" copy visible to the user. Replace text such as:
- "Welcome to GZCLP Tracker" → keep as-is (still appropriate)
- Any step title referring to "setup" or "getting started" → change to frame as "Starting Cycle 1"
- The weights step title → "Set your starting weights for Cycle 1"
- The T3 exercise step → keep as-is

For the step that shows "Day A", "Day B", "Day C", "Day D" labels in T3 exercise selection, update to "Day 1", "Day 2", "Day 3", "Day 4".

Specifically, find the `onboarding_t3_step.dart` widget and update any day label strings:

In `lib/features/workout/presentation/widgets/onboarding_t3_step.dart`:
```bash
# Find all references to day letters
grep -n "'A'\|'B'\|'C'\|'D'\|Day A\|Day B\|Day C\|Day D" lib/features/workout/presentation/widgets/onboarding_t3_step.dart
```

Replace each found occurrence — letter keys with number keys ('A'→'1', etc.) and label text "Day A" → "Day 1", etc.

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/features/workout/presentation/pages/onboarding_page.dart lib/features/workout/presentation/widgets/onboarding_t3_step.dart
```
Expected: No issues.

- [ ] **Step 3: Full project analyze**

```bash
flutter analyze
```
Expected: No issues across entire project.

- [ ] **Step 4: Run tests**

```bash
flutter test
```
Expected: All existing tests pass (database tests will run against a fresh schema).

- [ ] **Step 5: Commit**

```bash
git add lib/features/workout/presentation/pages/onboarding_page.dart
git add lib/features/workout/presentation/widgets/onboarding_t3_step.dart
git commit -m "refactor: reframe onboarding as Cycle 1 creation, update day labels to numbers"
```

---

## Task 17: Manual smoke test and final commit

- [ ] **Step 1: Run app on web**

```bash
flutter run -d chrome --web-port=8080
```

- [ ] **Step 2: Smoke test**
  - Fresh install: verify cycle creation flow appears (not old onboarding wording)
  - Complete cycle creation: verify home shows "Cycle 1 • Week 1 of 12"
  - Home day status row shows 4 unchecked days
  - Tap "Start Workout": verify day picker shows "Week 1 of 12", days labeled 1/2/3/4
  - Start Day 1 workout: verify active workout title shows "Week 1 • Day 1"
  - Complete Day 1: verify home shows Day 1 checked in status row
  - History filter shows Day 1/2/3/4 options

- [ ] **Step 3: Final push**

```bash
git push origin feature/ux-refactor
```
