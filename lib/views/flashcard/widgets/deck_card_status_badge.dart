import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/feedback_colors.dart';
import '../../../models/flashcard_model.dart';

/// Kart durum rozeti: pill zemin + ikon + metin (renge tek başına güvenilmez).
class DeckCardStatusBadge extends StatelessWidget {
  final String status;

  const DeckCardStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final fb = FeedbackColors.of(context);
    final palette = AppPalette.of(context);
    final (Color color, IconData icon) = switch (status) {
      'new' => (fb.info, LucideIcons.sparkles),
      'learning' => (fb.warning, LucideIcons.repeat),
      'mastered' => (fb.success, LucideIcons.badgeCheck),
      _ => (palette.textSecondary, LucideIcons.circleDashed),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppPalette.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              cardStatusLabel(status),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
