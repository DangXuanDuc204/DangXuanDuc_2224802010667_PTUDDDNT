import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: LayoutApp(),
      ),
    );
  }
}

class LayoutApp extends StatelessWidget {
  const LayoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "I'm in a Column and Centered. The below is a row.",
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                color: Colors.red,
              ),
              const SizedBox(width: 15),
              Container(
                width: 100,
                height: 100,
                color: Colors.green,
              ),
              const SizedBox(width: 15),
              Container(
                width: 100,
                height: 100,
                color: Colors.blue,
              ),
            ],
          ),

          const SizedBox(height: 20),

          Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: 300,
                height: 200,
                color: Colors.yellow,
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Stacked on Yellow Box',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}