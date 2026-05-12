import 'package:flutter/material.dart';

import '../accounts/login.dart';
import '../constants/token_handler.dart';
import '../shared/submit_button.dart';

class UnknownRolesPage extends StatelessWidget {
  const UnknownRolesPage({super.key});

  static const routeName = '/unknown-role';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.manage_accounts_outlined, size: 52),
                    const SizedBox(height: 14),
                    Text(
                      'Tài khoản của bạn chưa được phân quyền phù hợp',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SubmitButton(
                      label: 'Đăng xuất',
                      icon: Icons.logout,
                      onPressed: () async {
                        await TokenHandler.clearToken();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            LoginPage.routeName,
                            (_) => false,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
