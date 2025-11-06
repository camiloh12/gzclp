import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../data/datasources/local/app_database.dart';
import '../../../domain/repositories/cycle_state_repository.dart';
import '../../../domain/repositories/lift_repository.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

/// BLoC for managing onboarding flow
///
/// Handles:
/// - Checking onboarding status
/// - Unit system selection
/// - Lift initialization
/// - Initial weight input for T1/T2/T3
/// - Saving preferences and cycle states
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final LiftRepository liftRepository;
  final CycleStateRepository cycleStateRepository;
  final AppDatabase database;

  OnboardingBloc({
    required this.liftRepository,
    required this.cycleStateRepository,
    required this.database,
  }) : super(const OnboardingInitial()) {
    on<CheckOnboardingStatus>(_onCheckOnboardingStatus);
    on<SelectUnitSystem>(_onSelectUnitSystem);
    on<SetLiftWeights>(_onSetLiftWeights);
    on<CompleteOnboarding>(_onCompleteOnboarding);
    on<ResetOnboarding>(_onResetOnboarding);
  }

  Future<void> _onCheckOnboardingStatus(
    CheckOnboardingStatus event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingCheckingStatus());

    try {
      // Check if user has completed onboarding
      final hasCompleted = await database.userPreferencesDao.hasCompletedOnboarding();

      if (hasCompleted) {
        emit(const OnboardingAlreadyComplete());
      } else {
        // Start onboarding at step 0 (unit selection)
        emit(const OnboardingInProgress(currentStep: 0));
      }
    } catch (e) {
      // If database check fails (first run), default to onboarding
      emit(const OnboardingInProgress(currentStep: 0));
    }
  }

  Future<void> _onSelectUnitSystem(
    SelectUnitSystem event,
    Emitter<OnboardingState> emit,
  ) async {
    print('[OnboardingBloc] SelectUnitSystem called, isMetric: ${event.isMetric}');

    // Initialize lifts in the database
    final initResult = await liftRepository.initializeMainLifts();

    initResult.fold(
      (failure) => emit(OnboardingError('Failed to initialize lifts: ${failure.message}')),
      (_) {
        // Transition to OnboardingInProgress with unit system selected
        emit(OnboardingInProgress(
          currentStep: 1,
          isMetric: event.isMetric,
        ));
      },
    );
  }

  Future<void> _onSetLiftWeights(
    SetLiftWeights event,
    Emitter<OnboardingState> emit,
  ) async {
    print('[OnboardingBloc] SetLiftWeights called for lift ${event.liftId}: ${event.liftName}');

    // Get or create OnboardingInProgress state
    final OnboardingInProgress currentState;
    if (state is OnboardingInProgress) {
      currentState = state as OnboardingInProgress;
      print('[OnboardingBloc] Using existing OnboardingInProgress state');
    } else {
      print('[OnboardingBloc] State is $state, creating new OnboardingInProgress state');
      // Create initial state - we'll need to get isMetric from somewhere
      // For now, we'll keep existing entered weights and create the state
      currentState = const OnboardingInProgress(currentStep: 2);
    }

    // Add the entered weights to the map
    final updatedWeights = Map<int, LiftWeights>.from(currentState.enteredWeights);
    updatedWeights[event.liftId] = LiftWeights(
      liftId: event.liftId,
      liftName: event.liftName,
      t1Weight: event.t1Weight,
      t2Weight: event.t2Weight,
      t3Weight: event.t3Weight,
    );

    print('[OnboardingBloc] Updated weights count: ${updatedWeights.length}/4');

    // If we've entered weights for all 4 lifts, stay at step 4
    // Otherwise advance to next lift
    final nextStep = updatedWeights.length >= 4 ? 4 : currentState.currentStep + 1;

    emit(currentState.copyWith(
      currentStep: nextStep,
      enteredWeights: updatedWeights,
    ));
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    print('[OnboardingBloc] CompleteOnboarding called with isMetric: ${event.isMetric}');
    print('[OnboardingBloc] Current state: $state');

    // Get the current state or use event data
    final Map<int, LiftWeights> enteredWeights;
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      enteredWeights = currentState.enteredWeights;
      print('[OnboardingBloc] Using weights from state: ${enteredWeights.length}');
    } else {
      print('[OnboardingBloc] WARNING: State is not OnboardingInProgress, no weights in state');
      emit(const OnboardingError('Onboarding state was lost. Please try again.'));
      return;
    }

    print('[OnboardingBloc] enteredWeights count: ${enteredWeights.length}');

    // Validate we have all required data
    if (enteredWeights.length != 4) {
      print('[OnboardingBloc] ERROR: Not all weights entered (${enteredWeights.length}/4)');
      emit(const OnboardingError('Not all lift weights have been entered'));
      return;
    }

    print('[OnboardingBloc] Validation passed, emitting OnboardingCompleting');
    emit(const OnboardingCompleting());

    try {
      print('[OnboardingBloc] Initializing cycle states for ${enteredWeights.length} lifts');
      // Save cycle states for each lift
      for (final weights in enteredWeights.values) {
        print('[OnboardingBloc] Initializing cycle state for ${weights.liftName}');
        final result = await cycleStateRepository.initializeCycleStatesForLift(
          liftId: weights.liftId,
          t1StartWeight: weights.t1Weight,
          t2StartWeight: weights.t2Weight,
          t3StartWeight: weights.t3Weight,
        );

        // Check if initialization failed
        if (result.isLeft()) {
          print('[OnboardingBloc] ERROR: Failed to initialize cycle states for ${weights.liftName}');
          emit(OnboardingError('Failed to initialize cycle states for ${weights.liftName}'));
          return;
        }
      }

      print('[OnboardingBloc] Initializing user preferences');
      // Initialize and save user preferences
      await database.userPreferencesDao.initializePreferences();

      print('[OnboardingBloc] Updating preferences with unit system');
      // Update preferences with selected unit system and mark onboarding complete
      await database.userPreferencesDao.updatePreferenceFields(
        unitSystem: event.isMetric ? AppConstants.unitSystemMetric : AppConstants.unitSystemImperial,
        hasCompletedOnboarding: true,
      );

      print('[OnboardingBloc] Onboarding completed successfully!');
      emit(const OnboardingSuccess());
    } catch (e) {
      print('[OnboardingBloc] ERROR during completion: $e');
      emit(OnboardingError('Failed to complete onboarding: $e'));
    }
  }

  Future<void> _onResetOnboarding(
    ResetOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      // Reset onboarding flag in preferences
      await database.userPreferencesDao.updatePreferenceFields(
        hasCompletedOnboarding: false,
      );

      emit(const OnboardingInProgress(currentStep: 0));
    } catch (e) {
      emit(OnboardingError('Failed to reset onboarding: $e'));
    }
  }
}
