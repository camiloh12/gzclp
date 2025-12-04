import 'package:equatable/equatable.dart';

/// Domain entity representing a training cycle
///
/// A cycle is a 12-week training period (12 complete A→B→C→D rotations).
/// When a cycle completes, users can start a new cycle with adjusted weights.
class CycleEntity extends Equatable {
  /// Unique identifier
  final int id;

  /// Cycle number (1, 2, 3, etc.)
  final int cycleNumber;

  /// When this cycle started
  final DateTime startDate;

  /// When this cycle ended (null if still active)
  final DateTime? endDate;

  /// Status: 'active' or 'completed'
  final String status;

  /// Number of complete A→B→C→D rotations completed
  /// Cycle completes when this reaches 12
  final int completedRotations;

  const CycleEntity({
    required this.id,
    required this.cycleNumber,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.completedRotations,
  });

  /// Check if this cycle is active
  bool get isActive => status == 'active';

  /// Check if this cycle is completed
  bool get isCompleted => status == 'completed';

  /// Get the progress percentage (0-100)
  double get progressPercentage {
    return (completedRotations / 12.0) * 100.0;
  }

  /// Check if this cycle is ready to complete (12 rotations reached)
  bool get isReadyToComplete => completedRotations >= 12;

  /// Get the number of rotations remaining
  int get rotationsRemaining => 12 - completedRotations;

  /// Copy with updated fields
  CycleEntity copyWith({
    int? id,
    int? cycleNumber,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    int? completedRotations,
  }) {
    return CycleEntity(
      id: id ?? this.id,
      cycleNumber: cycleNumber ?? this.cycleNumber,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      completedRotations: completedRotations ?? this.completedRotations,
    );
  }

  @override
  List<Object?> get props => [
        id,
        cycleNumber,
        startDate,
        endDate,
        status,
        completedRotations,
      ];

  @override
  String toString() =>
      'CycleEntity(id: $id, cycleNumber: $cycleNumber, status: $status, completedRotations: $completedRotations)';
}
