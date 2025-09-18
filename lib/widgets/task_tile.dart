import 'package:flutter/material.dart';
import '../models/task.dart';

typedef TaskToggleCallback = void Function(Task task);
typedef TaskDeleteCallback = void Function(Task task);
typedef TaskEditCallback = void Function();

class TaskTile extends StatelessWidget {
  final Task task;
  final TaskToggleCallback onToggle;
  final TaskDeleteCallback onDelete;
  final TaskEditCallback? onEdit;

  const TaskTile({
    Key? key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: task.isDone,
        onChanged: (_) => onToggle(task),
      ),
      title: Text(
        task.title,
        style: TextStyle(
          decoration: task.isDone ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
            tooltip: 'Editar tarefa',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => onDelete(task),
            tooltip: 'Remover tarefa',
          ),
        ],
      ),
    );
  }
}
