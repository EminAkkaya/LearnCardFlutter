/// LearnCard SRS (Spaced Repetition System) Algoritması
/// 
/// Bu algoritma Anki'nin SM-2 hibrit varyantından esinlenerek geliştirilmiştir:
/// - Öğrenme/Relearning adımları kademeli olarak dakikadan güne ilerler.
/// - Review fazında "Hard" davranışı ease factor'den bağımsız sabit 1.2x çarpanıyla
///   hesaplanır ve her basıldığında tekrar sayısını (repetitions) kesinlikle artırır.
/// - Gelecekte daha gelişmiş bir zamanlama için FSRS (Free Spaced Repetition Scheduler)
///   algoritmasına geçiş değerlendirilebilir (bkz: https://github.com/open-spaced-repetition).
library;

import '../models/flashcard_model.dart';

enum ReviewRating { again, hard, good, easy }

class SRSService {
  // SRS Algoritması Sabitleri
  static const List<Duration> learningSteps = [
    Duration(minutes: 10),
    Duration(days: 1),
  ];
  static const int graduatingIntervalDays = 3;
  static const int easyGraduatingIntervalDays = 7;
  static const double hardIntervalMultiplier = 1.2;
  static const double easyBonusMultiplier = 1.3;
  static const double minEase = 1.3;
  static const double maxEase = 3.0;
  static const double defaultEase = 2.3;
  static const int maxIntervalDays = 180;
  static const int masteredMinRepetitions = 4;
  static const int masteredMinIntervalDays = 21;

  static const Map<ReviewRating, int> ratingMap = {
    ReviewRating.again: 1,
    ReviewRating.hard: 3,
    ReviewRating.good: 4,
    ReviewRating.easy: 5,
  };

  /// Calculates updated SRS metadata based on recall rating using Anki-style hybrid SM-2 algorithm.
  static FlashcardModel calculateSRS(FlashcardModel card, ReviewRating rating) {
    double easeFactor = card.easeFactor;
    if (easeFactor < minEase || easeFactor > maxEase) {
      easeFactor = card.easeFactor <= 0 ? defaultEase : card.easeFactor.clamp(minEase, maxEase);
    }

    int interval = card.interval;
    int repetitions = card.repetitions;
    int learningStep = card.learningStep;
    final DateTime now = DateTime.now();
    DateTime nextDate = now;
    String status = card.status;

    // Check phase: Learning/Relearning phase vs Review phase
    final bool isLearningPhase = card.status == 'new' || card.repetitions == 0;

    if (isLearningPhase) {
      switch (rating) {
        case ReviewRating.again:
          learningStep = 0;
          easeFactor = (easeFactor - 0.20).clamp(minEase, maxEase);
          interval = 0;
          repetitions = 0;
          status = 'learning';
          nextDate = now.add(learningSteps[0]);
          break;

        case ReviewRating.hard:
          // learningStep doesn't advance, repeat same step
          int stepIndex = learningStep.clamp(0, learningSteps.length - 1);
          easeFactor = (easeFactor - 0.10).clamp(minEase, maxEase);
          interval = 0;
          repetitions = 0;
          status = 'learning';
          nextDate = now.add(learningSteps[stepIndex]);
          break;

        case ReviewRating.good:
          int nextStep = learningStep + 1;
          if (nextStep >= learningSteps.length) {
            // Graduate!
            status = 'learning';
            interval = graduatingIntervalDays;
            repetitions = 1;
            learningStep = nextStep;
            nextDate = now.add(Duration(days: interval));
          } else {
            learningStep = nextStep;
            interval = 0;
            repetitions = 0;
            status = 'learning';
            nextDate = now.add(learningSteps[nextStep]);
          }
          break;

        case ReviewRating.easy:
          // Skip remaining steps and graduate immediately
          status = 'learning';
          interval = easyGraduatingIntervalDays;
          repetitions = 1;
          learningStep = learningSteps.length;
          nextDate = now.add(Duration(days: interval));
          break;
      }
    } else {
      // Review Phase
      switch (rating) {
        case ReviewRating.again:
          repetitions = 0;
          learningStep = 0;
          status = 'learning';
          interval = 0;
          easeFactor = (easeFactor - 0.20).clamp(minEase, maxEase);
          nextDate = now.add(learningSteps[0]);
          break;

        case ReviewRating.hard:
          int newInterval = (interval * hardIntervalMultiplier).round();
          if (newInterval <= interval) newInterval = interval + 1;
          if (newInterval > maxIntervalDays) newInterval = maxIntervalDays;
          interval = newInterval;
          easeFactor = (easeFactor - 0.15).clamp(minEase, maxEase);
          repetitions += 1;
          nextDate = now.add(Duration(days: interval));
          break;

        case ReviewRating.good:
          int newInterval = (interval * easeFactor).round();
          if (newInterval <= interval) newInterval = interval + 1;
          if (newInterval > maxIntervalDays) newInterval = maxIntervalDays;
          interval = newInterval;

          // Standard SM-2 ease update with q = 4
          const double q = 4.0;
          easeFactor = easeFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
          easeFactor = easeFactor.clamp(minEase, maxEase);
          repetitions += 1;
          nextDate = now.add(Duration(days: interval));
          break;

        case ReviewRating.easy:
          int newInterval = (interval * easeFactor * easyBonusMultiplier).round();
          if (newInterval <= interval) newInterval = interval + 1;
          if (newInterval > maxIntervalDays) newInterval = maxIntervalDays;
          interval = newInterval;
          easeFactor = (easeFactor + 0.15).clamp(minEase, maxEase);
          repetitions += 1;
          nextDate = now.add(Duration(days: interval));
          break;
      }
    }

    // Ensure interval does not exceed maxIntervalDays
    if (interval > maxIntervalDays) {
      interval = maxIntervalDays;
    }

    // Update status if conditions for mastered are met
    if (repetitions >= masteredMinRepetitions && interval >= masteredMinIntervalDays) {
      status = 'mastered';
    } else if (status != 'new' && status != 'mastered') {
      status = 'learning';
    }

    easeFactor = double.parse(easeFactor.toStringAsFixed(2));

    return card.copyWith(
      easeFactor: easeFactor,
      interval: interval,
      repetitions: repetitions,
      learningStep: learningStep,
      nextReviewDate: nextDate.toIso8601String(),
      status: status,
    );
  }

  /// Calculates next review interval preview in string format for each rating
  static Map<ReviewRating, String> getNextIntervalPreviews(FlashcardModel card) {
    final Map<ReviewRating, String> previews = {};
    final DateTime now = DateTime.now();
    for (final rating in ReviewRating.values) {
      final updated = calculateSRS(card, rating);
      final DateTime nextDate = DateTime.tryParse(updated.nextReviewDate) ?? now;
      final Duration diff = nextDate.difference(now);

      if (diff.inMinutes < 60) {
        final int mins = diff.inMinutes <= 0 ? 1 : diff.inMinutes;
        previews[rating] = '${mins}dk';
      } else if (diff.inHours < 24) {
        previews[rating] = '${diff.inHours}sa';
      } else {
        previews[rating] = '${diff.inDays}g';
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
