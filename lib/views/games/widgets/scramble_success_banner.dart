import 'package:flutter/material.dart';
import '../../../core/theme/feedback_colors.dart';
import '../../../core/utils/audio_helper.dart';
import '../../../models/flashcard_model.dart';

class ScrambleSuccessBanner extends StatelessWidget {
  final FlashcardModel card;
  final bool hasNext;
  final VoidCallback onNext;

  static const Color indigoColor = Color(0xFF6366F1);
  // indigo-600: beyaz buton metniyle 6.3:1 (indigo-500 yalnız 4.47:1).
  static const Color indigoFill = Color(0xFF4F46E5);

  const ScrambleSuccessBanner({
    super.key,
    required this.card,
    required this.hasNext,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final fb = FeedbackColors.of(context);
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: fb.success.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: fb.success.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, color: fb.success, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Harika! Doğru Yazdınız: ${card.word}',
                    style: TextStyle(
                      color: fb.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (card.phonetic.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  card.phonetic,
                  style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              ],
              if (card.audioUrl.isNotEmpty) ...[
                const SizedBox(height: 8),
                IconButton.filledTonal(
                  onPressed: () => AudioHelper.playAudio(card.audioUrl),
                  icon: const Icon(Icons.volume_up_rounded),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: onNext,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(
              hasNext ? 'Sonraki Kelime' : 'Sonuçları Gör',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: indigoFill,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}
