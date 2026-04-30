import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:io';
import 'dart:math';
import '../services/arasaac_service.dart';
import '../services/audio_service.dart';
import '../models/pictogram.dart';
import '../models/level.dart';

class CountingScreen extends StatefulWidget {
  final GameLevel level;
  const CountingScreen({super.key, required this.level});

  @override
  State<CountingScreen> createState() => _CountingScreenState();
}

class _CountingScreenState extends State<CountingScreen> {
  final ArasaacService _arasaacService = ArasaacService();
  final AudioService _audioService = AudioService();
  late ConfettiController _confettiController;
  final Random _random = Random();
  
  int _targetNumber = 0;
  List<int> _options = [];
  String? _mainImageUrl;
  String? _rewardImageUrl;
  bool _isLoading = true;
  
  int _currentRound = 1;
  final int _totalRounds = 3;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _loadData();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // Priorizar URLs seleccionadas manualmente en ajustes
      _mainImageUrl = widget.level.selectedPictogramUrl;
      _rewardImageUrl = widget.level.rewardPictogramUrl;

      // Si no hay URL seleccionada, buscamos por query (comportamiento por defecto)
      if (_mainImageUrl == null) {
        final results = await _arasaacService.searchPictograms(widget.level.query);
        if (results.isNotEmpty) _mainImageUrl = results.first.imageUrl;
      }

      if (_rewardImageUrl == null && widget.level.rewardImagePath == null) {
        final rewardResults = await _arasaacService.searchPictograms(widget.level.rewardQuery);
        if (rewardResults.isNotEmpty) _rewardImageUrl = rewardResults.first.imageUrl;
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _generateNewChallenge();
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  void _generateNewChallenge() {
    setState(() {
      _targetNumber = _random.nextInt(widget.level.targetCount) + 1;
      _options = [_targetNumber];
      while (_options.length < 3) {
        int wrong = _random.nextInt(widget.level.targetCount) + 1;
        if (!_options.contains(wrong)) {
          _options.add(wrong);
        }
      }
      _options.shuffle();
    });
  }

  void _onOptionSelected(int selected) {
    if (selected == _targetNumber) {
      _handleCorrect();
    } else {
      _handleIncorrect();
    }
  }

  void _handleCorrect() {
    if (_currentRound < _totalRounds) {
      setState(() => _currentRound++);
      _generateNewChallenge();
    } else {
      _audioService.playApplause();
      _confettiController.play();
      _showRewardDialog();
    }
  }

  void _handleIncorrect() {}

  void _showRewardDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: const Text('¡CAMPEÓN!', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, color: Colors.orange, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Has completado los desafíos', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            _buildRewardImage(),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() => _currentRound = 1);
                _generateNewChallenge();
              },
              child: const Text('¡Jugar otra vez!', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildRewardImage() {
    if (widget.level.rewardImagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(File(widget.level.rewardImagePath!), width: 180, height: 180, fit: BoxFit.cover),
      );
    }
    if (_rewardImageUrl != null) {
      return Image.network(_rewardImageUrl!, width: 180, height: 180);
    }
    return const Icon(Icons.stars, size: 120, color: Colors.amber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text(widget.level.title),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      // Progreso
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_totalRounds, (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: constraints.maxWidth * 0.1,
                            height: 10,
                            decoration: BoxDecoration(
                              color: index < _currentRound ? Colors.green : Colors.grey[300],
                              borderRadius: BorderRadius.circular(5),
                            ),
                          )),
                        ),
                      ),

                      // Área de Pictogramas (Responsiva)
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                          ),
                          child: Center(
                            child: SingleChildScrollView(
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                alignment: WrapAlignment.center,
                                children: List.generate(_targetNumber, (index) => 
                                  _mainImageUrl != null 
                                    ? Image.network(_mainImageUrl!, width: _calculateImageSize(constraints), height: _calculateImageSize(constraints))
                                    : const Icon(Icons.help_outline),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text('¿Cuántos hay?', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                      ),

                      // Botones de Opciones
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _options.map((number) => _buildOptionButton(number, constraints)).toList(),
                        ),
                      ),
                    ],
                  ),
              
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  double _calculateImageSize(BoxConstraints constraints) {
    // Ajuste dinámico del tamaño de los pictogramas según la cantidad
    if (_targetNumber <= 3) return 120;
    if (_targetNumber <= 6) return 90;
    return 70;
  }

  Widget _buildOptionButton(int number, BoxConstraints constraints) {
    double btnSize = constraints.maxWidth * 0.22;
    if (btnSize > 120) btnSize = 120;

    return GestureDetector(
      onTap: () => _onOptionSelected(number),
      child: Container(
        width: btnSize,
        height: btnSize,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(btnSize * 0.25),
          boxShadow: [
            BoxShadow(color: Colors.blue.withOpacity(0.3), offset: const Offset(0, 6), blurRadius: 8)
          ],
        ),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: btnSize * 0.45, 
              color: Colors.white, 
              fontWeight: FontWeight.bold,
              shadows: const [Shadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 2))],
            ),
          ),
        ),
      ),
    );
  }
}
