import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/lift_entity.dart';
import '../../domain/repositories/lift_repository.dart';
import '../datasources/local/app_database.dart';

/// Concrete implementation of LiftRepository
///
/// Handles conversion between database models and domain entities.
class LiftRepositoryImpl implements LiftRepository {
  final AppDatabase database;

  LiftRepositoryImpl(this.database);

  @override
  Future<Either<Failure, List<LiftEntity>>> getAllLifts() async {
    try {
      final lifts = await database.liftsDao.getAllLifts();
      return Right(lifts.map(_liftToEntity).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LiftEntity>> getLiftById(int id) async {
    try {
      final lift = await database.liftsDao.getLiftById(id);
      if (lift == null) {
        return Left(NotFoundFailure('Lift with ID $id not found'));
      }
      return Right(_liftToEntity(lift));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LiftEntity>> getLiftByName(String name) async {
    try {
      final lift = await database.liftsDao.getLiftByName(name);
      if (lift == null) {
        return Left(NotFoundFailure('Lift with name "$name" not found'));
      }
      return Right(_liftToEntity(lift));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LiftEntity>>> getLiftsByCategory(String category) async {
    try {
      final lifts = await database.liftsDao.getLiftsByCategory(category);
      return Right(lifts.map(_liftToEntity).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> hasLifts() async {
    try {
      final hasLifts = await database.liftsDao.hasLifts();
      return Right(hasLifts);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> initializeMainLifts() async {
    try {
      // Check if already initialized
      final hasLifts = await database.liftsDao.hasLifts();
      if (hasLifts) {
        return const Right(null);
      }

      // Insert the four main lifts
      final lifts = [
        LiftCompanion.insert(
          name: AppConstants.liftSquat,
          category: AppConstants.liftCategoryLower,
        ),
        LiftCompanion.insert(
          name: AppConstants.liftBench,
          category: AppConstants.liftCategoryUpper,
        ),
        LiftCompanion.insert(
          name: AppConstants.liftDeadlift,
          category: AppConstants.liftCategoryLower,
        ),
        LiftCompanion.insert(
          name: AppConstants.liftOhp,
          category: AppConstants.liftCategoryUpper,
        ),
      ];

      await database.liftsDao.insertLifts(lifts);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  /// Convert database Lift to domain LiftEntity
  LiftEntity _liftToEntity(Lift lift) {
    return LiftEntity(
      id: lift.id,
      name: lift.name,
      category: lift.category,
    );
  }
}
