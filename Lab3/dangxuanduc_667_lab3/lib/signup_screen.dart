import 'package:flutter/material.dart';
import 'api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final api = ApiService();

  void clearFields() {
    usernameController.clear();
    emailController.clear();
    passwordController.clear();
  }

  Future<void> registerUser() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final users = await api.getUsers("login");

    bool usernameExists = false;
    bool emailExists = false;

    for (var user in users) {
      if (user["username"].toString().toLowerCase() == username.toLowerCase()) {
        usernameExists = true;
      }

      if (user["email"].toString().toLowerCase() == email.toLowerCase()) {
        emailExists = true;
      }
    }

    if (usernameExists) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Thông báo"),
          content: const Text("Tên đăng nhập đã tồn tại"),
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
      return;
    }

    if (emailExists) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Thông báo"),
          content: const Text("Email đã tồn tại"),
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
      return;
    }

    await api.send("login", {
      "username": username,
      "email": email,
      "password": password,
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Thông báo"),
        content: const Text("Đăng ký thành công"),
        actions: [
          TextButton(
            onPressed: () {
              clearFields();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registration"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 40),
              const Icon(
                Icons.person_add,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(
                  hintText: "Username",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'The field cannot be empty';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'The field cannot be empty';
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Invalid email address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "Password",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'The field cannot be empty';
                  }
                  if (value.length < 3) {
                    return 'The password must contain at least 3 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await registerUser();
                  }
                },
                child: const Text("Sign up"),
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