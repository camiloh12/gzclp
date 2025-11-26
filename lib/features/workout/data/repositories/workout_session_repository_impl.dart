import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart' as drift;

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/workout_session_entity.dart';
import '../../domain/repositories/workout_session_repository.dart';
import '../datasources/local/app_database.dart';

/// Concrete implementation of WorkoutSessionRepository
class WorkoutSessionRepositoryImpl implements WorkoutSessionRepository {
  final AppDatabase database;

  WorkoutSessionRepositoryImpl(this.database);

  @override
  Future<Either<Failure, List<WorkoutSessionEntity>>> getAllSessions() async {
    try {
      final sessions = await database.workoutSessionsDao.getAllSessions();
      return Right(sessions.map(_sessionToEntity).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkoutSessionEntity>> getSessionById(int id) async {
    try {
      final session = await database.workoutSessionsDao.getSessionById(id);
      if (session == null) {
        return Left(NotFoundFailure('WorkoutSession with ID $id not found'));
      }
      return Right(_sessionToEntity(session));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkoutSessionEntity?>> getLastSession() async {
    try {
      final session = await database.workoutSessionsDao.getLastSession();
      return Right(session != null ? _sessionToEntity(session) : null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkoutSessionEntity?>> getLastFinalizedSession() async {
    try {
      final session = await database.workoutSessionsDao.getLastFinalizedSession();
      return Right(session != null ? _sessionToEntity(session) : null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkoutSessionEntity?>> getInProgressSession() async {
    try {
      final session = await database.workoutSessionsDao.getInProgressSession();
      return Right(session != null ? _sessionToEntity(session) : null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WorkoutSessionEntity>>> getSessionsByDayType(
    String dayType,
  ) async {
    try {
      final sessions = await database.workoutSessionsDao.getSessionsByDayType(dayType);
      return Right(sessions.map(_sessionToEntity).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WorkoutSessionEntity>>> getFinalizedSessions() async {
    try {
      final sessions = await database.workoutSessionsDao.getFinalizedSessions();
      return Right(sessions.map(_sessionToEntity).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> createSession(WorkoutSessionEntity session) async {
    try {
      final companion = WorkoutSessionCompanion.insert(
        cycleId: session.cycleId,
        dayType: session.dayType,
        rotationNumber: session.rotationNumber,
        rotationPosition: session.rotationPosition,
        dateStarted: session.dateStarted,
        dateCompleted: drift.Value(session.dateCompleted),
        isFinalized: drift.Value(session.isFinalized),
        sessionNotes: drift.Value(session.sessionNotes),
      );
      final id = await database.workoutSessionsDao.insertSession(companion);
      return Right(id);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateSession(WorkoutSessionEntity session) async {
    try {
      final dbSession = _entityToSession(session);
      await database.workoutSessionsDao.updateSession(dbSession);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> finalizeSession(int sessionId, DateTime completedAt) async {
    try {
      await database.workoutSessionsDao.finalizeSession(sessionId, completedAt);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSession(int id) async {
    try {
      await database.workoutSessionsDao.deleteSession(id);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  /// Convert database WorkoutSession to domain WorkoutSessionEntity
  WorkoutSessionEntity _sessionToEntity(WorkoutSession session) {
    return WorkoutSessionEntity(
      id: session.id,
      cycleId: session.cycleId,
      dayType: session.dayType,
      rotationNumber: session.rotationNumber,
      rotationPosition: session.rotationPosition,
      dateStarted: session.dateStarted,
      dateCompleted: session.dateCompleted,
      isFinalized: session.isFinalized,
      sessionNotes: session.sessionNotes,
    );
  }

  /// Convert domain WorkoutSessionEntity to database WorkoutSession
  WorkoutSession _entityToSession(WorkoutSessionEntity entity) {
    return WorkoutSession(
      id: entity.id,
      cycleId: entity.cycleId,
      dayType: entity.dayType,
      rotationNumber: entity.rotationNumber,
      rotationPosition: entity.rotationPosition,
      dateStarted: entity.dateStarted,
      dateCompleted: entity.dateCompleted,
      isFinalized: entity.isFinalized,
      sessionNotes: entity.sessionNotes,
    );
  }
}
