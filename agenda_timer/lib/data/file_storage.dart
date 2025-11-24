
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

/// Servizio per gestire file e upload immagini
class FileStorageService {
  
  /// Seleziona un file immagine dal computer (solo web)
  Future<Map<String, dynamic>?> pickImageFile() async {
    if (!kIsWeb) {
      throw UnsupportedError('pickImageFile is only supported on web');
    }
    
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          return {
            'name': file.name,
            'bytes': file.bytes!,
            'size': file.size,
          };
        }
      }
      return null;
    } catch (e) {
      print('❌ Errore selezione file: $e');
      return null;
    }
  }

  /// Converte bytes immagine in data URL base64 (per web)
  Future<String> convertImageToBase64(Uint8List imageBytes) async {
    if (kIsWeb) {
      final base64String = base64Encode(imageBytes);
      return 'data:image/png;base64,$base64String';
    }
    throw UnsupportedError('Base64 conversion only supported on web');
  }

  // Metodi deprecati - mantengono compatibilità
  Future<void> ensureAgendaDir(String agendaName) async {
    throw UnsupportedError('FileStorageService not supported - use JsonDataService instead');
  }

  Future<void> getAgendaImagesDir(String agendaName) async {
    throw UnsupportedError('FileStorageService not supported - use JsonDataService instead');
  }

  Future<void> getAgendaPictogramsDir(String agendaName) async {
    throw UnsupportedError('FileStorageService not supported - use JsonDataService instead');
  }

  Future<void> getAgendaExportsDir(String agendaName) async {
    throw UnsupportedError('FileStorageService not supported - use JsonDataService instead');
  }

  Future<List<String>> getExistingAgendaDirs() async {
    throw UnsupportedError('FileStorageService not supported - use JsonDataService instead');
  }

  Future<void> deleteAgendaDir(String agendaName) async {
    throw UnsupportedError('FileStorageService not supported - use JsonDataService instead');
  }

  Future<void> copyFileToDir(
    dynamic sourceFile,
    dynamic targetDir,
    String fileName,
  ) async {
    throw UnsupportedError('FileStorageService not supported - use JsonDataService instead');
  }

  Future<void> saveFileToDir(
    List<int> bytes,
    dynamic targetDir,
    String fileName,
  ) async {
    throw UnsupportedError('FileStorageService not supported - use JsonDataService instead');
  }

  Future<void> saveBytes({
    required List<int> bytes,
    required String agendaName,
    required String fileName,
  }) async {
    throw UnsupportedError('FileStorageService not supported - use JsonDataService instead');
  }
}