import 'dart:html' as html;
import 'package:flutter/foundation.dart';

/// Servizio per il file picking specifico per web
class WebFilePicker {
  /// Apre il dialog di selezione file per il web
  static Future<WebFileResult?> pickImage() async {
    if (!kIsWeb) {
      throw UnsupportedError('WebFilePicker è solo per web');
    }

    try {
      print('🔍 DEBUG: Avvio WebFilePicker...');

      // Crea un input file HTML
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.multiple = false;

      print('🔍 DEBUG: Input element creato, simulando click...');

      // Aggiunge l'elemento al DOM temporaneamente per garantire funzionalità
      html.document.body!.append(uploadInput);

      // Simula il click per aprire il dialog
      uploadInput.click();

      print('🔍 DEBUG: Aspettando selezione file...');

      // Aspetta che l'utente selezioni un file
      await uploadInput.onChange.first;

      print('🔍 DEBUG: File selezionato, verificando...');

      if (uploadInput.files?.isEmpty ?? true) {
        print('🔍 DEBUG: Nessun file selezionato');
        uploadInput.remove();
        return null;
      }

      final html.File file = uploadInput.files!.first;
      print('🔍 DEBUG: File trovato: ${file.name}, size: ${file.size} bytes');

      // Verifica dimensione file (max 5MB)
      if (file.size > 5 * 1024 * 1024) {
        print('❌ File troppo grande: ${file.size} bytes');
        uploadInput.remove();
        throw Exception('File troppo grande. Massimo 5MB consentiti.');
      }

      // Legge il file come bytes
      final html.FileReader reader = html.FileReader();
      print('🔍 DEBUG: Leggendo file come array buffer...');

      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;

      print('🔍 DEBUG: File letto con successo');

      final Uint8List bytes = Uint8List.fromList((reader.result as List<int>));

      // Rimuove l'elemento dal DOM
      uploadInput.remove();

      print('🔍 DEBUG: WebFilePicker completato con successo');
      return WebFileResult(name: file.name, bytes: bytes, size: file.size);
    } catch (e) {
      print('❌ Errore WebFilePicker: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      rethrow; // Rilancia l'errore per mostrarlo nell'UI
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
