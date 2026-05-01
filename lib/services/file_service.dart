import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class FileService {
  static final FileService _instance = FileService._internal();
  factory FileService() => _instance;
  FileService._internal();

  Future<String?> downloadAndSaveImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = p.basename(Uri.parse(url).path);
        // Asegurarnos de que el nombre sea único o identificable
        // Las URLs de ARASAAC suelen ser https://static.arasaac.org/pictograms/ID/ID_300.png
        // El fileName será ID_300.png
        final filePath = p.join(directory.path, fileName);
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      }
    } catch (e) {
      print('Error downloading image: $e');
    }
    return null;
  }

  Future<bool> fileExists(String? path) async {
    if (path == null) return false;
    return await File(path).exists();
  }
}
