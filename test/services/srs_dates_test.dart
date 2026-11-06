import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/models/flashcard_model.dart';
import 'package:learncard_flutter/services/srs_service.dart';

FlashcardModel _card(String nextReviewDate) => FlashcardModel(
      id: 'c1',
      word: 'resilient',
      definition: 'Able to recover quickly',
      trTranslation: 'Dayanıklı',
      status: 'learning',
      interval: 1,
      repetitions: 1,
      nextReviewDate: nextReviewDate,
      createdAt: '2026-11-01T00:00:00.000Z',
    );

void main() {
  group('SRSService review dates', () {
    test('formatReviewDate stores UTC ISO-8601', () {
      final local = DateTime(2026, 11, 7, 12, 30);
      final stored = SRSService.formatReviewDate(local);
      expect(stored.endsWith('Z'), isTrue);
      expect(DateTime.parse(stored).isAtSameMomentAs(local), isTrue);
    });

    test('calculateSRS writes UTC values that round-trip to the same instant', () {
      final card = _card('2026-11-01');
      final updated = SRSService.calculateSRS(card, ReviewRating.good);
      expect(updated.nextReviewDate.endsWith('Z'), isTrue);
      expect(SRSService.parseReviewDate(updated.nextReviewDate), isNotNull);
    });

    test('parseReviewDate keeps offsets instead of dropping them', () {
      final parsed = SRSService.parseReviewDate('2026-11-07T10:00:00+03:00')!;
      expect(parsed.isAtSameMomentAs(DateTime.utc(2026, 11, 7, 7)), isTrue);

      final supabase = SRSService.parseReviewDate('2026-11-07 07:00:00.123456+00')!;
      expect(supabase.toUtc().hour, 7);
      expect(supabase.isUtc, isTrue);
    });

    test('parseReviewDate accepts legacy date-only as local midnight', () {
      final parsed = SRSService.parseReviewDate('2026-11-07')!;
      expect(parsed, DateTime(2026, 11, 7));
      expect(parsed.isUtc, isFalse);
    });

    test('parseReviewDate accepts legacy local datetime without offset', () {
      final parsed = SRSService.parseReviewDate('2026-11-07T10:15:00.000')!;
      expect(parsed, DateTime(2026, 11, 7, 10, 15));
      expect(parsed.isUtc, isFalse);
    });

    test('parseReviewDate returns null for empty or garbage', () {
      expect(SRSService.parseReviewDate(''), isNull);
      expect(SRSService.parseReviewDate('not a date'), isNull);
    });
  });

  group('SRSService.isCardDue across formats', () {
    final now = DateTime(2026, 11, 7, 12, 0);

    test('legacy date-only: due on that day and before, not after', () {
      expect(SRSService.isCardDue(_card('2026-11-07'), now: now), isTrue);
      expect(SRSService.isCardDue(_card('2026-11-06'), now: now), isTrue);
      expect(SRSService.isCardDue(_card('2026-11-08'), now: now), isFalse);
    });

    test('legacy local datetime compares as local time', () {
      expect(SRSService.isCardDue(_card('2026-11-07T11:59:00.000'), now: now), isTrue);
      expect(SRSService.isCardDue(_card('2026-11-07T12:01:00.000'), now: now), isFalse);
    });

    test('UTC values compare by instant', () {
      final past = SRSService.formatReviewDate(now.subtract(const Duration(minutes: 1)));
      final future = SRSService.formatReviewDate(now.add(const Duration(minutes: 1)));
      expect(SRSService.isCardDue(_card(past), now: now), isTrue);
      expect(SRSService.isCardDue(_card(future), now: now), isFalse);
    });

    test('offset values compare by instant', () {
      final utcNow = now.toUtc();
      final inOneHour = utcNow.add(const Duration(hours: 1));
      final plus3 = inOneHour.add(const Duration(hours: 3));
      String two(int v) => v.toString().padLeft(2, '0');
      final str = '${plus3.year}-${two(plus3.month)}-${two(plus3.day)}'
          'T${two(plus3.hour)}:${two(plus3.minute)}:00+03:00';
      expect(SRSService.isCardDue(_card(str), now: now), isFalse);
      expect(
        SRSService.isCardDue(_card(str), now: now.add(const Duration(hours: 2))),
        isTrue,
      );
    });

    test('new cards and empty/unparseable dates are due', () {
      expect(SRSService.isCardDue(_card('2099-01-01').copyWith(status: 'new'), now: now), isTrue);
      expect(SRSService.isCardDue(_card(''), now: now), isTrue);
      expect(SRSService.isCardDue(_card('garbage'), now: now), isTrue);
    });
  });
}
