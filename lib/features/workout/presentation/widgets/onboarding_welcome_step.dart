import 'package:flutter/material.dart';

/// Welcome step - introduces the app
class OnboardingWelcomeStep extends StatelessWidget {
  final VoidCallback onNext;

  const OnboardingWelcomeStep({
    super.key,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.fitness_center, size: 96, color: Colors.blue),
        const SizedBox(height: 24),
        Text(
          'Welcome to GZCLP Tracker',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Your automated strength training companion',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What you\'ll need:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _buildBulletPoint(context, 'Choose your unit system (lbs/kg)'),
                _buildBulletPoint(
                    context, 'Your current training maxes or estimated 1RMs'),
                _buildBulletPoint(context, '5-10 minutes for setup'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: onNext,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Get Started'),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
