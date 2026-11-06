import 'package:flutter/material.dart';
import '../../../models/reader_theme.dart';
import '../../../providers/reading_provider.dart';

class ReaderAppBarTitle extends StatelessWidget {
  final ReadingState readingState;
  final ReaderThemeColors themeColors;

  const ReaderAppBarTitle({
    super.key,
    required this.readingState,
    required this.themeColors,
  });

  @override
  Widget build(BuildContext context) {
    final article = readingState.selectedArticle;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          article?.title ?? 'İnteraktif Okuma',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: themeColors.defaultText,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        if (article != null) ...[
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.folder_outlined,
                size: 12,
                color: themeColors.defaultText.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Text(
                article.folder,
                style: TextStyle(
                  color: themeColors.defaultText.withValues(alpha: 0.65),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
