import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/models/flashcard_model.dart';
import 'package:learncard_flutter/services/srs_service.dart';

void main() {
  group('SRSService Tests', () {
    late FlashcardModel newCard;

    setUp(() {
      newCard = FlashcardModel(
        id: 'test_card_1',
        word: 'serendipity',
        definition: 'Happy accident',
        trTranslation: 'Tesadüf',
        status: 'new',
        interval: 0,
        repetitions: 0,
        learningStep: 0,
        easeFactor: 2.3,
        nextReviewDate: DateTime.now().toIso8601String(),
        createdAt: DateTime.now().toIso8601String(),
      );
    });

    test('1. Pressing Hard 5 times on a new card does not lock it permanently, and pressing Good graduates it', () {
      FlashcardModel card = newCard;

      // Press Hard 5 times
      for (int i = 0; i < 5; i++) {
        card = SRSService.calculateSRS(card, ReviewRating.hard);
        expect(card.status, equals('learning'));
        expect(card.interval, equals(0));
        expect(card.repetitions, equals(0));
      }

      // Ease factor reduced, but learningStep remained 0
      expect(card.learningStep, equals(0));

      // Press Good once -> moves to step 1
      card = SRSService.calculateSRS(card, ReviewRating.good);
      expect(card.learningStep, equals(1));
      expect(card.repetitions, equals(0));

      // Press Good again -> graduates!
      card = SRSService.calculateSRS(card, ReviewRating.good);
      expect(card.status, equals('learning'));
      expect(card.interval, equals(SRSService.graduatingIntervalDays));
      expect(card.repetitions, equals(1));
    });

    test('2. Hard interval preview is always <= Good interval preview from the same starting state', () {
      FlashcardModel card = newCard;

      // Test in learning phase
      FlashcardModel afterHardLearning = SRSService.calculateSRS(card, ReviewRating.hard);
      FlashcardModel afterGoodLearning = SRSService.calculateSRS(card, ReviewRating.good);
      DateTime hardDateLearning = DateTime.parse(afterHardLearning.nextReviewDate);
      DateTime goodDateLearning = DateTime.parse(afterGoodLearning.nextReviewDate);
      expect(hardDateLearning.isBefore(goodDateLearning) || hardDateLearning.isAtSameMomentAs(goodDateLearning), isTrue);

      // Test in review phase
      FlashcardModel reviewCard = card.copyWith(
        status: 'learning',
        repetitions: 2,
        interval: 10,
        easeFactor: 2.3,
      );
      FlashcardModel afterHardReview = SRSService.calculateSRS(reviewCard, ReviewRating.hard);
      FlashcardModel afterGoodReview = SRSService.calculateSRS(reviewCard, ReviewRating.good);

      expect(afterHardReview.interval, lessThanOrEqualTo(afterGoodReview.interval));
    });

    test('3. Again rating always drops card back to learning/relearning phase and resets interval to 0', () {
      FlashcardModel reviewCard = newCard.copyWith(
        status: 'learning',
        repetitions: 3,
        interval: 15,
        easeFactor: 2.5,
      );

      FlashcardModel afterAgain = SRSService.calculateSRS(reviewCard, ReviewRating.again);

      expect(afterAgain.repetitions, equals(0));
      expect(afterAgain.learningStep, equals(0));
      expect(afterAgain.interval, equals(0));
      expect(afterAgain.status, equals('learning'));
    });

    test('4. Interval never exceeds maxIntervalDays (180)', () {
      FlashcardModel reviewCard = newCard.copyWith(
        status: 'learning',
        repetitions: 10,
        interval: 160,
        easeFactor: 2.5,
      );

      FlashcardModel afterEasy = SRSService.calculateSRS(reviewCard, ReviewRating.easy);

      expect(afterEasy.interval, lessThanOrEqualTo(SRSService.maxIntervalDays));
      expect(afterEasy.interval, equals(180));
    });

    test('5. Legacy FlashcardModel without learningStep does not crash and defaults learningStep=0', () {
      final Map<String, dynamic> legacyJson = {
        'id': 'legacy_1',
        'word': 'ephemeral',
        'definition': 'Transient',
        'tr_translation': 'Geçici',
        'status': 'new',
        'interval': 0,
        'repetitions': 0,
        'ease_factor': 2.5,
        'next_review_date': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };

      final legacyCard = FlashcardModel.fromMap(legacyJson);
      expect(legacyCard.learningStep, equals(0));

      expect(() => SRSService.calculateSRS(legacyCard, ReviewRating.good), returnsNormally);
      final updated = SRSService.calculateSRS(legacyCard, ReviewRating.good);
      expect(updated.learningStep, equals(1));
    });

    test('6. Status becomes mastered when repetitions >= 4 and interval >= 21', () {
      FlashcardModel card = newCard.copyWith(
        status: 'learning',
        repetitions: 3,
        interval: 15,
        easeFactor: 2.0,
      );

      // Reviewing with Good -> interval becomes round(15 * 2.0) = 30, repetitions becomes 4
      FlashcardModel updated = SRSService.calculateSRS(card, ReviewRating.good);

      expect(updated.repetitions, greaterThanOrEqualTo(SRSService.masteredMinRepetitions));
      expect(updated.interval, greaterThanOrEqualTo(SRSService.masteredMinIntervalDays));
      expect(updated.status, equals('mastered'));
    });

    test('7. isCardDue strictly respects minute-based scheduled time', () {
      final now = DateTime.now();

      // Card scheduled 10 minutes in the past -> DUE
      final cardPast = newCard.copyWith(
        status: 'learning',
        interval: 0,
        nextReviewDate: now.subtract(const Duration(minutes: 10)).toIso8601String(),
      );
      expect(SRSService.isCardDue(cardPast), isTrue);

      // Card scheduled 10 minutes in the future -> NOT DUE YET
      final cardFuture = newCard.copyWith(
        status: 'learning',
        interval: 0,
        nextReviewDate: now.add(const Duration(minutes: 10)).toIso8601String(),
      );
      expect(SRSService.isCardDue(cardFuture), isFalse);
    });

    test('8. isCardDue correctly parses Supabase timestamptz with +00 offset (e.g. 2026-08-09 23:29:10.805991+00)', () {
      final cardUser = newCard.copyWith(
        status: 'learning',
        interval: 0,
        nextReviewDate: '2026-08-09 23:29:10.805991+00',
      );

      // Card target is 23:29:10, current local time is 23:31+, so it MUST be due
      expect(SRSService.isCardDue(cardUser), isTrue);
    });
  });
}
