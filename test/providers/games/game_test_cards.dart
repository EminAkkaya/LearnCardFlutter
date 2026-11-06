import 'package:learncard_flutter/models/flashcard_model.dart';

FlashcardModel testCard(String id, String word, String tr, {String sentence = ''}) {
  return FlashcardModel(
    id: id,
    word: word,
    definition: 'def of $word',
    trTranslation: tr,
    exampleSentence: sentence,
    status: 'new',
    interval: 0,
    repetitions: 0,
    easeFactor: 2.5,
    nextReviewDate: '2026-11-06',
    createdAt: '2026-11-06',
  );
}

final gameTestCards = [
  testCard('c1', 'resilient', 'dayanıklı', sentence: 'She is resilient today.'),
  testCard('c2', 'serendipity', 'tatlı tesadüf', sentence: 'Pure serendipity.'),
  testCard('c3', 'ephemeral', 'geçici', sentence: 'Fame is ephemeral.'),
  testCard('c4', 'ubiquitous', 'her yerde', sentence: 'Phones are ubiquitous.'),
];
