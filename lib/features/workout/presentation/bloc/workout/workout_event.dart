import 'package:equatable/equatable.dart';

/// Events for workout session management
abstract class WorkoutEvent extends Equatable {
  const WorkoutEvent();

  @override
  List<Object?> get props => [];
}

/// Check if there's an in-progress workout
class CheckInProgressWorkout extends WorkoutEvent {
  const CheckInProgressWorkout();
}

/// Generate workout plan for a specific day
class GenerateWorkout extends WorkoutEvent {
  final String dayType; // A, B, C, or D

  const GenerateWorkout(this.dayType);

  @override
  List<Object?> get props => [dayType];
}

/// Start a new workout session
class StartWorkout extends WorkoutEvent {
  final String dayType;

  const StartWorkout(this.dayType);

  @override
  List<Object?> get props => [dayType];
}

/// Log a set during the workout
class LogSet extends WorkoutEvent {
  final int setId;
  final int actualReps;
  final double? actualWeight; // null means use target weight

  const LogSet({
    required this.setId,
    required this.actualReps,
    this.actualWeight,
  });

  @override
  List<Object?> get props => [setId, actualReps, actualWeight];
}

/// Complete and finalize the workout
class CompleteWorkout extends WorkoutEvent {
  const CompleteWorkout();
}

/// Cancel the in-progress workout
class CancelWorkout extends WorkoutEvent {
  const CancelWorkout();
}

/// Load workout history
class LoadWorkoutHistory extends WorkoutEvent {
  const LoadWorkoutHistory();
}

/// Update notes for a specific set
class UpdateSetNotes extends WorkoutEvent {
  final int setId;
  final String? notes;

  const UpdateSetNotes({
    required this.setId,
    this.notes,
  });

  @override
  List<Object?> get props => [setId, notes];
}

/// Update notes for the current session
class UpdateSessionNotes extends WorkoutEvent {
  final String? notes;

  const UpdateSessionNotes(this.notes);

  @override
  List<Object?> get props => [notes];
}
