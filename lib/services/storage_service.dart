import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/level.dart';
import 'file_service.dart';

class StorageService {
  static const String _key = 'contatea_levels';
  final FileService _fileService = FileService();

  Future<void> saveLevels(List<GameLevel> levels) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Antes de guardar, aseguramos que todos los recursos de ARASAAC estén en local
    for (var l in levels) {
      if (l.selectedPictogramUrl != null && l.selectedLocalImagePath == null) {
        l.selectedLocalImagePath = await _fileService.downloadAndSaveImage(l.selectedPictogramUrl!);
      }
      if (l.rewardPictogramUrl != null && l.rewardImagePath == null) {
        l.rewardImagePath = await _fileService.downloadAndSaveImage(l.rewardPictogramUrl!);
      }
      for (var p in l.pairs) {
        if (p.imageUrl != null && p.localImagePath == null) {
          p.localImagePath = await _fileService.downloadAndSaveImage(p.imageUrl!);
        }
      }
    }

    List<String> data = levels.map((l) => json.encode({
      'title': l.title,
      'type': l.type.name,
      'targetCount': l.targetCount,
      'totalRounds': l.totalRounds,
      'query': l.query,
      'selectedPictogramUrl': l.selectedPictogramUrl,
      'selectedLocalImagePath': l.selectedLocalImagePath,
      'pairs': l.pairs.map((p) => p.toJson()).toList(),
      'optionsCount': l.optionsCount,
      'rewardQuery': l.rewardQuery,
      'rewardPictogramUrl': l.rewardPictogramUrl,
      'rewardImagePath': l.rewardImagePath,
    })).toList();
    await prefs.setStringList(_key, data);
  }

  Future<List<GameLevel>?> loadLevels() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? data = prefs.getStringList(_key);
    if (data == null) return null;

    return data.map((item) {
      final map = json.decode(item);
      return GameLevel(
        title: map['title'],
        type: GameType.values.firstWhere((e) => e.name == (map['type'] ?? 'counting'), orElse: () => GameType.counting),
        targetCount: map['targetCount'] ?? 5,
        totalRounds: map['totalRounds'] ?? 3,
        query: map['query'] ?? 'manzana',
        selectedPictogramUrl: map['selectedPictogramUrl'],
        selectedLocalImagePath: map['selectedLocalImagePath'],
        pairs: (map['pairs'] as List? ?? []).map((p) => AssociationPair.fromJson(p)).toList(),
        optionsCount: map['optionsCount'] ?? 3,
        rewardQuery: map['rewardQuery'] ?? 'caramelo',
        rewardPictogramUrl: map['rewardPictogramUrl'],
        rewardImagePath: map['rewardImagePath'],
      );
    }).toList();
  }
}
