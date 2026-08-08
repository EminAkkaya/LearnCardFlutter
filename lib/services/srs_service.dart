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
    DateTime nextDate = DateTime.now();

    if (q < 3) {
      // Incorrect recall (Again) - Completely unknown
      // Reset to learning phase & set 10-minute interval
      repetitions = 0;
      interval = 0; 
      easeFactor = (easeFactor - 0.2).clamp(1.3, 5.0);
      nextDate = nextDate.add(const Duration(minutes: 10));
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

      nextDate = nextDate.add(Duration(days: interval));
    }

    // Keep full ISO string including time for minute-level precision
    final String nextReviewDateStr = nextDate.toIso8601String();

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

  /// Calculates next review interval preview in string format for each rating
  static Map<ReviewRating, String> getNextIntervalPreviews(FlashcardModel card) {
    final Map<ReviewRating, String> previews = {};
    for (final rating in ReviewRating.values) {
      final updated = calculateSRS(card, rating);
      if (rating == ReviewRating.again || updated.interval == 0) {
        previews[rating] = '10dk';
      } else {
        previews[rating] = '${updated.interval}g';
      }
    }
    return previews;
  }

  /// Checks if card is due for review today or overdue
  static bool isCardDue(FlashcardModel card) {
    if (card.nextReviewDate.isEmpty) return true;
    final DateTime now = DateTime.now();
    try {
      final DateTime reviewDate = DateTime.parse(card.nextReviewDate);
      return reviewDate.isBefore(now) || reviewDate.isAtSameMomentAs(now);
    } catch (e) {
      // Fallback for older formats (YYYY-MM-DD)
      final String todayStr = now.toIso8601String().split('T')[0];
      return card.nextReviewDate.compareTo(todayStr) <= 0;
    }
  }
}
