import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class Storage {
  static const String _key = 'todo_tasks';

  // Salva lista de tarefas
  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = tasks.map((t) => jsonEncode(t.toMap())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  // Carrega lista de tarefas
  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_key);
    if (jsonList == null) return [];
    return jsonList.map((s) {
      final Map<String, dynamic> map = jsonDecode(s);
      return Task.fromMap(map);
    }).toList();
  }

  // Limpa todas as tarefas (opcional)
  static Future<void> clearTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
