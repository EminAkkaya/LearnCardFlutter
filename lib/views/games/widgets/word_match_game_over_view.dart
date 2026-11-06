import 'package:flutter/material.dart';
import '../../../core/theme/feedback_colors.dart';
import '../../../models/flashcard_model.dart';
import 'game_mistakes_card.dart';

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
    final theme = Theme.of(context);
    final fb = FeedbackColors.of(context);
    final double accuracy = (totalPairs + mistakes > 0)
        ? (totalPairs / (totalPairs + mistakes)) * 100
        : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Oyun Tamamlandı')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: fb.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  size: 72,
                  color: fb.success,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Tebrikler!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tüm kelime çiftlerini başarıyla eşleştirdiniz.',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.7,
                  ),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  // Wrap: dar ekran / büyük yazıda istatistikler alt satıra iner.
                  child: SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceAround,
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'Toplam Puan',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$score',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: fb.warning,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text(
                              'Hata Sayısı',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$mistakes',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: fb.danger,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text(
                              'İsabet Oranı',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '%${accuracy.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: fb.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (missedCards.isNotEmpty) ...[
                const SizedBox(height: 24),
                GameMistakesCard(cards: missedCards),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: onPlayAgain,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Tekrar Oyna'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: fb.success,
                    foregroundColor: fb.onAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Oyun Merkezine Dön'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
