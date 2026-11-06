import 'package:flutter/material.dart';
import '../../../models/games/letter_tile_model.dart';

class ScramblePlacementSlots extends StatelessWidget {
  final int targetLength;
  final List<LetterTileModel> placedLetters;
  final bool isCompleted;
  final bool hasError;
  final ValueChanged<int> onSlotTapped;

  static const Color indigoColor = Color(0xFF6366F1);
  static const Color emerald = Color(0xFF10B981);

  const ScramblePlacementSlots({
    super.key,
    required this.targetLength,
    required this.placedLetters,
    required this.isCompleted,
    required this.hasError,
    required this.onSlotTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(targetLength, (index) {
        final bool hasLetter = index < placedLetters.length;
        final String char = hasLetter ? placedLetters[index].char : '';

        Color borderColor = theme.dividerColor.withValues(alpha: 0.5);
        Color bgColor = theme.colorScheme.surface;
        Color textColor = theme.colorScheme.onSurface;

        if (isCompleted) {
          borderColor = emerald;
          bgColor = emerald.withValues(alpha: 0.15);
          textColor = emerald;
        } else if (hasError && hasLetter) {
          borderColor = Colors.redAccent;
          bgColor = Colors.redAccent.withValues(alpha: 0.15);
          textColor = Colors.redAccent;
        } else if (hasLetter) {
          borderColor = indigoColor;
          bgColor = indigoColor.withValues(alpha: 0.1);
          textColor = indigoColor;
        }

        return InkWell(
          onTap: (hasLetter && !isCompleted) ? () => onSlotTapped(index) : null,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: hasLetter ? 2 : 1),
            ),
            alignment: Alignment.center,
            child: Text(
              char.toUpperCase(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        );
      }),
    );
  }
}
