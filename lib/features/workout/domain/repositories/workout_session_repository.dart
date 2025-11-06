import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/workout_session_entity.dart';

/// Repository interface for WorkoutSession operations
///
/// Manages workout sessions from creation to finalization.
abstract class WorkoutSessionRepository {
  /// Get all workout sessions, ordered by most recent first
  Future<Either<Failure, List<WorkoutSessionEntity>>> getAllSessions();

  /// Get a single session by ID
  Future<Either<Failure, WorkoutSessionEntity>> getSessionById(int id);

  /// Get the most recent session (finalized or not)
  Future<Either<Failure, WorkoutSessionEntity?>> getLastSession();

  /// Get the most recent finalized session
  Future<Either<Failure, WorkoutSessionEntity?>> getLastFinalizedSession();

  /// Get any in-progress (non-finalized) session
  Future<Either<Failure, WorkoutSessionEntity?>> getInProgressSession();

  /// Get sessions by day type
  Future<Either<Failure, List<WorkoutSessionEntity>>> getSessionsByDayType(
    String dayType,
  );

  /// Get finalized sessions
  Future<Either<Failure, List<WorkoutSessionEntity>>> getFinalizedSessions();

  /// Create a new workout session
  Future<Either<Failure, int>> createSession(WorkoutSessionEntity session);

  /// Update a workout session
  Future<Either<Failure, void>> updateSession(WorkoutSessionEntity session);

  /// Finalize a session (mark as completed and apply progression logic)
  /// This should be called AFTER progression logic has been applied
  Future<Either<Failure, void>> finalizeSession(int sessionId, DateTime completedAt);

  /// Delete a session
  Future<Either<Failure, void>> deleteSession(int id);
}
