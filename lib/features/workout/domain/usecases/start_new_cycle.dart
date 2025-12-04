import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/cycle_repository.dart';
import '../repositories/cycle_state_repository.dart';
import '../repositories/lift_repository.dart';

/// Starts a new training cycle with 90% deload from previous cycle
///
/// This use case:
/// 1. Completes the current active cycle
/// 2. Gets the final weights from the previous cycle
/// 3. Applies a 90% deload to all weights
/// 4. Creates a new cycle
/// 5. Creates new CycleStates with deloaded weights and Stage 1
///
/// This allows users to start fresh with reduced weights after completing
/// a 12-week cycle, promoting sustainable long-term progression.
class StartNewCycle implements UseCase<int, NoParams> {
  final CycleRepository cycleRepository;
  final CycleStateRepository cycleStateRepository;
  final LiftRepository liftRepository;

  StartNewCycle({
    required this.cycleRepository,
    required this.cycleStateRepository,
    required this.liftRepository,
  });

  @override
  Future<Either<Failure, int>> call(NoParams params) async {
    try {
      // 1. Get the current active cycle
      final activeCycleResult = await cycleRepository.getActiveCycle();
      if (activeCycleResult.isLeft()) {
        return Left((activeCycleResult as Left).value);
      }
      final currentCycle = (activeCycleResult as Right).value;

      // 2. Get all cycle states from the current cycle
      final cycleStatesResult = await cycleStateRepository.getCycleStatesForCycle(currentCycle.id);
      if (cycleStatesResult.isLeft()) {
        return Left((cycleStatesResult as Left).value);
      }
      final currentCycleStates = (cycleStatesResult as Right).value;

      if (currentCycleStates.isEmpty) {
        return Left(ValidationFailure('No cycle states found for current cycle'));
      }

      // 3. Complete the current cycle
      final now = DateTime.now();
      final completeCycleResult = await cycleRepository.completeCycle(currentCycle.id, now);
      if (completeCycleResult.isLeft()) {
        return Left((completeCycleResult as Left).value);
      }

      // 4. Get the maximum cycle number and create a new cycle
      final maxCycleNumberResult = await cycleRepository.getMaxCycleNumber();
      if (maxCycleNumberResult.isLeft()) {
        return Left((maxCycleNumberResult as Left).value);
      }
      final maxCycleNumber = (maxCycleNumberResult as Right).value;
      final newCycleNumber = maxCycleNumber + 1;

      final newCycleIdResult = await cycleRepository.createCycle(newCycleNumber, now);
      if (newCycleIdResult.isLeft()) {
        return Left((newCycleIdResult as Left).value);
      }
      final newCycleId = (newCycleIdResult as Right).value;

      // 5. Get all lifts to ensure we create states for all lift/tier combinations
      final liftsResult = await liftRepository.getAllLifts();
      if (liftsResult.isLeft()) {
        return Left((liftsResult as Left).value);
      }
      final lifts = (liftsResult as Right).value;

      // 6. Create new CycleStates with 90% deload and Stage 1
      for (final lift in lifts) {
        for (final tier in ['T1', 'T2', 'T3']) {
          // Find the corresponding state from the previous cycle
          final oldState = currentCycleStates.firstWhere(
            (state) => state.liftId == lift.id && state.currentTier == tier,
            orElse: () => throw Exception('Missing state for lift ${lift.name} tier $tier'),
          );

          // Apply 90% deload to the weight
          final deloadedWeight = oldState.nextTargetWeight * 0.9;

          // Round to nearest practical weight (2.5 for upper, 5 for lower)
          final roundedWeight = _roundToNearestWeight(deloadedWeight, lift.category);

          // Create new cycle state with deloaded weight and Stage 1
          final createResult = await cycleStateRepository.createCycleStateFromParams(
            cycleId: newCycleId,
            liftId: lift.id,
            tier: tier,
            stage: 1, // Reset to Stage 1
            nextTargetWeight: roundedWeight,
            lastStage1SuccessWeight: null, // Reset T2 anchor
            currentT3AmrapVolume: 0, // Reset T3 volume
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

  /// Round weight to nearest practical increment based on lift category
  double _roundToNearestWeight(double weight, String category) {
    final increment = category == 'lower' ? 5.0 : 2.5;
    return (weight / increment).round() * increment;
  }
}
