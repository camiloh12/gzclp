import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/app_routes.dart';
import '../bloc/onboarding/onboarding_bloc.dart';
import '../bloc/onboarding/onboarding_event.dart';
import '../bloc/onboarding/onboarding_state.dart';
import '../widgets/onboarding_unit_step.dart';
import '../widgets/onboarding_weights_step.dart';
import '../widgets/onboarding_welcome_step.dart';

/// Onboarding page - guides user through initial setup
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentStep = 0;
  bool? _selectedIsMetric;
  final Map<int, double> _enteredWeights = {};

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OnboardingBloc>(),
      child: BlocConsumer<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingSuccess) {
            // Navigate to home after successful onboarding
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
          } else if (state is OnboardingError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is OnboardingCompleting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            appBar: _currentStep > 0
                ? AppBar(
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        setState(() {
                          _currentStep--;
                        });
                      },
                    ),
                    title: Text('Setup ${_currentStep + 1}/3'),
                  )
                : null,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: _buildCurrentStep(context),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return OnboardingWelcomeStep(
          onNext: () {
            setState(() {
              _currentStep = 1;
            });
          },
        );
      case 1:
        return OnboardingUnitStep(
          initialIsMetric: _selectedIsMetric,
          onUnitSelected: (isMetric) {
            print('[OnboardingPage] Unit selected: $isMetric');
            _selectedIsMetric = isMetric;
            print('[OnboardingPage] Dispatching SelectUnitSystem event');
            context.read<OnboardingBloc>().add(SelectUnitSystem(isMetric));
            print('[OnboardingPage] SelectUnitSystem event dispatched');
          },
          onNext: () {
            if (_selectedIsMetric != null) {
              setState(() {
                _currentStep = 2;
              });
            }
          },
        );
      case 2:
        return OnboardingWeightsStep(
          isMetric: _selectedIsMetric ?? false,
          enteredWeights: const {},
          onWeightEntered: (liftId, weight) {
            _enteredWeights[liftId] = weight;
          },
          onComplete: () {
            print('[OnboardingPage] Complete button clicked');
            print('[OnboardingPage] _enteredWeights: $_enteredWeights');
            // Submit all entered weights using SetLiftWeights events
            final bloc = context.read<OnboardingBloc>();
            for (final entry in _enteredWeights.entries) {
              final liftId = entry.key;
              final trainingMax = entry.value;

              // Calculate T1, T2, T3 weights from training max
              // T1 = 85% of training max, T2 = 65%, T3 = 50%
              final t1Weight = trainingMax * 0.85;
              final t2Weight = trainingMax * 0.65;
              final t3Weight = trainingMax * 0.50;

              print('[OnboardingPage] Adding SetLiftWeights for lift $liftId: T1=$t1Weight, T2=$t2Weight, T3=$t3Weight');
              bloc.add(SetLiftWeights(
                liftId: liftId,
                liftName: _getLiftName(liftId),
                t1Weight: t1Weight,
                t2Weight: t2Weight,
                t3Weight: t3Weight,
              ));
            }

            // Finally, complete onboarding
            print('[OnboardingPage] Adding CompleteOnboarding event with isMetric=$_selectedIsMetric');
            if (_selectedIsMetric != null) {
              bloc.add(CompleteOnboarding(_selectedIsMetric!));
            } else {
              print('[OnboardingPage] ERROR: _selectedIsMetric is null!');
            }
          },
        );
      default:
        return OnboardingWelcomeStep(
          onNext: () {
            setState(() {
              _currentStep = 1;
            });
          },
        );
    }
  }

  String _getLiftName(int liftId) {
    switch (liftId) {
      case LiftType.squat:
        return 'Squat';
      case LiftType.benchPress:
        return 'Bench Press';
      case LiftType.deadlift:
        return 'Deadlift';
      case LiftType.overheadPress:
        return 'Overhead Press';
      default:
        return 'Unknown';
    }
  }
}
