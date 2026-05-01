import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  // Singleton para evitar múltiples instancias del reproductor
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.setVolume(1.0);
      _initialized = true;
    }
  }

  Future<void> playVictory() async => playApplause();
  Future<void> playSuccess() async => playApplause();
  Future<void> playError() async {}

  Future<void> playApplause() async {
    debugPrint('Solicitando audio de aplauso...');
    try {
      await _ensureInitialized();
      
      // Detener cualquier reproducción previa
      if (_audioPlayer.state == PlayerState.playing) {
        await _audioPlayer.stop();
      }

      // Sonido generado alegre
      await _audioPlayer.play(AssetSource('audio/success.wav'));
      
      debugPrint('Comando de reproducción enviado correctamente');
    } catch (e) {
      debugPrint('Error crítico al reproducir audio: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
