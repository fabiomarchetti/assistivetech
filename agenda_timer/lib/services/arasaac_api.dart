import 'dart:convert';
import 'package:http/http.dart' as http;

// Client minimale per ARASAAC: ricerca pittogrammi e download asset
class ArasaacApiClient {
  // Base URL ufficiale
  // Nota: il dominio corretto per le API è api.arasaac.org
  static const String _base = 'https://api.arasaac.org/api';
  // Host statico per file PNG
  static const String _staticBase = 'https://static.arasaac.org/pictograms';

  // Cerca pittogrammi per locale e query (prefisso digitato)
  Future<List<Map<String, dynamic>>> searchPictograms({
    required String locale,
    required String query,
    int limit = 24,
  }) async {
    final encodedQuery = Uri.encodeComponent(query.trim());
    final uri = Uri.parse('$_base/pictograms/$locale/search/$encodedQuery');
    final res = await http.get(uri);
    if (res.statusCode != 200) return [];
    final decoded = jsonDecode(utf8.decode(res.bodyBytes));
    if (decoded is! List) return [];
    final List<Map<String, dynamic>> list = [];
    for (final raw in decoded.take(limit)) {
      if (raw is! Map<String, dynamic>) continue;
      int? id;
      final rawId = raw['_id'];
      if (rawId is int) {
        id = rawId;
      } else if (rawId is String) {
        id = int.tryParse(rawId);
      }
      if (id == null) continue; // scarta risultati senza id valido
      final List<dynamic> keywordsRaw =
          (raw['keywords'] as List?)?.cast<dynamic>() ?? const [];
      list.add({
        'id': id,
        'keywords': keywordsRaw,
        'thumbnail': 'https://static.arasaac.org/pictograms/$id/${id}_300.png',
        'url': 'https://static.arasaac.org/pictograms/$id/${id}_500.png',
      });
    }
    return list;
  }

  // Restituisce URL PNG statico del pittogramma con dimensione fissa
  Uri pictogramPngUrlStatic({required int pictogramId, int size = 500}) {
    return Uri.parse('$_staticBase/$pictogramId/${pictogramId}_$size.png');
  }

  // BACKWARD-COMPAT: metodo precedente usato in alcuni punti della UI
  // Ignora il locale e rimappa alla versione statica con size=500
  Uri pictogramPngUrl({required String locale, required int pictogramId}) {
    return pictogramPngUrlStatic(pictogramId: pictogramId, size: 500);
  }
}
