import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';

class ExtractorFiltersRow extends StatelessWidget {
  final bool filterStopWords;
  final int minWordLength;
  final ValueChanged<bool> onFilterStopWordsChanged;
  final ValueChanged<int> onMinWordLengthChanged;

  const ExtractorFiltersRow({
    super.key,
    required this.filterStopWords,
    required this.minWordLength,
    required this.onFilterStopWordsChanged,
    required this.onMinWordLengthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: FilterChip(
                shape: const StadiumBorder(),
                selected: filterStopWords,
                label: const Text('Yaygın Kelimeleri Filtrele (the, a, is...)'),
                onSelected: onFilterStopWordsChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              'Min. Kelime Uzunluğu: $minWordLength harf',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppPalette.of(context).textSecondary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Expanded(
              child: Slider(
                value: minWordLength.toDouble(),
                min: 2,
                max: 6,
                divisions: 4,
                label: '$minWordLength',
                onChanged: (val) => onMinWordLengthChanged(val.toInt()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
