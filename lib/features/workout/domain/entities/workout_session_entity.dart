import 'package:equatable/equatable.dart';

/// Domain entity representing a complete workout session
///
/// A session represents one workout day (A, B, C, or D) from start to finalization.
/// Sessions must be finalized before progression logic is applied to prevent
/// duplicate updates.
class WorkoutSessionEntity extends Equatable {
  /// Unique identifier
  final int id;

  /// ID of the cycle this session belongs to
  final int cycleId;

  /// Day type: 'A', 'B', 'C', or 'D'
  /// Determines which lifts are performed:
  /// - Day A: Squat (T1), Overhead Press (T2)
  /// - Day B: Bench Press (T1), Deadlift (T2)
  /// - Day C: Squat (T2), Bench Press (T1)
  /// - Day D: Deadlift (T1), Overhead Press (T2)
  final String dayType;

  /// Which rotation number this session belongs to (1-12)
  /// Used to track progress toward cycle completion
  final int rotationNumber;

  /// Position within the rotation (1-4 for A, B, C, D)
  final int rotationPosition;

  /// When the workout was started
  final DateTime dateStarted;

  /// When the workout was completed (null if still in progress)
  final DateTime? dateCompleted;

  /// Critical flag: Has the progression logic been applied?
  /// Must be true before starting next workout to prevent duplicate progression updates
  final bool isFinalized;

  /// Optional notes about the entire session
  final String? sessionNotes;

  const WorkoutSessionEntity({
    required this.id,
    required this.cycleId,
    required this.dayType,
    required this.rotationNumber,
    required this.rotationPosition,
    required this.dateStarted,
    this.dateCompleted,
    this.isFinalized = false,
    this.sessionNotes,
  });

  /// Check if the session is in progress (not completed)
  bool get isInProgress => dateCompleted == null;

  /// Check if the session is completed but not finalized
  bool get isCompletedNotFinalized => dateCompleted != null && !isFinalized;

  /// Get the duration of the session (null if not completed)
  Duration? get duration {
    if (dateCompleted == null) return null;
    return dateCompleted!.difference(dateStarted);
  }

  /// Create a copy with updated fields
  WorkoutSessionEntity copyWith({
    int? id,
    int? cycleId,
    String? dayType,
    int? rotationNumber,
    int? rotationPosition,
    DateTime? dateStarted,
    DateTime? dateCompleted,
    bool? isFinalized,
    String? sessionNotes,
  }) {
    return WorkoutSessionEntity(
      id: id ?? this.id,
      cycleId: cycleId ?? this.cycleId,
      dayType: dayType ?? this.dayType,
      rotationNumber: rotationNumber ?? this.rotationNumber,
      rotationPosition: rotationPosition ?? this.rotationPosition,
      dateStarted: dateStarted ?? this.dateStarted,
      dateCompleted: dateCompleted ?? this.dateCompleted,
      isFinalized: isFinalized ?? this.isFinalized,
      sessionNotes: sessionNotes ?? this.sessionNotes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        cycleId,
        dayType,
        rotationNumber,
        rotationPosition,
        dateStarted,
        dateCompleted,
        isFinalized,
        sessionNotes,
      ];

  @override
  String toString() {
    return 'WorkoutSessionEntity(id: $id, dayType: $dayType, '
        'started: $dateStarted, completed: $dateCompleted, '
        'finalized: $isFinalized)';
  }
}
