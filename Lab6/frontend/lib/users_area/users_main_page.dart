import 'package:flutter/material.dart';

import '../accounts/login.dart';
import '../constants/api_endpoints.dart';
import '../constants/token_handler.dart';
import '../models/change_password_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../shared/custom_appbar.dart';
import '../shared/error_dialog.dart';
import '../shared/submit_button.dart';
import '../shared/text_fields.dart';
import '../shared/user_details.dart';

class UsersMainPage extends StatefulWidget {
  const UsersMainPage({super.key});

  static const routeName = '/users-main';

  @override
  State<UsersMainPage> createState() => _UsersMainPageState();
}

class _UsersMainPageState extends State<UsersMainPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  UserModel? _currentUser;
  bool _loading = true;
  bool _savingPassword = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  @override
  void dispose() {
    _oldPassword.dispose();
    _newPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Khu vực người dùng',
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  if (_currentUser != null) UserDetails(user: _currentUser!),
                  const SizedBox(height: 4),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Đổi mật khẩu',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              controller: _oldPassword,
                              label: 'Mật khẩu hiện tại',
                              icon: Icons.lock_outline,
                              obscureText: true,
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              controller: _newPassword,
                              label: 'Mật khẩu mới',
                              icon: Icons.lock_reset,
                              obscureText: true,
                            ),
                            const SizedBox(height: 18),
                            SubmitButton(
                              label: 'Cập nhật mật khẩu',
                              icon: Icons.save_outlined,
                              isLoading: _savingPassword,
                              onPressed: _changePassword,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final data =
          await ApiService().get(ApiEndpoints.profile) as Map<String, dynamic>;
      final userJson = data['user'] is Map<String, dynamic>
          ? data['user']
          : data;
      _currentUser = UserModel.fromJson(userJson as Map<String, dynamic>);
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

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _savingPassword = true);
    try {
      final model = ChangePasswordModel(
        oldPassword: _oldPassword.text,
        newPassword: _newPassword.text,
      );
      await ApiService().put(ApiEndpoints.changePassword, model.toJson());
      _oldPassword.clear();
      _newPassword.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đổi mật khẩu thành công.')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        await showErrorDialog(context, e.message);
      }
    } finally {
      if (mounted) {
        setState(() => _savingPassword = false);
      }
    }
  }

  Future<void> _logout() async {
    await TokenHandler.clearToken();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        LoginPage.routeName,
        (_) => false,
      );
    }
  }
}
