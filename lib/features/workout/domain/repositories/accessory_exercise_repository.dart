import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/accessory_exercise_entity.dart';

/// Repository interface for accessory exercise operations
///
/// Defines the contract for managing T3 accessory exercises in the domain layer.
/// Concrete implementations handle the actual data persistence.
abstract class AccessoryExerciseRepository {
  /// Get all accessory exercises for a specific workout day
  ///
  /// Returns exercises ordered by their orderIndex (ascending).
  /// Returns an empty list if no exercises are configured for the day.
  Future<Either<Failure, List<AccessoryExerciseEntity>>> getAccessoriesForDay(
    String dayType,
  );

  /// Get all accessory exercises across all days
  ///
  /// Returns exercises ordered by day type and then by orderIndex.
  Future<Either<Failure, List<AccessoryExerciseEntity>>> getAllAccessories();

  /// Create a new accessory exercise
  ///
  /// Returns the created exercise with its assigned ID.
  /// Validates that the dayType/orderIndex combination is unique.
  Future<Either<Failure, AccessoryExerciseEntity>> createAccessory(
    AccessoryExerciseEntity exercise,
  );

  /// Create multiple accessory exercises
  ///
  /// Useful for bulk initialization during onboarding.
  /// All exercises are created in a single transaction.
  Future<Either<Failure, List<AccessoryExerciseEntity>>> createAccessories(
    List<AccessoryExerciseEntity> exercises,
  );

  /// Update an existing accessory exercise
  ///
  /// Returns the updated exercise.
  Future<Either<Failure, AccessoryExerciseEntity>> updateAccessory(
    AccessoryExerciseEntity exercise,
  );

  /// Delete an accessory exercise
  ///
  /// Returns true if the exercise was deleted, false if it didn't exist.
  Future<Either<Failure, bool>> deleteAccessory(int id);

  /// Delete all accessory exercises for a specific day
  ///
  /// Returns the number of exercises deleted.
  Future<Either<Failure, int>> deleteAccessoriesForDay(String dayType);

  /// Reorder accessory exercises for a specific day
  ///
  /// Takes a list of exercise IDs in the desired order.
  /// Updates the orderIndex for each exercise.
  Future<Either<Failure, void>> reorderAccessories(
    String dayType,
    List<int> exerciseIdsInOrder,
  );
}
