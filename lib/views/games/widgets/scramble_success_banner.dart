import 'package:flutter/material.dart';
import '../../../core/utils/audio_helper.dart';
import '../../../models/flashcard_model.dart';

class ScrambleSuccessBanner extends StatelessWidget {
  final FlashcardModel card;
  final bool hasNext;
  final VoidCallback onNext;

  static const Color emerald = Color(0xFF10B981);
  static const Color indigoColor = Color(0xFF6366F1);

  const ScrambleSuccessBanner({
    super.key,
    required this.card,
    required this.hasNext,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: emerald.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: emerald.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded, color: emerald, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Harika! Doğru Yazdınız: ${card.word}',
                    style: const TextStyle(
                      color: emerald,
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
              backgroundColor: indigoColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}
