import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/providers/games/word_match_provider.dart';
import 'game_test_cards.dart';

void main() {
  late List<int> recorded;
  late WordMatchNotifier n;

  setUp(() {
    recorded = [];
    n = WordMatchNotifier(
      gameTestCards.take(2).toList(),
      playAudio: (_) {},
      recordScore: recorded.add,
      mismatchDelay: Duration.zero,
      gameOverDelay: Duration.zero,
    );
  });

  tearDown(() => n.dispose());

  Future<void> flushTimers() => Future<void>.delayed(Duration.zero);

  test('her kart için EN ve TR kutucuğu üretilir', () {
    expect(n.state.tiles, hasLength(4));
    expect(n.state.totalPairs, 2);
  });

  test('doğru eşleşme seriyle artan puan verir', () {
    n.tapTile('c1_en');
    n.tapTile('c1_tr');
    expect(n.state.matchedPairs, 1);
    expect(n.state.score, 100);
    n.tapTile('c2_tr');
    n.tapTile('c2_en');
    expect(n.state.score, 100 + 200);
  });

  test('yanlış eşleşme kilitler, sonra kutucukları serbest bırakır', () async {
    n.tapTile('c1_en');
    n.tapTile('c2_tr');
    expect(n.state.isLocked, isTrue);
    expect(n.state.mistakes, 1);
    expect(n.state.score, 0);

    n.tapTile('c2_en'); // kilitliyken yok sayılır
    expect(n.state.tiles.where((t) => t.isSelected), hasLength(2));

    await flushTimers();
    expect(n.state.isLocked, isFalse);
    expect(n.state.tiles.any((t) => t.isSelected || t.isError), isFalse);
  });

  test('aynı dildeki iki kutucuk eşleşmez', () async {
    n.tapTile('c1_en');
    n.tapTile('c2_en');
    expect(n.state.matchedPairs, 0);
    await flushTimers();
  });

  test('tüm çiftler bulununca skor kaydedilir ve oyun biter', () async {
    n.tapTile('c1_en');
    n.tapTile('c1_tr');
    n.tapTile('c2_en');
    n.tapTile('c2_tr');
    expect(recorded, [300]);
    await flushTimers();
    expect(n.state.isGameOver, isTrue);
  });

  test('aynı anlamlı ikinci kart oyuna alınmaz, tanım etiketi doğru', () {
    final tiles = buildWordMatchTiles([
      testCard('a', 'car', 'araba'),
      testCard('b', 'automobile', 'araba'),
      testCard('c', 'house', ''),
    ]);
    expect(tiles, hasLength(4));
    expect(tiles.where((t) => t.text == 'araba'), hasLength(1));
    expect(tiles.firstWhere((t) => t.cardId == 'c' && !t.isEnglish).label, 'TANIM');
  });

  test('seri çarpanı sınırlıdır, hata puan düşürür', () {
    final many = WordMatchNotifier(
      [for (var i = 0; i < 5; i++) testCard('k$i', 'w$i', 'm$i')],
      playAudio: (_) {},
      recordScore: (_) {},
      mismatchDelay: Duration.zero,
      gameOverDelay: Duration.zero,
    );
    for (var i = 0; i < 5; i++) {
      many.tapTile('k${i}_en');
      many.tapTile('k${i}_tr');
    }
    expect(many.state.score, 100 + 200 + 300 + 300 + 300);
    many.dispose();
  });

  test('hatalı eşleşmede ilk seçilen kart tekrar listesine girer', () async {
    n.tapTile('c1_en');
    n.tapTile('c2_tr');
    expect(n.state.missedCards.map((c) => c.id), ['c1']);
    await flushTimers();
  });
}
