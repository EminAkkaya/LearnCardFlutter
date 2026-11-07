import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        if (article != null) ...[
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.folder,
                size: 12,
                color: themeColors.defaultText.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Text(
                article.folder,
                style: TextStyle(
                  color: themeColors.defaultText.withValues(alpha: 0.75),
                  fontSize: 12,
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
