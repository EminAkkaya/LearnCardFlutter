import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/audio_helper.dart';
import '../../../models/games/speed_quiz_question_model.dart';

class SpeedQuizTargetCard extends StatelessWidget {
  final SpeedQuizQuestionModel question;
  final bool isAnswered;

  const SpeedQuizTargetCard({
    super.key,
    required this.question,
    required this.isAnswered,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = AppPalette.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: p.cardDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  question.isReverse ? 'İNGİLİZCESİ NEDİR?' : 'HEDEF KELİME',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    color: p.textSecondary,
                  ),
                ),
              ),
              if (isAnswered)
                IconButton.outlined(
                  tooltip: 'Telaffuzu dinle',
                  onPressed: () => AudioHelper.speak(question.card.word),
                  icon: const Icon(LucideIcons.volume2, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Ana kelime: ekrandaki tek gerçek vurgu.
          Text(
            question.targetWord,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: p.textPrimary,
            ),
          ),
          if (question.card.phonetic.isNotEmpty && (!question.isReverse || isAnswered)) ...[
            const SizedBox(height: 4),
            Text(
              question.card.phonetic,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: p.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
