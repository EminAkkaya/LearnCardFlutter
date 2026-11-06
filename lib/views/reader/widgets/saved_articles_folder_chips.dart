import 'package:flutter/material.dart';
import '../../../models/reading_article_model.dart';

/// "Tümü", klasör ve "Yeni Klasör" çiplerinden oluşan yatay filtre satırı.
class SavedArticlesFolderChips extends StatelessWidget {
  final List<ReadingArticleModel> articles;
  final List<String> folders;
  final String selectedFolder;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onDelete;
  final VoidCallback onCreate;

  static const Color emerald = Color(0xFF10B981);

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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
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
                avatar: Icon(Icons.folder_outlined, size: 16, color: isSel ? Colors.white : emerald),
                label: Text('$folder ($count)'),
                selected: isSel,
                selectedColor: emerald,
                labelStyle: TextStyle(
                  color: isSel ? Colors.white : null,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                ),
                deleteIconColor: isSel ? Colors.white70 : null,
                onSelected: (sel) {
                  if (sel) onSelect(folder);
                },
                onDeleted: folder == 'Genel' ? null : () => onDelete(folder),
              ),
            );
          }),
          ActionChip(
            avatar: const Icon(Icons.add, size: 16),
            label: const Text('Yeni Klasör'),
            onPressed: onCreate,
          ),
        ],
      ),
    );
  }
}
