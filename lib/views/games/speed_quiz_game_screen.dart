import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/flashcard_model.dart';
import '../../providers/games/speed_quiz_provider.dart';
import 'widgets/game_next_button.dart';
import 'widgets/game_progress_badge.dart';
import 'widgets/speed_quiz_hud_bar.dart';
import 'widgets/speed_quiz_options_list.dart';
import 'widgets/speed_quiz_summary_view.dart';
import 'widgets/speed_quiz_target_card.dart';

class SpeedQuizGameScreen extends ConsumerWidget {
  final List<FlashcardModel> cards;

  static const Color amberColor = Color(0xFFF59E0B);

  const SpeedQuizGameScreen({super.key, required this.cards});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = speedQuizProvider(cards);
    final s = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    if (s.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hızlı Karar Testi')),
        body: const Center(child: Text('Test edilecek kart bulunamadı.')),
      );
    }

    if (s.isFinished) {
      return SpeedQuizSummaryView(
        totalQuestions: s.questions.length,
        correctCount: s.correctCount,
        score: s.score,
        maxStreak: s.maxStreak,
        onRestart: notifier.restart,
        missedCards: s.missedCards,
      );
    }

    final q = s.currentQuestion;
    final timeLow = s.secondsRemaining <= 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hızlı Karar Testi'),
        centerTitle: true,
        actions: [GameProgressBadge(current: s.currentIndex + 1, total: s.questions.length)],
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: s.secondsRemaining / speedQuizQuestionSeconds,
              color: timeLow ? Colors.redAccent : amberColor,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              minHeight: 5,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  children: [
                    SpeedQuizHudBar(
                      score: s.score,
                      streak: s.streak,
                      secondsRemaining: s.secondsRemaining,
                    ),
                    const SizedBox(height: 20),
                    SpeedQuizTargetCard(question: q, isAnswered: s.isAnswered),
                    const SizedBox(height: 24),
                    SpeedQuizOptionsList(
                      question: q,
                      selectedOption: s.selectedOption,
                      isAnswered: s.isAnswered,
                      onOptionSelected: notifier.selectOption,
                    ),
                    if (s.isAnswered) ...[
                      const SizedBox(height: 12),
                      GameNextButton(hasNext: s.hasNext, color: amberColor, onPressed: notifier.next),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
