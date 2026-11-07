import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/feedback_colors.dart';
import 'game_score_label.dart';

class ClozeHudBar extends StatelessWidget {
  final int score;
  final bool showHint;
  final String hintText;
  final VoidCallback onToggleHint;

  const ClozeHudBar({
    super.key,
    required this.score,
    required this.showHint,
    required this.hintText,
    required this.onToggleHint,
  });

  @override
  Widget build(BuildContext context) {
    final fb = FeedbackColors.of(context);
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          children: [
            GameScoreLabel(score: score),
            TextButton.icon(
              onPressed: onToggleHint,
              icon: Icon(showHint ? LucideIcons.eyeOff : LucideIcons.lightbulb, size: 18),
              label: Text(
                showHint ? 'İpucunu Gizle' : 'İpucu Gör',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        if (showHint) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: fb.warningContainer,
              borderRadius: BorderRadius.circular(AppPalette.radiusControl),
              border: Border.all(color: fb.warning.withValues(alpha: 0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(LucideIcons.lightbulb, size: 16, color: fb.warning),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Türkçe Anlamı: $hintText',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: fb.warning),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
