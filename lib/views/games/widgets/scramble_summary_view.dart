import 'package:flutter/material.dart';
import '../../../core/theme/feedback_colors.dart';
import '../../../models/flashcard_model.dart';
import 'game_mistakes_card.dart';

class ScrambleSummaryView extends StatelessWidget {
  final int totalQuestions;
  final int correctCount;
  final int score;
  final VoidCallback onRestart;
  final List<FlashcardModel> missedCards;

  static const Color indigoColor = Color(0xFF6366F1);
  // indigo-600: beyaz buton metniyle 6.3:1 (indigo-500 yalnız 4.47:1).
  static const Color indigoFill = Color(0xFF4F46E5);

  const ScrambleSummaryView({
    super.key,
    required this.totalQuestions,
    required this.correctCount,
    required this.score,
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
      appBar: AppBar(title: const Text('Alıştırma Tamamlandı')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: indigoColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.spellcheck_rounded,
                  size: 72,
                  color: indigoColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Harika İş!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Toplam $totalQuestions kelimeden $correctCount tanesini başarıyla tamamladınız.',
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
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: fb.warning,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text(
                              'Başarı Oranı',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '%${accuracy.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 24,
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
                    backgroundColor: indigoFill,
                    foregroundColor: Colors.white,
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
