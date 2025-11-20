import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../data/datasources/local/app_database.dart';
import '../../../domain/entities/workout_session_entity.dart';
import '../../../domain/entities/workout_set_entity.dart';
import '../../../domain/repositories/workout_session_repository.dart';
import '../../../domain/repositories/workout_set_repository.dart';
import '../../../domain/usecases/finalize_workout_session.dart';
import '../../../domain/usecases/generate_workout_for_day.dart';
import 'workout_event.dart';
import 'workout_state.dart';

/// BLoC for managing workout sessions
///
/// Handles:
/// - Checking for in-progress workouts
/// - Generating workout plans
/// - Starting new sessions
/// - Logging sets
/// - Finalizing sessions with progression
class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  final GenerateWorkoutForDay generateWorkoutForDay;
  final WorkoutSessionRepository sessionRepository;
  final WorkoutSetRepository setRepository;
  final FinalizeWorkoutSession finalizeWorkoutSession;
  final AppDatabase database;

  WorkoutBloc({
    required this.generateWorkoutForDay,
    required this.sessionRepository,
    required this.setRepository,
    required this.finalizeWorkoutSession,
    required this.database,
  }) : super(const WorkoutInitial()) {
    on<CheckInProgressWorkout>(_onCheckInProgressWorkout);
    on<GenerateWorkout>(_onGenerateWorkout);
    on<StartWorkout>(_onStartWorkout);
    on<LogSet>(_onLogSet);
    on<CompleteWorkout>(_onCompleteWorkout);
    on<CancelWorkout>(_onCancelWorkout);
    on<LoadWorkoutHistory>(_onLoadWorkoutHistory);
    on<UpdateSetNotes>(_onUpdateSetNotes);
    on<UpdateSessionNotes>(_onUpdateSessionNotes);
  }

  Future<void> _onCheckInProgressWorkout(
    CheckInProgressWorkout event,
    Emitter<WorkoutState> emit,
  ) async {
    emit(const WorkoutLoading());

    try {
      // Check for in-progress session
      final result = await sessionRepository.getInProgressSession();

      await result.fold(
        (failure) async => emit(WorkoutError(failure.message)),
        (session) async {
          if (session != null) {
            // Load the workout plan and sets
            await _loadInProgressWorkout(session, emit);
          } else {
            // No in-progress workout, get last session for display
            final lastResult = await sessionRepository.getLastFinalizedSession();
            await lastResult.fold(
              (_) async => emit(const WorkoutReady()),
              (lastSession) async => emit(WorkoutReady(lastSession: lastSession)),
            );
          }
        },
      );
    } catch (e) {
      emit(WorkoutError('Failed to check in-progress workout: $e'));
    }
  }

  Future<void> _onGenerateWorkout(
    GenerateWorkout event,
    Emitter<WorkoutState> emit,
  ) async {
    emit(const WorkoutLoading());

    try {
      // Get user preferences for unit system
      final prefs = await database.userPreferencesDao.getPreferences();
      final isMetric = prefs?.unitSystem == AppConstants.unitSystemMetric;

      // Generate workout plan
      final result = await generateWorkoutForDay(WorkoutDayParams(dayType: event.dayType));

      result.fold(
        (failure) => emit(WorkoutError(failure.message)),
        (plan) => emit(WorkoutPlanGenerated(plan: plan, isMetric: isMetric)),
      );
    } catch (e) {
      emit(WorkoutError('Failed to generate workout: $e'));
    }
  }

  Future<void> _onStartWorkout(
    StartWorkout event,
    Emitter<WorkoutState> emit,
  ) async {
    emit(const WorkoutLoading());

    try {
      // Get user preferences
      final prefs = await database.userPreferencesDao.getPreferences();
      final isMetric = prefs?.unitSystem == AppConstants.unitSystemMetric;

      // Generate workout plan
      final planResult = await generateWorkoutForDay(WorkoutDayParams(dayType: event.dayType));

      await planResult.fold(
        (failure) async => emit(WorkoutError(failure.message)),
        (plan) async {
          // Create session
          final session = WorkoutSessionEntity(
            id: 0, // Will be set by database
            dayType: event.dayType,
            dateStarted: DateTime.now(),
            dateCompleted: null,
            isFinalized: false,
          );

          final sessionResult = await sessionRepository.createSession(session);

          await sessionResult.fold(
            (failure) async => emit(WorkoutError(failure.message)),
            (sessionId) async {
              // Create sets for T1 exercise
              final t1Sets = await _createSetsForExercise(
                sessionId: sessionId,
                liftId: plan.t1Exercise.lift.id,
                tier: 'T1',
                sets: plan.t1Exercise.sets,
                reps: plan.t1Exercise.reps,
                weight: plan.t1Exercise.targetWeight,
              );

              // Create sets for T2 exercise
              final t2Sets = await _createSetsForExercise(
                sessionId: sessionId,
                liftId: plan.t2Exercise.lift.id,
                tier: 'T2',
                sets: plan.t2Exercise.sets,
                reps: plan.t2Exercise.reps,
                weight: plan.t2Exercise.targetWeight,
              );

              // Create sets for T3 exercises (accessories)
              final List<WorkoutSetEntity> t3Sets = [];
              for (final t3Plan in plan.t3Exercises) {
                final exerciseSets = await _createSetsForExercise(
                  sessionId: sessionId,
                  liftId: plan.t1Exercise.lift.id, // Use T1 lift ID for T3 cycle state
                  tier: 'T3',
                  sets: t3Plan.sets,
                  reps: t3Plan.reps,
                  weight: t3Plan.targetWeight,
                  exerciseName: t3Plan.exercise.name,
                );
                t3Sets.addAll(exerciseSets);
              }

              final allSets = [...t1Sets, ...t2Sets, ...t3Sets];

              // Save sets to database
              final setsResult = await setRepository.createSets(allSets);

              setsResult.fold(
                (failure) => emit(WorkoutError(failure.message)),
                (_) => emit(WorkoutInProgress(
                  session: session.copyWith(id: sessionId),
                  plan: plan,
                  sets: allSets,
                  isMetric: isMetric,
                )),
              );
            },
          );
        },
      );
    } catch (e) {
      emit(WorkoutError('Failed to start workout: $e'));
    }
  }

  Future<void> _onLogSet(
    LogSet event,
    Emitter<WorkoutState> emit,
  ) async {
    if (state is! WorkoutInProgress) return;

    final currentState = state as WorkoutInProgress;

    try {
      // Find the set to update
      final setIndex = currentState.sets.indexWhere((s) => s.id == event.setId);
      if (setIndex == -1) {
        emit(const WorkoutError('Set not found'));
        return;
      }

      // Update the set
      final updatedSet = currentState.sets[setIndex].copyWith(
        actualReps: event.actualReps,
        actualWeight: event.actualWeight,
      );

      // Update in database
      final result = await setRepository.updateSet(updatedSet);

      result.fold(
        (failure) => emit(WorkoutError(failure.message)),
        (_) {
          // Update state with the logged set
          final updatedSets = List<WorkoutSetEntity>.from(currentState.sets);
          updatedSets[setIndex] = updatedSet;

          emit(currentState.copyWith(sets: updatedSets));
        },
      );
    } catch (e) {
      emit(WorkoutError('Failed to log set: $e'));
    }
  }

  Future<void> _onCompleteWorkout(
    CompleteWorkout event,
    Emitter<WorkoutState> emit,
  ) async {
    if (state is! WorkoutInProgress) return;

    final currentState = state as WorkoutInProgress;

    // Check if all sets are completed
    if (!currentState.allSetsCompleted) {
      emit(const WorkoutError('Not all sets have been completed'));
      return;
    }

    emit(const WorkoutCompleting());

    try {
      // Finalize the session (applies progression)
      final result = await finalizeWorkoutSession(FinalizeSessionParams(
        sessionId: currentState.session.id,
        isMetric: currentState.isMetric,
      ));

      result.fold(
        (failure) => emit(WorkoutError(failure.message)),
        (_) => emit(WorkoutCompleted(currentState.session)),
      );
    } catch (e) {
      emit(WorkoutError('Failed to complete workout: $e'));
    }
  }

  Future<void> _onCancelWorkout(
    CancelWorkout event,
    Emitter<WorkoutState> emit,
  ) async {
    if (state is! WorkoutInProgress) return;

    final currentState = state as WorkoutInProgress;

    try {
      // Delete the session (cascade will delete sets)
      final result = await sessionRepository.deleteSession(currentState.session.id);

      result.fold(
        (failure) => emit(WorkoutError(failure.message)),
        (_) => emit(const WorkoutReady()),
      );
    } catch (e) {
      emit(WorkoutError('Failed to cancel workout: $e'));
    }
  }

  Future<void> _onLoadWorkoutHistory(
    LoadWorkoutHistory event,
    Emitter<WorkoutState> emit,
  ) async {
    emit(const WorkoutLoading());

    try {
      final result = await sessionRepository.getFinalizedSessions();

      result.fold(
        (failure) => emit(WorkoutError(failure.message)),
        (sessions) => emit(WorkoutHistoryLoaded(sessions)),
      );
    } catch (e) {
      emit(WorkoutError('Failed to load workout history: $e'));
    }
  }

  /// Helper method to load an in-progress workout
  Future<void> _loadInProgressWorkout(
    WorkoutSessionEntity session,
    Emitter<WorkoutState> emit,
  ) async {
    try {
      // Get user preferences
      final prefs = await database.userPreferencesDao.getPreferences();
      final isMetric = prefs?.unitSystem == AppConstants.unitSystemMetric;

      // Generate workout plan for the day
      final planResult = await generateWorkoutForDay(WorkoutDayParams(dayType: session.dayType));

      await planResult.fold(
        (failure) async => emit(WorkoutError(failure.message)),
        (plan) async {
          // Load sets for this session
          final setsResult = await setRepository.getSetsForSession(session.id);

          setsResult.fold(
            (failure) => emit(WorkoutError(failure.message)),
            (sets) => emit(WorkoutInProgress(
              session: session,
              plan: plan,
              sets: sets,
              isMetric: isMetric,
            )),
          );
        },
      );
    } catch (e) {
      emit(WorkoutError('Failed to load in-progress workout: $e'));
    }
  }

  /// Helper method to create sets for an exercise
  Future<List<WorkoutSetEntity>> _createSetsForExercise({
    required int sessionId,
    required int liftId,
    required String tier,
    required int sets,
    required int reps,
    required double weight,
    String? exerciseName,
  }) async {
    final setsList = <WorkoutSetEntity>[];

    for (int i = 1; i <= sets; i++) {
      // Last set is AMRAP for T1 and T3
      final isAmrap = (tier == 'T1' || tier == 'T3') && i == sets;

      setsList.add(WorkoutSetEntity(
        id: 0, // Will be set by database
        sessionId: sessionId,
        liftId: liftId,
        tier: tier,
        setNumber: i,
        targetReps: reps,
        actualReps: null,
        targetWeight: weight,
        actualWeight: null,
        isAmrap: isAmrap,
        exerciseName: exerciseName,
      ));
    }

    return setsList;
  }

  /// Handler for updating set notes
  Future<void> _onUpdateSetNotes(
    UpdateSetNotes event,
    Emitter<WorkoutState> emit,
  ) async {
    if (state is! WorkoutInProgress) return;

    final currentState = state as WorkoutInProgress;

    try {
      // Find the set to update
      final setIndex = currentState.sets.indexWhere((s) => s.id == event.setId);
      if (setIndex == -1) {
        emit(const WorkoutError('Set not found'));
        return;
      }

      // Update the set with notes
      final updatedSet = currentState.sets[setIndex].copyWith(
        setNotes: event.notes,
      );

      // Update in database
      final result = await setRepository.updateSet(updatedSet);

      result.fold(
        (failure) => emit(WorkoutError(failure.message)),
        (_) {
          // Update state with the updated set
          final updatedSets = List<WorkoutSetEntity>.from(currentState.sets);
          updatedSets[setIndex] = updatedSet;

          emit(currentState.copyWith(sets: updatedSets));
        },
      );
    } catch (e) {
      emit(WorkoutError('Failed to update set notes: $e'));
    }
  }

  /// Handler for updating session notes
  Future<void> _onUpdateSessionNotes(
    UpdateSessionNotes event,
    Emitter<WorkoutState> emit,
  ) async {
    if (state is! WorkoutInProgress) return;

    final currentState = state as WorkoutInProgress;

    try {
      // Update the session with notes
      final updatedSession = currentState.session.copyWith(
        sessionNotes: event.notes,
      );

      // Update in database
      final result = await sessionRepository.updateSession(updatedSession);

      result.fold(
        (failure) => emit(WorkoutError(failure.message)),
        (_) {
          // Update state with the updated session
          emit(currentState.copyWith(session: updatedSession));
        },
      );
    } catch (e) {
      emit(WorkoutError('Failed to update session notes: $e'));
    }
  }
}
