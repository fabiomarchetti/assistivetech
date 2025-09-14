import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Servizio per l'upload di file immagine su server
class FileUploadService {
  static const String uploadUrl = './api/upload_image.php';

  /// Carica un file immagine sul server
  Future<Map<String, dynamic>?> uploadImage({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    if (!kIsWeb) {
      throw UnsupportedError('Upload supportato solo su web');
    }

    try {
      print('📤 Inizio upload file: $fileName (${imageBytes.length} bytes)');

      // Crea la richiesta multipart
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${_getBaseUrl()}$uploadUrl'),
      );

      // Aggiungi il file come multipart
      final multipartFile = http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: fileName,
      );
      request.files.add(multipartFile);

      print('🌐 Invio richiesta a: ${_getBaseUrl()}$uploadUrl');

      // Invia la richiesta
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📨 Risposta server: ${response.statusCode}');
      print('📄 Body risposta: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body) as Map<String, dynamic>;

        if (result['success'] == true) {
          print('✅ Upload completato: ${result['path']}');
          return result;
        } else {
          print('❌ Errore upload: ${result['message']}');
          throw Exception('Errore upload: ${result['message']}');
        }
      } else {
        print('❌ Errore HTTP: ${response.statusCode}');
        throw Exception('Errore HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Errore durante upload: $e');
      rethrow;
    }
  }

  /// Ottiene l'URL base del server
  String _getBaseUrl() {
    if (kIsWeb) {
      return ''; // URL relativo per web
    }
    return 'https://assistivetech.it/'; // URL assoluto per mobile (se necessario)
  }

  /// Verifica se un file è un'immagine supportata
  bool isValidImageFile(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  /// Genera un nome file sicuro
  String makeSafeFileName(String fileName) {
    final parts = fileName.split('.');
    final name = parts.length > 1
        ? parts.sublist(0, parts.length - 1).join('.')
        : fileName;
    final extension = parts.length > 1 ? parts.last : '';

    final safeName = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9._-]'), '_')
        .replaceAll(RegExp(r'_{2,}'), '_');

    return extension.isNotEmpty ? '$safeName.$extension' : safeName;
  }
}
