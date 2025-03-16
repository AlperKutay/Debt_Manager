import 'package:flutter/material.dart';

class MinimalApp extends StatelessWidget {
  const MinimalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minimal Debt Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MinimalHomeScreen(),
    );
  }
}

class MinimalHomeScreen extends StatelessWidget {
  const MinimalHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debt Manager'),
      ),
      body: const Center(
        child: Text('Minimal app is working!'),
      ),
    );
  }
} 