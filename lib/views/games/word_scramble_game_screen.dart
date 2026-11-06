import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/flashcard_model.dart';
import '../../providers/games/word_scramble_provider.dart';
import 'widgets/game_progress_badge.dart';
import 'widgets/scramble_clue_card.dart';
import 'widgets/scramble_control_buttons.dart';
import 'widgets/scramble_hud_row.dart';
import 'widgets/scramble_letter_pool.dart';
import 'widgets/scramble_placement_slots.dart';
import 'widgets/scramble_success_banner.dart';
import 'widgets/scramble_summary_view.dart';

class WordScrambleGameScreen extends ConsumerWidget {
  final List<FlashcardModel> cards;

  const WordScrambleGameScreen({super.key, required this.cards});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = wordScrambleProvider(cards);
    final s = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    if (s.cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Harf Sihirbazı')),
        body: const Center(child: Text('Çalışılacak uygun kelime bulunamadı.')),
      );
    }

    if (s.isFinished) {
      return ScrambleSummaryView(
        totalQuestions: s.cards.length,
        correctCount: s.correctCount,
        score: s.score,
        onRestart: notifier.restart,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Harf Sihirbazı'),
        centerTitle: true,
        actions: [GameProgressBadge(current: s.currentIndex + 1, total: s.cards.length)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: [
              ScrambleHudRow(score: s.score, wordLength: s.targetWord.length),
              const SizedBox(height: 16),
              ScrambleClueCard(card: s.currentCard),
              const SizedBox(height: 28),
              ScramblePlacementSlots(
                targetLength: s.targetWord.length,
                placedLetters: s.placedLetters,
                isCompleted: s.isCompleted,
                hasError: s.hasError,
                onSlotTapped: notifier.removeAt,
              ),
              const SizedBox(height: 28),
              if (!s.isCompleted) ...[
                ScrambleLetterPool(
                  pool: s.pool,
                  isCompleted: s.isCompleted,
                  onTileTapped: notifier.placeTile,
                ),
                const SizedBox(height: 24),
                ScrambleControlButtons(
                  isCompleted: s.isCompleted,
                  hasPlacedLetters: s.placedIds.isNotEmpty,
                  onClear: notifier.clearSlots,
                  onHint: notifier.hint,
                  onShuffle: notifier.shufflePool,
                ),
              ] else ...[
                const SizedBox(height: 16),
                ScrambleSuccessBanner(card: s.currentCard, hasNext: s.hasNext, onNext: notifier.next),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
