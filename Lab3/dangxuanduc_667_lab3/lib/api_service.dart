import 'package:dio/dio.dart';

class ApiService {
  final Dio dio = Dio();

  final String baseUrl = "https://69e62ce9ce4e908a155f1f78.mockapi.io";

  Future<void> send(String endpoint, Map<String, dynamic> data) async {
    try {
      final Response response = await dio.post("$baseUrl/$endpoint", data: data);
      print(response.data);
    } catch (e) {
      print("Dio error: $e");
    }
  }

  Future<List<dynamic>> getUsers(String endpoint) async {
    try {
      final Response response = await dio.get("$baseUrl/$endpoint");
      return response.data;
    } catch (e) {
      print("Dio error: $e");
      return [];
    }
  }

  Future<void> updateUserPassword(
    String endpoint,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final Response response =
          await dio.put("$baseUrl/$endpoint/$id", data: data);
      print(response.data);
    } catch (e) {
      print("Dio error: $e");
    }
  }
}