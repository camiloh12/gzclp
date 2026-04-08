import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/app_routes.dart';
import '../bloc/new_cycle/new_cycle_cubit.dart';
import '../bloc/new_cycle/new_cycle_state.dart';

class NewCyclePage extends StatelessWidget {
  const NewCyclePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NewCycleCubit>()..loadCompletedCycle(),
      child: BlocConsumer<NewCycleCubit, NewCycleState>(
        listener: (context, state) {
          if (state is NewCycleCreated) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.home,
              (route) => false,
            );
          } else if (state is NewCycleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NewCycleLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state is NewCycleCreating) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Starting new cycle...'),
                  ],
                ),
              ),
            );
          }
          if (state is NewCycleReady) {
            return _NewCycleReadyView(state: state);
          }
          return const Scaffold(
            body: Center(child: Text('Something went wrong')),
          );
        },
      ),
    );
  }
}

class _NewCycleReadyView extends StatelessWidget {
  final NewCycleReady state;
  const _NewCycleReadyView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Start New Cycle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Cycle ${state.completedCycle.cycleNumber} Complete!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '12 weeks • ${state.totalWorkouts} workouts',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Starting weights for Cycle ${state.completedCycle.cycleNumber + 1}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _WeightOptionButton(
              label: 'Keep current weights',
              subtitle: 'Use the same weights you ended with',
              selected: state.keepWeights == true,
              onTap: () => context.read<NewCycleCubit>().selectKeepWeights(),
            ),
            const SizedBox(height: 12),
            _WeightOptionButton(
              label: 'Adjust weights',
              subtitle: 'Edit starting weights for the new cycle',
              selected: state.keepWeights == false,
              onTap: () => context.read<NewCycleCubit>().selectAdjustWeights(),
            ),
            if (state.keepWeights == false) ...[
              const SizedBox(height: 24),
              Text(
                'Starting weights (T1)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ...state.lastCycleWeights.entries.map((entry) {
                final liftId = entry.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _WeightInput(
                    liftId: liftId,
                    initialWeight: state.editedWeights[liftId] ?? entry.value,
                    onChanged: (w) =>
                        context.read<NewCycleCubit>().updateWeight(liftId, w),
                  ),
                );
              }),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: state.keepWeights != null
                  ? () => context.read<NewCycleCubit>().confirmNewCycle()
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Start Cycle ${state.completedCycle.cycleNumber + 1}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightOptionButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _WeightOptionButton({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: selected ? Theme.of(context).colorScheme.primaryContainer : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: selected
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeightInput extends StatefulWidget {
  final int liftId;
  final double initialWeight;
  final ValueChanged<double> onChanged;

  const _WeightInput({
    required this.liftId,
    required this.initialWeight,
    required this.onChanged,
  });

  @override
  State<_WeightInput> createState() => _WeightInputState();
}

class _WeightInputState extends State<_WeightInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialWeight.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Lift #${widget.liftId} weight',
        border: const OutlineInputBorder(),
        suffixText: 'lbs',
      ),
      onChanged: (value) {
        final parsed = double.tryParse(value);
        if (parsed != null) widget.onChanged(parsed);
      },
    );
  }
}
