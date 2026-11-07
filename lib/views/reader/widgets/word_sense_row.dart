import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../models/offline_entry.dart';

/// Sözlükteki tek anlam: tür etiketi, kısa İngilizce açıklama ve seçilebilir karşılıklar.
class WordSenseRow extends StatelessWidget {
  final OfflineSense sense;
  final String selected;
  final ValueChanged<String> onPick;

  const WordSenseRow({super.key, required this.sense, required this.selected, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: sense.posLabel,
                style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
              ),
              if (sense.sense.isNotEmpty) TextSpan(text: '  ${sense.sense}', style: TextStyle(color: palette.textMuted)),
            ]),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final tr in sense.translations) WordPickChip(label: tr, selected: selected == tr, onPick: onPick),
            ],
          ),
        ],
      ),
    );
  }
}

/// Seçilebilir karşılık: pill ChoiceChip; seçili olanda onay işareti + vurgu zemini.
class WordPickChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<String> onPick;

  const WordPickChip({super.key, required this.label, required this.selected, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final scheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      visualDensity: VisualDensity.compact,
      shape: const StadiumBorder(),
      side: BorderSide(color: selected ? scheme.primary : palette.border),
      backgroundColor: palette.subtle,
      selectedColor: scheme.primaryContainer,
      checkmarkColor: scheme.onPrimaryContainer,
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        color: selected ? scheme.onPrimaryContainer : palette.textPrimary,
      ),
      onSelected: (_) => onPick(label),
    );
  }
}
