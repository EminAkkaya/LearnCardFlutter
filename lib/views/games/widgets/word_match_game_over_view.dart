import 'package:flutter/material.dart';
import '../../../models/flashcard_model.dart';
import 'game_stat_tile.dart';
import 'game_summary_scaffold.dart';

class WordMatchGameOverView extends StatelessWidget {
  final int totalPairs;
  final int score;
  final int mistakes;
  final VoidCallback onPlayAgain;
  final List<FlashcardModel> missedCards;

  const WordMatchGameOverView({
    super.key,
    required this.totalPairs,
    required this.score,
    required this.mistakes,
    required this.onPlayAgain,
    this.missedCards = const [],
  });

  @override
  Widget build(BuildContext context) {
    final double accuracy = (totalPairs + mistakes > 0)
        ? (totalPairs / (totalPairs + mistakes)) * 100
        : 0;

    return GameSummaryScaffold(
      appBarTitle: 'Oyun Tamamlandı',
      headline: 'Tebrikler!',
      message: 'Tüm kelime çiftlerini başarıyla eşleştirdiniz.',
      stats: [
        GameStatTile(label: 'Toplam Puan', value: '$score'),
        GameStatTile(label: 'Hata Sayısı', value: '$mistakes'),
        GameStatTile(label: 'İsabet Oranı', value: '%${accuracy.toStringAsFixed(0)}'),
      ],
      missedCards: missedCards,
      onRestart: onPlayAgain,
    );
  }
}
