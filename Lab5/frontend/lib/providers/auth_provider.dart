import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool isLoading = true;
  String? token;
  AppUser? user;

  bool get isLoggedIn => token != null && user != null;

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    final userJson = prefs.getString('user');
    if (userJson != null) {
      user = AppUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final data = await _apiService.register(
      fullName: fullName,
      email: email,
      password: password,
    );
    await _saveSession(data);
  }

  Future<void> login({required String email, required String password}) async {
    final data = await _apiService.login(email: email, password: password);
    await _saveSession(data);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    token = null;
    user = null;
    notifyListeners();
  }

  Future<void> _saveSession(Map<String, dynamic> data) async {
    token = data['token']?.toString();
    user = AppUser.fromJson(data['user'] as Map<String, dynamic>);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token ?? '');
    await prefs.setString('user', jsonEncode(user!.toJson()));
    notifyListeners();
  }
}
