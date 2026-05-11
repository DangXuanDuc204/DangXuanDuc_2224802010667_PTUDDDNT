import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
  }) {
    return _post('/auth/register', {
      'fullName': fullName,
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) {
    return _post('/auth/login', {'email': email, 'password': password});
  }

  Future<Map<String, dynamic>> getTodos(String token) {
    return _get('/todos', token);
  }

  Future<Map<String, dynamic>> createTodo({
    required String token,
    required String title,
    required String description,
  }) {
    return _post('/todos', {
      'title': title,
      'description': description,
    }, token: token);
  }

  Future<Map<String, dynamic>> updateTodo({
    required String token,
    required String id,
    required String title,
    required String description,
    required bool isDone,
  }) {
    return _put('/todos/$id', {
      'title': title,
      'description': description,
      'isDone': isDone,
    }, token: token);
  }

  Future<Map<String, dynamic>> toggleTodo({
    required String token,
    required String id,
  }) {
    return _patch('/todos/$id/toggle', token: token);
  }

  Future<Map<String, dynamic>> deleteTodo({
    required String token,
    required String id,
  }) {
    return _delete('/todos/$id', token);
  }

  Future<Map<String, dynamic>> _get(String path, String token) async {
    final response = await http.get(_uri(path), headers: _headers(token));
    return _decode(response);
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final response = await http.post(
      _uri(path),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> _put(
    String path,
    Map<String, dynamic> body, {
    required String token,
  }) async {
    final response = await http.put(
      _uri(path),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> _patch(
    String path, {
    required String token,
  }) async {
    final response = await http.patch(_uri(path), headers: _headers(token));
    return _decode(response);
  }

  Future<Map<String, dynamic>> _delete(String path, String token) async {
    final response = await http.delete(_uri(path), headers: _headers(token));
    return _decode(response);
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> _headers([String? token]) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decode(http.Response response) {
    final data = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw ApiException((data['message'] ?? 'Có lỗi xảy ra').toString());
  }
}
