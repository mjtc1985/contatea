import 'package:flutter/material.dart';
import 'dart:math';
import '../models/level.dart';
import '../services/storage_service.dart';
import 'counting_screen.dart';
import 'settings_screen.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  final StorageService _storageService = StorageService();
  List<GameLevel> _currentLevels = levels;

  @override
  void initState() {
    super.initState();
    _loadLevels();
  }

  Future<void> _loadLevels() async {
    final saved = await _storageService.loadLevels();
    if (saved != null && saved.isNotEmpty) {
      setState(() {
        _currentLevels = saved;
      });
    }
  }

  void _showParentalGate(GameLevel level) {
    final random = Random();
    int a = 5 + random.nextInt(10);
    int b = 2 + random.nextInt(10);
    int result = a + b;
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Control Parental'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Solo para adultos. Resuelve: $a + $b = ?'),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              onSubmitted: (_) => _verifyGate(controller, result, level),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _verifyGate(controller, result, level),
            child: const Text('Entrar'),
          )
        ],
      ),
    );
  }

  void _verifyGate(TextEditingController controller, int result, GameLevel level) {
    if (controller.text == result.toString()) {
      Navigator.pop(context);
      _openSettings(level);
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrecto')),
      );
    }
  }

  void _openSettings(GameLevel level) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen(level: level)),
    );
    await _storageService.saveLevels(_currentLevels);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_currentLevels.isEmpty) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
    final level = _currentLevels[0];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Contatea', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Stack(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CountingScreen(level: level)),
                    );
                  },
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
                      ],
                      border: Border.all(color: Colors.blue.shade100, width: 2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLevelIcon(level),
                        const SizedBox(height: 30),
                        Text(level.title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20)),
                          child: Text('Hasta el ${level.targetCount}', style: TextStyle(fontSize: 20, color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 20),
                        const Text('Pulsa para jugar', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(Icons.settings, color: Colors.blueGrey, size: 30),
                    onPressed: () => _showParentalGate(level),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelIcon(GameLevel level) {
    if (level.selectedPictogramUrl != null) {
      return Image.network(
        level.selectedPictogramUrl!, 
        width: 150, 
        height: 150,
        errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 150, color: Colors.red.shade200),
      );
    }
    return Icon(Icons.play_circle_fill, size: 150, color: Colors.blue.shade300);
  }
}
