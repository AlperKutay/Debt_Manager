import 'package:flutter/material.dart';

void main() {
  runApp(const SuperMinimalApp());
}

class SuperMinimalApp extends StatelessWidget {
  const SuperMinimalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World'),
        ),
      ),
    );
  }
} 