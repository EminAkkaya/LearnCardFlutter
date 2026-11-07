import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../models/reading_article_model.dart';

/// "Tümü", klasör ve "Yeni Klasör" çiplerinden oluşan yatay filtre satırı.
class SavedArticlesFolderChips extends StatelessWidget {
  final List<ReadingArticleModel> articles;
  final List<String> folders;
  final String selectedFolder;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onDelete;
  final VoidCallback onCreate;

  const SavedArticlesFolderChips({
    super.key,
    required this.articles,
    required this.folders,
    required this.selectedFolder,
    required this.onSelect,
    required this.onDelete,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              shape: const StadiumBorder(),
              label: Text('Tümü (${articles.length})'),
              selected: selectedFolder == 'Tümü',
              onSelected: (sel) {
                if (sel) onSelect('Tümü');
              },
            ),
          ),
          ...folders.map((folder) {
            final count = articles.where((a) => a.folder == folder).length;
            final isSel = selectedFolder == folder;

            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: InputChip(
                showCheckmark: false,
                avatar: Icon(
                  isSel ? LucideIcons.folderOpen : LucideIcons.folder,
                  size: 16,
                  color: isSel ? scheme.onPrimaryContainer : palette.textSecondary,
                ),
                label: Text('$folder ($count)'),
                selected: isSel,
                shape: const StadiumBorder(),
                side: BorderSide(color: isSel ? scheme.primary : palette.border),
                selectedColor: scheme.primaryContainer,
                labelStyle: TextStyle(
                  color: isSel ? scheme.onPrimaryContainer : palette.textPrimary,
                  fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                ),
                deleteIcon: const Icon(LucideIcons.x, size: 14),
                deleteIconColor: palette.textSecondary,
                onSelected: (sel) {
                  if (sel) onSelect(folder);
                },
                onDeleted: folder == 'Genel' ? null : () => onDelete(folder),
              ),
            );
          }),
          ActionChip(
            shape: const StadiumBorder(),
            avatar: Icon(LucideIcons.folderPlus, size: 16, color: palette.textSecondary),
            label: const Text('Yeni Klasör'),
            onPressed: onCreate,
          ),
        ],
      ),
    );
  }
}
