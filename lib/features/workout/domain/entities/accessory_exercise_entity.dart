import 'package:equatable/equatable.dart';

/// Domain entity representing a T3 accessory exercise
///
/// Accessory exercises are high-volume movements performed as Tier 3 (T3) work
/// in the GZCLP program. Users select which accessories to perform on each day.
class AccessoryExerciseEntity extends Equatable {
  /// Unique identifier for the accessory exercise
  final int id;

  /// Name of the exercise (e.g., "Lat Pulldown", "Dumbbell Row")
  final String name;

  /// Which workout day this exercise is performed on ('A', 'B', 'C', or 'D')
  final String dayType;

  /// Order in which this exercise appears in the workout
  /// Lower numbers appear first
  final int orderIndex;

  const AccessoryExerciseEntity({
    required this.id,
    required this.name,
    required this.dayType,
    required this.orderIndex,
  });

  /// Create a copy with optional field replacements
  AccessoryExerciseEntity copyWith({
    int? id,
    String? name,
    String? dayType,
    int? orderIndex,
  }) {
    return AccessoryExerciseEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      dayType: dayType ?? this.dayType,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  List<Object?> get props => [id, name, dayType, orderIndex];

  @override
  String toString() {
    return 'AccessoryExerciseEntity(id: $id, name: $name, dayType: $dayType, orderIndex: $orderIndex)';
  }
}
