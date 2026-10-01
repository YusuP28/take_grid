import 'package:flutter/material.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Init MediaStore
  MediaStore.appFolder = "TakeGrid";
  final tempDir = await getTemporaryDirectory();
  MediaStore.appFolderPath = tempDir.path;

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

