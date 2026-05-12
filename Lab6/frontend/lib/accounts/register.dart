import 'package:flutter/material.dart';

import '../constants/api_endpoints.dart';
import '../constants/token_handler.dart';
import '../models/register_model.dart';
import '../models/role_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../shared/custom_appbar.dart';
import '../shared/error_dialog.dart';
import '../shared/submit_button.dart';
import '../shared/text_fields.dart';
import '../users_area/users_main_page.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  static const routeName = '/register';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Đăng ký'),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        controller: _name,
                        label: 'Họ tên',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 14),
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
                      const SizedBox(height: 10),
                      const Chip(
                        avatar: Icon(Icons.person, size: 18),
                        label: Text('Role mặc định: User'),
                      ),
                      const SizedBox(height: 20),
                      SubmitButton(
                        label: 'Đăng ký',
                        icon: Icons.person_add_alt_1,
                        isLoading: _loading,
                        onPressed: _submit,
                      ),
                    ],
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
      final model = RegisterModel(
        fullName: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
        role: Roles.user,
      );
      final data = await ApiService().post(
        ApiEndpoints.register,
        model.toJson(),
      );
      if (data is Map<String, dynamic> && data['token'] != null) {
        await TokenHandler.saveToken(data['token'].toString());
        if (!mounted) {
          return;
        }
        Navigator.pushNamedAndRemoveUntil(
          context,
          UsersMainPage.routeName,
          (_) => false,
          arguments: data['user'] is Map<String, dynamic>
              ? UserModel.fromJson(data['user'] as Map<String, dynamic>)
              : null,
        );
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký thành công. Vui lòng đăng nhập.'),
          ),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          LoginPage.routeName,
          (_) => false,
        );
      }
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
}
