import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:io';
import 'package:confetti/confetti.dart';
import '../models/level.dart';
import '../services/arasaac_service.dart';
import '../services/audio_service.dart';

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
  final List<int> _numberBag = [];
  List<int> _options = [];
  String? _mainImageUrl;
  String? _rewardImageUrl;
  bool _isLoading = true;
  bool _showError = false;
  
  int _currentRound = 0;
  late int _totalRounds;

  @override
  void initState() {
    super.initState();
    _totalRounds = widget.level.totalRounds;
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
      _mainImageUrl = widget.level.selectedPictogramUrl;
      _rewardImageUrl = widget.level.rewardPictogramUrl;

      if (_mainImageUrl == null && widget.level.selectedLocalImagePath == null) {
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
      // Si la bolsa está vacía, la llenamos con números del 1 al targetCount y mezclamos
      if (_numberBag.isEmpty) {
        final List<int> pool = List.generate(widget.level.targetCount, (i) => i + 1);
        pool.shuffle();
        
        // Evitar que el primero de la nueva tanda sea igual al último de la anterior
        if (_targetNumber != 0 && pool.length > 1 && pool.first == _targetNumber) {
          final first = pool.removeAt(0);
          pool.add(first);
        }
        _numberBag.addAll(pool);
      }

      _targetNumber = _numberBag.removeAt(0);
      
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
    setState(() => _currentRound++);
    if (_currentRound < _totalRounds) {
      _audioService.playSuccess();
      _generateNewChallenge();
    } else {
      _audioService.playVictory();
      _confettiController.play();
      _showRewardDialog();
    }
  }

  void _handleIncorrect() {
    _audioService.playError();
    setState(() => _showError = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showError = false);
    });
  }

  void _showRewardDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: const Text('¡BIEN!', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, color: Colors.orange, fontWeight: FontWeight.bold)),
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
                  setState(() {
                    _currentRound = 0;
                    _numberBag.clear();
                  });
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
    if (widget.level.rewardImagePath != null && File(widget.level.rewardImagePath!).existsSync()) {
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
                      Container(
                        padding: const EdgeInsets.all(24),
                        child: LinearProgressIndicator(
                          value: _currentRound / _totalRounds,
                          minHeight: 20,
                          backgroundColor: Colors.grey[300],
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                          ),
                          child: Center(
                            child: SingleChildScrollView(
                              child: Wrap(
                                spacing: 20,
                                runSpacing: 20,
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: List.generate(_targetNumber, (index) => 
                                  _buildCountingItem(constraints),
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
              if (_showError)
                Container(
                  color: Colors.white.withValues(alpha: 0.8),
                  child: const Center(
                    child: Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 300,
                    ),
                  ),
                ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildCountingItem(BoxConstraints constraints) {
    double size = (constraints.maxWidth - 60) / (_targetNumber <= 4 ? 2.2 : 3.5);
    size = size.clamp(80.0, 200.0);
    
    if (widget.level.selectedLocalImagePath != null && File(widget.level.selectedLocalImagePath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(File(widget.level.selectedLocalImagePath!), width: size, height: size, fit: BoxFit.cover),
      );
    }
    if (_mainImageUrl != null) {
      return Image.network(_mainImageUrl!, width: size, height: size);
    }
    return const Icon(Icons.help_outline);
  }

  Widget _buildOptionButton(int number, BoxConstraints constraints) {
    double btnSize = (constraints.maxWidth * 0.22).clamp(0.0, 120.0);

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
            BoxShadow(color: Colors.blue.withValues(alpha: 0.3), offset: const Offset(0, 6), blurRadius: 8)
          ],
        ),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: btnSize * 0.45, 
              color: Colors.white, 
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
