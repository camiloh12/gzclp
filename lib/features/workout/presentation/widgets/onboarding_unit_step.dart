import 'package:flutter/material.dart';

/// Unit selection step - choose between metric (kg) and imperial (lbs)
class OnboardingUnitStep extends StatefulWidget {
  final bool? initialIsMetric;
  final Function(bool) onUnitSelected;
  final VoidCallback onNext;

  const OnboardingUnitStep({
    super.key,
    this.initialIsMetric,
    required this.onUnitSelected,
    required this.onNext,
  });

  @override
  State<OnboardingUnitStep> createState() => _OnboardingUnitStepState();
}

class _OnboardingUnitStepState extends State<OnboardingUnitStep> {
  bool? _selectedIsMetric;

  @override
  void initState() {
    super.initState();
    _selectedIsMetric = widget.initialIsMetric;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Choose Your Unit System',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Select the unit system you prefer for tracking weights',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        _buildUnitCard(
          context,
          title: 'Metric (kg)',
          description: 'Kilograms - Standard for most of the world',
          icon: Icons.public,
          isSelected: _selectedIsMetric == true,
          onTap: () {
            setState(() => _selectedIsMetric = true);
            widget.onUnitSelected(true);
          },
        ),
        const SizedBox(height: 16),
        _buildUnitCard(
          context,
          title: 'Imperial (lbs)',
          description: 'Pounds - Common in the United States',
          icon: Icons.flag,
          isSelected: _selectedIsMetric == false,
          onTap: () {
            setState(() => _selectedIsMetric = false);
            widget.onUnitSelected(false);
          },
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _selectedIsMetric != null ? widget.onNext : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _buildUnitCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 48,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isSelected
                                ? Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                : null,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                : null,
                          ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
