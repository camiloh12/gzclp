import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/lift_entity.dart';
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
class GenerateWorkoutForDay implements UseCase<WorkoutPlan, WorkoutDayParams> {
  final LiftRepository liftRepository;
  final CycleStateRepository cycleStateRepository;

  GenerateWorkoutForDay({
    required this.liftRepository,
    required this.cycleStateRepository,
  });

  @override
  Future<Either<Failure, WorkoutPlan>> call(WorkoutDayParams params) async {
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

      // Generate workout plan
      final workoutPlan = WorkoutPlan(
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

/// Represents a complete workout plan for a day
class WorkoutPlan {
  final String dayType;
  final LiftPlan t1Exercise;
  final LiftPlan t2Exercise;

  const WorkoutPlan({
    required this.dayType,
    required this.t1Exercise,
    required this.t2Exercise,
  });
}

/// Represents the plan for a single lift in a workout
class LiftPlan {
  final LiftEntity lift;
  final String tier;
  final int stage;
  final double targetWeight;
  final int sets;
  final int reps;

  const LiftPlan({
    required this.lift,
    required this.tier,
    required this.stage,
    required this.targetWeight,
    required this.sets,
    required this.reps,
  });

  /// Get description of the set/rep scheme (e.g., "5x3+", "3x10")
  String get setRepScheme {
    if (tier == 'T1' || tier == 'T2') {
      return '${sets}x$reps'; // e.g., "5x3", "3x10"
    } else {
      return '${sets}x$reps+'; // T3 always has + for AMRAP
    }
  }
}
