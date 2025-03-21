
import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../db/database_helper.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _showPendingOnly = false;
  String _searchQuery = '';

  List<Task> get tasks => _tasks;
  bool get showPendingOnly => _showPendingOnly;
  String get searchQuery => _searchQuery;

  TaskProvider() {
    refreshTasks();
  }

  Future<void> refreshTasks() async {
    if (_searchQuery.isNotEmpty) {
      _tasks = await DatabaseHelper.instance.searchTasks(_searchQuery);
    } else {
      _tasks = await DatabaseHelper.instance.getTasks(pendingOnly: _showPendingOnly);
    }
    notifyListeners();
  }

  void toggleShowPendingOnly() {
    _showPendingOnly = !_showPendingOnly;
    _searchQuery = ''; // Clear search when toggling filter
    refreshTasks();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    refreshTasks();
  }

  Future<void> addTask(Task task) async {
    await DatabaseHelper.instance.insertTask(task);
    refreshTasks();
  }

  Future<void> updateTask(Task task) async {
    await DatabaseHelper.instance.updateTask(task);
    refreshTasks();
  }

  Future<void> toggleTaskStatus(Task task) async {
    final updatedTask = task.copyWith(
      status: task.status == 0 ? 1 : 0,
      updatedAt: DateTime.now(),
    );
    await DatabaseHelper.instance.updateTask(updatedTask);
    refreshTasks();
  }

  Future<void> deleteTask(int id) async {
    await DatabaseHelper.instance.deleteTask(id);
    refreshTasks();
  }

  Future<Task?> getTask(int id) async {
    return await DatabaseHelper.instance.getTask(id);
  }
}