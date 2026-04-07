import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ResponsiveHomePage(),
    );
  }
}

class ResponsiveHomePage extends StatelessWidget {
  const ResponsiveHomePage({super.key});

  static const colorCodes = (
    body: Color(0xFFF8E287),
    navigation: Color(0xFFC5ECCE),
    pane: Color(0xFFFEEEBC),
  );

  static const _style = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const body = Center(
    child: Text('Body', style: _style),
  );

  static const navigation = Center(
    child: Text('Navigation', style: _style),
  );

  static const panes = Center(
    child: Text('Pane', style: _style),
  );

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: () {
          if (screenWidth < 600) {
            return const Text('Responsive UI - Phone');
          } else if (screenWidth < 840) {
            return const Text('Responsive UI - Tablet');
          } else if (screenWidth < 1200) {
            return const Text('Responsive UI - Landscape');
          } else {
            return const Text('Responsive UI - Large Desktop');
          }
        }(),
      ),
      body: () {
        if (screenWidth < 600) {
          return buildCompactScreen();
        } else if (screenWidth < 840) {
          return buildMediumScreen();
        } else if (screenWidth < 1200) {
          return buildExpandedScreen();
        } else {
          return buildLargeScreen();
        }
      }(),
    );
  }

  Widget buildCompactScreen() {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: colorCodes.body,
            child: body,
          ),
        ),
        Container(
          height: 80,
          color: colorCodes.navigation,
          child: navigation,
        ),
      ],
    );
  }

  Widget buildMediumScreen() {
    return Row(
      children: [
        Container(
          width: 80,
          color: colorCodes.navigation,
          child: navigation,
        ),
        Expanded(
          child: Container(
            color: colorCodes.body,
            child: body,
          ),
        ),
      ],
    );
  }

  Widget buildExpandedScreen() {
    return Row(
      children: [
        Container(
          width: 80,
          color: colorCodes.navigation,
          child: navigation,
        ),
        Container(
          width: 360,
          color: colorCodes.body,
          child: body,
        ),
        Expanded(
          child: Container(
            color: colorCodes.pane,
            child: panes,
          ),
        ),
      ],
    );
  }

  Widget buildLargeScreen() {
    return Row(
      children: [
        Container(
          width: 360,
          color: colorCodes.navigation,
          child: navigation,
        ),
        Container(
          width: 360,
          color: colorCodes.body,
          child: body,
        ),
        Expanded(
          child: Container(
            color: colorCodes.pane,
            child: panes,
          ),
        ),
      ],
    );
  }
}
