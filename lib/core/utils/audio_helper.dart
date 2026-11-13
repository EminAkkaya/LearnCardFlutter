import 'package:flutter_tts/flutter_tts.dart';

/// İngilizce telaffuz, cihazın kendi metin okuma (TTS) motoruyla.
///
/// Önceden dictionaryapi.dev'in ses dosyaları çalınıyordu; o dosyalar
/// sunucudan kaldırıldı (her istek 404), bu yüzden kelime artık TTS ile okunur.
class AudioHelper {
  static FlutterTts? _tts;
  static Future<void>? _ready;

  static Future<void> _init() async {
    final tts = FlutterTts();
    _tts = tts;
    await tts.setLanguage('en-US');
    await tts.setSpeechRate(0.45);
    await tts.setPitch(1.0);
    await tts.awaitSpeakCompletion(false);
  }

  /// [text] metnini İngilizce okur; önceki okumayı keser. Hatalar yutulur
  /// (TTS motoru olmayan cihazda düğme sessiz kalır, uygulama çökmez).
  static Future<void> speak(String text) async {
    final clean = text.trim();
    if (clean.isEmpty) return;
    try {
      await (_ready ??= _init());
      await _tts!.stop();
      await _tts!.speak(clean);
    } catch (_) {
      _ready = null;
    }
  }
}
