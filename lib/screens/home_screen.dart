import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../utils/storage.dart';
import '../widgets/task_input.dart';
import '../widgets/task_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> _tasks = [];
  final Uuid _uuid = const Uuid();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _loading = true);
    final loaded = await Storage.loadTasks();
    setState(() {
      _tasks.clear();
      _tasks.addAll(loaded);
      _loading = false;
    });
  }

  Future<void> _saveTasks() async {
    await Storage.saveTasks(_tasks);
  }

  void _addTask(String title) {
    final newTask = Task(id: _uuid.v4(), title: title);
    setState(() {
      _tasks.insert(0, newTask);
    });
    _saveTasks();
  }

  void _toggleTask(Task task) {
    setState(() {
      final idx = _tasks.indexWhere((t) => t.id == task.id);
      if (idx != -1) {
        _tasks[idx].isDone = !_tasks[idx].isDone;
      }
    });
    _saveTasks();
  }

  void _deleteTask(Task task) {
    setState(() {
      _tasks.removeWhere((t) => t.id == task.id);
    });
    _saveTasks();
  }

  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpar todas as tarefas?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              setState(() => _tasks.clear());
              _saveTasks();
              Navigator.of(ctx).pop();
            },
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = _tasks.where((t) => !t.isDone).length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Limpar tudo',
            onPressed: _tasks.isEmpty ? null : _confirmClearAll,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TaskInput(onAdd: _addTask),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Tarefas: ${_tasks.length}'),
                const SizedBox(width: 12),
                Text('Pendentes: $pending'),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _tasks.isEmpty
                      ? const Center(child: Text('Nenhuma tarefa. Adicione uma!'))
                      : ListView.separated(
                          itemCount: _tasks.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final task = _tasks[index];
                            return TaskTile(
                              task: task,
                              onToggle: _toggleTask,
                              onDelete: _deleteTask,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
