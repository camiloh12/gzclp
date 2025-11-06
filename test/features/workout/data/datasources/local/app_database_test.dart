import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gzclp_tracker/features/workout/data/datasources/local/app_database.dart';
import 'package:gzclp_tracker/core/constants/app_constants.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    // Create an in-memory database for testing
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('LiftsDao', () {
    test('should insert and retrieve a lift', () async {
      // Arrange
      final lift = LiftCompanion.insert(
        name: 'Squat',
        category: AppConstants.liftCategoryLower,
      );

      // Act
      final id = await database.liftsDao.insertLift(lift);
      final retrievedLift = await database.liftsDao.getLiftById(id);

      // Assert
      expect(retrievedLift, isNotNull);
      expect(retrievedLift!.name, equals('Squat'));
      expect(retrievedLift.category, equals(AppConstants.liftCategoryLower));
    });

    test('should get lift by name', () async {
      // Arrange
      await database.liftsDao.insertLift(LiftCompanion.insert(
        name: 'Bench Press',
        category: AppConstants.liftCategoryUpper,
      ));

      // Act
      final lift = await database.liftsDao.getLiftByName('Bench Press');

      // Assert
      expect(lift, isNotNull);
      expect(lift!.name, equals('Bench Press'));
      expect(lift.category, equals(AppConstants.liftCategoryUpper));
    });

    test('should get lifts by category', () async {
      // Arrange
      await database.liftsDao.insertLifts([
        LiftCompanion.insert(name: 'Squat', category: AppConstants.liftCategoryLower),
        LiftCompanion.insert(name: 'Deadlift', category: AppConstants.liftCategoryLower),
        LiftCompanion.insert(name: 'Bench Press', category: AppConstants.liftCategoryUpper),
      ]);

      // Act
      final lowerBodyLifts = await database.liftsDao.getLiftsByCategory(AppConstants.liftCategoryLower);

      // Assert
      expect(lowerBodyLifts.length, equals(2));
      expect(lowerBodyLifts.every((lift) => lift.category == AppConstants.liftCategoryLower), isTrue);
    });

    test('should update a lift', () async {
      // Arrange
      final id = await database.liftsDao.insertLift(LiftCompanion.insert(
        name: 'Squat',
        category: AppConstants.liftCategoryLower,
      ));
      final lift = (await database.liftsDao.getLiftById(id))!;

      // Act
      final updated = lift.copyWith(name: 'Back Squat');
      await database.liftsDao.updateLift(updated);
      final retrievedLift = await database.liftsDao.getLiftById(id);

      // Assert
      expect(retrievedLift!.name, equals('Back Squat'));
    });

    test('should delete a lift', () async {
      // Arrange
      final id = await database.liftsDao.insertLift(LiftCompanion.insert(
        name: 'Squat',
        category: AppConstants.liftCategoryLower,
      ));

      // Act
      await database.liftsDao.deleteLift(id);
      final lift = await database.liftsDao.getLiftById(id);

      // Assert
      expect(lift, isNull);
    });

    test('should check if lifts exist', () async {
      // Assert initially empty
      expect(await database.liftsDao.hasLifts(), isFalse);

      // Act
      await database.liftsDao.insertLift(LiftCompanion.insert(
        name: 'Squat',
        category: AppConstants.liftCategoryLower,
      ));

      // Assert after insertion
      expect(await database.liftsDao.hasLifts(), isTrue);
    });
  });

  group('CycleStatesDao', () {
    late int squatId;

    setUp(() async {
      // Insert a test lift
      squatId = await database.liftsDao.insertLift(LiftCompanion.insert(
        name: 'Squat',
        category: AppConstants.liftCategoryLower,
      ));
    });

    test('should insert and retrieve a cycle state', () async {
      // Arrange
      final state = CycleStateCompanion.insert(
        liftId: squatId,
        currentTier: 'T1',
        currentStage: 1,
        nextTargetWeight: 225.0,
      );

      // Act
      final id = await database.cycleStatesDao.insertCycleState(state);
      final retrievedState = await database.cycleStatesDao.getCycleStateById(id);

      // Assert
      expect(retrievedState, isNotNull);
      expect(retrievedState!.liftId, equals(squatId));
      expect(retrievedState.currentTier, equals('T1'));
      expect(retrievedState.currentStage, equals(1));
      expect(retrievedState.nextTargetWeight, equals(225.0));
    });

    test('should get cycle state by lift and tier', () async {
      // Arrange
      await database.cycleStatesDao.insertCycleState(CycleStateCompanion.insert(
        liftId: squatId,
        currentTier: 'T1',
        currentStage: 1,
        nextTargetWeight: 225.0,
      ));

      // Act
      final state = await database.cycleStatesDao.getCycleStateByLiftAndTier(squatId, 'T1');

      // Assert
      expect(state, isNotNull);
      expect(state!.currentTier, equals('T1'));
    });

    test('should update last_stage1_success_weight for T2 tracking', () async {
      // Arrange
      final id = await database.cycleStatesDao.insertCycleState(CycleStateCompanion.insert(
        liftId: squatId,
        currentTier: 'T2',
        currentStage: 1,
        nextTargetWeight: 185.0,
      ));
      final state = (await database.cycleStatesDao.getCycleStateById(id))!;

      // Act - Simulate successful T2 Stage 1 completion
      final updated = state.copyWith(lastStage1SuccessWeight: const Value(185.0));
      await database.cycleStatesDao.updateCycleState(updated);
      final retrievedState = await database.cycleStatesDao.getCycleStateById(id);

      // Assert
      expect(retrievedState!.lastStage1SuccessWeight, equals(185.0));
    });

    test('should update multiple cycle states in transaction', () async {
      // Arrange
      final id1 = await database.cycleStatesDao.insertCycleState(CycleStateCompanion.insert(
        liftId: squatId,
        currentTier: 'T1',
        currentStage: 1,
        nextTargetWeight: 225.0,
      ));
      final id2 = await database.cycleStatesDao.insertCycleState(CycleStateCompanion.insert(
        liftId: squatId,
        currentTier: 'T2',
        currentStage: 1,
        nextTargetWeight: 185.0,
      ));

      final state1 = (await database.cycleStatesDao.getCycleStateById(id1))!;
      final state2 = (await database.cycleStatesDao.getCycleStateById(id2))!;

      // Act - Update both states atomically
      await database.cycleStatesDao.updateCycleStatesInTransaction([
        state1.copyWith(nextTargetWeight: 235.0),
        state2.copyWith(nextTargetWeight: 195.0),
      ]);

      // Assert
      final updated1 = await database.cycleStatesDao.getCycleStateById(id1);
      final updated2 = await database.cycleStatesDao.getCycleStateById(id2);
      expect(updated1!.nextTargetWeight, equals(235.0));
      expect(updated2!.nextTargetWeight, equals(195.0));
    });

    test('should enforce unique constraint on lift+tier combination', () async {
      // Arrange
      await database.cycleStatesDao.insertCycleState(CycleStateCompanion.insert(
        liftId: squatId,
        currentTier: 'T1',
        currentStage: 1,
        nextTargetWeight: 225.0,
      ));

      // Act & Assert - Attempt to insert duplicate
      expect(
        () => database.cycleStatesDao.insertCycleState(CycleStateCompanion.insert(
          liftId: squatId,
          currentTier: 'T1', // Same lift and tier
          currentStage: 2,
          nextTargetWeight: 235.0,
        )),
        throwsA(isA<SqliteException>()),
      );
    });
  });

  group('WorkoutSessionsDao', () {
    test('should insert and retrieve a workout session', () async {
      // Arrange
      final session = WorkoutSessionCompanion.insert(
        dayType: 'A',
        dateStarted: DateTime.now(),
      );

      // Act
      final id = await database.workoutSessionsDao.insertSession(session);
      final retrievedSession = await database.workoutSessionsDao.getSessionById(id);

      // Assert
      expect(retrievedSession, isNotNull);
      expect(retrievedSession!.dayType, equals('A'));
      expect(retrievedSession.isFinalized, isFalse);
    });

    test('should get last session', () async {
      // Arrange
      final now = DateTime.now();
      await database.workoutSessionsDao.insertSession(WorkoutSessionCompanion.insert(
        dayType: 'A',
        dateStarted: now.subtract(const Duration(days: 2)),
      ));
      await database.workoutSessionsDao.insertSession(WorkoutSessionCompanion.insert(
        dayType: 'B',
        dateStarted: now.subtract(const Duration(days: 1)),
      ));
      await database.workoutSessionsDao.insertSession(WorkoutSessionCompanion.insert(
        dayType: 'C',
        dateStarted: now,
      ));

      // Act
      final lastSession = await database.workoutSessionsDao.getLastSession();

      // Assert
      expect(lastSession, isNotNull);
      expect(lastSession!.dayType, equals('C'));
    });

    test('should get in-progress session', () async {
      // Arrange
      await database.workoutSessionsDao.insertSession(WorkoutSessionCompanion.insert(
        dayType: 'A',
        dateStarted: DateTime.now(),
        isFinalized: const Value(true),
      ));
      await database.workoutSessionsDao.insertSession(WorkoutSessionCompanion.insert(
        dayType: 'B',
        dateStarted: DateTime.now(),
      ));

      // Act
      final inProgress = await database.workoutSessionsDao.getInProgressSession();

      // Assert
      expect(inProgress, isNotNull);
      expect(inProgress!.dayType, equals('B'));
      expect(inProgress.isFinalized, isFalse);
    });

    test('should finalize a session', () async {
      // Arrange
      final id = await database.workoutSessionsDao.insertSession(WorkoutSessionCompanion.insert(
        dayType: 'A',
        dateStarted: DateTime.now(),
      ));

      // Act
      final completedAt = DateTime.now();
      await database.workoutSessionsDao.finalizeSession(id, completedAt);
      final session = await database.workoutSessionsDao.getSessionById(id);

      // Assert
      expect(session!.isFinalized, isTrue);
      expect(session.dateCompleted, isNotNull);
    });

    test('should get sessions by day type', () async {
      // Arrange
      await database.workoutSessionsDao.insertSession(WorkoutSessionCompanion.insert(
        dayType: 'A',
        dateStarted: DateTime.now(),
      ));
      await database.workoutSessionsDao.insertSession(WorkoutSessionCompanion.insert(
        dayType: 'A',
        dateStarted: DateTime.now().subtract(const Duration(days: 1)),
      ));
      await database.workoutSessionsDao.insertSession(WorkoutSessionCompanion.insert(
        dayType: 'B',
        dateStarted: DateTime.now(),
      ));

      // Act
      final dayASessions = await database.workoutSessionsDao.getSessionsByDayType('A');

      // Assert
      expect(dayASessions.length, equals(2));
      expect(dayASessions.every((s) => s.dayType == 'A'), isTrue);
    });
  });

  group('WorkoutSetsDao', () {
    late int sessionId;
    late int squatId;

    setUp(() async {
      // Insert test data
      squatId = await database.liftsDao.insertLift(LiftCompanion.insert(
        name: 'Squat',
        category: AppConstants.liftCategoryLower,
      ));
      sessionId = await database.workoutSessionsDao.insertSession(WorkoutSessionCompanion.insert(
        dayType: 'A',
        dateStarted: DateTime.now(),
      ));
    });

    test('should insert and retrieve workout sets', () async {
      // Arrange
      final set = WorkoutSetCompanion.insert(
        sessionId: sessionId,
        liftId: squatId,
        tier: 'T1',
        setNumber: 1,
        targetReps: 3,
        targetWeight: 225.0,
      );

      // Act
      final id = await database.workoutSetsDao.insertSet(set);
      final sets = await database.workoutSetsDao.getSetsForSession(sessionId);

      // Assert
      expect(sets.length, equals(1));
      expect(sets.first.id, equals(id));
      expect(sets.first.tier, equals('T1'));
    });

    test('should get sets for specific lift in session', () async {
      // Arrange
      final benchId = await database.liftsDao.insertLift(LiftCompanion.insert(
        name: 'Bench Press',
        category: AppConstants.liftCategoryUpper,
      ));

      await database.workoutSetsDao.insertSets([
        WorkoutSetCompanion.insert(
          sessionId: sessionId,
          liftId: squatId,
          tier: 'T1',
          setNumber: 1,
          targetReps: 3,
          targetWeight: 225.0,
        ),
        WorkoutSetCompanion.insert(
          sessionId: sessionId,
          liftId: benchId,
          tier: 'T2',
          setNumber: 1,
          targetReps: 10,
          targetWeight: 185.0,
        ),
      ]);

      // Act
      final squatSets = await database.workoutSetsDao.getSetsForLiftInSession(sessionId, squatId);

      // Assert
      expect(squatSets.length, equals(1));
      expect(squatSets.first.liftId, equals(squatId));
    });

    test('should get sets by tier', () async {
      // Arrange
      await database.workoutSetsDao.insertSets([
        WorkoutSetCompanion.insert(
          sessionId: sessionId,
          liftId: squatId,
          tier: 'T1',
          setNumber: 1,
          targetReps: 3,
          targetWeight: 225.0,
        ),
        WorkoutSetCompanion.insert(
          sessionId: sessionId,
          liftId: squatId,
          tier: 'T1',
          setNumber: 2,
          targetReps: 3,
          targetWeight: 225.0,
        ),
        WorkoutSetCompanion.insert(
          sessionId: sessionId,
          liftId: squatId,
          tier: 'T2',
          setNumber: 1,
          targetReps: 10,
          targetWeight: 185.0,
        ),
      ]);

      // Act
      final t1Sets = await database.workoutSetsDao.getSetsForTierInSession(sessionId, 'T1');

      // Assert
      expect(t1Sets.length, equals(2));
      expect(t1Sets.every((s) => s.tier == 'T1'), isTrue);
    });

    test('should track AMRAP sets', () async {
      // Arrange & Act
      await database.workoutSetsDao.insertSet(WorkoutSetCompanion.insert(
        sessionId: sessionId,
        liftId: squatId,
        tier: 'T1',
        setNumber: 5,
        targetReps: 3,
        targetWeight: 225.0,
        isAmrap: const Value(true),
      ));

      // Assert
      final sets = await database.workoutSetsDao.getSetsForSession(sessionId);
      expect(sets.first.isAmrap, isTrue);
    });

    test('should cascade delete sets when session is deleted', () async {
      // Arrange
      await database.workoutSetsDao.insertSet(WorkoutSetCompanion.insert(
        sessionId: sessionId,
        liftId: squatId,
        tier: 'T1',
        setNumber: 1,
        targetReps: 3,
        targetWeight: 225.0,
      ));

      // Act
      await database.workoutSessionsDao.deleteSession(sessionId);
      final sets = await database.workoutSetsDao.getSetsForSession(sessionId);

      // Assert
      expect(sets.isEmpty, isTrue);
    });
  });

  group('UserPreferencesDao', () {
    test('should initialize default preferences', () async {
      // Act
      await database.userPreferencesDao.initializePreferences();
      final prefs = await database.userPreferencesDao.getPreferences();

      // Assert
      expect(prefs, isNotNull);
      expect(prefs!.unitSystem, equals('imperial'));
      expect(prefs.t1RestSeconds, equals(240));
      expect(prefs.t2RestSeconds, equals(150));
      expect(prefs.t3RestSeconds, equals(75));
      expect(prefs.minimumRestHours, equals(24));
      expect(prefs.hasCompletedOnboarding, isFalse);
    });

    test('should update specific preference fields', () async {
      // Arrange
      await database.userPreferencesDao.initializePreferences();

      // Act
      await database.userPreferencesDao.updatePreferenceFields(
        unitSystem: 'metric',
        hasCompletedOnboarding: true,
      );
      final prefs = await database.userPreferencesDao.getPreferences();

      // Assert
      expect(prefs!.unitSystem, equals('metric'));
      expect(prefs.hasCompletedOnboarding, isTrue);
      // Other fields should remain unchanged
      expect(prefs.t1RestSeconds, equals(240));
    });

    test('should check onboarding completion status', () async {
      // Arrange
      await database.userPreferencesDao.initializePreferences();

      // Assert initial state
      expect(await database.userPreferencesDao.hasCompletedOnboarding(), isFalse);

      // Act
      await database.userPreferencesDao.updatePreferenceFields(hasCompletedOnboarding: true);

      // Assert after update
      expect(await database.userPreferencesDao.hasCompletedOnboarding(), isTrue);
    });
  });

  group('AccessoryExercisesDao', () {
    test('should insert and retrieve accessory exercises', () async {
      // Arrange
      final exercise = AccessoryExerciseCompanion.insert(
        name: 'Lat Pulldown',
        dayType: 'A',
        orderIndex: 0,
      );

      // Act
      await database.accessoryExercisesDao.insertAccessory(exercise);
      final exercises = await database.accessoryExercisesDao.getAccessoriesForDay('A');

      // Assert
      expect(exercises.length, equals(1));
      expect(exercises.first.name, equals('Lat Pulldown'));
    });

    test('should get accessories ordered by orderIndex', () async {
      // Arrange
      await database.accessoryExercisesDao.insertAccessories([
        AccessoryExerciseCompanion.insert(name: 'Exercise 3', dayType: 'A', orderIndex: 2),
        AccessoryExerciseCompanion.insert(name: 'Exercise 1', dayType: 'A', orderIndex: 0),
        AccessoryExerciseCompanion.insert(name: 'Exercise 2', dayType: 'A', orderIndex: 1),
      ]);

      // Act
      final exercises = await database.accessoryExercisesDao.getAccessoriesForDay('A');

      // Assert
      expect(exercises.length, equals(3));
      expect(exercises[0].name, equals('Exercise 1'));
      expect(exercises[1].name, equals('Exercise 2'));
      expect(exercises[2].name, equals('Exercise 3'));
    });

    test('should reorder accessories', () async {
      // Arrange
      final id1 = await database.accessoryExercisesDao.insertAccessory(
        AccessoryExerciseCompanion.insert(name: 'Exercise 1', dayType: 'A', orderIndex: 0),
      );
      final id2 = await database.accessoryExercisesDao.insertAccessory(
        AccessoryExerciseCompanion.insert(name: 'Exercise 2', dayType: 'A', orderIndex: 1),
      );
      final id3 = await database.accessoryExercisesDao.insertAccessory(
        AccessoryExerciseCompanion.insert(name: 'Exercise 3', dayType: 'A', orderIndex: 2),
      );

      // Act - Reverse the order
      await database.accessoryExercisesDao.reorderAccessories('A', [id3, id2, id1]);
      final exercises = await database.accessoryExercisesDao.getAccessoriesForDay('A');

      // Assert
      expect(exercises[0].name, equals('Exercise 3'));
      expect(exercises[1].name, equals('Exercise 2'));
      expect(exercises[2].name, equals('Exercise 1'));
    });

    test('should enforce unique constraint on dayType+orderIndex', () async {
      // Arrange
      await database.accessoryExercisesDao.insertAccessory(
        AccessoryExerciseCompanion.insert(name: 'Exercise 1', dayType: 'A', orderIndex: 0),
      );

      // Act & Assert - Attempt to insert duplicate
      expect(
        () => database.accessoryExercisesDao.insertAccessory(
          AccessoryExerciseCompanion.insert(name: 'Exercise 2', dayType: 'A', orderIndex: 0),
        ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('should delete all accessories for a day', () async {
      // Arrange
      await database.accessoryExercisesDao.insertAccessories([
        AccessoryExerciseCompanion.insert(name: 'Exercise 1', dayType: 'A', orderIndex: 0),
        AccessoryExerciseCompanion.insert(name: 'Exercise 2', dayType: 'A', orderIndex: 1),
        AccessoryExerciseCompanion.insert(name: 'Exercise 3', dayType: 'B', orderIndex: 0),
      ]);

      // Act
      await database.accessoryExercisesDao.deleteAccessoriesForDay('A');
      final dayAExercises = await database.accessoryExercisesDao.getAccessoriesForDay('A');
      final dayBExercises = await database.accessoryExercisesDao.getAccessoriesForDay('B');

      // Assert
      expect(dayAExercises.isEmpty, isTrue);
      expect(dayBExercises.length, equals(1));
    });
  });

  group('Foreign Key Constraints', () {
    test('should cascade delete cycle states when lift is deleted', () async {
      // Arrange
      final liftId = await database.liftsDao.insertLift(LiftCompanion.insert(
        name: 'Squat',
        category: AppConstants.liftCategoryLower,
      ));
      await database.cycleStatesDao.insertCycleState(CycleStateCompanion.insert(
        liftId: liftId,
        currentTier: 'T1',
        currentStage: 1,
        nextTargetWeight: 225.0,
      ));

      // Act
      await database.liftsDao.deleteLift(liftId);
      final states = await database.cycleStatesDao.getCycleStatesForLift(liftId);

      // Assert
      expect(states.isEmpty, isTrue);
    });
  });
}
