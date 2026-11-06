import 'package:flutter/material.dart';
import '../../../core/theme/feedback_colors.dart';
import '../../../models/flashcard_model.dart';
import 'game_mistakes_card.dart';

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
    final theme = Theme.of(context);
    final fb = FeedbackColors.of(context);
    final double accuracy = totalQuestions > 0
        ? (correctCount / totalQuestions) * 100
        : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Test Tamamlandı')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: fb.warning.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.timer_rounded, size: 72, color: fb.warning),
              ),
              const SizedBox(height: 20),
              Text(
                'Hızlı Test Bitti!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Toplam $totalQuestions sorudan $correctCount tanesini doğru bildiniz.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
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
                              'En Yüksek Kombo',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'x$maxStreak',
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
                  onPressed: onRestart,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Tekrar Oyna'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: fb.warning,
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
