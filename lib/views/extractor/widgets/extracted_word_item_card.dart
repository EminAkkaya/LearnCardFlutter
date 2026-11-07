import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/text_parser.dart';

class ExtractedWordItemCard extends StatelessWidget {
  final ExtractedWordItem item;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;

  const ExtractedWordItemCard({super.key, required this.item, required this.isSelected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: palette.cardDecoration(),
      child: Material(
        type: MaterialType.transparency,
        child: CheckboxListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppPalette.radiusCard)),
          value: isSelected,
          onChanged: onChanged,
          title: Row(
            children: [
              Text(
                item.word,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: palette.textPrimary),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: palette.subtle,
                  borderRadius: BorderRadius.circular(AppPalette.radiusPill),
                  border: Border.all(color: palette.border),
                ),
                child: Text(
                  '${item.count}x',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: palette.textSecondary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          subtitle: Text(
            item.sentence,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: palette.textSecondary),
          ),
        ),
      ),
    );
  }
}
