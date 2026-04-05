import 'package:equatable/equatable.dart';

class WorkoutSessionEntity extends Equatable {
  final int id;
  final int cycleId;

  /// Day number: '1', '2', '3', or '4'
  final String dayType;

  /// Which rotation (week) this session belongs to (1–12)
  final int rotationNumber;

  final DateTime dateStarted;
  final DateTime? dateCompleted;
  final bool isFinalized;
  final String? sessionNotes;

  const WorkoutSessionEntity({
    required this.id,
    required this.cycleId,
    required this.dayType,
    required this.rotationNumber,
    required this.dateStarted,
    this.dateCompleted,
    this.isFinalized = false,
    this.sessionNotes,
  });

  bool get isInProgress => dateCompleted == null;
  bool get isCompletedNotFinalized => dateCompleted != null && !isFinalized;

  Duration? get duration {
    if (dateCompleted == null) return null;
    return dateCompleted!.difference(dateStarted);
  }

  WorkoutSessionEntity copyWith({
    int? id,
    int? cycleId,
    String? dayType,
    int? rotationNumber,
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
      dateStarted: dateStarted ?? this.dateStarted,
      dateCompleted: dateCompleted ?? this.dateCompleted,
      isFinalized: isFinalized ?? this.isFinalized,
      sessionNotes: sessionNotes ?? this.sessionNotes,
    );
  }

  @override
  List<Object?> get props => [
        id, cycleId, dayType, rotationNumber,
        dateStarted, dateCompleted, isFinalized, sessionNotes,
      ];

  @override
  String toString() =>
      'WorkoutSessionEntity(id: $id, dayType: $dayType, '
      'rotation: $rotationNumber, finalized: $isFinalized)';
}
