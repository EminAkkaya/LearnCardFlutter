import 'package:audioplayers/audioplayers.dart';

class AudioHelper {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> playAudio(String url) async {
    if (url.trim().isEmpty) return;

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url.trim()));
    } catch (_) {}
  }
}
