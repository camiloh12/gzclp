import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/cycle_repository.dart';
import '../../../domain/repositories/workout_session_repository.dart';
import 'session_manager_event.dart';
import 'session_manager_state.dart';

class SessionManagerBloc
    extends Bloc<SessionManagerEvent, SessionManagerState> {
  final WorkoutSessionRepository sessionRepository;
  final CycleRepository cycleRepository;

  SessionManagerBloc({
    required this.sessionRepository,
    required this.cycleRepository,
  }) : super(const SessionManagerInitial()) {
    on<CheckInProgressSession>(_onCheckInProgressSession);
  }

  Future<void> _onCheckInProgressSession(
    CheckInProgressSession event,
    Emitter<SessionManagerState> emit,
  ) async {
    emit(const SessionManagerLoading());

    try {
      // Load active cycle
      final cycleResult = await cycleRepository.getActiveCycle();
      final activeCycle =
          cycleResult.fold((_) => null, (cycle) => cycle);

      final int currentRotation;
      final Set<String> completedDaysThisWeek;

      if (activeCycle != null) {
        currentRotation = activeCycle.completedRotations + 1;
        // Get finalized days for the current rotation
        final daysResult = await sessionRepository
            .getFinalizedDayTypesForRotation(
                activeCycle.id, currentRotation);
        completedDaysThisWeek =
            daysResult.fold((_) => <String>{}, (days) => days);
      } else {
        currentRotation = 1;
        completedDaysThisWeek = {};
      }

      // Check for in-progress session
      final result = await sessionRepository.getInProgressSession();

      await result.fold(
        (failure) async => emit(SessionManagerError(failure.message)),
        (session) async {
          if (session != null) {
            emit(SessionManagerInProgress(
              session,
              activeCycle: activeCycle,
              currentWeek: currentRotation,
              completedDaysThisWeek: completedDaysThisWeek,
            ));
          } else {
            final lastResult =
                await sessionRepository.getLastSession();
            lastResult.fold(
              (_) => emit(SessionManagerNoSession(
                activeCycle: activeCycle,
                currentWeek: currentRotation,
                completedDaysThisWeek: completedDaysThisWeek,
              )),
              (lastSession) => emit(SessionManagerNoSession(
                lastSession: lastSession,
                activeCycle: activeCycle,
                currentWeek: currentRotation,
                completedDaysThisWeek: completedDaysThisWeek,
              )),
            );
          }
        },
      );
    } catch (e) {
      emit(SessionManagerError('Failed to check in-progress session: $e'));
    }
  }
}
