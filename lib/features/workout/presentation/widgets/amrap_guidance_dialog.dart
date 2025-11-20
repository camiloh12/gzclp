import 'package:flutter/material.dart';

/// Dialog that provides guidance for AMRAP (As Many Reps As Possible) sets
class AmrapGuidanceDialog extends StatelessWidget {
  final String tier;
  final int targetReps;
  final int? previousAmrapReps;

  const AmrapGuidanceDialog({
    super.key,
    required this.tier,
    required this.targetReps,
    this.previousAmrapReps,
  });

  /// Shows the AMRAP guidance dialog
  static Future<void> show({
    required BuildContext context,
    required String tier,
    required int targetReps,
    int? previousAmrapReps,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AmrapGuidanceDialog(
        tier: tier,
        targetReps: targetReps,
        previousAmrapReps: previousAmrapReps,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(
        Icons.flash_on,
        color: Colors.orange,
        size: 48,
      ),
      title: Text(
        'AMRAP Set Guidance',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // What is AMRAP
            _buildSectionTitle(context, 'What is AMRAP?'),
            const SizedBox(height: 8),
            _buildInfoText(
              context,
              'AMRAP means "As Many Reps As Possible". This is your final set where you push for maximum reps.',
            ),
            const SizedBox(height: 16),

            // Target
            _buildSectionTitle(context, 'Your Target'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.track_changes,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Minimum: $targetReps reps\nGo for as many as you can!',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Previous performance (if available)
            if (previousAmrapReps != null) ...[
              _buildSectionTitle(context, 'Last Time'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history, color: Colors.blue),
                    const SizedBox(width: 12),
                    Text(
                      'You did $previousAmrapReps reps',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Key Guidelines
            _buildSectionTitle(context, 'Key Guidelines'),
            const SizedBox(height: 8),
            _buildGuideline(
              context,
              icon: Icons.warning_amber,
              iconColor: Colors.orange,
              text: 'Leave 1-2 reps in reserve (RIR 1-2)',
            ),
            const SizedBox(height: 8),
            _buildGuideline(
              context,
              icon: Icons.fitness_center,
              iconColor: Colors.green,
              text: 'Focus on maintaining good form',
            ),
            const SizedBox(height: 8),
            _buildGuideline(
              context,
              icon: Icons.stop_circle_outlined,
              iconColor: Colors.red,
              text: 'Stop if form breaks down',
            ),
            const SizedBox(height: 16),

            // Tier-specific advice
            _buildTierSpecificAdvice(context),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Got it!'),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  Widget _buildInfoText(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  Widget _buildGuideline(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildTierSpecificAdvice(BuildContext context) {
    String advice;
    Color backgroundColor;
    Color borderColor;

    switch (tier) {
      case 'T1':
        advice = 'T1 AMRAP: This is a heavy set. Focus on explosiveness and technique.';
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        borderColor = Colors.red;
        break;
      case 'T2':
        advice = 'T2 AMRAP: Moderate weight. Maintain steady tempo and control.';
        backgroundColor = Colors.blue.withValues(alpha: 0.1);
        borderColor = Colors.blue;
        break;
      case 'T3':
        advice = 'T3 AMRAP: Target 25+ reps to increase weight next time!';
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        borderColor = Colors.green;
        break;
      default:
        advice = 'Push hard but maintain good form!';
        backgroundColor = Colors.grey.withValues(alpha: 0.1);
        borderColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: borderColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              advice,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: borderColor.withValues(alpha: 0.9),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
