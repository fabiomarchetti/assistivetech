import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// Servizio per cache delle immagini ARASAAC
/// Versione semplificata per web - usa solo HTTP senza cache locale
class ImageCacheService {
  
  /// Scarica immagine da URL (solo web)
  Future<Uint8List?> fetchAndCache(String url) async {
    return _fetchImageWeb(url);
  }

  /// Versione web che usa direttamente HTTP senza cache locale
  Future<Uint8List?> _fetchImageWeb(String url) async {
    try {
      print('🌐 Caricamento immagine web: $url');
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print('✅ Immagine caricata: ${response.bodyBytes.length} bytes');
        return response.bodyBytes;
      } else {
        print('❌ Errore HTTP: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Errore caricamento immagine web: $e');
      return null;
    }
  }
  
  /// Pulisce cache scaduta (non fa nulla nella versione web)
  Future<void> cleanExpiredCache() async {
    // Non fare nulla nella versione web
  }
  
  /// Ottiene dimensione cache in bytes (sempre 0 nella versione web)
  Future<int> getCacheSize() async {
    return 0;
  }
  
  /// Pulisce tutta la cache (non fa nulla nella versione web)
  Future<void> clearCache() async {
    // Non fare nulla nella versione web
  }
}