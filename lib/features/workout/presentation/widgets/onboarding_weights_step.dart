import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_constants.dart';

/// Weight input step - enter training maxes for all lifts
class OnboardingWeightsStep extends StatefulWidget {
  final bool isMetric;
  final Map<int, double> enteredWeights;
  final Function(int liftId, double weight) onWeightEntered;
  final VoidCallback onComplete;

  const OnboardingWeightsStep({
    super.key,
    required this.isMetric,
    required this.enteredWeights,
    required this.onWeightEntered,
    required this.onComplete,
  });

  @override
  State<OnboardingWeightsStep> createState() => _OnboardingWeightsStepState();
}

class _OnboardingWeightsStepState extends State<OnboardingWeightsStep> {
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, String> _liftNames = {
    LiftType.squat: 'Squat',
    LiftType.benchPress: 'Bench Press',
    LiftType.deadlift: 'Deadlift',
    LiftType.overheadPress: 'Overhead Press',
  };

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing values if any
    for (final entry in _liftNames.entries) {
      final liftId = entry.key;
      final existingWeight = widget.enteredWeights[liftId];
      _controllers[liftId] = TextEditingController(
        text: existingWeight?.toString() ?? '',
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _allWeightsEntered {
    return _liftNames.keys.every((liftId) {
      final text = _controllers[liftId]?.text ?? '';
      return text.isNotEmpty && double.tryParse(text) != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.isMetric ? 'kg' : 'lbs';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Enter Your Training Maxes',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Enter your current training maxes or estimated 1RMs for each lift',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'The program will automatically calculate your starting weights',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Expanded(
          child: ListView(
            children: [
              for (final entry in _liftNames.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildWeightInput(
                    context,
                    liftId: entry.key,
                    liftName: entry.value,
                    unit: unit,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _allWeightsEntered
              ? () {
                  // Save all weights before completing
                  for (final entry in _controllers.entries) {
                    final weight = double.parse(entry.value.text);
                    widget.onWeightEntered(entry.key, weight);
                  }
                  widget.onComplete();
                }
              : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Complete Setup'),
        ),
      ],
    );
  }

  Widget _buildWeightInput(
    BuildContext context, {
    required int liftId,
    required String liftName,
    required String unit,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getLiftIcon(liftId),
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  liftName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controllers[liftId],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: 'Training Max',
                suffixText: unit,
                border: const OutlineInputBorder(),
                helperText: 'Enter your current 1RM or training max',
              ),
              onChanged: (value) {
                final weight = double.tryParse(value);
                if (weight != null) {
                  widget.onWeightEntered(liftId, weight);
                }
                setState(() {}); // Trigger rebuild to update button state
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getLiftIcon(int liftId) {
    switch (liftId) {
      case LiftType.squat:
        return Icons.accessibility_new;
      case LiftType.benchPress:
        return Icons.airline_seat_flat;
      case LiftType.deadlift:
        return Icons.fitness_center;
      case LiftType.overheadPress:
        return Icons.pan_tool;
      default:
        return Icons.fitness_center;
    }
  }
}
