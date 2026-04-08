import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/cycle_entity.dart';
import '../../../domain/repositories/cycle_repository.dart';
import '../../../domain/repositories/cycle_state_repository.dart';
import '../../../domain/repositories/lift_repository.dart';
import '../../../domain/repositories/workout_session_repository.dart';
import '../../../domain/usecases/start_new_cycle.dart';
import 'new_cycle_state.dart';

class NewCycleCubit extends Cubit<NewCycleState> {
  final CycleRepository cycleRepository;
  final CycleStateRepository cycleStateRepository;
  final LiftRepository liftRepository;
  final WorkoutSessionRepository sessionRepository;
  final StartNewCycle startNewCycle;

  NewCycleCubit({
    required this.cycleRepository,
    required this.cycleStateRepository,
    required this.liftRepository,
    required this.sessionRepository,
    required this.startNewCycle,
  }) : super(const NewCycleLoading());

  Future<void> loadCompletedCycle() async {
    emit(const NewCycleLoading());

    try {
      // Get the most recently completed cycle
      final cyclesResult = await cycleRepository.getCompletedCycles();
      if (cyclesResult.isLeft()) {
        emit(const NewCycleError('Failed to load completed cycle'));
        return;
      }
      final completedCycles = (cyclesResult as Right).value as List<CycleEntity>;
      if (completedCycles.isEmpty) {
        emit(const NewCycleError('No completed cycle found'));
        return;
      }
      final completedCycle = completedCycles.first;

      // Get total finalized workouts in that cycle
      final sessionsResult =
          await sessionRepository.getFinalizedSessionsForCycle(completedCycle.id);
      final totalWorkouts = sessionsResult.fold((_) => 0, (s) => s.length);

      // Get last cycle states to extract ending weights
      final statesResult =
          await cycleStateRepository.getCycleStatesForCycle(completedCycle.id);
      if (statesResult.isLeft()) {
        emit(const NewCycleError('Failed to load cycle weights'));
        return;
      }
      final states = (statesResult as Right).value;

      // Build weight map: liftId → T1 nextTargetWeight
      final Map<int, double> lastWeights = {};
      for (final state in states) {
        if (state.currentTier == 'T1') {
          lastWeights[state.liftId] = state.nextTargetWeight;
        }
      }

      emit(NewCycleReady(
        completedCycle: completedCycle,
        totalWorkouts: totalWorkouts,
        lastCycleWeights: lastWeights,
        editedWeights: Map.from(lastWeights),
      ));
    } catch (e) {
      emit(NewCycleError('Error: $e'));
    }
  }

  void selectKeepWeights() {
    if (state is! NewCycleReady) return;
    emit((state as NewCycleReady).copyWith(keepWeights: true));
  }

  void selectAdjustWeights() {
    if (state is! NewCycleReady) return;
    emit((state as NewCycleReady).copyWith(keepWeights: false));
  }

  void updateWeight(int liftId, double weight) {
    if (state is! NewCycleReady) return;
    final current = state as NewCycleReady;
    final updated = Map<int, double>.from(current.editedWeights);
    updated[liftId] = weight;
    emit(current.copyWith(editedWeights: updated));
  }

  Future<void> confirmNewCycle() async {
    if (state is! NewCycleReady) return;
    final current = state as NewCycleReady;
    emit(const NewCycleCreating());

    final weightOption = current.keepWeights == true
        ? const KeepWeights()
        : CustomWeights(current.editedWeights);

    final result = await startNewCycle(
      NewCycleWeightParams(weightOption: weightOption),
    );

    result.fold(
      (failure) => emit(NewCycleError(failure.message)),
      (_) => emit(const NewCycleCreated()),
    );
  }
}
