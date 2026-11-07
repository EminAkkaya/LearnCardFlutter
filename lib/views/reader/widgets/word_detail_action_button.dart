import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/feedback_colors.dart';
import '../../../models/flashcard_model.dart';

class WordDetailActionButton extends StatelessWidget {
  final FlashcardModel? existingCard;
  final bool isAdding;
  final VoidCallback onAdd;

  const WordDetailActionButton({
    super.key,
    required this.existingCard,
    required this.isAdding,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (existingCard != null) {
      // Durum: renk + ikon + metin birlikte.
      final fb = FeedbackColors.of(context);
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fb.successContainer,
          borderRadius: BorderRadius.circular(AppPalette.radiusControl),
          border: Border.all(color: fb.success.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.circleCheck, size: 18, color: fb.success),
            const SizedBox(width: 8),
            Text(
              'Destede Var (${cardStatusLabel(existingCard!.status)})',
              style: TextStyle(fontWeight: FontWeight.w600, color: fb.success),
            ),
          ],
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: isAdding ? null : onAdd,
      icon: const Icon(LucideIcons.plus, size: 18),
      label: const Text('Desteye Kart Olarak Ekle'),
    );
  }
}
