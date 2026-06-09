import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  String _filter = 'All';
  TaskCategory? _categoryFilter;
  Priority? _priorityFilter;
  bool _isLoading = false;

  static const _storageKey = 'tasks_v1';
  final _uuid = const Uuid();

  List<Task> get tasks => _getFilteredTasks();
  List<Task> get allTasks => _tasks;
  String get filter => _filter;
  bool get isLoading => _isLoading;
  TaskCategory? get categoryFilter => _categoryFilter;
  Priority? get priorityFilter => _priorityFilter;

  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((t) => t.isCompleted).length;
  int get pendingTasks => _tasks.where((t) => !t.isCompleted).length;
  double get completionRate => _tasks.isEmpty ? 0 : completedTasks / totalTasks;

  TaskProvider() {
    _loadTasks();
  }

  List<Task> _getFilteredTasks() {
    List<Task> filtered = List.from(_tasks);

    if (_filter == 'Active') {
      filtered = filtered.where((t) => !t.isCompleted).toList();
    } else if (_filter == 'Completed') {
      filtered = filtered.where((t) => t.isCompleted).toList();
    }

    if (_categoryFilter != null) {
      filtered = filtered.where((t) => t.category == _categoryFilter).toList();
    }

    if (_priorityFilter != null) {
      filtered = filtered.where((t) => t.priority == _priorityFilter).toList();
    }

    filtered.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return b.priority.index.compareTo(a.priority.index);
    });

    return filtered;
  }

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  void setCategoryFilter(TaskCategory? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void setPriorityFilter(Priority? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  void addTask({
    required String title,
    String description = '',
    Priority priority = Priority.medium,
    TaskCategory category = TaskCategory.personal,
    DateTime? dueDate,
  }) {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      priority: priority,
      category: category,
      createdAt: DateTime.now(),
      dueDate: dueDate,
    );
    _tasks.insert(0, task);
    _saveTasks();
    notifyListeners();
  }

  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      _saveTasks();
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _saveTasks();
    notifyListeners();
  }

  void toggleTaskCompletion(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
      );
      _saveTasks();
      notifyListeners();
    }
  }

  void deleteCompleted() {
    _tasks.removeWhere((t) => t.isCompleted);
    _saveTasks();
    notifyListeners();
  }

  Future<void> _loadTasks() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_storageKey) ?? [];
      _tasks = raw.map((s) => Task.fromJson(jsonDecode(s))).toList();
    } catch (_) {
      _tasks = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = _tasks.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList(_storageKey, raw);
  }
}
