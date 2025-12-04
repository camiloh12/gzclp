import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/cycle_entity.dart';

/// Repository interface for Cycle operations
///
/// Defines the contract for accessing and managing training cycle data.
/// Implementations are in the data layer.
abstract class CycleRepository {
  /// Get all cycles
  Future<Either<Failure, List<CycleEntity>>> getAllCycles();

  /// Get a cycle by ID
  Future<Either<Failure, CycleEntity>> getCycleById(int id);

  /// Get a cycle by cycle number
  Future<Either<Failure, CycleEntity>> getCycleByCycleNumber(int cycleNumber);

  /// Get the active cycle
  Future<Either<Failure, CycleEntity>> getActiveCycle();

  /// Get completed cycles
  Future<Either<Failure, List<CycleEntity>>> getCompletedCycles();

  /// Create a new cycle
  Future<Either<Failure, int>> createCycle(int cycleNumber, DateTime startDate);

  /// Complete the current cycle
  Future<Either<Failure, void>> completeCycle(int cycleId, DateTime endDate);

  /// Increment the completed rotations count for a cycle
  Future<Either<Failure, void>> incrementRotations(int cycleId);

  /// Get the highest cycle number
  Future<Either<Failure, int>> getMaxCycleNumber();
}
