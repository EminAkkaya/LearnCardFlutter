import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';

class ExtractedWordsHeader extends StatelessWidget {
  final int selectedCount;
  final int totalCount;
  final VoidCallback onToggleAll;

  const ExtractedWordsHeader({
    super.key,
    required this.selectedCount,
    required this.totalCount,
    required this.onToggleAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Çıkarılan Kelimeler ($selectedCount/$totalCount)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppPalette.of(context).textPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        TextButton(
          onPressed: onToggleAll,
          child: Text(selectedCount == totalCount ? 'Tümünü Kaldır' : 'Tümünü Seç'),
        ),
      ],
    );
  }
}
