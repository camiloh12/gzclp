import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/lift_entity.dart';

/// Repository interface for Lift operations
///
/// Defines the contract for accessing and managing lift data.
/// Implementations are in the data layer.
abstract class LiftRepository {
  /// Get all lifts
  Future<Either<Failure, List<LiftEntity>>> getAllLifts();

  /// Get a single lift by ID
  Future<Either<Failure, LiftEntity>> getLiftById(int id);

  /// Get a lift by name
  Future<Either<Failure, LiftEntity>> getLiftByName(String name);

  /// Get lifts by category (lower/upper)
  Future<Either<Failure, List<LiftEntity>>> getLiftsByCategory(String category);

  /// Check if lifts have been initialized
  Future<Either<Failure, bool>> hasLifts();

  /// Initialize the four main lifts
  /// Should be called during app first run or onboarding
  Future<Either<Failure, void>> initializeMainLifts();
}
