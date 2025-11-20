import 'package:flutter/material.dart';

/// Dialog for adding/editing notes on sets or sessions
class NotesDialog extends StatefulWidget {
  final String? initialNotes;
  final String title;
  final String hint;
  final List<String> quickNotes;

  const NotesDialog({
    super.key,
    this.initialNotes,
    required this.title,
    this.hint = 'Add notes...',
    this.quickNotes = const [],
  });

  /// Shows a dialog for editing set notes
  static Future<String?> showSetNotes({
    required BuildContext context,
    String? initialNotes,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => NotesDialog(
        initialNotes: initialNotes,
        title: 'Set Notes',
        hint: 'How did this set feel?',
        quickNotes: const [
          'Easy',
          'Moderate',
          'Tough',
          'Failed rep',
          'Form breakdown',
          'Good form',
          'Felt strong',
          'Fatigued',
        ],
      ),
    );
  }

  /// Shows a dialog for editing session notes
  static Future<String?> showSessionNotes({
    required BuildContext context,
    String? initialNotes,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => NotesDialog(
        initialNotes: initialNotes,
        title: 'Session Notes',
        hint: 'How was the overall workout?',
        quickNotes: const [
          'Great workout',
          'Good session',
          'Felt tired',
          'Low energy',
          'PR today!',
          'Need more rest',
          'Felt strong',
          'Struggled today',
        ],
      ),
    );
  }

  @override
  State<NotesDialog> createState() => _NotesDialogState();
}

class _NotesDialogState extends State<NotesDialog> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNotes ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addQuickNote(String note) {
    final currentText = _controller.text;
    if (currentText.isEmpty) {
      _controller.text = note;
    } else if (!currentText.contains(note)) {
      _controller.text = currentText.endsWith('.') || currentText.endsWith(',')
          ? '$currentText $note'
          : '$currentText, $note';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text input field
                TextFormField(
                  controller: _controller,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    border: const OutlineInputBorder(),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _controller.clear();
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {}); // Rebuild to show/hide clear button
                  },
                ),

                if (widget.quickNotes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Quick notes:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.quickNotes.map((note) {
                      return ActionChip(
                        label: Text(note),
                        onPressed: () {
                          setState(() {
                            _addQuickNote(note);
                          });
                        },
                        avatar: const Icon(Icons.add, size: 18),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final notes = _controller.text.trim();
            Navigator.of(context).pop(notes.isEmpty ? null : notes);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
