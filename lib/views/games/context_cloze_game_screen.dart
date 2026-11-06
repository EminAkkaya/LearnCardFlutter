import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/flashcard_model.dart';
import '../../providers/games/context_cloze_provider.dart';
import 'widgets/cloze_hud_bar.dart';
import 'widgets/cloze_options_list.dart';
import 'widgets/cloze_sentence_card.dart';
import 'widgets/cloze_summary_view.dart';
import 'widgets/game_next_button.dart';
import 'widgets/game_progress_badge.dart';

class ContextClozeGameScreen extends ConsumerWidget {
  final List<FlashcardModel> cards;

  static const Color pinkAccent = Color(0xFFEC4899);

  const ContextClozeGameScreen({super.key, required this.cards});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = contextClozeProvider(cards);
    final s = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    if (s.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cümle Tamamlama')),
        body: const Center(child: Text('Çalışılacak soru oluşturulamadı.')),
      );
    }

    if (s.isFinished) {
      return ClozeSummaryView(
        totalQuestions: s.questions.length,
        correctCount: s.correctCount,
        score: s.score,
        onRestart: notifier.restart,
      );
    }

    final q = s.currentQuestion;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cümle İçi Boşluk Doldurma'),
        centerTitle: true,
        actions: [GameProgressBadge(current: s.currentIndex + 1, total: s.questions.length)],
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (s.currentIndex + 1) / s.questions.length,
              color: pinkAccent,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              minHeight: 4,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  children: [
                    ClozeHudBar(
                      score: s.score,
                      showHint: s.showHint,
                      hintText: q.card.trTranslation.isNotEmpty ? q.card.trTranslation : q.card.definition,
                      onToggleHint: notifier.toggleHint,
                    ),
                    const SizedBox(height: 20),
                    ClozeSentenceCard(
                      question: q,
                      isAnswered: s.isAnswered,
                      selectedOption: s.selectedOption,
                    ),
                    const SizedBox(height: 28),
                    ClozeOptionsList(
                      question: q,
                      selectedOption: s.selectedOption,
                      isAnswered: s.isAnswered,
                      onOptionSelected: notifier.selectOption,
                    ),
                    if (s.isAnswered) ...[
                      const SizedBox(height: 16),
                      GameNextButton(hasNext: s.hasNext, color: pinkAccent, onPressed: notifier.next),
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
