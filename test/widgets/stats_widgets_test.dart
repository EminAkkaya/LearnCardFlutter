import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/models/daily_activity_model.dart';
import 'package:learncard_flutter/models/flashcard_model.dart';
import 'package:learncard_flutter/models/user_stats_model.dart';
import 'package:learncard_flutter/providers/flashcard_provider.dart';
import 'package:learncard_flutter/providers/stats_provider.dart';
import 'package:learncard_flutter/views/stats/stats_overview_screen.dart';

void main() {
  group('StatsOverviewScreen Widget Tests', () {
    testWidgets('1. StatsOverviewScreen displays streak, today activity, distribution and minigames', (WidgetTester tester) async {
      final now = DateTime.now();
      final todayStr = now.toIso8601String().split('T')[0];

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
          word: 'learning_1',
          status: 'learning',
          nextReviewDate: now.subtract(const Duration(hours: 1)).toIso8601String(), // due
          createdAt: now.toIso8601String(),
        ),
        FlashcardModel(
          id: '3',
          word: 'new_1',
          status: 'new',
          nextReviewDate: now.toIso8601String(),
          createdAt: now.toIso8601String(),
        ),
      ];

      final fakeState = FlashcardState(cards: fakeCards);
      final fakeStats = UserStatsModel(
        currentStreak: 5,
        longestStreak: 12,
        lastActiveDate: todayStr,
        dailyGoal: 20,
        totalGameScore: 1250,
        totalGamesPlayed: 8,
        dailyActivities: {
          todayStr: DailyActivityModel(
            date: todayStr,
            cardsReviewed: 15,
            cardsAdded: 3,
            gameScore: 350,
            gamesPlayed: 2,
          ),
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            flashcardProvider.overrideWith((ref) => FlashcardNotifier(fakeState, false)),
            statsProvider.overrideWith((ref) => _FakeStatsNotifier(fakeStats)),
          ],
          child: const MaterialApp(
            home: StatsOverviewScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Streak & Header
      expect(find.text('5 Günlük Seri!'), findsOneWidget);
      expect(find.text('En uzun seri: 12 gün'), findsOneWidget);
      expect(find.text('Bugünkü Hedef: 15 / 20 Kelime'), findsOneWidget);

      // Today Activity
      expect(find.text('Bugünkü Aktiviteleriniz'), findsOneWidget);
      expect(find.text('Bugün Çalışılan'), findsOneWidget);
      expect(find.text('Yeni Eklenen'), findsOneWidget);
      expect(find.text('Oyun Puanı'), findsOneWidget);
      expect(find.text('Oyun Seansı'), findsOneWidget);

      // Weekly Trend & Deck Distribution
      expect(find.text('Son 7 Günlük İlerleme'), findsOneWidget);
      expect(find.text('Deste Durum Dağılımı'), findsOneWidget);
      expect(find.text('Toplam 3 Kelime'), findsOneWidget);
      expect(find.text('Öğrenildi'), findsOneWidget);
      expect(find.text('Öğrenilmekte'), findsOneWidget);

      // Minigames stats
      expect(find.text('Oyun Başarıları & Skor'), findsOneWidget);
      expect(find.text('1250'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
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

  group('UserStatsModel & DailyActivityModel Unit Tests', () {
    test('DailyActivityModel serialization and copyWith', () {
      const model = DailyActivityModel(
        date: '2026-08-19',
        cardsReviewed: 10,
        cardsAdded: 4,
        gameScore: 300,
        gamesPlayed: 2,
      );

      final map = model.toMap();
      final restored = DailyActivityModel.fromMap(map);

      expect(restored.date, equals('2026-08-19'));
      expect(restored.cardsReviewed, equals(10));
      expect(restored.cardsAdded, equals(4));
      expect(restored.gameScore, equals(300));
      expect(restored.gamesPlayed, equals(2));

      final updated = model.copyWith(cardsReviewed: 15);
      expect(updated.cardsReviewed, equals(15));
      expect(updated.cardsAdded, equals(4));
    });

    test('UserStatsModel calculations and last 7 days list', () {
      final now = DateTime.now();
      final todayStr = now.toIso8601String().split('T')[0];

      final stats = UserStatsModel(
        currentStreak: 3,
        longestStreak: 7,
        dailyGoal: 20,
        dailyActivities: {
          todayStr: DailyActivityModel(
            date: todayStr,
            cardsReviewed: 10,
          ),
        },
      );

      expect(stats.todayActivity.cardsReviewed, equals(10));
      expect(stats.todayGoalProgress, equals(0.5));
      expect(stats.last7DaysActivities.length, equals(7));
      expect(stats.last7DaysActivities.last.date, equals(todayStr));
    });
  });
}

class _FakeStatsNotifier extends StatsNotifier {
  _FakeStatsNotifier(UserStatsModel initial) : super() {
    state = initial;
  }
}
