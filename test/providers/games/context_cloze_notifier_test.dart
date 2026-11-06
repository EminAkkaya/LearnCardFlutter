import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/providers/games/context_cloze_provider.dart';
import 'game_test_cards.dart';

void main() {
  late List<int> recorded;
  late ContextClozeNotifier n;

  setUp(() {
    recorded = [];
    n = ContextClozeNotifier(gameTestCards, playAudio: (_) {}, recordScore: recorded.add);
  });

  test('cümledeki kelime boşluğa çevrilir', () {
    final q = buildClozeQuestions([gameTestCards.first]).single;
    expect(q.sentenceBefore, 'She is ');
    expect(q.sentenceAfter, ' today.');
    expect(q.options, hasLength(4));
    expect(q.options, contains('resilient'));
  });

  test('ipucusuz doğru cevap 100, ipuçlu 60 puan', () {
    n.selectOption(n.state.currentQuestion.correctWord.toUpperCase());
    expect(n.state.score, clozePointsNoHint);

    n.next();
    expect(n.state.showHint, isFalse);
    n.toggleHint();
    n.selectOption(n.state.currentQuestion.correctWord);
    expect(n.state.score, clozePointsNoHint + clozePointsWithHint);
  });

  test('restart puanı ve ilerlemeyi sıfırlar', () {
    n.selectOption(n.state.currentQuestion.correctWord);
    n.next();
    n.restart();
    expect(n.state.score, 0);
    expect(n.state.currentIndex, 0);
    expect(n.state.correctCount, 0);
  });

  test('oyun sonunda skor kaydedilir', () {
    while (!n.state.isFinished) {
      n.selectOption('yanlış');
      n.next();
    }
    expect(recorded, [0]);
  });
}
