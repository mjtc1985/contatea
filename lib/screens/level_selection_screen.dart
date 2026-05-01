import 'package:contatea/screens/association_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:contatea/models/level.dart';
import 'package:contatea/screens/counting_screen.dart';
import 'package:contatea/screens/settings_screen.dart';
import 'package:contatea/services/storage_service.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadLevels();
  }

  Future<void> _loadLevels() async {
    final storage = StorageService();
    final savedLevels = await storage.loadLevels();
    if (savedLevels != null) {
      setState(() {
        levels.clear();
        levels.addAll(savedLevels);
        
        // Corrección de desincronización histórica (CASA -> POLLO)
        for (var level in levels) {
          if (level.type == GameType.association) {
            for (var pair in level.pairs) {
              if (pair.word == 'CASA' && pair.imageUrl != null && pair.imageUrl!.contains('2565')) {
                pair.word = 'POLLO';
              }
            }
          }
        }
        _isLoaded = true;
      });
      // Asegurar que todo esté en local por si acaso (ej. actualización de app)
      storage.saveLevels(levels);
    } else {
      // Primera vez: Guardar los niveles por defecto para forzar descarga
      await storage.saveLevels(levels);
      setState(() {
        _isLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Contatea',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006064),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 30,
                      runSpacing: 30,
                      alignment: WrapAlignment.center,
                      children: levels.map((level) => _buildLevelCard(context, level)).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, GameLevel level) {
    final bool isCounting = level.type == GameType.counting;
    
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (level.type == GameType.counting) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CountingScreen(level: level)),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AssociationSelectionScreen(level: level)),
              );
            }
          },
          child: Container(
            width: 300,
            height: 350,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isCounting ? Colors.orange.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCounting ? Icons.calculate : Icons.abc,
                    size: 100,
                    color: isCounting ? Colors.orange : Colors.blue,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  level.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF006064),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isCounting ? '¡Vamos a contar!' : '¡Aprende palabras!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(level: level),
                ),
              ).then((_) => setState(() {}));
            },
          ),
        ),
      ],
    );
  }
}
