import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pictogram.dart';

class ArasaacService {
  static const String baseUrl = 'https://api.arasaac.org/api/pictograms';

  Future<List<Pictogram>> searchPictograms(String query, {String language = 'es'}) async {
    final url = Uri.parse('$baseUrl/$language/search/$query');
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Pictogram.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        // Si no hay resultados, devolvemos lista vacía en lugar de error
        return [];
      } else {
        throw Exception('Error al buscar pictogramas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión con ARASAAC: $e');
    }
  }
}
