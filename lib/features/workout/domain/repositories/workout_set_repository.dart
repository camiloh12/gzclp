import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/workout_set_entity.dart';

/// Repository interface for WorkoutSet operations
///
/// Manages individual sets within workout sessions.
abstract class WorkoutSetRepository {
  /// Get all sets for a specific session
  Future<Either<Failure, List<WorkoutSetEntity>>> getSetsForSession(int sessionId);

  /// Get sets for a specific lift in a session
  Future<Either<Failure, List<WorkoutSetEntity>>> getSetsForLiftInSession(
    int sessionId,
    int liftId,
  );

  /// Get sets for a specific tier in a session
  Future<Either<Failure, List<WorkoutSetEntity>>> getSetsForTierInSession(
    int sessionId,
    String tier,
  );

  /// Create a new workout set
  Future<Either<Failure, int>> createSet(WorkoutSetEntity set);

  /// Create multiple sets (batch operation)
  Future<Either<Failure, void>> createSets(List<WorkoutSetEntity> sets);

  /// Update a workout set
  Future<Either<Failure, void>> updateSet(WorkoutSetEntity set);

  /// Delete a set
  Future<Either<Failure, void>> deleteSet(int id);

  /// Delete all sets for a session
  Future<Either<Failure, void>> deleteSetsForSession(int sessionId);
}
