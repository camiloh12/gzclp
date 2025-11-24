import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cycle_state_entity.dart';
import '../entities/workout_set_entity.dart';
import '../repositories/cycle_state_repository.dart';
import '../repositories/lift_repository.dart';
import '../repositories/workout_session_repository.dart';
import '../repositories/workout_set_repository.dart';
import '../services/progression_service.dart';

/// Finalizes a workout session by applying progression logic to all lifts
///
/// CRITICAL USE CASE - This orchestrates the entire progression algorithm:
/// 1. Get all sets for the session
/// 2. Group sets by lift and tier
/// 3. Get current cycle states for each lift/tier
/// 4. Apply appropriate progression logic (T1, T2, or T3) via ProgressionService
/// 5. Update all cycle states atomically in a transaction
/// 6. Mark session as finalized
///
/// IMPORTANT: This must be called exactly once per session to prevent duplicate progression updates.
class FinalizeWorkoutSession implements UseCase<void, FinalizeSessionParams> {
  final WorkoutSessionRepository sessionRepository;
  final WorkoutSetRepository setRepository;
  final CycleStateRepository cycleStateRepository;
  final LiftRepository liftRepository;
  final ProgressionService progressionService;

  FinalizeWorkoutSession({
    required this.sessionRepository,
    required this.setRepository,
    required this.cycleStateRepository,
    required this.liftRepository,
    required this.progressionService,
  });

  @override
  Future<Either<Failure, void>> call(FinalizeSessionParams params) async {
    try {
      final sessionId = params.sessionId;
      final isMetric = params.isMetric;
      final completedAt = params.completedAt ?? DateTime.now();

      // 1. Get the session and validate it's not already finalized
      final sessionResult = await sessionRepository.getSessionById(sessionId);
      if (sessionResult.isLeft()) {
        return Left((sessionResult as Left).value);
      }
      final session = (sessionResult as Right).value;

      if (session.isFinalized) {
        return Left(ValidationFailure('Session is already finalized'));
      }

      // 2. Get all sets for this session
      final setsResult = await setRepository.getSetsForSession(sessionId);
      if (setsResult.isLeft()) {
        return Left((setsResult as Left).value);
      }
      final allSets = (setsResult as Right).value;

      if (allSets.isEmpty) {
        return Left(ValidationFailure('Session has no sets to finalize'));
      }

      // 3. Group sets by lift and tier
      final liftTierGroups = _groupSetsByLiftAndTier(allSets);

      // 4. Calculate progression for each lift/tier combination
      final updatedStates = <CycleStateEntity>[];

      for (final entry in liftTierGroups.entries) {
        final liftId = entry.key.$1;
        final tier = entry.key.$2;
        final sets = entry.value;

        // Get current cycle state for this lift/tier
        final stateResult = await cycleStateRepository.getCycleStateByLiftAndTier(liftId, tier);
        if (stateResult.isLeft()) {
          // If no cycle state found, skip this lift (shouldn't happen in normal flow)
          continue;
        }
        final currentState = (stateResult as Right).value;

        // Get lift entity
        final liftResult = await liftRepository.getLiftById(liftId);
        if (liftResult.isLeft()) {
          continue;
        }
        final lift = (liftResult as Right).value;

        // Apply progression logic via service
        final progressionResult = await progressionService.calculateProgression(
          currentState: currentState,
          completedSets: sets,
          lift: lift,
          tier: tier,
          isMetric: isMetric,
        );

        // If progression calculation succeeded, add to update list
        if (progressionResult.isRight()) {
          updatedStates.add((progressionResult as Right).value);
        }
      }

      // 5. Update all cycle states atomically in a transaction
      if (updatedStates.isNotEmpty) {
        final updateResult = await cycleStateRepository.updateCycleStatesInTransaction(updatedStates);
        if (updateResult.isLeft()) {
          return Left((updateResult as Left).value);
        }
      }

      // 6. Mark session as finalized
      final finalizeResult = await sessionRepository.finalizeSession(sessionId, completedAt);
      if (finalizeResult.isLeft()) {
        return Left((finalizeResult as Left).value);
      }

      return const Right(null);
    } catch (e) {
      return Left(ValidationFailure('Session finalization failed: $e'));
    }
  }

  /// Group sets by (liftId, tier) for progression calculations
  Map<(int, String), List<WorkoutSetEntity>> _groupSetsByLiftAndTier(List<WorkoutSetEntity> sets) {
    final groups = <(int, String), List<WorkoutSetEntity>>{};

    for (final set in sets) {
      final key = (set.liftId, set.tier);
      groups.putIfAbsent(key, () => []).add(set);
    }

    // Sort sets within each group by set number
    for (final sets in groups.values) {
      sets.sort((a, b) => a.setNumber.compareTo(b.setNumber));
    }

    return groups;
  }
}

/// Parameters for session finalization
class FinalizeSessionParams {
  final int sessionId;
  final bool isMetric;
  final DateTime? completedAt;

  const FinalizeSessionParams({
    required this.sessionId,
    required this.isMetric,
    this.completedAt,
  });
}
