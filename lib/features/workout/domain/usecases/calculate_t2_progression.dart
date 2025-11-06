import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cycle_state_entity.dart';
import '../entities/lift_entity.dart';
import '../entities/workout_set_entity.dart';

/// Calculates T2 progression based on GZCLP algorithm
///
/// T2 PROGRESSION RULES:
/// - Stage 1 (3x10): If all sets >= 10 reps → add weight, otherwise → Stage 2
/// - Stage 2 (3x8): If all sets >= 8 reps → add weight, otherwise → Stage 3
/// - Stage 3 (3x6): If all sets >= 6 reps → add weight, otherwise → RESET
///
/// CRITICAL RESET LOGIC:
/// - Reset to Stage 1 at: last_stage1_success_weight + 15-20 lbs / 7.5-10 kg
/// - The last_stage1_success_weight MUST be updated on every successful Stage 1 completion
/// - This historical anchor is ESSENTIAL for proper T2 reset calculations
class CalculateT2Progression implements UseCase<CycleStateEntity, T2ProgressionParams> {
  @override
  Future<Either<Failure, CycleStateEntity>> call(T2ProgressionParams params) async {
    try {
      final currentState = params.currentState;
      final sets = params.completedSets;
      final lift = params.lift;
      final isMetric = params.isMetric;

      // Validate this is a T2 state
      if (!currentState.isT2) {
        return Left(ValidationFailure('CycleState is not T2'));
      }

      // Validate all sets are completed
      if (!_allSetsCompleted(sets)) {
        return Left(ValidationFailure('Not all sets are completed'));
      }

      // Get weight increment for this lift
      final weightIncrement = lift.getWeightIncrement(isMetric: isMetric);

      // Determine success: ALL sets must meet required reps
      final requiredReps = currentState.getRequiredReps();
      final isSuccessful = _allSetsMetTarget(sets, requiredReps);

      // Calculate new state based on success/failure
      if (isSuccessful) {
        // SUCCESS: Add weight, stay at current stage
        final newWeight = currentState.nextTargetWeight + weightIncrement;

        // CRITICAL: If this was a successful Stage 1 completion, update last_stage1_success_weight
        if (currentState.isStage1) {
          return Right(currentState.copyWith(
            nextTargetWeight: newWeight,
            lastStage1SuccessWeight: currentState.nextTargetWeight, // Record current weight as last successful Stage 1 weight
            lastUpdated: DateTime.now(),
          ));
        } else {
          return Right(currentState.copyWith(
            nextTargetWeight: newWeight,
            lastUpdated: DateTime.now(),
          ));
        }
      } else {
        // FAILURE: Keep weight, advance stage or reset
        if (currentState.isAtFinalStage) {
          // Stage 3 failure → RESET
          return Right(_calculateT2Reset(currentState, weightIncrement, isMetric));
        } else {
          // Stage 1 or 2 failure → Advance to next stage
          return Right(currentState.copyWith(
            currentStage: currentState.currentStage + 1,
            // Weight stays the same
            lastUpdated: DateTime.now(),
          ));
        }
      }
    } catch (e) {
      return Left(ValidationFailure('T2 progression calculation failed: $e'));
    }
  }

  /// Check if all sets are completed (have actualReps logged)
  bool _allSetsCompleted(List<WorkoutSetEntity> sets) {
    return sets.every((set) => set.isCompleted);
  }

  /// Check if all sets met or exceeded the target reps
  bool _allSetsMetTarget(List<WorkoutSetEntity> sets, int requiredReps) {
    return sets.every((set) => set.actualReps! >= requiredReps);
  }

  /// Calculate T2 reset
  /// CRITICAL: Uses last_stage1_success_weight as anchor point
  CycleStateEntity _calculateT2Reset(
    CycleStateEntity currentState,
    double weightIncrement,
    bool isMetric,
  ) {
    // Get the T2 reset increment (15-20 lbs / 7.5-10 kg)
    final resetIncrement = isMetric
        ? AppConstants.t2ResetIncrementKg
        : AppConstants.t2ResetIncrementLbs;

    // Calculate reset weight based on last successful Stage 1 weight
    final double resetWeight;
    if (currentState.lastStage1SuccessWeight != null) {
      resetWeight = currentState.lastStage1SuccessWeight! + resetIncrement;
    } else {
      // Fallback: If no Stage 1 weight recorded (shouldn't happen in normal flow),
      // use a conservative estimate
      resetWeight = currentState.nextTargetWeight * 0.85;
    }

    // Round to nearest weight increment for practical loading
    final roundedWeight = _roundToIncrement(resetWeight, weightIncrement);

    return currentState.copyWith(
      currentStage: 1, // Reset to Stage 1
      nextTargetWeight: roundedWeight,
      lastUpdated: DateTime.now(),
    );
  }

  /// Round weight to nearest increment for practical loading
  double _roundToIncrement(double weight, double increment) {
    return (weight / increment).round() * increment;
  }
}

/// Parameters for T2 progression calculation
class T2ProgressionParams {
  final CycleStateEntity currentState;
  final List<WorkoutSetEntity> completedSets;
  final LiftEntity lift;
  final bool isMetric;

  const T2ProgressionParams({
    required this.currentState,
    required this.completedSets,
    required this.lift,
    required this.isMetric,
  });
}
