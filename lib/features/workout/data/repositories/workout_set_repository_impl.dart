import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart' as drift;

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/workout_set_entity.dart';
import '../../domain/repositories/workout_set_repository.dart';
import '../datasources/local/app_database.dart';

/// Concrete implementation of WorkoutSetRepository
class WorkoutSetRepositoryImpl implements WorkoutSetRepository {
  final AppDatabase database;

  WorkoutSetRepositoryImpl(this.database);

  @override
  Future<Either<Failure, List<WorkoutSetEntity>>> getSetsForSession(int sessionId) async {
    try {
      final sets = await database.workoutSetsDao.getSetsForSession(sessionId);
      return Right(sets.map(_setToEntity).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WorkoutSetEntity>>> getSetsForLiftInSession(
    int sessionId,
    int liftId,
  ) async {
    try {
      final sets = await database.workoutSetsDao.getSetsForLiftInSession(sessionId, liftId);
      return Right(sets.map(_setToEntity).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WorkoutSetEntity>>> getSetsForTierInSession(
    int sessionId,
    String tier,
  ) async {
    try {
      final sets = await database.workoutSetsDao.getSetsForTierInSession(sessionId, tier);
      return Right(sets.map(_setToEntity).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> createSet(WorkoutSetEntity set) async {
    try {
      final companion = _entityToSetCompanion(set);
      final id = await database.workoutSetsDao.insertSet(companion);
      return Right(id);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createSets(List<WorkoutSetEntity> sets) async {
    try {
      final companions = sets.map(_entityToSetCompanion).toList();
      await database.workoutSetsDao.insertSets(companions);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateSet(WorkoutSetEntity set) async {
    try {
      final dbSet = _entityToSet(set);
      await database.workoutSetsDao.updateSet(dbSet);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSet(int id) async {
    try {
      await database.workoutSetsDao.deleteSet(id);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSetsForSession(int sessionId) async {
    try {
      await database.workoutSetsDao.deleteSetsForSession(sessionId);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  /// Convert database WorkoutSet to domain WorkoutSetEntity
  WorkoutSetEntity _setToEntity(WorkoutSet set) {
    return WorkoutSetEntity(
      id: set.id,
      sessionId: set.sessionId,
      liftId: set.liftId,
      tier: set.tier,
      setNumber: set.setNumber,
      targetReps: set.targetReps,
      actualReps: set.actualReps,
      targetWeight: set.targetWeight,
      actualWeight: set.actualWeight,
      isAmrap: set.isAmrap,
      setNotes: set.setNotes,
    );
  }

  /// Convert domain WorkoutSetEntity to database WorkoutSet
  WorkoutSet _entityToSet(WorkoutSetEntity entity) {
    return WorkoutSet(
      id: entity.id,
      sessionId: entity.sessionId,
      liftId: entity.liftId,
      tier: entity.tier,
      setNumber: entity.setNumber,
      targetReps: entity.targetReps,
      actualReps: entity.actualReps,
      targetWeight: entity.targetWeight,
      actualWeight: entity.actualWeight,
      isAmrap: entity.isAmrap,
      setNotes: entity.setNotes,
    );
  }

  /// Convert domain WorkoutSetEntity to WorkoutSetCompanion for insert
  WorkoutSetCompanion _entityToSetCompanion(WorkoutSetEntity entity) {
    return WorkoutSetCompanion.insert(
      sessionId: entity.sessionId,
      liftId: entity.liftId,
      tier: entity.tier,
      setNumber: entity.setNumber,
      targetReps: entity.targetReps,
      actualReps: drift.Value(entity.actualReps),
      targetWeight: entity.targetWeight,
      actualWeight: drift.Value(entity.actualWeight),
      isAmrap: drift.Value(entity.isAmrap),
      setNotes: drift.Value(entity.setNotes),
    );
  }
}
