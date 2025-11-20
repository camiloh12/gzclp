import 'package:flutter/material.dart';

import '../../../../core/constants/t3_exercise_suggestions.dart';

/// T3 Exercise Selection Step for Onboarding
///
/// Allows the user to select one accessory exercise for each workout day (A/B/C/D).
/// Shows pre-populated suggestions but users can also type custom exercises.
class OnboardingT3Step extends StatefulWidget {
  final Map<String, String> selectedExercises;
  final Function(Map<String, String>) onExercisesSelected;
  final VoidCallback onBack;

  const OnboardingT3Step({
    super.key,
    required this.selectedExercises,
    required this.onExercisesSelected,
    required this.onBack,
  });

  @override
  State<OnboardingT3Step> createState() => _OnboardingT3StepState();
}

class _OnboardingT3StepState extends State<OnboardingT3Step> {
  late Map<String, String> _selectedExercises;
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _selectedExercises = Map.from(widget.selectedExercises);

    // Initialize with defaults if empty
    if (_selectedExercises.isEmpty) {
      _selectedExercises = Map.from(T3ExerciseSuggestions.defaults);
    }

    // Create controllers for each day
    _controllers = {
      'A': TextEditingController(text: _selectedExercises['A'] ?? ''),
      'B': TextEditingController(text: _selectedExercises['B'] ?? ''),
      'C': TextEditingController(text: _selectedExercises['C'] ?? ''),
      'D': TextEditingController(text: _selectedExercises['D'] ?? ''),
    };

    // Listen to text changes
    _controllers.forEach((dayType, controller) {
      controller.addListener(() {
        setState(() {
          _selectedExercises[dayType] = controller.text;
        });
      });
    });
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  bool _allExercisesSelected() {
    return _selectedExercises.length == 4 &&
        _selectedExercises.values.every((name) => name.isNotEmpty);
  }

  void _handleContinue() {
    if (_allExercisesSelected()) {
      widget.onExercisesSelected(_selectedExercises);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            'Step 3: T3 Accessories',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select one accessory exercise (T3) for each workout day',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          // Exercise selection for each day
          Expanded(
            child: ListView(
              children: [
                _buildDayExerciseSelector(context, 'A', 'Squat Day'),
                const SizedBox(height: 16),
                _buildDayExerciseSelector(context, 'B', 'Bench Day'),
                const SizedBox(height: 16),
                _buildDayExerciseSelector(context, 'C', 'Bench/Back Day'),
                const SizedBox(height: 16),
                _buildDayExerciseSelector(context, 'D', 'Deadlift Day'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Navigation buttons
          Row(
            children: [
              OutlinedButton(
                onPressed: widget.onBack,
                child: const Text('Back'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: _allExercisesSelected() ? _handleContinue : null,
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayExerciseSelector(
    BuildContext context,
    String dayType,
    String dayName,
  ) {
    final suggestions = T3ExerciseSuggestions.forDay(dayType);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      dayType,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day $dayType',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        dayName,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Exercise dropdown with search
            DropdownMenu<String>(
              width: MediaQuery.of(context).size.width - 80,
              initialSelection: _controllers[dayType]!.text.isEmpty
                  ? null
                  : _controllers[dayType]!.text,
              controller: _controllers[dayType],
              label: const Text('Exercise'),
              hintText: 'Select or type an exercise',
              enableFilter: true,
              enableSearch: true,
              requestFocusOnTap: true,
              leadingIcon: const Icon(Icons.fitness_center),
              trailingIcon: _controllers[dayType]!.text.isNotEmpty
                  ? Icon(Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary)
                  : const Icon(Icons.arrow_drop_down),
              inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(),
              ),
              onSelected: (String? value) {
                if (value != null) {
                  setState(() {
                    _controllers[dayType]!.text = value;
                  });
                }
              },
              dropdownMenuEntries: suggestions.map<DropdownMenuEntry<String>>(
                (String exercise) {
                  return DropdownMenuEntry<String>(
                    value: exercise,
                    label: exercise,
                  );
                },
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
