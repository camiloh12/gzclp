import 'package:get_it/get_it.dart';

import '../../features/workout/data/datasources/local/app_database.dart';
import '../../features/workout/data/repositories/accessory_exercise_repository_impl.dart';
import '../../features/workout/data/repositories/cycle_state_repository_impl.dart';
import '../../features/workout/data/repositories/lift_repository_impl.dart';
import '../../features/workout/data/repositories/workout_session_repository_impl.dart';
import '../../features/workout/data/repositories/workout_set_repository_impl.dart';
import '../../features/workout/domain/repositories/accessory_exercise_repository.dart';
import '../../features/workout/domain/repositories/cycle_state_repository.dart';
import '../../features/workout/domain/repositories/lift_repository.dart';
import '../../features/workout/domain/repositories/workout_session_repository.dart';
import '../../features/workout/domain/repositories/workout_set_repository.dart';
import '../../features/workout/domain/usecases/calculate_t1_progression.dart';
import '../../features/workout/domain/usecases/calculate_t2_progression.dart';
import '../../features/workout/domain/usecases/calculate_t3_progression.dart';
import '../../features/workout/domain/usecases/finalize_workout_session.dart';
import '../../features/workout/domain/usecases/generate_workout_for_day.dart';
import '../../features/workout/presentation/bloc/onboarding/onboarding_bloc.dart'
    as features;
import '../../features/workout/presentation/bloc/workout/workout_bloc.dart'
    as features;

/// Dependency Injection Container
///
/// This service locator provides global access to all registered dependencies
/// throughout the application. Uses the GetIt package for service location.
final sl = GetIt.instance;

/// Initialize all dependencies for the application
///
/// This function should be called once during app startup before runApp().
/// It registers all services, repositories, use cases, and BLoCs with the
/// dependency injection container.
Future<void> init() async {
  //! Phase 1: Database and DAOs
  // Register database as singleton
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // DAOs are accessed through the database instance
  // Example: sl<AppDatabase>().liftsDao

  //! Phase 2: Repositories
  sl.registerLazySingleton<LiftRepository>(
    () => LiftRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<CycleStateRepository>(
    () => CycleStateRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<WorkoutSessionRepository>(
    () => WorkoutSessionRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<WorkoutSetRepository>(
    () => WorkoutSetRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<AccessoryExerciseRepository>(
    () => AccessoryExerciseRepositoryImpl(sl()),
  );

  //! Phase 2: Use Cases - Progression Logic
  sl.registerLazySingleton(() => CalculateT1Progression());
  sl.registerLazySingleton(() => CalculateT2Progression());
  sl.registerLazySingleton(() => CalculateT3Progression());

  sl.registerLazySingleton(
    () => FinalizeWorkoutSession(
      sessionRepository: sl(),
      setRepository: sl(),
      cycleStateRepository: sl(),
      liftRepository: sl(),
      calculateT1Progression: sl(),
      calculateT2Progression: sl(),
      calculateT3Progression: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => GenerateWorkoutForDay(
      liftRepository: sl(),
      cycleStateRepository: sl(),
      accessoryExerciseRepository: sl(),
    ),
  );

  //! Phase 3: BLoCs
  // Note: BLoCs are registered as factories (new instance each time)
  // They will be provided at widget level via BlocProvider

  // Onboarding BLoC
  sl.registerFactory(
    () => features.OnboardingBloc(
      liftRepository: sl(),
      cycleStateRepository: sl(),
      accessoryExerciseRepository: sl(),
      database: sl(),
    ),
  );

  // Workout BLoC
  sl.registerFactory(
    () => features.WorkoutBloc(
      generateWorkoutForDay: sl(),
      sessionRepository: sl(),
      setRepository: sl(),
      finalizeWorkoutSession: sl(),
      database: sl(),
    ),
  );

  //! Phase 4: External dependencies
  // TODO: Register external dependencies (SharedPreferences, etc.) once needed
}
