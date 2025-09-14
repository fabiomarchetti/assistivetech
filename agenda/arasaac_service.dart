import 'dart:convert';
import 'package:http/http.dart' as http;

class ArasaacService {
  static const String baseUrl = 'https://api.arasaac.org/api';

  static Future<List<Map<String, dynamic>>> searchPictograms({
    required String query,
    String language = 'it',
    int limit = 20,
  }) async {
    try {
      final url = '$baseUrl/pictograms/$language/search/$query';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .take(limit)
            .map(
              (item) => {
                'id': item['_id'],
                'keywords': item['keywords'] as List<dynamic>,
                'url':
                    'https://static.arasaac.org/pictograms/${item['_id']}/${item['_id']}_500.png',
                'thumbnail':
                    'https://static.arasaac.org/pictograms/${item['_id']}/${item['_id']}_300.png',
              },
            )
            .toList();
      }
    } catch (e) {
      print('Errore ricerca ARASAAC: $e');
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> searchByCategory({
    required String category,
    String language = 'it',
    int limit = 50,
  }) async {
    try {
      // Mappiamo le categorie alle parole chiave in italiano
      final Map<String, List<String>> categoryKeywords = {
        'CHI': [
          'persona',
          'famiglia',
          'bambino',
          'uomo',
          'donna',
          'io',
          'tu',
          'lui',
          'lei',
        ],
        'QUANDO': [
          'ora',
          'tempo',
          'oggi',
          'ieri',
          'domani',
          'mattina',
          'sera',
          'notte',
        ],
        'COSA': [
          'mangiare',
          'bere',
          'giocare',
          'dormire',
          'leggere',
          'guardare',
          'ascoltare',
        ],
        'DOVE': [
          'casa',
          'scuola',
          'ospedale',
          'parco',
          'negozio',
          'bagno',
          'camera',
          'cucina',
        ],
      };

      final keywords = categoryKeywords[category] ?? [category.toLowerCase()];
      final List<Map<String, dynamic>> allResults = [];

      for (String keyword in keywords) {
        final results = await searchPictograms(
          query: keyword,
          language: language,
          limit: 10,
        );
        allResults.addAll(results);

        // Pausa per evitare troppi request
        await Future.delayed(const Duration(milliseconds: 200));
      }

      // Rimuovi duplicati e limita risultati
      final uniqueResults = <String, Map<String, dynamic>>{};
      for (var result in allResults) {
        uniqueResults[result['id'].toString()] = result;
      }

      return uniqueResults.values.take(limit).toList();
    } catch (e) {
      print('Errore ricerca categoria ARASAAC: $e');
    }
    return [];
  }

  static String getPictogramUrl(int pictogramId, {int size = 500}) {
    return 'https://static.arasaac.org/pictograms/$pictogramId/${pictogramId}_$size.png';
  }

  static Future<Map<String, dynamic>?> getPictogramInfo(
    int pictogramId, {
    String language = 'it',
  }) async {
    try {
      final url = '$baseUrl/pictograms/$language/$pictogramId';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Errore info pittogramma ARASAAC: $e');
    }
    return null;
  }
}
