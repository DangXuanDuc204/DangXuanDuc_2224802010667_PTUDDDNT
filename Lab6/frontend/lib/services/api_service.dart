import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_endpoints.dart';
import '../constants/token_handler.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiService {
  ApiService({this.token});

  final String? token;

  Future<Map<String, String>> get _headers async {
    final authToken = token ?? await TokenHandler.getToken();
    return {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };
  }

  Future<dynamic> get(String path) async {
    final response = await http.get(_uri(path), headers: await _headers);
    return _handle(response);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final response = await http.post(
      _uri(path),
      headers: await _headers,
      body: jsonEncode(body),
    );
    return _handle(response);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final response = await http.put(
      _uri(path),
      headers: await _headers,
      body: jsonEncode(body),
    );
    return _handle(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await http.delete(_uri(path), headers: await _headers);
    return _handle(response);
  }

  Uri _uri(String path) => Uri.parse('${ApiEndpoints.baseUrl}$path');

  dynamic _handle(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return jsonDecode(response.body);
    }

    var message = 'Có lỗi xảy ra. Vui lòng thử lại.';
    if (response.body.isNotEmpty) {
      try {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          message = (data['message'] ?? data['title'] ?? message).toString();
        } else {
          message = response.body;
        }
      } catch (_) {
        message = response.body;
      }
    }
    throw ApiException(message, statusCode: response.statusCode);
  }
}
