import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/lift_name_helper.dart';
import '../bloc/workout/workout_bloc.dart';
import '../bloc/workout/workout_event.dart';
import '../bloc/workout/workout_state.dart';
import '../widgets/rest_timer_widget.dart';
import '../widgets/set_card.dart';

/// Active workout page - log sets during an active workout session
class ActiveWorkoutPage extends StatelessWidget {
  const ActiveWorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WorkoutBloc>()..add(const CheckInProgressWorkout()),
      child: BlocConsumer<WorkoutBloc, WorkoutState>(
        listener: (context, state) {
          if (state is WorkoutCompleted) {
            // Navigate back to home after workout completion
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.home,
              (route) => false,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Workout completed! Great job!'),
                backgroundColor: Colors.green,
              ),
            );
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
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is WorkoutInProgress) {
            return _buildActiveWorkoutView(context, state);
          }

          // No workout in progress
          return Scaffold(
            appBar: AppBar(title: const Text('Workout')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'No active workout',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveWorkoutView(
    BuildContext context,
    WorkoutInProgress state,
  ) {
    final currentSet = state.sets
        .where((s) => !s.isCompleted)
        .isNotEmpty
        ? state.sets.firstWhere((s) => !s.isCompleted)
        : state.sets.last;

    return Scaffold(
      appBar: AppBar(
        title: Text('Day ${state.session.dayType} Workout'),
        actions: [
          if (!state.allSetsCompleted)
            TextButton.icon(
              onPressed: () {
                _showQuitWorkoutDialog(context);
              },
              icon: const Icon(Icons.close, color: Colors.red),
              label: const Text(
                'Quit',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: state.progressPercentage,
            minHeight: 8,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${state.completedSetsCount} / ${state.sets.length} sets',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Current set focus area
          if (!state.allSetsCompleted) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Current Set',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            SetCard(
              set: currentSet,
              isMetric: state.isMetric,
              exerciseName: LiftNameHelper.getLiftName(currentSet.liftId),
              onLogSet: (reps, weight) {
                context.read<WorkoutBloc>().add(LogSet(
                      setId: currentSet.id,
                      actualReps: reps,
                      actualWeight: weight,
                    ));
              },
            ),
            const SizedBox(height: 16),
            // Rest timer - key based on completed sets count to restart timer
            if (state.completedSetsCount > 0 &&
                !state.allSetsCompleted)
              RestTimerWidget(
                key: ValueKey('rest_timer_${state.completedSetsCount}'),
              ),
          ],
          const Divider(),
          // All sets list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.sets.length,
              itemBuilder: (context, index) {
                final set = state.sets[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: SetCard(
                    set: set,
                    isMetric: state.isMetric,
                    exerciseName: LiftNameHelper.getLiftName(set.liftId),
                    isCompact: true,
                    onLogSet: set.isCompleted
                        ? null
                        : (reps, weight) {
                            context.read<WorkoutBloc>().add(LogSet(
                                  setId: set.id,
                                  actualReps: reps,
                                  actualWeight: weight,
                                ));
                          },
                  ),
                );
              },
            ),
          ),
          // Complete workout button
          if (state.allSetsCompleted)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<WorkoutBloc>().add(const CompleteWorkout());
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('Complete Workout'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showQuitWorkoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Quit Workout?'),
        content: const Text(
          'Are you sure you want to quit this workout? Your progress will be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Quit'),
          ),
        ],
      ),
    );
  }
}
