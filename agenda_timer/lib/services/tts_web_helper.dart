// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;

class WebSpeechHelper {
  WebSpeechHelper() : _utterance = html.SpeechSynthesisUtterance();

  final html.SpeechSynthesisUtterance _utterance;
  bool _initialized = false;

  html.SpeechSynthesis? get _speech => html.window.speechSynthesis;

  bool get isSupported => _speech != null;

  Future<void> initialize({required String language}) async {
    if (!isSupported || _initialized) return;

    _utterance
      ..lang = language
      ..pitch = 1.0
      ..rate = 1.0
      ..volume = 1.0;

    _initialized = true;
  }

  Future<void> unlock({required String language}) async {
    final speech = _speech;
    if (speech == null) return;

    final unlockUtterance = html.SpeechSynthesisUtterance()
      ..text = ' '
      ..lang = language
      ..volume = 0.0
      ..rate = 1.0;

    speech.speak(unlockUtterance);
  }

  Future<void> speak({
    required String text,
    required String language,
    required double rate,
    required double pitch,
  }) async {
    final speech = _speech;
    if (speech == null) return;

    if ((speech.speaking ?? false) || (speech.pending ?? false)) {
      speech.cancel();
    }

    _utterance
      ..text = text
      ..lang = language
      ..rate = rate
      ..pitch = pitch
      ..volume = 1.0;

    speech.speak(_utterance);
  }

  Future<void> stop() async {
    final speech = _speech;
    if (speech == null) return;
    speech.cancel();
  }

  bool get isSpeaking {
    final speech = _speech;
    if (speech == null) return false;
    final speaking = speech.speaking ?? false;
    final pending = speech.pending ?? false;
    return speaking || pending;
  }
}
