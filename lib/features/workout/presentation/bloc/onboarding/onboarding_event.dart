import 'package:equatable/equatable.dart';

/// Events for onboarding flow
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Check if onboarding has been completed
class CheckOnboardingStatus extends OnboardingEvent {
  const CheckOnboardingStatus();
}

/// User selected unit system
class SelectUnitSystem extends OnboardingEvent {
  final bool isMetric;

  const SelectUnitSystem(this.isMetric);

  @override
  List<Object?> get props => [isMetric];
}

/// User entered starting weights for a lift
class SetLiftWeights extends OnboardingEvent {
  final int liftId;
  final String liftName;
  final double t1Weight;
  final double t2Weight;
  final double t3Weight;

  const SetLiftWeights({
    required this.liftId,
    required this.liftName,
    required this.t1Weight,
    required this.t2Weight,
    required this.t3Weight,
  });

  @override
  List<Object?> get props => [liftId, liftName, t1Weight, t2Weight, t3Weight];
}

/// Complete the onboarding process
class CompleteOnboarding extends OnboardingEvent {
  final bool isMetric;

  const CompleteOnboarding(this.isMetric);

  @override
  List<Object?> get props => [isMetric];
}

/// Reset onboarding (for testing/debugging)
class ResetOnboarding extends OnboardingEvent {
  const ResetOnboarding();
}
