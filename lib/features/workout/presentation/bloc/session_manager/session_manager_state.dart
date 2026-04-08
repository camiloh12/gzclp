import 'package:equatable/equatable.dart';
import '../../../domain/entities/cycle_entity.dart';
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
  final CycleEntity? activeCycle;
  final int currentWeek;
  final Set<String> completedDaysThisWeek;

  const SessionManagerInProgress(
    this.session, {
    this.activeCycle,
    this.currentWeek = 1,
    this.completedDaysThisWeek = const {},
  });

  @override
  List<Object?> get props =>
      [session, activeCycle, currentWeek, completedDaysThisWeek];
}

class SessionManagerNoSession extends SessionManagerState {
  final WorkoutSessionEntity? lastSession;
  final CycleEntity? activeCycle;
  final int currentWeek;
  final Set<String> completedDaysThisWeek;

  const SessionManagerNoSession({
    this.lastSession,
    this.activeCycle,
    this.currentWeek = 1,
    this.completedDaysThisWeek = const {},
  });

  bool get isCycleComplete => activeCycle?.isReadyToComplete ?? false;

  @override
  List<Object?> get props =>
      [lastSession, activeCycle, currentWeek, completedDaysThisWeek];
}

class SessionManagerError extends SessionManagerState {
  final String message;

  const SessionManagerError(this.message);

  @override
  List<Object?> get props => [message];
}
