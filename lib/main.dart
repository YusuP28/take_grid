import 'package:flutter/material.dart';

void main() {
  runApp(const TakeGridApp());
}

class TakeGridApp extends StatelessWidget {
  const TakeGridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Take Grid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take Grid')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grid_on, size: 80),
            SizedBox(height: 16),
            Text('Take Grid — Coming Soon', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Fase 2 selesai. Fase 3: Grid Renderer.',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
