import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';

/// AppBar sağındaki "3/10" soru sayacı.
class GameProgressBadge extends StatelessWidget {
  final int current;
  final int total;

  const GameProgressBadge({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: p.subtle,
            borderRadius: BorderRadius.circular(AppPalette.radiusPill),
            border: Border.all(color: p.border),
          ),
          child: Text(
            '$current/$total',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: p.textSecondary,
              fontSize: 13,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}
