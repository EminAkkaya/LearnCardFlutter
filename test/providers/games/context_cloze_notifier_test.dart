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

  test('cümledeki kelime boşluğa çevrilir, ek dışarıda kalır', () {
    final cards = [
      testCard('w', 'walk', 'yürümek', sentence: 'We walked home.'),
      ...gameTestCards,
    ];
    final q = buildClozeQuestions(cards).firstWhere((q) => q.card.id == 'w');
    expect(q.sentenceBefore, 'We ');
    expect(q.sentenceAfter, 'ed home.');
    expect(q.options, hasLength(4));
    expect(q.options, contains('walk'));
  });

  test('kelimesi cümlede geçmeyen kart ve az çeldirici atlanır', () {
    final cards = [testCard('x', 'run', 'koşmak', sentence: 'He ran fast.'), ...gameTestCards];
    expect(buildClozeQuestions(cards).any((q) => q.card.id == 'x'), isFalse);
    expect(buildClozeQuestions(gameTestCards.take(2).toList()), isEmpty);
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

  test('yanlış cevaplanan kart tekrar listesine girer', () {
    final card = n.state.currentQuestion.card;
    n.selectOption('yanlış');
    expect(n.state.missedCards.single.id, card.id);
  });
}
