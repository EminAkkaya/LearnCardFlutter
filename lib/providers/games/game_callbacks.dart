import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/audio_helper.dart';
import '../stats_provider.dart';

/// Oyun notifier'larının dış dünyaya dokunduğu iki yan etki.
/// Testlerde sahte fonksiyonlarla değiştirilir.
typedef PlayAudio = void Function(String url);
typedef RecordScore = void Function(int score);

void defaultPlayAudio(String url) {
  if (url.isNotEmpty) AudioHelper.playAudio(url);
}

RecordScore statsRecorder(Ref ref) {
  return (score) => ref.read(statsProvider.notifier).recordGameScore(score);
}
