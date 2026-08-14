import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/models/flashcard_model.dart';
import 'package:learncard_flutter/providers/flashcard_provider.dart';
import 'package:learncard_flutter/views/stats/stats_overview_screen.dart';

void main() {
  group('StatsOverviewScreen Widget Tests', () {
    testWidgets('1. StatsOverviewScreen displays calculated mastery percentage and metric counts', (WidgetTester tester) async {
      final now = DateTime.now();

      final fakeCards = [
        FlashcardModel(
          id: '1',
          word: 'mastered_1',
          status: 'mastered',
          nextReviewDate: now.add(const Duration(days: 30)).toIso8601String(),
          createdAt: now.toIso8601String(),
        ),
        FlashcardModel(
          id: '2',
          word: 'mastered_2',
          status: 'mastered',
          nextReviewDate: now.add(const Duration(days: 30)).toIso8601String(),
          createdAt: now.toIso8601String(),
        ),
        FlashcardModel(
          id: '3',
          word: 'learning_1',
          status: 'learning',
          nextReviewDate: now.subtract(const Duration(hours: 1)).toIso8601String(), // due
          createdAt: now.toIso8601String(),
        ),
        FlashcardModel(
          id: '4',
          word: 'new_1',
          status: 'new',
          nextReviewDate: now.toIso8601String(),
          createdAt: now.toIso8601String(),
        ),
      ];

      final fakeState = FlashcardState(cards: fakeCards);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            flashcardProvider.overrideWith((ref) => FlashcardNotifier(fakeState, false)),
          ],
          child: const MaterialApp(
            home: StatsOverviewScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Total = 4, Mastered = 2 -> 50% Mastery
      expect(find.text('%50 Ustalaşıldı'), findsOneWidget);
      expect(find.text('2 / 4 Kelime'), findsOneWidget);

      // Verify Metric Cards
      expect(find.text('Bugün Tekrar'), findsOneWidget);
      expect(find.text('Öğrenilen'), findsOneWidget);
      expect(find.text('Öğrenildi'), findsOneWidget);
      expect(find.text('Yeni Kartlar'), findsOneWidget);
    });

    testWidgets('2. StatsOverviewScreen triggers tab navigation callback when action tapped', (WidgetTester tester) async {
      int? navigatedTab;

      final fakeState = FlashcardState(cards: []);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            flashcardProvider.overrideWith((ref) => FlashcardNotifier(fakeState, false)),
          ],
          child: MaterialApp(
            home: StatsOverviewScreen(
              onNavigateToTab: (index) {
                navigatedTab = index;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final target = find.text('İnteraktif Okuyucuya Git');
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();

      await tester.tap(target);
      await tester.pumpAndSettle();

      expect(navigatedTab, equals(1));
    });
  });
}
