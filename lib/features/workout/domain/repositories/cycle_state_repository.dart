import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/cycle_state_entity.dart';

/// Repository interface for CycleState operations
///
/// CRITICAL REPOSITORY - Manages progression state for all lifts.
/// This is the heart of the GZCLP progression algorithm.
abstract class CycleStateRepository {
  /// Get all cycle states
  Future<Either<Failure, List<CycleStateEntity>>> getAllCycleStates();

  /// Get cycle state by ID
  Future<Either<Failure, CycleStateEntity>> getCycleStateById(int id);

  /// Get cycle state for a specific lift and tier
  /// This is the most commonly used query for progression logic
  Future<Either<Failure, CycleStateEntity>> getCycleStateByLiftAndTier(
    int liftId,
    String tier,
  );

  /// Get all cycle states for a specific lift
  Future<Either<Failure, List<CycleStateEntity>>> getCycleStatesForLift(int liftId);

  /// Get all cycle states for a specific cycle
  Future<Either<Failure, List<CycleStateEntity>>> getCycleStatesForCycle(int cycleId);

  /// Create a new cycle state from entity
  Future<Either<Failure, int>> createCycleState(CycleStateEntity state);

  /// Create a new cycle state with individual parameters (convenience method)
  Future<Either<Failure, int>> createCycleStateFromParams({
    required int cycleId,
    required int liftId,
    required String tier,
    required int stage,
    required double nextTargetWeight,
    double? lastStage1SuccessWeight,
    int currentT3AmrapVolume = 0,
  });

  /// Update an existing cycle state
  Future<Either<Failure, void>> updateCycleState(CycleStateEntity state);

  /// Update multiple cycle states atomically
  /// CRITICAL: Used during session finalization to update all affected lifts
  Future<Either<Failure, void>> updateCycleStatesInTransaction(
    List<CycleStateEntity> states,
  );

  /// Initialize cycle states for a lift at all tiers (T1, T2, T3)
  /// Used during onboarding when setting up initial weights
  Future<Either<Failure, void>> initializeCycleStatesForLift({
    required int liftId,
    required double t1StartWeight,
    required double t2StartWeight,
    required double t3StartWeight,
  });
}
