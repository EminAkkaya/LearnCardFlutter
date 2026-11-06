import 'package:flutter/material.dart';
import '../../../core/utils/audio_helper.dart';
import '../../../models/games/speed_quiz_question_model.dart';

class SpeedQuizTargetCard extends StatelessWidget {
  final SpeedQuizQuestionModel question;
  final bool isAnswered;

  static const Color amberColor = Color(0xFFF59E0B);

  const SpeedQuizTargetCard({
    super.key,
    required this.question,
    required this.isAnswered,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'HEDEF KELİME',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: amberColor,
                  ),
                ),
                if (isAnswered && question.card.audioUrl.isNotEmpty)
                  IconButton.filledTonal(
                    onPressed: () => AudioHelper.playAudio(question.card.audioUrl),
                    icon: const Icon(Icons.volume_up_rounded, size: 20),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              question.targetWord,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            if (question.card.phonetic.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                question.card.phonetic,
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
