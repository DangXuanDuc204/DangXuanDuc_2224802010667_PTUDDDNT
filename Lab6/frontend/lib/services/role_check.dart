import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../accounts/login.dart';
import '../constants/token_handler.dart';

class RoleCheck {
  static const String roleClaim =
      'http://schemas.microsoft.com/ws/2008/06/identity/claims/role';

  Future<String> getRole() async {
    final token = await TokenHandler.getToken();

    if (token == null || token.isEmpty) {
      return '';
    }

    if (JwtDecoder.isExpired(token)) {
      return '';
    }

    final decodedToken = JwtDecoder.decode(token);

    final role =
        decodedToken[roleClaim] ??
        decodedToken['role'] ??
        decodedToken['Role'] ??
        '';

    return role.toString();
  }

  Future<bool> isAdmin() async {
    final role = await getRole();
    return role == 'Admin';
  }

  Future<bool> isManager() async {
    final role = await getRole();
    return role == 'Manager';
  }

  Future<bool> isStaff() async {
    final role = await getRole();
    return role == 'Staff';
  }

  Future<bool> isUser() async {
    final role = await getRole();
    return role == 'User';
  }

  Future<bool> canManageUsers() async {
    final role = await getRole();
    return role == 'Admin' || role == 'Manager';
  }

  Future<bool> canEditUser({
    required String currentRole,
    required String targetRole,
  }) async {
    if (currentRole == 'Admin') {
      return true;
    }

    if (currentRole == 'Manager') {
      return targetRole == 'Staff' || targetRole == 'User';
    }

    return false;
  }

  Future<void> checkAdminRole(BuildContext context) async {
    final role = await getRole();

    if (!context.mounted) return;

    if (role != 'Admin') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (dynamic route) => false,
      );
    }
  }

  Future<void> checkAdminOrManagerRole(BuildContext context) async {
    final role = await getRole();

    if (!context.mounted) return;

    if (role != 'Admin' && role != 'Manager') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (dynamic route) => false,
      );
    }
  }
}
