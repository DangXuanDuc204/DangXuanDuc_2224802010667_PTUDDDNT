import 'package:flutter/material.dart';

import 'accounts/login.dart';
import 'accounts/register.dart';
import 'admin_area/admin_main_page.dart';
import 'constants/token_handler.dart';
import 'other_roles/unknown_roles.dart';
import 'users_area/users_main_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TokenHandler.clearToken();
  runApp(const Lab6App());
}

class Lab6App extends StatelessWidget {
  const Lab6App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lab 6 User Management',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B5FEF),
          primary: const Color(0xFF3158E8),
          secondary: const Color(0xFF7C3AED),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
          elevation: 0.5,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      home: const LoginPage(),
      routes: {
        LoginPage.routeName: (_) => const LoginPage(),
        RegisterPage.routeName: (_) => const RegisterPage(),
        AdminMainPage.routeName: (_) => const AdminMainPage(),
        UsersMainPage.routeName: (_) => const UsersMainPage(),
        UnknownRolesPage.routeName: (_) => const UnknownRolesPage(),
      },
    );
  }
}
