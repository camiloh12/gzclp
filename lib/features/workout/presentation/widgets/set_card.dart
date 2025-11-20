import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/workout_set_entity.dart';
import 'amrap_guidance_dialog.dart';
import 'notes_dialog.dart';

/// Card widget for displaying and logging a set
class SetCard extends StatefulWidget {
  final WorkoutSetEntity set;
  final bool isMetric;
  final String? exerciseName;
  final Function(int reps, double? weight)? onLogSet;
  final Function(String? notes)? onNotesChanged;
  final bool isCompact;

  const SetCard({
    super.key,
    required this.set,
    required this.isMetric,
    this.exerciseName,
    this.onLogSet,
    this.onNotesChanged,
    this.isCompact = false,
  });

  @override
  State<SetCard> createState() => _SetCardState();
}

class _SetCardState extends State<SetCard> {
  late TextEditingController _repsController;
  late TextEditingController _weightController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _repsController = TextEditingController(
      text: widget.set.actualReps?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: widget.set.actualWeight?.toString() ?? widget.set.targetWeight.toString(),
    );
  }

  @override
  void didUpdateWidget(SetCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset controllers when the set changes
    if (oldWidget.set.id != widget.set.id) {
      _repsController.text = widget.set.actualReps?.toString() ?? '';
      _weightController.text = widget.set.actualWeight?.toString() ?? widget.set.targetWeight.toString();
    }
  }

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _showAmrapGuidance(BuildContext context) {
    AmrapGuidanceDialog.show(
      context: context,
      tier: widget.set.tier,
      targetReps: widget.set.targetReps,
      previousAmrapReps: null, // TODO: Get from previous workout history
    );
  }

  Future<void> _showNotesDialog(BuildContext context) async {
    final notes = await NotesDialog.showSetNotes(
      context: context,
      initialNotes: widget.set.setNotes,
    );

    if (notes != null || notes != widget.set.setNotes) {
      widget.onNotesChanged?.call(notes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.isMetric ? 'kg' : 'lbs';

    if (widget.isCompact) {
      return _buildCompactCard(context, unit);
    }

    return _buildFullCard(context, unit);
  }

  Widget _buildCompactCard(BuildContext context, String unit) {
    final displayName = widget.exerciseName ?? 'Exercise ${widget.set.liftId}';

    return Card(
      color: widget.set.isCompleted
          ? Colors.green.withValues(alpha: 0.1)
          : null,
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: widget.set.isCompleted
                ? Colors.green
                : Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: widget.set.isCompleted
                ? const Icon(Icons.check, color: Colors.white)
                : Text(
                    '${widget.set.setNumber}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
          ),
        ),
        title: Text(
          '$displayName - ${widget.set.tier}',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Text(
          widget.set.isCompleted
              ? '${widget.set.actualReps} reps @ ${widget.set.actualWeight} $unit'
              : '${widget.set.targetReps}${widget.set.isAmrap ? '+' : ''} reps @ ${widget.set.targetWeight} $unit',
        ),
        trailing: widget.set.isCompleted
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
      ),
    );
  }

  Widget _buildFullCard(BuildContext context, String unit) {
    final displayName = widget.exerciseName ?? 'Exercise ${widget.set.liftId}';

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getTierColor(widget.set.tier),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.set.tier,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      displayName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${widget.set.setNumber}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Target info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.track_changes),
                    const SizedBox(width: 8),
                    Text(
                      'Target: ${widget.set.targetReps}${widget.set.isAmrap ? '+' : ''} reps @ ${widget.set.targetWeight} $unit',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              if (widget.set.isAmrap) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _showAmrapGuidance(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange, width: 2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.flash_on, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AMRAP SET - As Many Reps As Possible',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade900,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap for guidance and tips',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.orange.shade700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.help_outline, color: Colors.orange),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              // Input fields
              if (!widget.set.isCompleted) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _repsController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: 'Reps Completed',
                          border: const OutlineInputBorder(),
                          suffixIcon: const Icon(Icons.fitness_center),
                          helperText: widget.set.isAmrap ? 'Total reps' : null,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'),
                          ),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Weight',
                          border: const OutlineInputBorder(),
                          suffixText: unit,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Notes button
                    OutlinedButton.icon(
                      onPressed: () => _showNotesDialog(context),
                      icon: Icon(
                        widget.set.setNotes != null && widget.set.setNotes!.isNotEmpty
                            ? Icons.note
                            : Icons.note_add,
                      ),
                      label: const Text('Notes'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Log Set button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final reps = int.parse(_repsController.text);
                            final weight = double.parse(_weightController.text);
                            widget.onLogSet?.call(reps, weight);
                          }
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Log Set'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Completed: ${widget.set.actualReps} reps @ ${widget.set.actualWeight} $unit',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.green.shade900,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      if (widget.set.setNotes != null && widget.set.setNotes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.note, size: 16, color: Colors.green.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.set.setNotes!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.green.shade800,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'T1':
        return Colors.red;
      case 'T2':
        return Colors.blue;
      case 'T3':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
