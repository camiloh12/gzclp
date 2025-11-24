import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/workout_session_repository.dart';
import 'workout_history_event.dart';
import 'workout_history_state.dart';

class WorkoutHistoryBloc extends Bloc<WorkoutHistoryEvent, WorkoutHistoryState> {
  final WorkoutSessionRepository sessionRepository;

  WorkoutHistoryBloc({
    required this.sessionRepository,
  }) : super(const WorkoutHistoryInitial()) {
    on<LoadWorkoutHistory>(_onLoadWorkoutHistory);
  }

  Future<void> _onLoadWorkoutHistory(
    LoadWorkoutHistory event,
    Emitter<WorkoutHistoryState> emit,
  ) async {
    emit(const WorkoutHistoryLoading());

    try {
      final result = await sessionRepository.getFinalizedSessions();

      result.fold(
        (failure) => emit(WorkoutHistoryError(failure.message)),
        (sessions) => emit(WorkoutHistoryLoaded(sessions)),
      );
    } catch (e) {
      emit(WorkoutHistoryError('Failed to load workout history: $e'));
    }
  }
}
