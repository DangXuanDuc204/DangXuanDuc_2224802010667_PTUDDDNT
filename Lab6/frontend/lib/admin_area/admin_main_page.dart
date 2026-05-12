import 'package:flutter/material.dart';

import '../accounts/login.dart';
import '../constants/api_endpoints.dart';
import '../constants/token_handler.dart';
import '../models/role_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/role_check.dart';
import '../shared/confirmation_dialog.dart';
import '../shared/custom_appbar.dart';
import '../shared/error_dialog.dart';
import '../shared/submit_button.dart';
import '../shared/text_fields.dart';
import '../shared/user_details.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  static const routeName = '/admin-main';

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  final _search = TextEditingController();
  UserModel? _currentUser;
  List<UserModel> _users = [];
  String _currentRole = '';
  bool _canManageUsers = false;
  bool _isAdmin = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadRolePermission();
      await _loadData();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyword = _search.text.trim().toLowerCase();
    final users = _users.where((user) {
      if (keyword.isEmpty) {
        return true;
      }
      return user.fullName.toLowerCase().contains(keyword) ||
          user.email.toLowerCase().contains(keyword) ||
          user.role.toLowerCase().contains(keyword);
    }).toList();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Khu quản trị',
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: _canManageUsers
          ? FloatingActionButton.extended(
              onPressed: () => _openUserForm(),
              icon: const Icon(Icons.add),
              label: const Text('Thêm user'),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_currentUser != null)
                    _DashboardHeader(user: _currentUser!),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _search,
                    label: 'Tìm kiếm user',
                    icon: Icons.search,
                    onChanged: (_) => setState(() {}),
                    validator: (_) => null,
                  ),
                  const SizedBox(height: 14),
                  for (final user in users)
                    UserDetails(
                      user: user,
                      canEdit: _canEditTargetUser(user.role),
                      canToggle: _canDeactivateTargetUser(user.role),
                      onEdit: () => _openUserForm(user: user),
                      onToggle: () => _toggleUser(user),
                    ),
                  if (users.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: Center(child: Text('Không tìm thấy người dùng')),
                    ),
                ],
              ),
            ),
    );
  }

  Future<void> _loadRolePermission() async {
    final roleCheck = RoleCheck();
    final role = await roleCheck.getRole();
    final canManage = await roleCheck.canManageUsers();
    final isAdmin = await roleCheck.isAdmin();

    if (!mounted) {
      return;
    }

    setState(() {
      _currentRole = role;
      _canManageUsers = canManage;
      _isAdmin = isAdmin;
    });
  }

  bool _canEditTargetUser(String targetRole) {
    if (_isAdmin) {
      return true;
    }
    if (_currentRole == Roles.manager) {
      return targetRole == Roles.staff || targetRole == Roles.user;
    }
    return false;
  }

  bool _canDeactivateTargetUser(String targetRole) {
    return _isAdmin && targetRole != Roles.admin;
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final profile =
          await ApiService().get(ApiEndpoints.profile) as Map<String, dynamic>;
      final userJson = profile['user'] is Map<String, dynamic>
          ? profile['user']
          : profile;
      _currentUser = UserModel.fromJson(userJson as Map<String, dynamic>);
      if (_currentRole.isEmpty) {
        _currentRole = _currentUser?.role ?? '';
        _canManageUsers =
            _currentRole == Roles.admin || _currentRole == Roles.manager;
        _isAdmin = _currentRole == Roles.admin;
      }

      final data = await ApiService().get(ApiEndpoints.users) as List<dynamic>;
      _users = data
          .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
          .toList();
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

  Future<void> _openUserForm({UserModel? user}) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _UserFormDialog(
        currentRole: _currentRole.isNotEmpty
            ? _currentRole
            : _currentUser?.role ?? Roles.user,
        user: user,
      ),
    );
    if (saved == true) {
      await _loadData();
    }
  }

  Future<void> _toggleUser(UserModel user) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: user.isActive ? 'Khóa người dùng' : 'Kích hoạt người dùng',
      message: user.isActive
          ? 'Bạn có chắc muốn khóa tài khoản ${user.email}?'
          : 'Bạn có chắc muốn kích hoạt tài khoản ${user.email}?',
      confirmText: user.isActive ? 'Khóa' : 'Kích hoạt',
    );
    if (!confirmed) {
      return;
    }

    try {
      if (user.isActive) {
        await ApiService().delete(ApiEndpoints.userById(user.id));
      } else {
        await ApiService().put(ApiEndpoints.activateUser(user.id), {});
      }
      await _loadData();
    } on ApiException catch (e) {
      if (mounted) {
        await showErrorDialog(context, e.message);
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

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [Color(0xFF3158E8), Color(0xFF7C3AED)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Xin chào,', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            user.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(user.email, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 12),
          RoleBadge(user.role),
        ],
      ),
    );
  }
}

class _UserFormDialog extends StatefulWidget {
  const _UserFormDialog({required this.currentRole, this.user});

  final String currentRole;
  final UserModel? user;

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  late String _role;
  late bool _isActive;
  bool _saving = false;

  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _name.text = user?.fullName ?? '';
    _email.text = user?.email ?? '';
    _role = user?.role ?? Roles.user;
    _isActive = user?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roles = widget.currentRole == Roles.admin
        ? Roles.all
        : Roles.managedByManager;
    final selectedRole = roles.contains(_role) ? _role : roles.last;

    return AlertDialog(
      title: Text(_isEditing ? 'Sửa người dùng' : 'Thêm người dùng'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 460,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                if (!_isEditing) ...[
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _password,
                    label: 'Mật khẩu',
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                ],
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  items: roles
                      .map(
                        (role) =>
                            DropdownMenuItem(value: role, child: Text(role)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _role = value ?? Roles.user),
                  decoration: const InputDecoration(
                    labelText: 'Vai trò',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Đang hoạt động'),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Hủy'),
        ),
        SubmitButton(
          label: 'Lưu',
          icon: Icons.save_outlined,
          isLoading: _saving,
          onPressed: _submit,
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _saving = true);
    try {
      final body = UserModel(
        id: widget.user?.id ?? 0,
        fullName: _name.text.trim(),
        email: _email.text.trim(),
        role: _role,
        isActive: _isActive,
        createdAt: widget.user?.createdAt ?? DateTime.now(),
      ).toJson(password: _isEditing ? null : _password.text);

      if (_isEditing) {
        await ApiService().put(ApiEndpoints.userById(widget.user!.id), body);
      } else {
        await ApiService().post(ApiEndpoints.users, body);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } on ApiException catch (e) {
      if (mounted) {
        await showErrorDialog(context, e.message);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
