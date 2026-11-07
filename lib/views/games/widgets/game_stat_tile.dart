import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';

/// Oyun sonu özetindeki tek istatistik: küçük etiket + tabular değer.
class GameStatTile extends StatelessWidget {
  final String label;
  final String value;

  const GameStatTile({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: p.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: p.textPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
