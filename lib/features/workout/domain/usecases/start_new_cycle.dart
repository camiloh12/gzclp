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
