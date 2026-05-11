import 'package:flutter/foundation.dart';

import '../models/todo.dart';
import '../services/api_service.dart';

class TodoProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool isLoading = false;
  List<Todo> todos = [];

  int get doneCount => todos.where((todo) => todo.isDone).length;
  int get pendingCount => todos.length - doneCount;

  Future<void> fetchTodos(String token) async {
    isLoading = true;
    notifyListeners();
    try {
      final data = await _apiService.getTodos(token);
      final list = data['todos'] as List<dynamic>? ?? [];
      todos = list
          .map((item) => Todo.fromJson(item as Map<String, dynamic>))
          .toList();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTodo({
    required String token,
    required String title,
    required String description,
  }) async {
    final data = await _apiService.createTodo(
      token: token,
      title: title,
      description: description,
    );
    todos = [Todo.fromJson(data['todo'] as Map<String, dynamic>), ...todos];
    notifyListeners();
  }

  Future<void> updateTodo({
    required String token,
    required Todo todo,
    required String title,
    required String description,
  }) async {
    final data = await _apiService.updateTodo(
      token: token,
      id: todo.id,
      title: title,
      description: description,
      isDone: todo.isDone,
    );
    _replaceTodo(Todo.fromJson(data['todo'] as Map<String, dynamic>));
  }

  Future<void> toggleTodo({required String token, required Todo todo}) async {
    final data = await _apiService.toggleTodo(token: token, id: todo.id);
    _replaceTodo(Todo.fromJson(data['todo'] as Map<String, dynamic>));
  }

  Future<void> deleteTodo({required String token, required Todo todo}) async {
    await _apiService.deleteTodo(token: token, id: todo.id);
    todos = todos.where((item) => item.id != todo.id).toList();
    notifyListeners();
  }

  void clear() {
    todos = [];
    notifyListeners();
  }

  void _replaceTodo(Todo todo) {
    todos = todos.map((item) => item.id == todo.id ? todo : item).toList();
    notifyListeners();
  }
}
