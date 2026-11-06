import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/reading_provider.dart';
import 'create_folder_dialog.dart';
import 'edit_article_dialog.dart';

class SavedArticlesSheet extends ConsumerStatefulWidget {
  const SavedArticlesSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const SavedArticlesSheet(),
    );
  }

  @override
  ConsumerState<SavedArticlesSheet> createState() => _SavedArticlesSheetState();
}

class _SavedArticlesSheetState extends ConsumerState<SavedArticlesSheet> {
  static const Color emerald = Color(0xFF10B981);
  String _searchQuery = '';
  String _currentFilterFolder = 'Tümü';

  Future<void> _deleteFolder(String folderName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Klasörü Sil'),
        content: Text(
          '"$folderName" klasörünü silmek istediğinize emin misiniz? (İçindeki metinler Genel klasörüne taşınacaktır.)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(readingProvider.notifier).deleteCustomFolder(folderName);
      if (_currentFilterFolder == folderName) {
        setState(() => _currentFilterFolder = 'Tümü');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final readingState = ref.watch(readingProvider);
    final allArticles = readingState.articles;
    final allFolders = readingState.allFolders;

    final filteredArticles = allArticles.where((article) {
      final matchesFolder = _currentFilterFolder == 'Tümü' || article.folder == _currentFilterFolder;
      final query = _searchQuery.trim().toLowerCase();
      final matchesQuery = query.isEmpty ||
          article.title.toLowerCase().contains(query) ||
          article.text.toLowerCase().contains(query);
      return matchesFolder && matchesQuery;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.folder_copy_rounded, color: emerald),
                  const SizedBox(width: 10),
                  Text(
                    'Kayıtlı Okuma Metinleri (${allArticles.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Metinlerde veya başlıklarda ara...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 20),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text('Tümü (${allArticles.length})'),
                    selected: _currentFilterFolder == 'Tümü',
                    onSelected: (sel) {
                      if (sel) setState(() => _currentFilterFolder = 'Tümü');
                    },
                  ),
                ),
                ...allFolders.map((folderName) {
                  final count = allArticles.where((a) => a.folder == folderName).length;
                  final isSel = _currentFilterFolder == folderName;
                  final isDefault = folderName == 'Genel';

                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InputChip(
                      showCheckmark: false,
                      avatar: Icon(
                        Icons.folder_outlined,
                        size: 16,
                        color: isSel ? Colors.white : emerald,
                      ),
                      label: Text('$folderName ($count)'),
                      selected: isSel,
                      selectedColor: emerald,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : null,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      ),
                      deleteIconColor: isSel ? Colors.white70 : null,
                      onSelected: (sel) {
                        if (sel) setState(() => _currentFilterFolder = folderName);
                      },
                      onDeleted: isDefault ? null : () => _deleteFolder(folderName),
                    ),
                  );
                }),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 16),
                  label: const Text('Yeni Klasör'),
                  onPressed: () {
                    CreateFolderDialog.show(
                      context,
                      ref,
                      onCreated: (newFolder) {
                        setState(() => _currentFilterFolder = newFolder);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 24),
          if (allArticles.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open_rounded, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('Henüz kaydedilmiş bir okuma metni yok.'),
                  ],
                ),
              ),
            )
          else if (filteredArticles.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text('"$_currentFilterFolder" klasöründe aramanıza uygun metin bulunamadı.'),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: filteredArticles.length,
                itemBuilder: (context, index) {
                  final article = filteredArticles[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              article.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: emerald.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.folder_outlined, size: 12, color: emerald),
                                const SizedBox(width: 4),
                                Text(
                                  article.folder,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: emerald,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          article.text.length > 90
                              ? '${article.text.substring(0, 90)}...'
                              : article.text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded),
                        onSelected: (action) async {
                          if (action == 'edit') {
                            EditArticleDialog.show(context, ref, article);
                          } else if (action == 'delete') {
                            await ref.read(readingProvider.notifier).deleteArticle(article.id);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('Düzenle / Klasör Değiştir'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Sil', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        ref.read(readingProvider.notifier).selectArticle(article);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
