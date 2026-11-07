import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/feedback_colors.dart';

class WordMatchHudBar extends StatelessWidget {
  final int matchedPairs;
  final int totalPairs;
  final int score;
  final int mistakes;
  final int streak;

  const WordMatchHudBar({
    super.key,
    required this.matchedPairs,
    required this.totalPairs,
    required this.score,
    required this.mistakes,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final fb = FeedbackColors.of(context);
    final onStreak = streak > 1;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: p.cardDecoration(),
      // Wrap: dar ekran / büyük yazıda istatistikler alt satıra iner.
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 12,
        runSpacing: 8,
        children: [
          _HudStat(label: 'Eşleşen', value: '$matchedPairs/$totalPairs'),
          _HudStat(label: 'Puan', value: '$score'),
          _HudStat(
            label: 'Seri',
            value: 'x$streak',
            icon: onStreak ? LucideIcons.flame : null,
            color: onStreak ? fb.warning : p.textMuted,
          ),
          const _HudStat(label: 'Süre', value: 'Serbest'),
        ],
      ),
    );
  }
}

class _HudStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;

  const _HudStat({required this.label, required this.value, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final c = color ?? p.textPrimary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: p.textSecondary)),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 14, color: c), const SizedBox(width: 2)],
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: c,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
