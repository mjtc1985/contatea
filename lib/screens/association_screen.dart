import 'package:flutter/material.dart';
import 'package:contatea/models/level.dart';
import 'package:contatea/services/audio_service.dart';
import 'dart:io';
import 'dart:math';
import 'package:confetti/confetti.dart';

class AssociationScreen extends StatefulWidget {
  final GameLevel level;
  final List<AssociationPair> selectedPairs;

  const AssociationScreen({
    super.key, 
    required this.level,
    required this.selectedPairs,
  });

  @override
  State<AssociationScreen> createState() => _AssociationScreenState();
}

class _AssociationScreenState extends State<AssociationScreen> {
  final AudioService _audioService = AudioService();
  late ConfettiController _confettiController;
  
  int _currentRound = 0;
  bool _isFinished = false;
  bool _showError = false;
  
  late AssociationPair _currentPair;
  late List<String> _options;
  bool _localFileExists = false;
  
  final List<AssociationPair> _remainingPairs = [];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _nextRound();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _nextRound() {
    if (_currentRound >= widget.level.totalRounds) {
      setState(() {
        _isFinished = true;
      });
      _audioService.playVictory();
      _confettiController.play();
      return;
    }

    setState(() {
      // Si la bolsa está vacía, la llenamos y mezclamos
      if (_remainingPairs.isEmpty) {
        final List<AssociationPair> newPool = List.from(widget.selectedPairs);
        newPool.shuffle();
        
        // Evitar que la primera de la nueva tanda sea igual a la última de la anterior
        if (_currentRound > 0 && newPool.length > 1 && newPool.first.word == _currentPair.word) {
          final first = newPool.removeAt(0);
          newPool.add(first);
        }
        _remainingPairs.addAll(newPool);
      }

      _currentPair = _remainingPairs.removeAt(0);
      
      // Generar opciones (palabra correcta + distractores)
      _options = [_currentPair.word];
      final allWords = widget.level.pairs.map((p) => p.word).toSet();
      final distractorWords = allWords.where((w) => w != _currentPair.word).toList();
      distractorWords.shuffle();
      
      _options.addAll(distractorWords.take(widget.level.optionsCount - 1));
      _options.shuffle();
      _checkImages();
    });
  }

  void _checkImages() {
    setState(() {
      _localFileExists = _currentPair.localImagePath != null && 
                          File(_currentPair.localImagePath!).existsSync();
    });
  }

  void _handleOptionSelected(String word) {
    if (word == _currentPair.word) {
      _audioService.playSuccess();
      // Forzar que el foco se pierda antes de pasar de ronda
      FocusScope.of(context).unfocus();
      setState(() {
        _currentRound++;
      });
      _nextRound();
    } else {
      _audioService.playError();
      setState(() {
        _showError = true;
      });
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _showError = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) return _buildVictoryScreen();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildProgress(),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildImage(),
                      const SizedBox(height: 50),
                      _buildOptions(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showError)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Icon(Icons.close, size: 300, color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 40),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            '¡Busca la palabra!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildImage() {
    Widget image;
    if (_localFileExists) {
      image = Image.file(File(_currentPair.localImagePath!), fit: BoxFit.contain);
    } else if (_currentPair.imageUrl != null) {
      image = Image.network(_currentPair.imageUrl!, fit: BoxFit.contain);
    } else {
      image = const Icon(Icons.image, size: 200);
    }

    return Container(
      width: 300,
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: image,
    );
  }

  Widget _buildOptions() {
    return Wrap(
      key: ValueKey('options_round_$_currentRound'),
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: _options.map((option) {
        return ElevatedButton(
          key: ValueKey('option_${_currentRound}_$option'),
          focusNode: FocusNode(canRequestFocus: false),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue[900],
            overlayColor: Colors.transparent, // Elimina el sombreado gris tras el clic
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 5,
          ),
          onPressed: () => _handleOptionSelected(option),
          child: Text(
            option,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProgress() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      child: LinearProgressIndicator(
        value: _currentRound / widget.level.totalRounds,
        minHeight: 20,
        backgroundColor: Colors.grey[300],
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildVictoryScreen() {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '¡BIEN!',
                  style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                const SizedBox(height: 40),
                _buildRewardImage(),
                const SizedBox(height: 60),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('VOLVER', style: TextStyle(fontSize: 30, color: Colors.white)),
                ),
              ],
            ),
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
      ),
    );
  }

  Widget _buildRewardImage() {
    if (widget.level.rewardImagePath != null && File(widget.level.rewardImagePath!).existsSync()) {
      return Image.file(File(widget.level.rewardImagePath!), height: 250);
    } else if (widget.level.rewardPictogramUrl != null) {
      return Image.network(widget.level.rewardPictogramUrl!, height: 250);
    } else {
      return const Icon(Icons.star, size: 200, color: Colors.yellow);
    }
  }
}
