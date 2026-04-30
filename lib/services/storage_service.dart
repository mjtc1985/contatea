import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/level.dart';

class StorageService {
  static const String _key = 'contatea_levels';

  Future<void> saveLevels(List<GameLevel> levels) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> data = levels.map((l) => json.encode({
      'title': l.title,
      'targetCount': l.targetCount,
      'query': l.query,
      'selectedPictogramUrl': l.selectedPictogramUrl,
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
        targetCount: map['targetCount'],
        query: map['query'],
        selectedPictogramUrl: map['selectedPictogramUrl'],
        rewardQuery: map['rewardQuery'] ?? 'caramelo',
        rewardPictogramUrl: map['rewardPictogramUrl'],
        rewardImagePath: map['rewardImagePath'],
      );
    }).toList();
  }
}
