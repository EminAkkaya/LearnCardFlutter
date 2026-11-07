import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/feedback_colors.dart';
import '../../../models/games/letter_tile_model.dart';
import 'game_status_line.dart';

class ScramblePlacementSlots extends StatelessWidget {
  final int targetLength;
  final List<LetterTileModel> placedLetters;
  final bool isCompleted;
  final bool hasError;
  final ValueChanged<int> onSlotTapped;

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
    final scheme = Theme.of(context).colorScheme;
    final p = AppPalette.of(context);
    final fb = FeedbackColors.of(context);
    final radius = BorderRadius.circular(AppPalette.radiusControl);

    final slots = Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(targetLength, (index) {
        final bool hasLetter = index < placedLetters.length;
        final String char = hasLetter ? placedLetters[index].char : '';

        Color borderColor = p.controlBorder;
        Color bgColor = p.subtle;
        Color textColor = p.textPrimary;

        if (isCompleted) {
          borderColor = fb.success;
          bgColor = fb.successContainer;
          textColor = fb.success;
        } else if (hasError && hasLetter) {
          borderColor = fb.danger;
          bgColor = fb.dangerContainer;
          textColor = fb.danger;
        } else if (hasLetter) {
          borderColor = scheme.primary;
          bgColor = scheme.primaryContainer;
        }

        return Semantics(
          button: hasLetter && !isCompleted,
          label: hasLetter
              ? '${index + 1}. harf ${char.toUpperCase()}, kaldırmak için dokun'
              : '${index + 1}. harf boş',
          excludeSemantics: true,
          child: Material(
            color: bgColor,
            shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(color: borderColor, width: hasLetter ? 1.5 : 1),
            ),
            child: InkWell(
              onTap: (hasLetter && !isCompleted) ? () => onSlotTapped(index) : null,
              borderRadius: radius,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: Text(
                    char.toUpperCase(),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textColor),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );

    if (!hasError || isCompleted) return slots;
    return Column(
      children: [
        slots,
        const SizedBox(height: 12),
        GameStatusLine(
          icon: LucideIcons.x,
          text: 'Sıralama hatalı, harfe dokunup kaldırabilirsin',
          color: fb.danger,
          fontSize: 13,
        ),
      ],
    );
  }
}
