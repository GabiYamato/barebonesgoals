import 'package:flutter/material.dart';
import '../theme/neo_brutalist_theme.dart';

class AddTaskModal extends StatefulWidget {
  final Function(String taskName) onAddTask;

  const AddTaskModal({super.key, required this.onAddTask});

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) {
      widget.onAddTask(name);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NeoBrutalistTheme.backgroundColor,
        border: Border(
          top: BorderSide(
            color: NeoBrutalistTheme.borderColor,
            width: NeoBrutalistTheme.borderWidth,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: NeoBrutalistTheme.boxDecoration,
              child: const Text(
                'ADD NEW TASK',
                style: NeoBrutalistTheme.titleStyle,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            // Input field
            TextField(
              controller: _controller,
              style: NeoBrutalistTheme.bodyStyle,
              decoration: NeoBrutalistTheme.inputDecoration('Enter task name'),
              textCapitalization: TextCapitalization.words,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            // Add button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _submit,
                style: NeoBrutalistTheme.buttonStyleFlat,
                child: const Text(
                  'ADD TASK',
                  style: NeoBrutalistTheme.buttonStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
