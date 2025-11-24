import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/app_routes.dart';
import '../bloc/session_manager/session_manager_bloc.dart';
import '../bloc/session_manager/session_manager_event.dart';
import '../bloc/session_manager/session_manager_state.dart';

/// Home page - main entry point after onboarding
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SessionManagerBloc>()..add(const CheckInProgressSession()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('GZCLP Tracker'),
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.history);
              },
              tooltip: 'History',
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.settings);
              },
              tooltip: 'Settings',
            ),
          ],
        ),
        body: BlocBuilder<SessionManagerBloc, SessionManagerState>(
          builder: (context, state) {
            if (state is SessionManagerLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SessionManagerError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<SessionManagerBloc>().add(const CheckInProgressSession());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is SessionManagerInProgress) {
              // Resume in-progress workout
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.fitness_center, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Workout in Progress',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Day ${state.session.dayType}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.activeWorkout);
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Continue Workout'),
                    ),
                  ],
                ),
              );
            }

            // SessionManagerNoSession state
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.fitness_center, size: 96, color: Colors.blue),
                  const SizedBox(height: 24),
                  Text(
                    'Ready to Lift!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Phase 3: UI Implementation - Basic Flow Complete',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.startWorkout);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Start Workout'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.dashboard);
                    },
                    icon: const Icon(Icons.analytics),
                    label: const Text('View Dashboard'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                  if (state is SessionManagerNoSession && state.lastSession != null) ...[
                    const SizedBox(height: 24),
                    Card(
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last Workout',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Day ${state.lastSession!.dayType}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              state.lastSession!.dateStarted.toString().substring(0, 16),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
