import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/models/flashcard_model.dart';
import 'package:learncard_flutter/services/srs_service.dart';

/// Sabit "şimdi": yerel 7 Kasım 2026 öğlen.
final DateTime now = DateTime(2026, 11, 7, 12, 0);

FlashcardModel card({
  String id = 'card_1',
  String status = 'new',
  int interval = 0,
  int repetitions = 0,
  int learningStep = 0,
  double ease = 2.5,
  DateTime? due,
  String? nextReviewDate,
}) =>
    FlashcardModel(
      id: id,
      word: 'serendipity',
      definition: 'Happy accident',
      trTranslation: 'Tesadüf',
      status: status,
      interval: interval,
      repetitions: repetitions,
      learningStep: learningStep,
      easeFactor: ease,
      nextReviewDate: nextReviewDate ?? SRSService.formatReviewDate(due ?? now),
      createdAt: '2026-11-01T00:00:00.000Z',
    );

/// Tekrar fazındaki, zamanında gelmiş kart.
FlashcardModel review(int interval, {double ease = 2.5, int reps = 3, String id = 'card_1', DateTime? due}) =>
    card(id: id, status: 'learning', interval: interval, repetitions: reps, learningStep: 2, ease: ease, due: due);

FlashcardModel rate(FlashcardModel c, ReviewRating r, {DateTime? at}) =>
    SRSService.calculateSRS(c, r, now: at ?? now);

DateTime dueOf(FlashcardModel c) => SRSService.parseReviewDate(c.nextReviewDate)!.toLocal();

int fuzzRange(int days) => days < SRSService.fuzzMinIntervalDays ? 0 : max(1, (days * SRSService.fuzzFraction).round());

Matcher near(int days) => inInclusiveRange(days - fuzzRange(days), days + fuzzRange(days));

/// Önizleme etiketinin sonuç karttan beklenen hali.
String expectedLabel(FlashcardModel updated, DateTime at) {
  if (updated.repetitions > 0) return '${updated.interval}g';
  final diff = dueOf(updated).difference(at);
  if (diff.inMinutes < 60) return '${max(1, diff.inMinutes)}dk';
  if (diff.inHours < 24) return '${diff.inHours}sa';
  return '${diff.inDays}g';
}

void main() {
  group('learning steps (new card)', () {
    test('Again 1m, Hard 5m (between steps), Good 10m, Easy graduates to ~4d', () {
      final c = card();
      final again = rate(c, ReviewRating.again);
      final hard = rate(c, ReviewRating.hard);
      final good = rate(c, ReviewRating.good);
      final easy = rate(c, ReviewRating.easy);

      expect(dueOf(again), now.add(const Duration(minutes: 1)));
      expect(dueOf(hard), now.add(const Duration(minutes: 5, seconds: 30)));
      expect(dueOf(good), now.add(const Duration(minutes: 10)));
      expect(good.learningStep, 1);
      for (final r in [again, hard, good]) {
        expect(r.status, 'learning');
        expect(r.repetitions, 0);
        expect(r.interval, 0);
      }

      expect(easy.repetitions, 1);
      expect(easy.interval, near(SRSService.easyIntervalDays));
      expect(dueOf(easy), SRSService.dueDateAfterDays(now, easy.interval));
    });

    test('last step: Good graduates to 1 day at next 04:00, Hard repeats 10m', () {
      final c = card(status: 'learning', learningStep: 1);
      final good = rate(c, ReviewRating.good);
      expect(good.interval, SRSService.graduatingIntervalDays);
      expect(good.repetitions, 1);
      expect(good.status, 'learning');
      expect(dueOf(good), DateTime(2026, 11, 8, 4));

      expect(dueOf(rate(c, ReviewRating.hard)), now.add(const Duration(minutes: 10)));
      final again = rate(c, ReviewRating.again);
      expect(again.learningStep, 0);
      expect(dueOf(again), now.add(const Duration(minutes: 1)));
    });

    test('learning ratings never change ease (no ease hell before graduating)', () {
      var c = card(ease: 2.5);
      for (var i = 0; i < 5; i++) {
        c = rate(c, ReviewRating.hard);
        c = rate(c, ReviewRating.again);
      }
      expect(c.easeFactor, 2.5);
      c = rate(rate(c, ReviewRating.good), ReviewRating.good);
      expect(c.repetitions, 1);
      expect(c.easeFactor, 2.5);
    });

    test('Good, Good path: 1m -> 10m -> 1d -> ~3d -> ~8d -> ~20d -> mastered', () {
      var c = card(id: 'path');
      var at = now;
      final intervals = <int>[];
      c = rate(c, ReviewRating.good, at: at);
      c = rate(c, ReviewRating.good, at: at);
      intervals.add(c.interval);
      for (var i = 0; i < 4; i++) {
        at = dueOf(c).add(const Duration(hours: 6));
        c = rate(c, ReviewRating.good, at: at);
        intervals.add(c.interval);
      }
      expect(intervals[0], 1);
      expect(intervals[1], near(3));
      expect(intervals[2], inInclusiveRange(6, 12));
      expect(intervals[3], inInclusiveRange(15, 30));
      expect(intervals[4], greaterThanOrEqualTo(SRSService.masteredMinIntervalDays));
      expect(c.status, 'mastered');
    });
  });

  group('review phase', () {
    test('on-time review: Hard ~1.2x, Good ~ease x, Easy ~ease x 1.3 with ease changes', () {
      final c = review(10, ease: 2.5);
      final hard = rate(c, ReviewRating.hard);
      final good = rate(c, ReviewRating.good);
      final easy = rate(c, ReviewRating.easy);

      expect(hard.interval, inInclusiveRange(11, 13));
      expect(good.interval, near(25));
      expect(easy.interval, near(33));
      expect(hard.easeFactor, 2.35);
      expect(good.easeFactor, 2.5);
      expect(easy.easeFactor, 2.65);
      for (final r in [hard, good, easy]) {
        expect(r.repetitions, 4);
        expect(dueOf(r), SRSService.dueDateAfterDays(now, r.interval));
      }
    });

    test('small interval with low ease still gives Hard < Good < Easy', () {
      final c = review(1, ease: 1.3, reps: 1);
      final hard = rate(c, ReviewRating.hard).interval;
      final good = rate(c, ReviewRating.good).interval;
      final easy = rate(c, ReviewRating.easy).interval;
      expect(hard, greaterThanOrEqualTo(2));
      expect(hard, lessThan(good));
      expect(good, lessThan(easy));
    });

    test('Hard < Good < Easy and Again earliest for many random states; preview == result', () {
      final rng = Random(42);
      const statuses = ['new', 'learning', 'mastered', 'weird'];
      for (var i = 0; i < 3000; i++) {
        final at = DateTime(2026, 1 + rng.nextInt(12), 1 + rng.nextInt(28), 5 + rng.nextInt(19), rng.nextInt(60));
        final c = card(
          id: 'rnd_$i',
          status: statuses[rng.nextInt(statuses.length)],
          interval: rng.nextInt(420) - 5,
          repetitions: rng.nextInt(12) - 1,
          learningStep: rng.nextInt(6) - 1,
          ease: rng.nextDouble() * 4 - 0.5,
          due: at.subtract(Duration(minutes: rng.nextInt(400 * 1440) - 60 * 1440)),
        );
        final results = {for (final r in ReviewRating.values) r: SRSService.calculateSRS(c, r, now: at)};
        final previews = SRSService.getNextIntervalPreviews(c, now: at);

        for (final entry in results.entries) {
          final r = entry.value;
          expect(r.interval, inInclusiveRange(0, SRSService.maxIntervalDays), reason: '$c');
          expect(r.easeFactor, inInclusiveRange(SRSService.minEase, SRSService.maxEase));
          expect(dueOf(r).isAfter(at), isTrue);
          expect(previews[entry.key], expectedLabel(r, at), reason: '${entry.key} for state $i');
          expect(r.status == 'mastered', r.repetitions > 0 && r.interval >= SRSService.masteredMinIntervalDays);
        }

        final again = dueOf(results[ReviewRating.again]!);
        final hard = dueOf(results[ReviewRating.hard]!);
        final good = dueOf(results[ReviewRating.good]!);
        final easy = dueOf(results[ReviewRating.easy]!);
        final capped = results[ReviewRating.easy]!.interval == SRSService.maxIntervalDays;
        expect(again.isBefore(hard), isTrue, reason: 'again<hard state $i');
        if (capped) {
          expect(hard.isAfter(good), isFalse);
          expect(good.isAfter(easy), isFalse);
        } else {
          expect(hard.isBefore(good), isTrue, reason: 'hard<good state $i');
          expect(good.isBefore(easy), isTrue, reason: 'good<easy state $i');
        }
      }
    });
  });

  group('lapses', () {
    test('Again on a review card: ease -0.20, interval kept at 25%, relearn in 10m', () {
      final lapsed = rate(review(40, ease: 2.5), ReviewRating.again);
      expect(lapsed.easeFactor, 2.3);
      expect(lapsed.interval, 10);
      expect(lapsed.repetitions, 0);
      expect(lapsed.learningStep, 0);
      expect(lapsed.status, 'learning');
      expect(dueOf(lapsed), now.add(const Duration(minutes: 10)));

      // Yeniden öğrenme: Hard 15dk, Again 10dk, ease değişmez.
      expect(dueOf(rate(lapsed, ReviewRating.hard)), now.add(const Duration(minutes: 15)));
      expect(rate(lapsed, ReviewRating.again).easeFactor, 2.3);
      expect(rate(lapsed, ReviewRating.again).interval, 10);

      final back = rate(lapsed, ReviewRating.good);
      expect(back.repetitions, 1);
      expect(back.interval, near(10));
      expect(back.easeFactor, 2.3);
      expect(rate(lapsed, ReviewRating.easy).interval, greaterThan(back.interval));
    });

    test('lapse of a young card returns after at least 1 day', () {
      final lapsed = rate(review(2, reps: 1), ReviewRating.again);
      expect(lapsed.interval, SRSService.minLapseIntervalDays);
      expect(rate(lapsed, ReviewRating.good).interval, 1);
    });

    test('mastered card that is forgotten goes back to learning', () {
      final m = review(60).copyWith(status: 'mastered');
      final lapsed = rate(m, ReviewRating.again);
      expect(lapsed.status, 'learning');
      expect(lapsed.interval, 15);
    });
  });

  group('ease bounds', () {
    test('ease never drops below min and never rises above max', () {
      var c = review(10, ease: 1.4);
      for (var i = 0; i < 10; i++) {
        c = rate(c, i.isEven ? ReviewRating.hard : ReviewRating.again);
        if (c.repetitions == 0) c = rate(c, ReviewRating.good);
      }
      expect(c.easeFactor, SRSService.minEase);

      var e = review(3, ease: 2.9);
      for (var i = 0; i < 5; i++) {
        e = rate(e, ReviewRating.easy);
      }
      expect(e.easeFactor, SRSService.maxEase);
    });

    test('invalid stored ease is repaired', () {
      expect(rate(review(10, ease: 0), ReviewRating.good).easeFactor, SRSService.defaultEase);
      expect(rate(review(10, ease: double.nan), ReviewRating.good).easeFactor, SRSService.defaultEase);
      expect(rate(review(10, ease: 9), ReviewRating.good).easeFactor, SRSService.maxEase);
      expect(rate(review(10, ease: 0.5), ReviewRating.good).easeFactor, SRSService.minEase);
    });
  });

  group('fuzz', () {
    test('is deterministic and stays within bounds', () {
      for (final days in [3, 7, 20, 50, 100, 300]) {
        for (var i = 0; i < 200; i++) {
          final f = SRSService.applyFuzz(days, 'seed$i');
          expect(f, SRSService.applyFuzz(days, 'seed$i'));
          expect(f, near(days));
        }
      }
      expect(SRSService.applyFuzz(1, 'x'), 1);
      expect(SRSService.applyFuzz(2, 'x'), 2);
    });

    test('same rating on the same state gives the same result (preview == actual)', () {
      final c = review(30, id: 'stable');
      expect(rate(c, ReviewRating.good).interval, rate(c, ReviewRating.good).interval);
    });

    test('cards added on the same day spread over several days', () {
      final intervals = {
        for (var i = 0; i < 60; i++) rate(review(20, id: 'card_$i'), ReviewRating.good).interval,
      };
      expect(intervals.length, greaterThanOrEqualTo(3));
      expect(intervals.every((d) => d >= 47 && d <= 53), isTrue);
    });
  });

  group('overdue and early reviews', () {
    test('overdue: part of the delay is added (Hard 1/4, Good 1/2, Easy all)', () {
      final c = review(10, ease: 2.5, due: now.subtract(const Duration(days: 10)));
      expect(rate(c, ReviewRating.hard).interval, inInclusiveRange(13, 15)); // (10+2)*1.2
      expect(rate(c, ReviewRating.good).interval, near(38)); // (10+5)*2.5
      expect(rate(c, ReviewRating.easy).interval, near(65)); // 20*2.5*1.3
      expect(rate(c, ReviewRating.good).interval, greaterThan(rate(review(10), ReviewRating.good).interval));
    });

    test('early review never shrinks Good below the current interval', () {
      final c = review(30, ease: 2.5, due: now.add(const Duration(days: 20)));
      expect(rate(c, ReviewRating.good).interval, greaterThanOrEqualTo(30));
      expect(rate(c, ReviewRating.hard).interval, lessThan(30));
    });
  });

  group('day boundary and limits', () {
    test('day intervals start at 04:00 local; 02:00 belongs to the previous day', () {
      final step = card(status: 'learning', learningStep: 1);
      expect(dueOf(rate(step, ReviewRating.good, at: DateTime(2026, 11, 8, 2))), DateTime(2026, 11, 8, 4));
      expect(dueOf(rate(step, ReviewRating.good, at: DateTime(2026, 11, 7, 23, 30))), DateTime(2026, 11, 8, 4));
      expect(dueOf(rate(step, ReviewRating.good, at: DateTime(2026, 11, 8, 5))), DateTime(2026, 11, 9, 4));
    });

    test('stored dates are UTC', () {
      expect(rate(review(10), ReviewRating.good).nextReviewDate.endsWith('Z'), isTrue);
    });

    test('interval never exceeds maxIntervalDays', () {
      expect(rate(review(300), ReviewRating.easy).interval, SRSService.maxIntervalDays);
      expect(rate(review(365), ReviewRating.good).interval, SRSService.maxIntervalDays);
      expect(rate(review(365), ReviewRating.hard).interval, SRSService.maxIntervalDays);
    });

    test('mastered means a review interval of at least 21 days', () {
      final ok = rate(review(10, ease: 2.2), ReviewRating.good); // 22 ± 1
      expect(ok.status, 'mastered');
      final notYet = rate(review(5), ReviewRating.good); // ~13
      expect(notYet.status, 'learning');
    });
  });

  group('legacy cards from the old algorithm', () {
    test('old relearning state (interval 0, reps 0) restarts learning normally', () {
      final c = card(status: 'learning', interval: 0, repetitions: 0, learningStep: 0, ease: 2.1);
      expect(dueOf(rate(c, ReviewRating.good)), now.add(const Duration(minutes: 10)));
    });

    test('old 1-day step (learningStep 1, reps 0) graduates on Good', () {
      final c = card(status: 'learning', learningStep: 1, nextReviewDate: '2026-11-06');
      final g = rate(c, ReviewRating.good);
      expect(g.repetitions, 1);
      expect(g.interval, 1);
    });

    test('old graduated cards (learningStep 2, 3-day/7-day intervals) continue as reviews', () {
      final c = card(status: 'learning', interval: 3, repetitions: 1, learningStep: 2, ease: 2.3,
          nextReviewDate: now.subtract(const Duration(hours: 1)).toIso8601String());
      final g = rate(c, ReviewRating.good);
      expect(g.repetitions, 2);
      expect(g.interval, near(7));
    });

    test('out-of-range and missing values do not crash', () {
      final weird = [
        card(status: 'new', interval: 5, repetitions: 3, learningStep: 9),
        card(status: 'learning', interval: -4, repetitions: 0, learningStep: -2),
        card(status: 'mastered', interval: 0, repetitions: 7, nextReviewDate: ''),
        card(status: 'learning', interval: 1000, repetitions: 2, nextReviewDate: 'garbage'),
        FlashcardModel.fromMap({'id': 'legacy', 'word': 'ephemeral'}),
      ];
      for (final c in weird) {
        for (final r in ReviewRating.values) {
          expect(() => SRSService.calculateSRS(c, r, now: now), returnsNormally);
          final out = SRSService.calculateSRS(c, r, now: now);
          expect(out.interval, inInclusiveRange(0, SRSService.maxIntervalDays));
        }
        expect(() => SRSService.getNextIntervalPreviews(c, now: now), returnsNormally);
      }
      // Durumu 'new' olan kart her zaman öğrenme adımlarından başlar.
      expect(rate(weird.first, ReviewRating.good).learningStep, 1);
    });
  });

  group('previews', () {
    test('new card previews', () {
      final p = SRSService.getNextIntervalPreviews(card(), now: now);
      expect(p[ReviewRating.again], '1dk');
      expect(p[ReviewRating.hard], '5dk');
      expect(p[ReviewRating.good], '10dk');
      expect(p[ReviewRating.easy], matches(RegExp(r'^[345]g$')));
    });

    test('review previews match the real intervals', () {
      final c = review(10);
      final p = SRSService.getNextIntervalPreviews(c, now: now);
      expect(p[ReviewRating.again], '10dk');
      for (final r in [ReviewRating.hard, ReviewRating.good, ReviewRating.easy]) {
        expect(p[r], '${rate(c, r).interval}g');
      }
    });
  });

  group('isCardDue', () {
    test('respects minute-based scheduled time', () {
      final c = card(status: 'learning');
      expect(SRSService.isCardDue(c.copyWith(nextReviewDate: SRSService.formatReviewDate(now.subtract(const Duration(minutes: 10)))), now: now), isTrue);
      expect(SRSService.isCardDue(c.copyWith(nextReviewDate: SRSService.formatReviewDate(now.add(const Duration(minutes: 10)))), now: now), isFalse);
    });

    test('parses Supabase timestamptz with +00 offset', () {
      final c = card(status: 'learning', nextReviewDate: '2026-08-09 23:29:10.805991+00');
      expect(SRSService.isCardDue(c, now: now), isTrue);
    });
  });
}
