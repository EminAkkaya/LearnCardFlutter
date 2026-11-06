import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/models/flashcard_model.dart';
import 'package:learncard_flutter/providers/games/practice_order.dart';

FlashcardModel _card(String id, {required String status, double ease = 2.5, int interval = 10}) {
  return FlashcardModel(
    id: id,
    word: id,
    status: status,
    easeFactor: ease,
    interval: interval,
    nextReviewDate: '2026-11-07',
    createdAt: '2026-11-07',
  );
}

void main() {
  test('zayıf kart güçlü kartlardan daha ağırdır', () {
    final weak = _card('weak', status: 'learning', ease: 2.0, interval: 1);
    final strong = _card('strong', status: 'mastered');
    expect(practiceWeight(weak), greaterThan(practiceWeight(strong) * 5));
  });

  test('sıralama tüm kartları bir kez içerir', () {
    final cards = [for (var i = 0; i < 20; i++) _card('c$i', status: i.isEven ? 'new' : 'mastered')];
    final ordered = practiceOrder(cards, random: Random(1));
    expect(ordered.map((c) => c.id).toSet(), cards.map((c) => c.id).toSet());
    expect(ordered, hasLength(20));
  });

  test('zayıf kart başa belirgin şekilde daha sık gelir', () {
    final cards = [
      _card('weak', status: 'learning', ease: 2.0, interval: 1),
      for (var i = 0; i < 9; i++) _card('m$i', status: 'mastered'),
    ];
    final rng = Random(42);
    var weakFirst = 0;
    const trials = 500;
    for (var i = 0; i < trials; i++) {
      if (practiceOrder(cards, random: rng).first.id == 'weak') weakFirst++;
    }
    // Eşit dağılımda ~%10 olurdu; ağırlık 9x → ~%50.
    expect(weakFirst / trials, greaterThan(0.35));
  });
}
