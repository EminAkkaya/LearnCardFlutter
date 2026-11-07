import 'package:flutter/material.dart';
import '../../../models/flashcard_model.dart';
import 'game_stat_tile.dart';
import 'game_summary_scaffold.dart';

class ClozeSummaryView extends StatelessWidget {
  final int totalQuestions;
  final int correctCount;
  final int score;
  final VoidCallback onRestart;
  final List<FlashcardModel> missedCards;

  const ClozeSummaryView({
    super.key,
    required this.totalQuestions,
    required this.correctCount,
    required this.score,
    required this.onRestart,
    this.missedCards = const [],
  });

  @override
  Widget build(BuildContext context) {
    final double accuracy = totalQuestions > 0
        ? (correctCount / totalQuestions) * 100
        : 0;

    return GameSummaryScaffold(
      appBarTitle: 'Alıştırma Tamamlandı',
      headline: 'Bağlamsal Pratik Tamamlandı!',
      message: 'Toplam $totalQuestions cümleden $correctCount tanesini başarıyla tamamladınız.',
      stats: [
        GameStatTile(label: 'Toplam Puan', value: '$score'),
        GameStatTile(label: 'Başarı Oranı', value: '%${accuracy.toStringAsFixed(0)}'),
      ],
      missedCards: missedCards,
      restartLabel: 'Yeni Cümlelerle Tekrar Et',
      onRestart: onRestart,
    );
  }
}
