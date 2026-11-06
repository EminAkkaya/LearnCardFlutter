import 'package:flutter/material.dart';
import '../../../providers/reading_provider.dart';
import 'reader_legend_item.dart';

class ReaderLegendBar extends StatelessWidget {
  final ReaderThemeColors colors;

  const ReaderLegendBar({super.key, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colors.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ReaderLegendItem(color: colors.newWordColor, label: 'Öğrenilmemiş'),
            const SizedBox(width: 14),
            ReaderLegendItem(color: colors.learningWordColor, label: 'Öğrenilmekte'),
            const SizedBox(width: 14),
            ReaderLegendItem(color: colors.masteredWordColor, label: 'Öğrenildi'),
            const SizedBox(width: 14),
            ReaderLegendItem(color: colors.unaddedWordColor, label: 'Destede Yok'),
          ],
        ),
      ),
    );
  }
}
