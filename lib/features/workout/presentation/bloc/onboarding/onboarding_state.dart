import 'package:equatable/equatable.dart';

/// States for onboarding flow
abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

/// Checking if onboarding is complete
class OnboardingCheckingStatus extends OnboardingState {
  const OnboardingCheckingStatus();
}

/// Onboarding is already complete
class OnboardingAlreadyComplete extends OnboardingState {
  const OnboardingAlreadyComplete();
}

/// Onboarding in progress
class OnboardingInProgress extends OnboardingState {
  final int currentStep; // 0: unit selection, 1-4: lift weights
  final bool? isMetric;
  final Map<int, LiftWeights> enteredWeights;

  const OnboardingInProgress({
    required this.currentStep,
    this.isMetric,
    this.enteredWeights = const {},
  });

  OnboardingInProgress copyWith({
    int? currentStep,
    bool? isMetric,
    Map<int, LiftWeights>? enteredWeights,
  }) {
    return OnboardingInProgress(
      currentStep: currentStep ?? this.currentStep,
      isMetric: isMetric ?? this.isMetric,
      enteredWeights: enteredWeights ?? this.enteredWeights,
    );
  }

  @override
  List<Object?> get props => [currentStep, isMetric, enteredWeights];
}

/// Completing onboarding (saving to database)
class OnboardingCompleting extends OnboardingState {
  const OnboardingCompleting();
}

/// Onboarding completed successfully
class OnboardingSuccess extends OnboardingState {
  const OnboardingSuccess();
}

/// Error during onboarding
class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Helper class to store lift weights
class LiftWeights extends Equatable {
  final int liftId;
  final String liftName;
  final double t1Weight;
  final double t2Weight;
  final double t3Weight;

  const LiftWeights({
    required this.liftId,
    required this.liftName,
    required this.t1Weight,
    required this.t2Weight,
    required this.t3Weight,
  });

  @override
  List<Object?> get props => [liftId, liftName, t1Weight, t2Weight, t3Weight];
}
