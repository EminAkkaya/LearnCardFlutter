import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
    if (isCompleted) return const SizedBox.shrink();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: hasPlacedLetters ? onClear : null,
          icon: const Icon(LucideIcons.delete, size: 18),
          label: const Text('Temizle'),
        ),
        OutlinedButton.icon(
          onPressed: onShuffle,
          icon: const Icon(LucideIcons.shuffle, size: 18),
          label: const Text('Karıştır'),
        ),
        OutlinedButton.icon(
          onPressed: onHint,
          icon: const Icon(LucideIcons.lightbulb, size: 18),
          label: const Text('İpucu'),
        ),
        TextButton.icon(
          onPressed: onSkip,
          icon: const Icon(LucideIcons.skipForward, size: 18),
          label: const Text('Geç'),
        ),
      ],
    );
  }
}
