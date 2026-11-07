import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/feedback_colors.dart';
import '../../../models/reading_article_model.dart';

class SavedArticleTile extends StatelessWidget {
  final ReadingArticleModel article;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SavedArticleTile({
    super.key,
    required this.article,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final danger = FeedbackColors.of(context).danger;
    final preview =
        article.text.length > 90 ? '${article.text.substring(0, 90)}...' : article.text;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: palette.cardDecoration(),
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppPalette.radiusCard),
          ),
          contentPadding: const EdgeInsets.only(left: 16, right: 4, top: 8, bottom: 8),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  article.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: palette.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _FolderBadge(folder: article.folder),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              preview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, height: 1.5, color: palette.textSecondary),
            ),
          ),
          trailing: PopupMenuButton<String>(
            icon: Icon(LucideIcons.ellipsisVertical, size: 18, color: palette.textSecondary),
            onSelected: (action) => action == 'edit' ? onEdit() : onDelete(),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(LucideIcons.pencil, size: 16),
                    SizedBox(width: 8),
                    Text('Düzenle / Klasör Değiştir'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(LucideIcons.trash2, size: 16, color: danger),
                    const SizedBox(width: 8),
                    Text('Sil', style: TextStyle(color: danger)),
                  ],
                ),
              ),
            ],
          ),
          onTap: onOpen,
        ),
      ),
    );
  }
}

class _FolderBadge extends StatelessWidget {
  final String folder;

  const _FolderBadge({required this.folder});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: palette.subtle,
        borderRadius: BorderRadius.circular(AppPalette.radiusPill),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.folder, size: 12, color: palette.textSecondary),
          const SizedBox(width: 4),
          Text(
            folder,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: palette.textSecondary),
          ),
        ],
      ),
    );
  }
}
