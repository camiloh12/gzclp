import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cycle_state_entity.dart';
import '../entities/lift_entity.dart';
import '../entities/workout_set_entity.dart';

/// Calculates T1 progression based on GZCLP algorithm
///
/// T1 PROGRESSION RULES:
/// - Stage 1 (5x3+): If AMRAP set >= 3 reps → add weight, otherwise → Stage 2
/// - Stage 2 (6x2+): If AMRAP set >= 2 reps → add weight, otherwise → Stage 3
/// - Stage 3 (10x1+): If AMRAP set >= 1 rep → add weight, otherwise → RESET
///
/// RESET LOGIC:
/// - Reset to Stage 1 at 85% of the weight where Stage 3 was successfully completed
/// - If no successful Stage 3 weight recorded, use 85% of current weight
class CalculateT1Progression implements UseCase<CycleStateEntity, T1ProgressionParams> {
  @override
  Future<Either<Failure, CycleStateEntity>> call(T1ProgressionParams params) async {
    try {
      final currentState = params.currentState;
      final sets = params.completedSets;
      final lift = params.lift;
      final isMetric = params.isMetric;

      // Validate this is a T1 state
      if (!currentState.isT1) {
        return Left(ValidationFailure('CycleState is not T1'));
      }

      // Find the AMRAP set (last set in the sequence)
      final amrapSet = _findAmrapSet(sets);
      if (amrapSet == null || !amrapSet.isCompleted) {
        return Left(ValidationFailure('No completed AMRAP set found'));
      }

      // Get weight increment for this lift
      final weightIncrement = lift.getWeightIncrement(isMetric: isMetric);

      // Determine success based on current stage
      final requiredReps = currentState.getRequiredReps();
      final actualReps = amrapSet.actualReps!;
      final isSuccessful = actualReps >= requiredReps;

      // Calculate new state based on success/failure
      if (isSuccessful) {
        // SUCCESS: Add weight, stay at current stage
        return Right(currentState.copyWith(
          nextTargetWeight: currentState.nextTargetWeight + weightIncrement,
          lastUpdated: DateTime.now(),
        ));
      } else {
        // FAILURE: Keep weight, advance stage or reset
        if (currentState.isAtFinalStage) {
          // Stage 3 failure → RESET
          return Right(_calculateT1Reset(currentState, weightIncrement));
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
      return Left(ValidationFailure('T1 progression calculation failed: $e'));
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

    // Fallback: return the last set
    return sets.last;
  }

  /// Calculate T1 reset
  /// Reset to Stage 1 at 85% of current weight
  CycleStateEntity _calculateT1Reset(CycleStateEntity currentState, double weightIncrement) {
    final resetWeight = currentState.nextTargetWeight * AppConstants.t1ResetPercentage;

    // Round to nearest weight increment to keep weights practical
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

/// Parameters for T1 progression calculation
class T1ProgressionParams {
  final CycleStateEntity currentState;
  final List<WorkoutSetEntity> completedSets;
  final LiftEntity lift;
  final bool isMetric;

  const T1ProgressionParams({
    required this.currentState,
    required this.completedSets,
    required this.lift,
    required this.isMetric,
  });
}
