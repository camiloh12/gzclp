import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/app_routes.dart';
import '../bloc/workout/workout_bloc.dart';
import '../bloc/workout/workout_event.dart';
import '../bloc/workout/workout_state.dart';

/// Start workout page - day selection
class StartWorkoutPage extends StatelessWidget {
  const StartWorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WorkoutBloc>(),
      child: BlocConsumer<WorkoutBloc, WorkoutState>(
        listener: (context, state) {
          if (state is WorkoutInProgress) {
            // Navigate to active workout page
            Navigator.of(context).pushReplacementNamed(AppRoutes.activeWorkout);
          } else if (state is WorkoutError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WorkoutLoading) {
            return Scaffold(
              appBar: AppBar(title: const Text('Start Workout')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          return _buildDaySelection(context);
        },
      ),
    );
  }

  Widget _buildDaySelection(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Workout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Workout Day',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '4-day GZCLP rotation',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildDayCard(
                    context,
                    'A',
                    'Squat (T1)',
                    'Overhead Press (T2)',
                  ),
                  const SizedBox(height: 12),
                  _buildDayCard(
                    context,
                    'B',
                    'Bench Press (T1)',
                    'Deadlift (T2)',
                  ),
                  const SizedBox(height: 12),
                  _buildDayCard(
                    context,
                    'C',
                    'Bench Press (T1)',
                    'Squat (T2)',
                  ),
                  const SizedBox(height: 12),
                  _buildDayCard(
                    context,
                    'D',
                    'Deadlift (T1)',
                    'Overhead Press (T2)',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Phase 3: UI Foundation\nWorkout execution flow coming in next iteration',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCard(
    BuildContext context,
    String dayType,
    String t1Lift,
    String t2Lift,
  ) {
    return Card(
      child: InkWell(
        onTap: () {
          // Start workout for selected day
          context.read<WorkoutBloc>().add(StartWorkout(dayType));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        dayType,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Day $dayType',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              _buildLiftRow(context, 'T1', t1Lift),
              const SizedBox(height: 4),
              _buildLiftRow(context, 'T2', t2Lift),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiftRow(BuildContext context, String tier, String liftName) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: tier == 'T1'
                ? Colors.red.withValues(alpha: 0.2)
                : Colors.blue.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            tier,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: tier == 'T1'
                      ? Colors.red.shade900
                      : Colors.blue.shade900,
                ),
          ),
        ),
        const SizedBox(width: 8),
        Text(liftName, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
