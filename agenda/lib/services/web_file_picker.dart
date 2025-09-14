import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

/// Servizio per il file picking specifico per web
class WebFilePicker {
  /// Apre il dialog di selezione file per il web
  static Future<WebFileResult?> pickImage() async {
    if (!kIsWeb) {
      throw UnsupportedError('WebFilePicker è solo per web');
    }

    try {
      // Crea un input file HTML
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.multiple = false;

      // Simula il click per aprire il dialog
      uploadInput.click();

      // Aspetta che l'utente selezioni un file
      await uploadInput.onChange.first;

      if (uploadInput.files?.isEmpty ?? true) {
        return null;
      }

      final html.File file = uploadInput.files!.first;

      // Legge il file come bytes
      final html.FileReader reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;

      final Uint8List bytes = Uint8List.fromList((reader.result as List<int>));

      return WebFileResult(name: file.name, bytes: bytes, size: file.size);
    } catch (e) {
      print('❌ Errore WebFilePicker: $e');
      return null;
    }
  }
}

/// Risultato del file picking per web
class WebFileResult {
  final String name;
  final Uint8List bytes;
  final int size;

  WebFileResult({required this.name, required this.bytes, required this.size});
}
