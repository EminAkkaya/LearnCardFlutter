import '../models/flashcard_model.dart';

enum ReviewRating { again, hard, good, easy }

class SRSService {
  static const Map<ReviewRating, int> ratingMap = {
    ReviewRating.again: 1,
    ReviewRating.hard: 3,
    ReviewRating.good: 4,
    ReviewRating.easy: 5,
  };

  /// Calculates updated SRS metadata based on SM-2 recall rating
  static FlashcardModel calculateSRS(FlashcardModel card, ReviewRating rating) {
    final int q = ratingMap[rating] ?? 3;
    double easeFactor = card.easeFactor;
    int interval = card.interval;
    int repetitions = card.repetitions;

    if (q < 3) {
      // Incorrect recall: reset repetitions & set 1-day interval
      repetitions = 0;
      interval = 1;
      easeFactor = (easeFactor - 0.2).clamp(1.3, 5.0);
    } else {
      // Successful recall
      if (repetitions == 0) {
        interval = 1;
      } else if (repetitions == 1) {
        interval = 6;
      } else {
        interval = (interval * easeFactor).round();
      }
      repetitions += 1;

      // Standard SM-2 ease factor update formula
      easeFactor = easeFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
      if (easeFactor < 1.3) easeFactor = 1.3;
      easeFactor = double.parse(easeFactor.toStringAsFixed(2));
    }

    final DateTime nextDate = DateTime.now().add(Duration(days: interval));
    final String nextReviewDateStr = nextDate.toIso8601String().split('T')[0];

    String status = 'learning';
    if (repetitions == 0) {
      status = 'new';
    } else if (interval >= 21 || repetitions >= 5) {
      status = 'mastered';
    }

    return card.copyWith(
      easeFactor: easeFactor,
      interval: interval,
      repetitions: repetitions,
      nextReviewDate: nextReviewDateStr,
      status: status,
    );
  }

  /// Calculates next review interval preview in days for each rating option
  static Map<ReviewRating, int> getNextIntervalPreviews(FlashcardModel card) {
    final Map<ReviewRating, int> previews = {};
    for (final rating in ReviewRating.values) {
      final updated = calculateSRS(card, rating);
      previews[rating] = updated.interval;
    }
    return previews;
  }

  /// Checks if card is due for review today or overdue
  static bool isCardDue(FlashcardModel card) {
    if (card.nextReviewDate.isEmpty) return true;
    final String today = DateTime.now().toIso8601String().split('T')[0];
    return card.nextReviewDate.compareTo(today) <= 0;
  }
}
