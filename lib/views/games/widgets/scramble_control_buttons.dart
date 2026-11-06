import 'package:flutter/material.dart';
import '../../../core/theme/feedback_colors.dart';

class ScrambleControlButtons extends StatelessWidget {
  final bool isCompleted;
  final bool hasPlacedLetters;
  final VoidCallback onClear;
  final VoidCallback onHint;
  final VoidCallback onShuffle;
  final VoidCallback onSkip;

  const ScrambleControlButtons({
    super.key,
    required this.isCompleted,
    required this.hasPlacedLetters,
    required this.onClear,
    required this.onHint,
    required this.onShuffle,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final fb = FeedbackColors.of(context);
    if (isCompleted) return const SizedBox.shrink();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: hasPlacedLetters ? onClear : null,
          icon: const Icon(Icons.backspace_outlined, size: 18),
          label: const Text('Temizle'),
        ),
        OutlinedButton.icon(
          onPressed: onShuffle,
          icon: const Icon(Icons.shuffle_rounded, size: 18),
          label: const Text('Karıştır'),
        ),
        OutlinedButton.icon(
          onPressed: onHint,
          icon: Icon(Icons.lightbulb_outline_rounded, size: 18, color: fb.warning),
          label: const Text('İpucu'),
        ),
        TextButton.icon(
          onPressed: onSkip,
          icon: const Icon(Icons.skip_next_rounded, size: 18),
          label: const Text('Geç'),
        ),
      ],
    );
  }
}
