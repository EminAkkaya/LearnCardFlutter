import 'dart:math';
import '../../models/flashcard_model.dart';

/// Bir kartın oyunda öne çıkma ağırlığı: henüz oturmamış (yeni/öğreniliyor),
/// kolaylık katsayısı düşük (sık unutulan) ve aralığı kısa kartlar daha ağır.
double practiceWeight(FlashcardModel card) {
  var weight = card.status == 'mastered' ? 1.0 : 3.0;
  if (card.easeFactor < 2.3) weight *= 2;
  if (card.interval <= 1) weight *= 1.5;
  return weight;
}

/// Ağırlıklı rastgele sıralama (Efraimidis–Spirakis): zayıf kartlar daha sık
/// başa gelir ama güçlü kartlar da hâlâ çıkabilir; her oyun farklı olur.
List<FlashcardModel> practiceOrder(List<FlashcardModel> cards, {Random? random}) {
  final rng = random ?? Random();
  final keyed = [
    for (final card in cards) (card, pow(rng.nextDouble(), 1 / practiceWeight(card)).toDouble()),
  ]..sort((a, b) => b.$2.compareTo(a.$2));
  return [for (final entry in keyed) entry.$1];
}
