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
  String _filter = 'todas'; // todas, pendentes, concluidas

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

  void _editTask(Task task) async {
    final controller = TextEditingController(text: task.title);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar tarefa'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Novo texto'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        final idx = _tasks.indexWhere((t) => t.id == task.id);
        if (idx != -1) _tasks[idx].title = result;
      });
      _saveTasks();
    }
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
    final theme = Theme.of(context);
    List<Task> filteredTasks;
    if (_filter == 'pendentes') {
      filteredTasks = _tasks.where((t) => !t.isDone).toList();
    } else if (_filter == 'concluidas') {
      filteredTasks = _tasks.where((t) => t.isDone).toList();
    } else {
      filteredTasks = _tasks;
    }
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: theme.brightness == Brightness.dark
                ? [Colors.indigo.shade900, Colors.black]
                : [Colors.indigo.shade100, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TaskInput(onAdd: _addTask),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Tarefas: ${_tasks.length}', style: theme.textTheme.bodyMedium),
                  const SizedBox(width: 12),
                  Text('Pendentes: $pending', style: theme.textTheme.bodyMedium),
                  const Spacer(),
                  DropdownButton<String>(
                    value: _filter,
                    items: const [
                      DropdownMenuItem(value: 'todas', child: Text('Todas')),
                      DropdownMenuItem(value: 'pendentes', child: Text('Pendentes')),
                      DropdownMenuItem(value: 'concluidas', child: Text('Concluídas')),
                    ],
                    onChanged: (v) => setState(() => _filter = v ?? 'todas'),
                  ),
                  IconButton(
                    icon: theme.brightness == Brightness.dark
                        ? const Icon(Icons.light_mode)
                        : const Icon(Icons.dark_mode),
                    tooltip: 'Alternar tema',
                    onPressed: () {
                      final brightness = theme.brightness == Brightness.dark
                          ? Brightness.light
                          : Brightness.dark;
                      final newTheme = ThemeData(
                        brightness: brightness,
                        primarySwatch: Colors.indigo,
                        visualDensity: VisualDensity.adaptivePlatformDensity,
                      );
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => Theme(data: newTheme, child: const HomeScreen())),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredTasks.isEmpty
                        ? const Center(child: Text('Nenhuma tarefa. Adicione uma!'))
                        : ListView.separated(
                            itemCount: filteredTasks.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final task = filteredTasks[index];
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Card(
                                  key: ValueKey(task.id),
                                  elevation: 3,
                                  color: task.isDone
                                      ? Colors.grey.shade300
                                      : Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: TaskTile(
                                    task: task,
                                    onToggle: _toggleTask,
                                    onDelete: _deleteTask,
                                    onEdit: () => _editTask(task),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
