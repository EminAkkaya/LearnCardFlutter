import 'package:flutter/material.dart';
import '../../../core/theme/feedback_colors.dart';
import '../../../core/utils/audio_helper.dart';
import '../../../models/games/cloze_question_model.dart';

class ClozeSentenceCard extends StatelessWidget {
  final ClozeQuestionModel question;
  final bool isAnswered;
  final String? selectedOption;

  const ClozeSentenceCard({
    super.key,
    required this.question,
    required this.isAnswered,
    required this.selectedOption,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fb = FeedbackColors.of(context);
    final isCorrect =
        selectedOption?.toLowerCase() == question.correctWord.toLowerCase();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'CÜMLE BAĞLAMI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: fb.highlight,
                    ),
                  ),
                ),
                if (isAnswered && question.card.audioUrl.isNotEmpty)
                  IconButton.filledTonal(
                    onPressed: () =>
                        AudioHelper.playAudio(question.card.audioUrl),
                    icon: const Icon(Icons.volume_up_rounded, size: 20),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            RichText(
              text: TextSpan(
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 18,
                  height: 1.6,
                ),
                children: [
                  TextSpan(text: question.sentenceBefore),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isAnswered
                            ? (isCorrect
                                  ? fb.success.withValues(alpha: 0.25)
                                  : fb.danger.withValues(alpha: 0.25))
                            : fb.highlight.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isAnswered
                              ? (isCorrect ? fb.success : fb.danger)
                              : fb.highlight,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        isAnswered ? question.correctWord : ' _____ ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isAnswered
                              ? (isCorrect ? fb.success : fb.danger)
                              : fb.highlight,
                        ),
                      ),
                    ),
                  ),
                  TextSpan(text: question.sentenceAfter),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
