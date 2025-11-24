import 'package:equatable/equatable.dart';
import '../../../domain/entities/workout_session_entity.dart';

abstract class WorkoutHistoryState extends Equatable {
  const WorkoutHistoryState();

  @override
  List<Object?> get props => [];
}

class WorkoutHistoryInitial extends WorkoutHistoryState {
  const WorkoutHistoryInitial();
}

class WorkoutHistoryLoading extends WorkoutHistoryState {
  const WorkoutHistoryLoading();
}

class WorkoutHistoryLoaded extends WorkoutHistoryState {
  final List<WorkoutSessionEntity> sessions;

  const WorkoutHistoryLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

class WorkoutHistoryError extends WorkoutHistoryState {
  final String message;

  const WorkoutHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
