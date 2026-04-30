import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playApplause() async {
    try {
      // Usar el asset local registrado en pubspec.yaml
      await _audioPlayer.play(AssetSource('audio/applause.mp3'));
    } catch (e) {
      debugPrint('Error al cargar el audio local: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
