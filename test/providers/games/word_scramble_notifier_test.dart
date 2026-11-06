import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/providers/games/word_scramble_provider.dart';
import 'game_test_cards.dart';

void main() {
  late List<int> recorded;
  late WordScrambleNotifier n;

  setUp(() {
    recorded = [];
    n = WordScrambleNotifier(
      [testCard('a', 'cat', 'kedi'), testCard('b', 'dog', 'köpek'), testCard('x', 'two words', 'iki')],
      playAudio: (_) {},
      recordScore: recorded.add,
    );
  });

  void placeWord(String word) {
    for (final ch in word.split('')) {
      final tile = n.state.pool.firstWhere((t) => !t.isPlaced && t.char == ch);
      n.placeTile(tile);
    }
  }

  test('boşluklu kelimeler oyuna alınmaz', () {
    expect(n.state.cards.map((c) => c.word), unorderedEquals(['cat', 'dog']));
  });

  test('doğru dizilim kelimeyi tamamlar ve 100 puan verir', () {
    placeWord(n.state.targetWord);
    expect(n.state.isCompleted, isTrue);
    expect(n.state.score, scramblePointsPerWord);
  });

  test('yanlış dizilim hata verir, slot silince hata kalkar', () {
    final reversed = n.state.targetWord.split('').reversed.join();
    placeWord(reversed);
    expect(n.state.hasError, isTrue);
    n.removeAt(0);
    expect(n.state.hasError, isFalse);
    expect(n.state.placedIds, hasLength(2));
    expect(n.state.pool.where((t) => t.isPlaced), hasLength(2));
  });

  test('ipucu cezası yalnız o kelimenin ödülünden düşer', () {
    placeWord(n.state.targetWord);
    n.next();
    expect(n.state.score, 100);
    n.hint();
    expect(n.state.placedLetters.single.char, n.state.targetWord[0]);
    expect(n.state.score, 100);
    placeWord(n.state.targetWord.substring(1));
    expect(n.state.score, 100 + scramblePointsPerWord - scrambleHintPenalty);
  });

  test('geç butonu puansız sonraki kelimeye geçer, sonda skor kaydedilir', () {
    n.skip();
    expect(n.state.currentIndex, 1);
    expect(n.state.skippedCount, 1);
    n.skip();
    expect(n.state.isFinished, isTrue);
    expect(recorded, [0]);
  });

  test('Türkçe İ tek harf karosu olur', () {
    expect(normalizeScrambleWord('İnci'), 'inci');
    expect(buildLetterPool(normalizeScrambleWord('İnci')), hasLength(4));
  });

  test('temizle tüm harfleri havuza geri koyar', () {
    n.hint();
    n.clearSlots();
    expect(n.state.placedIds, isEmpty);
    expect(n.state.pool.any((t) => t.isPlaced), isFalse);
  });

  test('son kelimeden sonra skor kaydedilir', () {
    placeWord(n.state.targetWord);
    n.next();
    placeWord(n.state.targetWord);
    expect(recorded, [200]);
    n.next();
    expect(n.state.isFinished, isTrue);
  });
}
