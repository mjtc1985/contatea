import 'package:flutter/material.dart';
import 'screens/level_selection_screen.dart';

void main() {
  runApp(const ContateaApp());
}

class ContateaApp extends StatelessWidget {
  const ContateaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contatea',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LevelSelectionScreen(),
    );
  }
}
