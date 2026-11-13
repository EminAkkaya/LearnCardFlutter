import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/audio_helper.dart';
import '../stats_provider.dart';

/// Oyun notifier'larının dış dünyaya dokunduğu iki yan etki.
/// Testlerde sahte fonksiyonlarla değiştirilir.
/// Kelimeyi sesli okur (cihaz TTS'i).
typedef PlayAudio = void Function(String word);
typedef RecordScore = void Function(int score);

void defaultPlayAudio(String word) => AudioHelper.speak(word);

RecordScore statsRecorder(Ref ref) {
  return (score) => ref.read(statsProvider.notifier).recordGameScore(score);
}
