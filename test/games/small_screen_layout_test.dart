import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/core/theme/feedback_colors.dart';
import 'package:learncard_flutter/models/flashcard_model.dart';
import 'package:learncard_flutter/services/srs_service.dart';
import 'package:learncard_flutter/views/flashcard/widgets/flashcard_item_view.dart';
import 'package:learncard_flutter/views/flashcard/widgets/review_completion_view.dart';
import 'package:learncard_flutter/views/games/context_cloze_game_screen.dart';
import 'package:learncard_flutter/views/games/mini_games_hub_screen.dart';
import 'package:learncard_flutter/views/games/speed_quiz_game_screen.dart';
import 'package:learncard_flutter/views/games/widgets/cloze_summary_view.dart';
import 'package:learncard_flutter/views/games/widgets/scramble_summary_view.dart';
import 'package:learncard_flutter/views/games/widgets/speed_quiz_summary_view.dart';
import 'package:learncard_flutter/views/games/widgets/word_match_game_over_view.dart';
import 'package:learncard_flutter/views/games/word_match_game_screen.dart';
import 'package:learncard_flutter/views/games/word_scramble_game_screen.dart';
import 'package:learncard_flutter/core/theme/app_palette.dart';

/// Küçük ekran (320x568) + büyük yazı (1.5x) altında oyun ve tekrar
/// ekranlarının taşma (RenderFlex overflow) üretmediğini doğrular.

FlashcardModel _card(String id, String word, String tr, String sentence) {
  return FlashcardModel(
    id: id,
    word: word,
    definition: 'A fairly long English definition used to stress the layout',
    trTranslation: tr,
    exampleSentence: sentence,
    phonetic: '/ˌɪn.kɒm.prɪˈhen.sə.bəl/',
    status: 'learning',
    interval: 1,
    repetitions: 1,
    easeFactor: 2.5,
    nextReviewDate: '2026-08-18',
    createdAt: '2026-08-18',
  );
}

final _cards = [
  _card('c1', 'incomprehensible', 'anlaşılmaz, akıl almaz',
      'The instructions were incomprehensible to everyone.'),
  _card('c2', 'serendipity', 'tatlı tesadüf, beklenmedik şans',
      'Finding the book was pure serendipity.'),
  _card('c3', 'ephemeral', 'geçici, kısa ömürlü',
      'Fame is often ephemeral in the age of social media.'),
  _card('c4', 'ubiquitous', 'her yerde bulunan',
      'Phones are ubiquitous today.'),
  _card('c5', 'resilient', 'dayanıklı, esnek',
      'She has a resilient personality.'),
];

ThemeData _theme(Brightness b) => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1),
        brightness: b,
      ),
      extensions: [
        b == Brightness.dark ? FeedbackColors.dark : FeedbackColors.light,
      ],
    );

Future<void> _pumpSmall(WidgetTester tester, Widget home, Brightness b) async {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: _theme(b),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.5),
          ),
          child: child!,
        ),
        home: home,
      ),
    ),
  );
  await _frames(tester);
}

/// Zamanlayıcılı oyunlarda pumpAndSettle bitmeyeceği için sabit kare pompalar.
Future<void> _frames(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

/// Taşma varsa hatanın tamamını (hangi widget, kaç piksel) gerekçe olarak basar.
void _expectNoOverflow(WidgetTester tester, [String? where]) {
  final e = tester.takeException();
  expect(e, isNull, reason: '${where ?? ''} $e');
}

Future<void> _tapFirstOption(WidgetTester tester) async {
  final option = find.byType(ElevatedButton).first;
  await tester.ensureVisible(option);
  await tester.pump();
  await tester.tap(option);
  await _frames(tester);
}

void main() {
  for (final b in Brightness.values) {
    final mode = b.name;

    group('320x568 @1.5x ($mode)', () {
      testWidgets('hub ekranı taşmaz', (tester) async {
        await _pumpSmall(tester, const MiniGamesHubScreen(), b);
        _expectNoOverflow(tester);
      });

      testWidgets('kelime eşleştirme taşmaz', (tester) async {
        await _pumpSmall(tester, WordMatchGameScreen(cards: _cards), b);
        _expectNoOverflow(tester);
      });

      testWidgets('harf sihirbazı taşmaz, kutular >= 48x48', (tester) async {
        await _pumpSmall(tester, WordScrambleGameScreen(cards: _cards), b);
        _expectNoOverflow(tester);

        // Harf havuzu ve yerleşim kutuları dokunma hedefi olarak >= 48x48.
        final slots = find.bySemanticsLabel(RegExp(r'\. harf '));
        final tiles = find.bySemanticsLabel(RegExp(r'^Harf '));
        expect(slots, findsWidgets);
        expect(tiles, findsWidgets);
        for (final f in [slots.first, tiles.first]) {
          final size = tester.getSize(f);
          expect(size.width, greaterThanOrEqualTo(48));
          expect(size.height, greaterThanOrEqualTo(48));
        }

        await tester.tap(find.text('İpucu'));
        await _frames(tester);
        _expectNoOverflow(tester);
      });

      testWidgets('hızlı karar testi soru + cevap durumu taşmaz',
          (tester) async {
        await _pumpSmall(tester, SpeedQuizGameScreen(cards: _cards), b);
        _expectNoOverflow(tester);
        await _tapFirstOption(tester);
        _expectNoOverflow(tester);
        // Zamanlayıcıyı kapatmak için ağacı sök.
        await tester.pumpWidget(const SizedBox());
      });

      testWidgets('boşluk doldurma soru + cevap durumu taşmaz',
          (tester) async {
        await _pumpSmall(tester, ContextClozeGameScreen(cards: _cards), b);
        _expectNoOverflow(tester);
        await tester.tap(find.text('İpucu Gör'));
        await _frames(tester);
        await _tapFirstOption(tester);
        _expectNoOverflow(tester);
      });

      testWidgets('oyun sonu ekranları taşmaz', (tester) async {
        final summaries = <Widget>[
          WordMatchGameOverView(
            totalPairs: 5,
            score: 1250,
            mistakes: 3,
            onPlayAgain: () {},
            missedCards: _cards,
          ),
          ScrambleSummaryView(
            totalQuestions: 5,
            correctCount: 3,
            score: 980,
            onRestart: () {},
            missedCards: _cards,
          ),
          SpeedQuizSummaryView(
            totalQuestions: 5,
            correctCount: 4,
            score: 1500,
            maxStreak: 4,
            onRestart: () {},
            missedCards: _cards,
          ),
          ClozeSummaryView(
            totalQuestions: 5,
            correctCount: 2,
            score: 600,
            onRestart: () {},
            missedCards: _cards,
          ),
        ];
        for (final s in summaries) {
          await _pumpSmall(tester, s, b);
          _expectNoOverflow(tester, '${s.runtimeType}');
        }
      });

      testWidgets('kart tekrarı ön/arka yüz ve tamamlama taşmaz',
          (tester) async {
        final card = _cards.first;
        await _pumpSmall(
          tester,
          Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FlashcardItemView(
                card: card,
                previews: SRSService.getNextIntervalPreviews(card),
                onRating: (_) {},
              ),
            ),
          ),
          b,
        );
        _expectNoOverflow(tester);

        await tester.tap(find.byType(FlashcardItemView));
        await tester.pumpAndSettle();
        _expectNoOverflow(tester);
        expect(find.text('Kolay'), findsOneWidget);

        for (final custom in [false, true]) {
          await _pumpSmall(
            tester,
            ReviewCompletionView(isCustomStudy: custom, onRestart: () {}),
            b,
          );
          _expectNoOverflow(tester);
        }
      });
    });
  }

  test('FeedbackColors tonları kart yüzeyinde metin olarak AA (>= 4.5:1)', () {
    double contrast(Color a, Color b) {
      final la = a.computeLuminance(), lb = b.computeLuminance();
      return ((la > lb ? la : lb) + 0.05) / ((la > lb ? lb : la) + 0.05);
    }

    for (final (fb, surface) in [
      (FeedbackColors.light, AppPalette.light.card),
      (FeedbackColors.light, AppPalette.light.bg),
      (FeedbackColors.dark, AppPalette.dark.card),
      (FeedbackColors.dark, AppPalette.dark.bg),
    ]) {
      for (final c in [fb.success, fb.danger, fb.warning, fb.info, fb.highlight]) {
        expect(contrast(c, surface), greaterThanOrEqualTo(4.5), reason: '$c / $surface');
      }
    }
  });

  testWidgets('FeedbackColors.of eklentisiz MaterialApp içinde çalışır',
      (tester) async {
    late FeedbackColors light, dark;
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(brightness: Brightness.light),
      home: Builder(builder: (c) {
        light = FeedbackColors.of(c);
        return const SizedBox();
      }),
    ));
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(brightness: Brightness.dark),
      home: Builder(builder: (c) {
        dark = FeedbackColors.of(c);
        return const SizedBox();
      }),
    ));
    await tester.pumpAndSettle(); // tema geçiş animasyonu bitsin
    expect(light.success, FeedbackColors.light.success);
    expect(dark.success, FeedbackColors.dark.success);
  });
}
