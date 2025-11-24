import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/workout_session_repository.dart';
import 'session_manager_event.dart';
import 'session_manager_state.dart';

class SessionManagerBloc extends Bloc<SessionManagerEvent, SessionManagerState> {
  final WorkoutSessionRepository sessionRepository;

  SessionManagerBloc({
    required this.sessionRepository,
  }) : super(const SessionManagerInitial()) {
    on<CheckInProgressSession>(_onCheckInProgressSession);
  }

  Future<void> _onCheckInProgressSession(
    CheckInProgressSession event,
    Emitter<SessionManagerState> emit,
  ) async {
    emit(const SessionManagerLoading());

    try {
      // Check for in-progress session
      final result = await sessionRepository.getInProgressSession();

      await result.fold(
        (failure) async => emit(SessionManagerError(failure.message)),
        (session) async {
          if (session != null) {
            emit(SessionManagerInProgress(session));
          } else {
            // No in-progress workout, get last session for display
            final lastResult = await sessionRepository.getLastFinalizedSession();
            lastResult.fold(
              (_) => emit(const SessionManagerNoSession()),
              (lastSession) => emit(SessionManagerNoSession(lastSession: lastSession)),
            );
          }
        },
      );
    } catch (e) {
      emit(SessionManagerError('Failed to check in-progress session: $e'));
    }
  }
}
