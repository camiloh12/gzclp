import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cycle_state_entity.dart';
import '../entities/workout_set_entity.dart';

/// Calculates T3 progression based on GZCLP algorithm
///
/// T3 PROGRESSION RULES:
/// - T3 has only one stage: 3x15+
/// - Weight increases ONLY if the final AMRAP set achieves 25+ reps
/// - If < 25 reps on AMRAP set, weight stays the same
/// - T3 uses small increments: 5 lbs / 2.5 kg
/// - No stage transitions or resets for T3
///
/// CRITICAL: Track currentT3AmrapVolume to monitor progress over time
class CalculateT3Progression implements UseCase<CycleStateEntity, T3ProgressionParams> {
  @override
  Future<Either<Failure, CycleStateEntity>> call(T3ProgressionParams params) async {
    try {
      final currentState = params.currentState;
      final sets = params.completedSets;
      final isMetric = params.isMetric;

      // Validate this is a T3 state
      if (!currentState.isT3) {
        return Left(ValidationFailure('CycleState is not T3'));
      }

      // Find the AMRAP set (last set)
      final amrapSet = _findAmrapSet(sets);
      if (amrapSet == null || !amrapSet.isCompleted) {
        return Left(ValidationFailure('No completed AMRAP set found'));
      }

      final amrapReps = amrapSet.actualReps!;

      // T3 progression threshold: 25+ reps on AMRAP set
      if (amrapReps >= AppConstants.t3AmrapThreshold) {
        // SUCCESS: Increase weight by T3 increment
        final t3Increment = isMetric
            ? AppConstants.t3IncrementKg
            : AppConstants.t3IncrementLbs;

        return Right(currentState.copyWith(
          nextTargetWeight: currentState.nextTargetWeight + t3Increment,
          currentT3AmrapVolume: amrapReps, // Track AMRAP performance
          lastUpdated: DateTime.now(),
        ));
      } else {
        // NOT YET READY: Keep same weight, update AMRAP volume tracking
        return Right(currentState.copyWith(
          // Weight stays the same
          currentT3AmrapVolume: amrapReps, // Track AMRAP performance
          lastUpdated: DateTime.now(),
        ));
      }
    } catch (e) {
      return Left(ValidationFailure('T3 progression calculation failed: $e'));
    }
  }

  /// Find the AMRAP set (should be the last set and marked as AMRAP)
  WorkoutSetEntity? _findAmrapSet(List<WorkoutSetEntity> sets) {
    if (sets.isEmpty) return null;

    // Find the set marked as AMRAP
    final amrapSets = sets.where((s) => s.isAmrap).toList();
    if (amrapSets.isNotEmpty) {
      return amrapSets.last;
    }

    // Fallback: return the last set (T3 always has AMRAP on last set)
    return sets.last;
  }
}

/// Parameters for T3 progression calculation
class T3ProgressionParams {
  final CycleStateEntity currentState;
  final List<WorkoutSetEntity> completedSets;
  final bool isMetric;

  const T3ProgressionParams({
    required this.currentState,
    required this.completedSets,
    required this.isMetric,
  });
}
