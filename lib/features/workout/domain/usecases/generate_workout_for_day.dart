import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/accessory_exercise_entity.dart';
import '../entities/lift_entity.dart';
import '../entities/workout_plan_entity.dart';
import '../repositories/accessory_exercise_repository.dart';
import '../repositories/cycle_state_repository.dart';
import '../repositories/lift_repository.dart';

/// Generates a workout plan for a specific day type (A, B, C, or D)
///
/// GZCLP 4-DAY ROTATION:
/// - Day A: Squat (T1), Overhead Press (T2), + T3 accessories
/// - Day B: Bench Press (T1), Deadlift (T2), + T3 accessories
/// - Day C: Squat (T2), Bench Press (T1), + T3 accessories
/// - Day D: Deadlift (T1), Overhead Press (T2), + T3 accessories
///
/// Returns a WorkoutPlan containing the lifts and their programmed weights/sets/reps
class GenerateWorkoutForDay implements UseCase<WorkoutPlanEntity, WorkoutDayParams> {
  final LiftRepository liftRepository;
  final CycleStateRepository cycleStateRepository;
  final AccessoryExerciseRepository accessoryExerciseRepository;

  GenerateWorkoutForDay({
    required this.liftRepository,
    required this.cycleStateRepository,
    required this.accessoryExerciseRepository,
  });

  @override
  Future<Either<Failure, WorkoutPlanEntity>> call(WorkoutDayParams params) async {
    try {
      final dayType = params.dayType.toUpperCase();

      // Validate day type
      if (!AppConstants.workoutDays.contains(dayType)) {
        return Left(ValidationFailure('Invalid day type: $dayType'));
      }

      // Get lift assignments for this day
      final assignment = _getDayAssignment(dayType);

      // Get lift entities
      final t1LiftResult = await liftRepository.getLiftByName(assignment.t1Lift);
      if (t1LiftResult.isLeft()) {
        return Left((t1LiftResult as Left).value);
      }
      final t1Lift = (t1LiftResult as Right).value;

      final t2LiftResult = await liftRepository.getLiftByName(assignment.t2Lift);
      if (t2LiftResult.isLeft()) {
        return Left((t2LiftResult as Left).value);
      }
      final t2Lift = (t2LiftResult as Right).value;

      // Get cycle states for these lifts
      final t1StateResult = await cycleStateRepository.getCycleStateByLiftAndTier(t1Lift.id, 'T1');
      if (t1StateResult.isLeft()) {
        return Left((t1StateResult as Left).value);
      }
      final t1State = (t1StateResult as Right).value;

      final t2StateResult = await cycleStateRepository.getCycleStateByLiftAndTier(t2Lift.id, 'T2');
      if (t2StateResult.isLeft()) {
        return Left((t2StateResult as Left).value);
      }
      final t2State = (t2StateResult as Right).value;

      // Get T3 accessory exercises for this day
      final t3ExercisesResult = await accessoryExerciseRepository.getAccessoriesForDay(dayType);
      if (t3ExercisesResult.isLeft()) {
        // If no T3 exercises found, just use empty list (not an error)
        print('[GenerateWorkoutForDay] No T3 exercises found for day $dayType');
      }
      final t3Exercises = t3ExercisesResult.fold(
        (_) => <AccessoryExerciseEntity>[],
        (exercises) => exercises,
      );

      // Get cycle states for T3 exercises (if any)
      final List<T3Plan> t3Plans = [];
      for (final t3Exercise in t3Exercises) {
        // For T3 exercises, we need a "fake" lift ID or we store T3 weights separately
        // For MVP, let's use a simple approach: T3 exercises use T1 lift cycle states
        // We'll get the T3 tier cycle state for the T1 lift of this day
        final t3StateResult = await cycleStateRepository.getCycleStateByLiftAndTier(t1Lift.id, 'T3');

        if (t3StateResult.isRight()) {
          final t3State = (t3StateResult as Right).value;
          t3Plans.add(T3Plan(
            exercise: t3Exercise,
            targetWeight: t3State.nextTargetWeight,
            sets: 3, // T3 is always 3 sets
            reps: 15, // T3 is always 15+ reps
          ));
        }
      }

      // Generate workout plan
      final workoutPlan = WorkoutPlanEntity(
        dayType: dayType,
        t1Exercise: LiftPlan(
          lift: t1Lift,
          tier: 'T1',
          stage: t1State.currentStage,
          targetWeight: t1State.nextTargetWeight,
          sets: t1State.getRequiredSets(),
          reps: t1State.getRequiredReps(),
        ),
        t2Exercise: LiftPlan(
          lift: t2Lift,
          tier: 'T2',
          stage: t2State.currentStage,
          targetWeight: t2State.nextTargetWeight,
          sets: t2State.getRequiredSets(),
          reps: t2State.getRequiredReps(),
        ),
        t3Exercises: t3Plans,
      );

      return Right(workoutPlan);
    } catch (e) {
      return Left(ValidationFailure('Workout generation failed: $e'));
    }
  }

  /// Get lift assignments for a specific day
  _DayAssignment _getDayAssignment(String dayType) {
    switch (dayType) {
      case 'A':
        return _DayAssignment(
          t1Lift: AppConstants.liftSquat,
          t2Lift: AppConstants.liftOhp,
        );
      case 'B':
        return _DayAssignment(
          t1Lift: AppConstants.liftBench,
          t2Lift: AppConstants.liftDeadlift,
        );
      case 'C':
        return _DayAssignment(
          t1Lift: AppConstants.liftBench,
          t2Lift: AppConstants.liftSquat,
        );
      case 'D':
        return _DayAssignment(
          t1Lift: AppConstants.liftDeadlift,
          t2Lift: AppConstants.liftOhp,
        );
      default:
        throw ArgumentError('Invalid day type: $dayType');
    }
  }
}

/// Internal class for day lift assignments
class _DayAssignment {
  final String t1Lift;
  final String t2Lift;

  _DayAssignment({required this.t1Lift, required this.t2Lift});
}

/// Parameters for workout generation
class WorkoutDayParams {
  final String dayType;

  const WorkoutDayParams({required this.dayType});
}


