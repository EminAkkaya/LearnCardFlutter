import 'package:flutter/material.dart';
import '../../../models/reader_theme.dart';
import 'reader_legend_item.dart';
import 'reader_word_style.dart';

class ReaderLegendBar extends StatelessWidget {
  final ReaderThemeColors colors;

  const ReaderLegendBar({super.key, required this.colors});

  @override
  Widget build(BuildContext context) {
    final labelColor = colors.defaultText.withValues(alpha: 0.8);
    Widget item(String? status, String label) => ReaderLegendItem(
          look: ReaderWordStyle.forStatus(status, colors),
          label: label,
          labelColor: labelColor,
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(color: colors.defaultText.withValues(alpha: 0.1)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            item('new', 'Öğrenilmemiş'),
            const SizedBox(width: 16),
            item('learning', 'Öğrenilmekte'),
            const SizedBox(width: 16),
            item('mastered', 'Öğrenildi'),
            const SizedBox(width: 16),
            item(null, 'Destede Yok'),
          ],
        ),
      ),
    );
  }
}
