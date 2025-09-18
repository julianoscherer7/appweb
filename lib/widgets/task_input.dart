import 'package:flutter/material.dart';

typedef AddTaskCallback = void Function(String title);

class TaskInput extends StatefulWidget {
  final AddTaskCallback onAdd;

  const TaskInput({Key? key, required this.onAdd}) : super(key: key);

  @override
  _TaskInputState createState() => _TaskInputState();
}

class _TaskInputState extends State<TaskInput> {
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onAdd(text);
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            onSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'Adicionar tarefa',
              hintText: 'Ex: Estudar matemática',
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
