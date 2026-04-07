import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RegisterPage(),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Application'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              label: 'First Name',
              controller: firstNameController,
            ),
            CustomTextField(
              label: 'Last Name',
              controller: lastNameController,
            ),

            const CustomTextField(
              label: 'Email',
              suffixText: '@mlritm.ac.in',
            ),

            CustomTextField(
              prefixText: '+91 ',
              label: 'Phone Number',
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),

            const Divider(indent: 8, endIndent: 8),

            const CustomTextField(label: 'Username'),
            const CustomTextField(label: 'Password', obscureText: true),
            const CustomTextField(label: 'Confirm Password', obscureText: true),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                final fullName =
                    '${firstNameController.text} ${lastNameController.text}'
                        .trim();

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Registration Successful'),
                    content: Text('Welcome, $fullName'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final String? prefixText;
  final String? suffixText;
  final bool obscureText;
  final TextInputType keyboardType;
  final int? maxLength;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.label,
    this.prefixText,
    this.suffixText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.controller,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefixText,
          suffixText: suffixText,
          border: const OutlineInputBorder(),
          counterText: '',
        ),
      ),
    );
  }
}