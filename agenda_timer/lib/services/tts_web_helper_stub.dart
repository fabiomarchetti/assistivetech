class WebSpeechHelper {
  const WebSpeechHelper();

  bool get isSupported => false;

  Future<void> initialize({required String language}) async {}

  Future<void> unlock({required String language}) async {}

  Future<void> speak({
    required String text,
    required String language,
    required double rate,
    required double pitch,
  }) async {}

  Future<void> stop() async {}

  bool get isSpeaking => false;
}
