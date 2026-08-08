import 'package:flutter/material.dart';
import '../../../providers/reading_provider.dart';

class ReaderLegendBar extends StatelessWidget {
  final ReaderThemeColors colors;

  const ReaderLegendBar({super.key, required this.colors});

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colors.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildLegendItem(colors.newWordColor, 'Öğrenilmemiş'),
            const SizedBox(width: 14),
            _buildLegendItem(colors.learningWordColor, 'Öğrenilmekte'),
            const SizedBox(width: 14),
            _buildLegendItem(colors.masteredWordColor, 'Öğrenildi'),
            const SizedBox(width: 14),
            _buildLegendItem(colors.unaddedWordColor, 'Destede Yok'),
          ],
        ),
      ),
    );
  }
}
