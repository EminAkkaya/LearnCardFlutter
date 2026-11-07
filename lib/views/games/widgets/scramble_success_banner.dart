import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/feedback_colors.dart';
import '../../../core/utils/audio_helper.dart';
import '../../../models/flashcard_model.dart';

class ScrambleSuccessBanner extends StatelessWidget {
  final FlashcardModel card;
  final bool hasNext;
  final VoidCallback onNext;

  const ScrambleSuccessBanner({
    super.key,
    required this.card,
    required this.hasNext,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final fb = FeedbackColors.of(context);
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: fb.successContainer,
            borderRadius: BorderRadius.circular(AppPalette.radiusCard),
            border: Border.all(color: fb.success),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.circleCheck, color: fb.success, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Harika! Doğru Yazdınız: ${card.word}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: fb.success,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              if (card.phonetic.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  card.phonetic,
                  style: TextStyle(fontStyle: FontStyle.italic, color: p.textSecondary),
                ),
              ],
              if (card.audioUrl.isNotEmpty) ...[
                const SizedBox(height: 8),
                IconButton.outlined(
                  tooltip: 'Telaffuzu dinle',
                  onPressed: () => AudioHelper.playAudio(card.audioUrl),
                  icon: const Icon(LucideIcons.volume2, size: 20),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: onNext,
            icon: const Icon(LucideIcons.arrowRight, size: 18),
            label: Text(
              hasNext ? 'Sonraki Kelime' : 'Sonuçları Gör',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
