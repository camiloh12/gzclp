import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../data/datasources/local/app_database.dart';
import '../../../domain/usecases/generate_workout_for_day.dart';
import 'workout_generation_event.dart';
import 'workout_generation_state.dart';

class WorkoutGenerationBloc extends Bloc<WorkoutGenerationEvent, WorkoutGenerationState> {
  final GenerateWorkoutForDay generateWorkoutForDay;
  final AppDatabase database;

  WorkoutGenerationBloc({
    required this.generateWorkoutForDay,
    required this.database,
  }) : super(const WorkoutGenerationInitial()) {
    on<GenerateWorkout>(_onGenerateWorkout);
  }

  Future<void> _onGenerateWorkout(
    GenerateWorkout event,
    Emitter<WorkoutGenerationState> emit,
  ) async {
    emit(const WorkoutGenerationLoading());

    try {
      // Get user preferences for unit system
      final prefs = await database.userPreferencesDao.getPreferences();
      final isMetric = prefs?.unitSystem == AppConstants.unitSystemMetric;

      // Generate workout plan
      final result = await generateWorkoutForDay(WorkoutDayParams(dayType: event.dayType));

      result.fold(
        (failure) => emit(WorkoutGenerationError(failure.message)),
        (plan) => emit(WorkoutGenerationLoaded(plan: plan, isMetric: isMetric)),
      );
    } catch (e) {
      emit(WorkoutGenerationError('Failed to generate workout: $e'));
    }
  }
}
