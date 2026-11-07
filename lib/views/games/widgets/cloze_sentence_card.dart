import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
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
    final p = AppPalette.of(context);
    final fb = FeedbackColors.of(context);
    final isCorrect = selectedOption?.toLowerCase() == question.correctWord.toLowerCase();

    // Boşluk: cevaptan önce oyun vurgusu; sonra doğru/yanlış rengi + ikon.
    final Color blankColor = isAnswered ? (isCorrect ? fb.success : fb.danger) : fb.highlight;
    final Color blankBg = isAnswered
        ? (isCorrect ? fb.successContainer : fb.dangerContainer)
        : fb.highlight.withValues(alpha: 0.10);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: p.cardDecoration(),
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
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    color: p.textSecondary,
                  ),
                ),
              ),
              if (isAnswered && question.card.audioUrl.isNotEmpty)
                IconButton.outlined(
                  tooltip: 'Telaffuzu dinle',
                  onPressed: () => AudioHelper.playAudio(question.card.audioUrl),
                  icon: const Icon(LucideIcons.volume2, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            textScaler: MediaQuery.textScalerOf(context),
            text: TextSpan(
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                height: 1.6,
                color: p.textPrimary,
              ),
              children: [
                TextSpan(text: question.sentenceBefore),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: blankBg,
                      borderRadius: BorderRadius.circular(AppPalette.radiusControl),
                      border: Border.all(color: blankColor, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isAnswered) ...[
                          Icon(isCorrect ? LucideIcons.check : LucideIcons.x, size: 16, color: blankColor),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(
                            isAnswered ? question.correctWord : ' _____ ',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: blankColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                TextSpan(text: question.sentenceAfter),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
