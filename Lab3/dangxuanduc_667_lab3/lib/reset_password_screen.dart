import 'package:flutter/material.dart';
import 'api_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final api = ApiService();

  void clearFields() {
    emailController.clear();
  }

  Future<void> resetPassword() async {
    final email = emailController.text.trim();

    final users = await api.getUsers("login");

    dynamic foundUser;
    for (var user in users) {
      if (user["email"].toString() == email) {
        foundUser = user;
        break;
      }
    }

    if (foundUser != null) {
      await api.updateUserPassword(
        "login",
        foundUser["id"].toString(),
        {
          "username": foundUser["username"],
          "email": foundUser["email"],
          "password": "123",
        },
      );

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Thông báo"),
          content: const Text("Đã reset password về 123"),
          actions: [
            TextButton(
              onPressed: () {
                clearFields();
                Navigator.pop(context); // đóng dialog
                Navigator.pop(context); // quay về login
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Thông báo"),
          content: const Text("Email không tồn tại"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 40),
              Image.network(
                "https://cdn-icons-png.flaticon.com/512/709/709496.png",
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 20),

              const Center(
                child: Text(
                  "RESET PASSWORD",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'The field cannot be empty';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await resetPassword();
                  }
                },
                child: const Text("Reset Password"),
              ),

              const SizedBox(height: 10),

              OutlinedButton(
                onPressed: () {
                  clearFields();
                  Navigator.pop(context);
                },
                child: const Text("Back"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}