import 'package:flutter_tts/flutter_tts.dart';

/// Servizio per la sintesi vocale
class TtsService {
  TtsService._();
  static final TtsService _instance = TtsService._();
  factory TtsService() => _instance;

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  /// Inizializza il servizio TTS
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configurazione di base
      await _flutterTts.setLanguage('it-IT');
      await _flutterTts.setSpeechRate(0.4); // Velocità più lenta
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // Gestori degli eventi
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        print('🎙️ TTS: Inizio riproduzione');
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        print('🎙️ TTS: Completato');
      });

      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        print('❌ TTS Error: $msg');
      });

      _isInitialized = true;
      print('✅ TTS Service inizializzato');
    } catch (e) {
      print('❌ Errore inizializzazione TTS: $e');
    }
  }

  /// Pronuncia una frase
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (text.trim().isEmpty) {
      print('⚠️ TTS: Testo vuoto, nessuna vocalizzazione');
      return;
    }

    try {
      print('🎙️ TTS: Pronuncia "$text"');
      await _flutterTts.speak(text);
    } catch (e) {
      print('❌ Errore TTS durante vocalizzazione: $e');
    }
  }

  /// Ferma la riproduzione corrente
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
      print('⏹️ TTS: Fermato');
    } catch (e) {
      print('❌ Errore TTS durante stop: $e');
    }
  }

  /// Mette in pausa la riproduzione
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
      print('⏸️ TTS: In pausa');
    } catch (e) {
      print('❌ Errore TTS durante pausa: $e');
    }
  }

  /// Controlla se sta parlando (tracciamento interno)
  bool _isSpeaking = false;
  bool get isSpeaking => _isSpeaking;

  /// Imposta la velocità di riproduzione
  Future<void> setSpeechRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate.clamp(0.1, 1.0));
      print('🎛️ TTS: Velocità impostata a $rate');
    } catch (e) {
      print('❌ Errore impostazione velocità TTS: $e');
    }
  }

  /// Imposta il volume
  Future<void> setVolume(double volume) async {
    try {
      await _flutterTts.setVolume(volume.clamp(0.0, 1.0));
      print('🔊 TTS: Volume impostato a $volume');
    } catch (e) {
      print('❌ Errore impostazione volume TTS: $e');
    }
  }

  /// Restituisce la lista delle lingue disponibili
  Future<List<String>> getLanguages() async {
    try {
      final languages = await _flutterTts.getLanguages;
      return List<String>.from(languages);
    } catch (e) {
      print('❌ Errore recupero lingue TTS: $e');
      return ['it-IT'];
    }
  }

  /// Imposta la lingua
  Future<void> setLanguage(String language) async {
    try {
      await _flutterTts.setLanguage(language);
      print('🌍 TTS: Lingua impostata a $language');
    } catch (e) {
      print('❌ Errore impostazione lingua TTS: $e');
    }
  }

  /// Rilascia le risorse
  Future<void> dispose() async {
    try {
      await _flutterTts.stop();
      _isInitialized = false;
      print('🗑️ TTS Service disposto');
    } catch (e) {
      print('❌ Errore dispose TTS: $e');
    }
  }
}