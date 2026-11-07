import 'package:flutter/material.dart';
import '../../../models/flashcard_model.dart';
import 'game_stat_tile.dart';
import 'game_summary_scaffold.dart';

class SpeedQuizSummaryView extends StatelessWidget {
  final int totalQuestions;
  final int correctCount;
  final int score;
  final int maxStreak;
  final VoidCallback onRestart;
  final List<FlashcardModel> missedCards;

  const SpeedQuizSummaryView({
    super.key,
    required this.totalQuestions,
    required this.correctCount,
    required this.score,
    required this.maxStreak,
    required this.onRestart,
    this.missedCards = const [],
  });

  @override
  Widget build(BuildContext context) {
    final double accuracy = totalQuestions > 0
        ? (correctCount / totalQuestions) * 100
        : 0;

    return GameSummaryScaffold(
      appBarTitle: 'Test Tamamlandı',
      headline: 'Hızlı Test Bitti!',
      message: 'Toplam $totalQuestions sorudan $correctCount tanesini doğru bildiniz.',
      stats: [
        GameStatTile(label: 'Toplam Puan', value: '$score'),
        GameStatTile(label: 'En Yüksek Kombo', value: 'x$maxStreak'),
        GameStatTile(label: 'İsabet Oranı', value: '%${accuracy.toStringAsFixed(0)}'),
      ],
      missedCards: missedCards,
      onRestart: onRestart,
    );
  }
}
