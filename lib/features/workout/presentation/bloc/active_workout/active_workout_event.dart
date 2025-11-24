import 'package:equatable/equatable.dart';
import '../../../domain/entities/workout_session_entity.dart';
import '../../../domain/entities/workout_set_entity.dart';

abstract class ActiveWorkoutEvent extends Equatable {
  const ActiveWorkoutEvent();

  @override
  List<Object?> get props => [];
}

class StartWorkout extends ActiveWorkoutEvent {
  final String dayType;

  const StartWorkout({required this.dayType});

  @override
  List<Object?> get props => [dayType];
}

class CheckForActiveWorkout extends ActiveWorkoutEvent {
  const CheckForActiveWorkout();
}

class ResumeWorkout extends ActiveWorkoutEvent {
  final WorkoutSessionEntity session;

  const ResumeWorkout({required this.session});

  @override
  List<Object?> get props => [session];
}

class LogSet extends ActiveWorkoutEvent {
  final int setId;
  final int? actualReps;
  final double? actualWeight;

  const LogSet({
    required this.setId,
    this.actualReps,
    this.actualWeight,
  });

  @override
  List<Object?> get props => [setId, actualReps, actualWeight];
}

class UpdateSetNotes extends ActiveWorkoutEvent {
  final int setId;
  final String? notes;

  const UpdateSetNotes({
    required this.setId,
    this.notes,
  });

  @override
  List<Object?> get props => [setId, notes];
}

class UpdateSessionNotes extends ActiveWorkoutEvent {
  final String? notes;

  const UpdateSessionNotes({this.notes});

  @override
  List<Object?> get props => [notes];
}

class CompleteWorkout extends ActiveWorkoutEvent {
  const CompleteWorkout();
}

class CancelWorkout extends ActiveWorkoutEvent {
  const CancelWorkout();
}
