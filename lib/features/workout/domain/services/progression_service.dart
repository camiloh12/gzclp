import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/cycle_state_entity.dart';
import '../entities/lift_entity.dart';
import '../entities/workout_set_entity.dart';
import '../usecases/calculate_t1_progression.dart';
import '../usecases/calculate_t2_progression.dart';
import '../usecases/calculate_t3_progression.dart';

/// Service to handle progression calculation logic
class ProgressionService {
  final CalculateT1Progression calculateT1Progression;
  final CalculateT2Progression calculateT2Progression;
  final CalculateT3Progression calculateT3Progression;

  ProgressionService({
    required this.calculateT1Progression,
    required this.calculateT2Progression,
    required this.calculateT3Progression,
  });

  Future<Either<Failure, CycleStateEntity>> calculateProgression({
    required CycleStateEntity currentState,
    required List<WorkoutSetEntity> completedSets,
    required LiftEntity lift,
    required String tier,
    required bool isMetric,
  }) async {
    if (tier == 'T1') {
      return calculateT1Progression(T1ProgressionParams(
        currentState: currentState,
        completedSets: completedSets,
        lift: lift,
        isMetric: isMetric,
      ));
    } else if (tier == 'T2') {
      return calculateT2Progression(T2ProgressionParams(
        currentState: currentState,
        completedSets: completedSets,
        lift: lift,
        isMetric: isMetric,
      ));
    } else if (tier == 'T3') {
      return calculateT3Progression(T3ProgressionParams(
        currentState: currentState,
        completedSets: completedSets,
        isMetric: isMetric,
      ));
    } else {
      return Left(ValidationFailure('Unknown tier: $tier'));
    }
  }
}
