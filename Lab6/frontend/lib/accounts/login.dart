import 'package:flutter/material.dart';

import '../admin_area/admin_main_page.dart';
import '../constants/api_endpoints.dart';
import '../constants/token_handler.dart';
import '../models/login_model.dart';
import '../models/role_model.dart';
import '../models/user_model.dart';
import '../other_roles/unknown_roles.dart';
import '../services/api_service.dart';
import '../shared/error_dialog.dart';
import '../shared/submit_button.dart';
import '../shared/text_fields.dart';
import '../users_area/users_main_page.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const routeName = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEAF0FF), Color(0xFFF5EDFF)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          size: 54,
                          color: Color(0xFF3158E8),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Đăng nhập',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 24),
                        AppTextField(
                          controller: _email,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _password,
                          label: 'Mật khẩu',
                          icon: Icons.lock_outline,
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        SubmitButton(
                          label: 'Đăng nhập',
                          icon: Icons.login,
                          isLoading: _loading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tài khoản demo: admin@gmail.com / 123456',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            RegisterPage.routeName,
                          ),
                          child: const Text('Chưa có tài khoản? Đăng ký'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);
    try {
      final model = LoginModel(
        email: _email.text.trim(),
        password: _password.text,
      );
      final data =
          await ApiService().post(ApiEndpoints.login, model.toJson())
              as Map<String, dynamic>;
      final token = data['token']?.toString();
      if (token == null || token.isEmpty) {
        throw ApiException('Backend không trả về token đăng nhập.');
      }
      await TokenHandler.saveToken(token);

      final userJson = data['user'] as Map<String, dynamic>?;
      final user = userJson == null
          ? await _loadProfile()
          : UserModel.fromJson(userJson);

      if (!mounted) {
        return;
      }
      _goByRole(user.role);
    } on ApiException catch (e) {
      if (mounted) {
        await showErrorDialog(context, e.message);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<UserModel> _loadProfile() async {
    final data =
        await ApiService().get(ApiEndpoints.profile) as Map<String, dynamic>;
    final userJson = data['user'] is Map<String, dynamic> ? data['user'] : data;
    return UserModel.fromJson(userJson as Map<String, dynamic>);
  }

  void _goByRole(String role) {
    final route = switch (role) {
      Roles.admin || Roles.manager => AdminMainPage.routeName,
      Roles.staff || Roles.user => UsersMainPage.routeName,
      _ => UnknownRolesPage.routeName,
    };
    Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
  }
}
