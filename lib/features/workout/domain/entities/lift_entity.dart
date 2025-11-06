import 'package:equatable/equatable.dart';

/// Domain entity representing a main compound lift
///
/// This is a pure business object, independent of any persistence layer.
/// Represents one of the four main lifts: Squat, Bench Press, Deadlift, or Overhead Press.
class LiftEntity extends Equatable {
  /// Unique identifier
  final int id;

  /// Name of the lift (e.g., "Squat", "Bench Press")
  final String name;

  /// Category determines weight increment:
  /// - "lower": Lower body lifts (Squat, Deadlift) - 10 lbs / 5 kg increments
  /// - "upper": Upper body lifts (Bench, OHP) - 5 lbs / 2.5 kg increments
  final String category;

  const LiftEntity({
    required this.id,
    required this.name,
    required this.category,
  });

  /// Check if this is a lower body lift
  bool get isLowerBody => category == 'lower';

  /// Check if this is an upper body lift
  bool get isUpperBody => category == 'upper';

  /// Get the weight increment for this lift based on unit system
  double getWeightIncrement({required bool isMetric}) {
    if (isLowerBody) {
      return isMetric ? 5.0 : 10.0; // 5 kg or 10 lbs for lower body
    } else {
      return isMetric ? 2.5 : 5.0; // 2.5 kg or 5 lbs for upper body
    }
  }

  @override
  List<Object?> get props => [id, name, category];

  @override
  String toString() => 'LiftEntity(id: $id, name: $name, category: $category)';
}
