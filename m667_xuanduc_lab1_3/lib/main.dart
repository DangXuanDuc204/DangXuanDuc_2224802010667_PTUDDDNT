import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lab 1.3',
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Lab 1.3 Flutter Widgets"),
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(20),
            color: Colors.blueAccent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Xuan Duc - 667",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Image.asset(
                  'assets/images/flutter_logo.png',
                  width: 120,
                ),

                const SizedBox(height: 20),

          
              ],
            ),
          ),
        ),
      ),
    );
  }
}