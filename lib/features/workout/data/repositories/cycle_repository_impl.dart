import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cycle_entity.dart';
import '../../domain/repositories/cycle_repository.dart';
import '../datasources/local/app_database.dart';

/// Concrete implementation of CycleRepository
///
/// Handles conversion between database models and domain entities.
class CycleRepositoryImpl implements CycleRepository {
  final AppDatabase database;

  CycleRepositoryImpl(this.database);

  @override
  Future<Either<Failure, List<CycleEntity>>> getAllCycles() async {
    try {
      final cycles = await database.cyclesDao.getAllCycles();
      return Right(cycles.map(_cycleToEntity).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CycleEntity>> getCycleById(int id) async {
    try {
      final cycle = await database.cyclesDao.getCycleById(id);
      if (cycle == null) {
        return Left(NotFoundFailure('Cycle with ID $id not found'));
      }
      return Right(_cycleToEntity(cycle));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CycleEntity>> getCycleByCycleNumber(int cycleNumber) async {
    try {
      final cycle = await database.cyclesDao.getCycleByCycleNumber(cycleNumber);
      if (cycle == null) {
        return Left(NotFoundFailure('Cycle #$cycleNumber not found'));
      }
      return Right(_cycleToEntity(cycle));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CycleEntity>> getActiveCycle() async {
    try {
      final cycle = await database.cyclesDao.getActiveCycle();
      if (cycle == null) {
        return Left(NotFoundFailure('No active cycle found'));
      }
      return Right(_cycleToEntity(cycle));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CycleEntity>>> getCompletedCycles() async {
    try {
      final cycles = await database.cyclesDao.getCompletedCycles();
      return Right(cycles.map(_cycleToEntity).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> createCycle(int cycleNumber, DateTime startDate) async {
    try {
      final cycleId = await database.cyclesDao.insertCycle(
        CycleCompanion.insert(
          cycleNumber: cycleNumber,
          startDate: startDate,
          status: 'active',
        ),
      );
      return Right(cycleId);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> completeCycle(int cycleId, DateTime endDate) async {
    try {
      await database.cyclesDao.completeCycle(cycleId, endDate);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> incrementRotations(int cycleId) async {
    try {
      await database.cyclesDao.incrementRotations(cycleId);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getMaxCycleNumber() async {
    try {
      final maxCycleNumber = await database.cyclesDao.getMaxCycleNumber();
      return Right(maxCycleNumber);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  /// Convert database Cycle to domain CycleEntity
  CycleEntity _cycleToEntity(Cycle cycle) {
    return CycleEntity(
      id: cycle.id,
      cycleNumber: cycle.cycleNumber,
      startDate: cycle.startDate,
      endDate: cycle.endDate,
      status: cycle.status,
      completedRotations: cycle.completedRotations,
    );
  }
}
