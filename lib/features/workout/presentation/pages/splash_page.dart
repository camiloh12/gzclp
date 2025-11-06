import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/app_routes.dart';
import '../bloc/onboarding/onboarding_bloc.dart';
import '../bloc/onboarding/onboarding_event.dart';
import '../bloc/onboarding/onboarding_state.dart';

/// Splash screen that checks onboarding status and routes accordingly
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OnboardingBloc>()..add(const CheckOnboardingStatus()),
      child: BlocListener<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingAlreadyComplete) {
            // User has completed onboarding, go to home
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
          } else if (state is OnboardingInProgress) {
            // User needs to complete onboarding
            Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
          } else if (state is OnboardingError) {
            // On error, default to onboarding (safe fallback)
            // Show error message briefly
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // Navigate to onboarding after short delay
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
              }
            });
          }
        },
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'GZCLP Tracker',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
