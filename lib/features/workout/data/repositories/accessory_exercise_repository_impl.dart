import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/accessory_exercise_entity.dart';
import '../../domain/repositories/accessory_exercise_repository.dart';
import '../datasources/local/app_database.dart';

/// Concrete implementation of AccessoryExerciseRepository
///
/// Handles conversion between database models and domain entities,
/// delegates persistence to the AccessoryExercisesDao.
class AccessoryExerciseRepositoryImpl implements AccessoryExerciseRepository {
  final AppDatabase database;

  AccessoryExerciseRepositoryImpl(this.database);

  @override
  Future<Either<Failure, List<AccessoryExerciseEntity>>> getAccessoriesForDay(
    String dayType,
  ) async {
    try {
      final exercises = await database.accessoryExercisesDao.getAccessoriesForDay(dayType);
      return Right(exercises.map(_toEntity).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Failed to get accessories for day: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AccessoryExerciseEntity>>> getAllAccessories() async {
    try {
      final exercises = await database.accessoryExercisesDao.getAllAccessories();
      return Right(exercises.map(_toEntity).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Failed to get all accessories: $e'));
    }
  }

  @override
  Future<Either<Failure, AccessoryExerciseEntity>> createAccessory(
    AccessoryExerciseEntity exercise,
  ) async {
    try {
      final companion = AccessoryExerciseCompanion.insert(
        name: exercise.name,
        dayType: exercise.dayType,
        orderIndex: exercise.orderIndex,
      );

      final id = await database.accessoryExercisesDao.insertAccessory(companion);

      return Right(exercise.copyWith(id: id));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Failed to create accessory: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AccessoryExerciseEntity>>> createAccessories(
    List<AccessoryExerciseEntity> exercises,
  ) async {
    try {
      final companions = exercises.map((e) => AccessoryExerciseCompanion.insert(
        name: e.name,
        dayType: e.dayType,
        orderIndex: e.orderIndex,
      )).toList();

      await database.accessoryExercisesDao.insertAccessories(companions);

      // Fetch all accessories to get assigned IDs
      final allExercises = await database.accessoryExercisesDao.getAllAccessories();
      return Right(allExercises.map(_toEntity).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Failed to create accessories: $e'));
    }
  }

  @override
  Future<Either<Failure, AccessoryExerciseEntity>> updateAccessory(
    AccessoryExerciseEntity exercise,
  ) async {
    try {
      final dbExercise = AccessoryExercise(
        id: exercise.id,
        name: exercise.name,
        dayType: exercise.dayType,
        orderIndex: exercise.orderIndex,
      );

      await database.accessoryExercisesDao.updateAccessory(dbExercise);

      return Right(exercise);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Failed to update accessory: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAccessory(int id) async {
    try {
      final count = await database.accessoryExercisesDao.deleteAccessory(id);
      return Right(count > 0);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete accessory: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> deleteAccessoriesForDay(String dayType) async {
    try {
      final count = await database.accessoryExercisesDao.deleteAccessoriesForDay(dayType);
      return Right(count);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete accessories for day: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> reorderAccessories(
    String dayType,
    List<int> exerciseIdsInOrder,
  ) async {
    try {
      await database.accessoryExercisesDao.reorderAccessories(
        dayType,
        exerciseIdsInOrder,
      );
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Failed to reorder accessories: $e'));
    }
  }

  /// Convert database model to domain entity
  AccessoryExerciseEntity _toEntity(AccessoryExercise exercise) {
    return AccessoryExerciseEntity(
      id: exercise.id,
      name: exercise.name,
      dayType: exercise.dayType,
      orderIndex: exercise.orderIndex,
    );
  }
}
