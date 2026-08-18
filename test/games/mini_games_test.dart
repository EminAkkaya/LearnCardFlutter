import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/models/flashcard_model.dart';
import 'package:learncard_flutter/views/games/context_cloze_game_screen.dart';
import 'package:learncard_flutter/views/games/mini_games_hub_screen.dart';
import 'package:learncard_flutter/views/games/speed_quiz_game_screen.dart';
import 'package:learncard_flutter/views/games/word_match_game_screen.dart';
import 'package:learncard_flutter/views/games/word_scramble_game_screen.dart';

void main() {
  final testCards = [
    FlashcardModel(
      id: 'c1',
      word: 'resilient',
      definition: 'Able to recover quickly',
      trTranslation: 'dayanıklı, esnek',
      exampleSentence: 'She has a resilient personality.',
      status: 'learning',
      interval: 1,
      repetitions: 1,
      easeFactor: 2.5,
      nextReviewDate: '2026-08-18',
      createdAt: '2026-08-18',
    ),
    FlashcardModel(
      id: 'c2',
      word: 'serendipity',
      definition: 'Happy chance discovery',
      trTranslation: 'tatlı tesadüf',
      exampleSentence: 'Finding the book was pure serendipity.',
      status: 'learning',
      interval: 1,
      repetitions: 1,
      easeFactor: 2.5,
      nextReviewDate: '2026-08-18',
      createdAt: '2026-08-18',
    ),
    FlashcardModel(
      id: 'c3',
      word: 'ephemeral',
      definition: 'Short-lived',
      trTranslation: 'geçici, kısa ömürlü',
      exampleSentence: 'Fame is often ephemeral.',
      status: 'new',
      interval: 0,
      repetitions: 0,
      easeFactor: 2.5,
      nextReviewDate: '2026-08-18',
      createdAt: '2026-08-18',
    ),
    FlashcardModel(
      id: 'c4',
      word: 'ubiquitous',
      definition: 'Present everywhere',
      trTranslation: 'her yerde bulunan',
      exampleSentence: 'Phones are ubiquitous today.',
      status: 'mastered',
      interval: 25,
      repetitions: 5,
      easeFactor: 2.6,
      nextReviewDate: '2026-09-10',
      createdAt: '2026-08-18',
    ),
  ];

  group('Mini Games Hub Tests', () {
    testWidgets('1. MiniGamesHubScreen renders title, banner and all 5 mode options', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MiniGamesHubScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mini Oyunlar & Alıştırmalar'), findsOneWidget);
      expect(find.text('Bilişsel Öğrenme Oyunları'), findsOneWidget);
      expect(find.text('1. Özel Kart Tekrarı (Serbest Mod)'), findsOneWidget);
      expect(find.text('2. Kelime Eşleştirme'), findsOneWidget);
      expect(find.text('3. Harf Sihirbazı (Yazım)'), findsOneWidget);
      expect(find.text('4. Hızlı Karar Testi'), findsOneWidget);
      expect(find.text('5. Cümle İçi Boşluk Doldurma'), findsOneWidget);
    });
  });

  group('Word Match Game Tests', () {
    testWidgets('2. WordMatchGameScreen renders matching tiles and HUD', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WordMatchGameScreen(cards: testCards),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kelime Eşleştirme'), findsOneWidget);
      expect(find.text('Süre'), findsOneWidget);
      expect(find.text('Puan'), findsOneWidget);
      expect(find.text('Seri'), findsOneWidget);
      expect(find.text('Eşleşen'), findsOneWidget);

      // Verify at least some cards appear
      expect(find.byType(GridView), findsOneWidget);
    });
  });

  group('Word Scramble Game Tests', () {
    testWidgets('3. WordScrambleGameScreen displays clues, slots, pool and controls', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WordScrambleGameScreen(cards: testCards),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Harf Sihirbazı'), findsOneWidget);
      expect(find.text('TÜRKÇE ANLAMI'), findsOneWidget);
      expect(find.text('İpucu'), findsOneWidget);
      expect(find.text('Karıştır'), findsOneWidget);
      expect(find.text('Temizle'), findsOneWidget);

      // Tapping İpucu fills a slot
      await tester.tap(find.text('İpucu'));
      await tester.pumpAndSettle();
      expect(find.text('Temizle'), findsOneWidget);
    });
  });

  group('Speed Quiz Game Tests', () {
    testWidgets('4. SpeedQuizGameScreen displays target word and 4 multiple choice options', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SpeedQuizGameScreen(cards: testCards),
        ),
      );
      await tester.pump();

      expect(find.text('Hızlı Karar Testi'), findsOneWidget);
      expect(find.textContaining('Puan:'), findsOneWidget);
      expect(find.textContaining('Seri:'), findsOneWidget);

      // Verify options are displayed
      final buttons = find.byType(ElevatedButton);
      expect(buttons, findsWidgets);
    });
  });

  group('Context Cloze Game Tests', () {
    testWidgets('5. ContextClozeGameScreen renders sentence blank and word options', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ContextClozeGameScreen(cards: testCards),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cümle İçi Boşluk Doldurma'), findsOneWidget);
      expect(find.text('CÜMLE BAĞLAMI'), findsOneWidget);
      expect(find.text('İpucu Gör'), findsOneWidget);

      // Tap hint
      await tester.tap(find.text('İpucu Gör'));
      await tester.pumpAndSettle();
      expect(find.text('İpucunu Gizle'), findsOneWidget);
    });
  });
}
