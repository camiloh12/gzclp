import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart' as drift;

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cycle_state_entity.dart';
import '../../domain/repositories/cycle_state_repository.dart';
import '../datasources/local/app_database.dart';

/// Concrete implementation of CycleStateRepository
///
/// CRITICAL REPOSITORY - Handles conversion between database models and domain entities
/// for progression state tracking.
class CycleStateRepositoryImpl implements CycleStateRepository {
  final AppDatabase database;

  CycleStateRepositoryImpl(this.database);

  @override
  Future<Either<Failure, List<CycleStateEntity>>> getAllCycleStates() async {
    try {
      final states = await database.cycleStatesDao.getAllCycleStates();
      return Right(states.map(_cycleStateToEntity).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CycleStateEntity>> getCycleStateById(int id) async {
    try {
      final state = await database.cycleStatesDao.getCycleStateById(id);
      if (state == null) {
        return Left(NotFoundFailure('CycleState with ID $id not found'));
      }
      return Right(_cycleStateToEntity(state));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CycleStateEntity>> getCycleStateByLiftAndTier(
    int liftId,
    String tier,
  ) async {
    try {
      final state = await database.cycleStatesDao.getCycleStateByLiftAndTier(liftId, tier);
      if (state == null) {
        return Left(NotFoundFailure('CycleState for lift $liftId tier $tier not found'));
      }
      return Right(_cycleStateToEntity(state));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CycleStateEntity>>> getCycleStatesForLift(int liftId) async {
    try {
      final states = await database.cycleStatesDao.getCycleStatesForLift(liftId);
      return Right(states.map(_cycleStateToEntity).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> createCycleState(CycleStateEntity state) async {
    try {
      final companion = _entityToCycleStateCompanion(state);
      final id = await database.cycleStatesDao.insertCycleState(companion);
      return Right(id);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCycleState(CycleStateEntity state) async {
    try {
      final dbState = _entityToCycleState(state);
      await database.cycleStatesDao.updateCycleState(dbState);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCycleStatesInTransaction(
    List<CycleStateEntity> states,
  ) async {
    try {
      final dbStates = states.map(_entityToCycleState).toList();
      await database.cycleStatesDao.updateCycleStatesInTransaction(dbStates);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> initializeCycleStatesForLift({
    required int liftId,
    required double t1StartWeight,
    required double t2StartWeight,
    required double t3StartWeight,
  }) async {
    try {
      final now = DateTime.now();
      final states = [
        CycleStateCompanion.insert(
          liftId: liftId,
          currentTier: 'T1',
          currentStage: 1,
          nextTargetWeight: t1StartWeight,
          lastUpdated: drift.Value(now),
        ),
        CycleStateCompanion.insert(
          liftId: liftId,
          currentTier: 'T2',
          currentStage: 1,
          nextTargetWeight: t2StartWeight,
          lastUpdated: drift.Value(now),
        ),
        CycleStateCompanion.insert(
          liftId: liftId,
          currentTier: 'T3',
          currentStage: 1,
          nextTargetWeight: t3StartWeight,
          lastUpdated: drift.Value(now),
        ),
      ];

      await database.cycleStatesDao.insertCycleStates(states);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  /// Convert database CycleState to domain CycleStateEntity
  CycleStateEntity _cycleStateToEntity(CycleState state) {
    return CycleStateEntity(
      id: state.id,
      liftId: state.liftId,
      currentTier: state.currentTier,
      currentStage: state.currentStage,
      nextTargetWeight: state.nextTargetWeight,
      lastStage1SuccessWeight: state.lastStage1SuccessWeight,
      currentT3AmrapVolume: state.currentT3AmrapVolume,
      lastUpdated: state.lastUpdated,
    );
  }

  /// Convert domain CycleStateEntity to database CycleState
  CycleState _entityToCycleState(CycleStateEntity entity) {
    return CycleState(
      id: entity.id,
      liftId: entity.liftId,
      currentTier: entity.currentTier,
      currentStage: entity.currentStage,
      nextTargetWeight: entity.nextTargetWeight,
      lastStage1SuccessWeight: entity.lastStage1SuccessWeight,
      currentT3AmrapVolume: entity.currentT3AmrapVolume,
      lastUpdated: entity.lastUpdated,
    );
  }

  /// Convert domain CycleStateEntity to CycleStateCompanion for insert
  CycleStateCompanion _entityToCycleStateCompanion(CycleStateEntity entity) {
    return CycleStateCompanion.insert(
      liftId: entity.liftId,
      currentTier: entity.currentTier,
      currentStage: entity.currentStage,
      nextTargetWeight: entity.nextTargetWeight,
      lastStage1SuccessWeight: drift.Value(entity.lastStage1SuccessWeight),
      currentT3AmrapVolume: drift.Value(entity.currentT3AmrapVolume),
      lastUpdated: drift.Value(entity.lastUpdated),
    );
  }
}
