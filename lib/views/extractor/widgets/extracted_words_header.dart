import 'package:flutter/material.dart';

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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
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
