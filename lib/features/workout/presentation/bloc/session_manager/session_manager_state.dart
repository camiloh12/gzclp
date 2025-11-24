import 'package:equatable/equatable.dart';
import '../../../domain/entities/workout_session_entity.dart';

abstract class SessionManagerState extends Equatable {
  const SessionManagerState();

  @override
  List<Object?> get props => [];
}

class SessionManagerInitial extends SessionManagerState {
  const SessionManagerInitial();
}

class SessionManagerLoading extends SessionManagerState {
  const SessionManagerLoading();
}

class SessionManagerInProgress extends SessionManagerState {
  final WorkoutSessionEntity session;

  const SessionManagerInProgress(this.session);

  @override
  List<Object?> get props => [session];
}

class SessionManagerNoSession extends SessionManagerState {
  final WorkoutSessionEntity? lastSession;

  const SessionManagerNoSession({this.lastSession});

  @override
  List<Object?> get props => [lastSession];
}

class SessionManagerError extends SessionManagerState {
  final String message;

  const SessionManagerError(this.message);

  @override
  List<Object?> get props => [message];
}
