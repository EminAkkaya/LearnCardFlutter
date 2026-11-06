import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/providers/games/speed_quiz_provider.dart';
import 'game_test_cards.dart';

void main() {
  late List<int> recorded;
  late SpeedQuizNotifier n;

  setUp(() {
    recorded = [];
    n = SpeedQuizNotifier(
      gameTestCards,
      playAudio: (_) {},
      recordScore: recorded.add,
      useTimer: false,
    );
  });

  tearDown(() => n.dispose());

  String wrongOption() =>
      n.state.currentQuestion.options.firstWhere((o) => o != n.state.currentQuestion.correctAnswer);

  test('her soru 4 farklı şık ve doğru cevabı içerir', () {
    final qs = buildSpeedQuizQuestions(gameTestCards);
    expect(qs, hasLength(4));
    for (final q in qs) {
      expect(q.options.toSet(), hasLength(4));
      expect(q.options, contains(q.correctAnswer));
    }
  });

  test('doğru cevap süre ve seriye göre puan verir', () {
    n.tick();
    n.tick(); // 8 sn kaldı
    n.selectOption(n.state.currentQuestion.correctAnswer);
    expect(n.state.score, 100 + 8 * 10);
    expect(n.state.streak, 1);

    n.next();
    n.selectOption(n.state.currentQuestion.correctAnswer);
    expect(n.state.score, 180 + (100 + 10 * 10 + 1 * 20));
    expect(n.state.maxStreak, 2);
  });

  test('yanlış cevap seriyi sıfırlar ve puan vermez', () {
    n.selectOption(n.state.currentQuestion.correctAnswer);
    n.next();
    n.selectOption(wrongOption());
    expect(n.state.streak, 0);
    expect(n.state.maxStreak, 1);
    expect(n.state.correctCount, 1);
  });

  test('süre bitince soru cevapsız kapanır, sonra seçim yok sayılır', () {
    for (var i = 0; i < speedQuizQuestionSeconds; i++) {
      n.tick();
    }
    expect(n.state.isAnswered, isTrue);
    expect(n.state.selectedOption, isNull);
    n.selectOption(n.state.currentQuestion.correctAnswer);
    expect(n.state.score, 0);
  });

  test('son sorudan sonra skor bir kez kaydedilir', () {
    for (var i = 0; i < 4; i++) {
      n.selectOption(n.state.currentQuestion.correctAnswer);
      n.next();
    }
    expect(n.state.isFinished, isTrue);
    expect(recorded, [n.state.score]);
    n.next();
    expect(recorded, hasLength(1));
  });

  test('skor son cevap anında kaydedilir (özet ekranına geçmeden çıkılsa da)', () {
    for (var i = 0; i < 4; i++) {
      n.selectOption(n.state.currentQuestion.correctAnswer);
      if (i < 3) n.next();
    }
    expect(n.state.isFinished, isFalse);
    expect(recorded, hasLength(1));
  });

  test('cevaplanmadan sonraki soruya geçilmez', () {
    n.next();
    expect(n.state.currentIndex, 0);
  });

  test('çeldiriciler yalnız desteden ve aynı türden gelir', () {
    final mixed = [
      ...gameTestCards,
      testCard('d1', 'alpha', ''),
      testCard('d2', 'beta', ''),
    ];
    final qs = buildSpeedQuizQuestions(mixed);
    final trMeanings = gameTestCards.map((c) => c.trTranslation).toSet();
    for (final q in qs) {
      final isTrQuestion = trMeanings.contains(q.correctAnswer);
      for (final o in q.options) {
        expect(trMeanings.contains(o), isTrQuestion, reason: 'karışık tür: ${q.options}');
      }
    }
    // tanım kartları için yalnız 1 çeldirici var → soru üretilmez
    expect(qs.any((q) => q.correctAnswer.startsWith('def of')), isFalse);
  });

  test('yeterli çeldirici yoksa soru üretilmez', () {
    expect(buildSpeedQuizQuestions(gameTestCards.take(2).toList()), isEmpty);
    expect(buildSpeedQuizQuestions(gameTestCards.take(3).toList()), hasLength(3));
  });

  test('yanlış ve süresi dolan sorular tekrar listesine girer', () {
    final first = n.state.currentQuestion.card;
    n.selectOption(wrongOption());
    n.next();
    final second = n.state.currentQuestion.card;
    for (var i = 0; i < speedQuizQuestionSeconds; i++) {
      n.tick();
    }
    n.next();
    n.selectOption(n.state.currentQuestion.correctAnswer);
    expect(n.state.missedCards.map((c) => c.id), [first.id, second.id]);
    n.restart();
    expect(n.state.missedIds, isEmpty);
  });
}
