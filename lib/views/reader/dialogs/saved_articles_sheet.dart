import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/reading_article_model.dart';
import '../../../providers/reading_provider.dart';
import '../widgets/saved_article_tile.dart';
import '../widgets/saved_articles_folder_chips.dart';
import 'create_folder_dialog.dart';
import 'delete_folder_dialog.dart';
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

/// Arama metni ve seçili klasör yalnız bu sheet'e ait geçici UI durumudur.
class _SavedArticlesSheetState extends ConsumerState<SavedArticlesSheet> {
  static const Color emerald = Color(0xFF10B981);
  final _searchController = TextEditingController();
  String _filterFolder = 'Tümü';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteFolder(String folder) async {
    if (!await DeleteFolderDialog.confirm(context, folder)) return;
    await ref.read(readingProvider.notifier).deleteCustomFolder(folder);
    if (mounted && _filterFolder == folder) setState(() => _filterFolder = 'Tümü');
  }

  List<ReadingArticleModel> _filter(List<ReadingArticleModel> articles) {
    final query = _searchController.text.trim().toLowerCase();
    return articles.where((a) {
      final inFolder = _filterFolder == 'Tümü' || a.folder == _filterFolder;
      final matches = query.isEmpty ||
          a.title.toLowerCase().contains(query) ||
          a.text.toLowerCase().contains(query);
      return inFolder && matches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final readingState = ref.watch(readingProvider);
    final notifier = ref.read(readingProvider.notifier);
    final articles = readingState.articles;
    final filtered = _filter(articles);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.folder_copy_rounded, color: emerald),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Kayıtlı Okuma Metinleri (${articles.length})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Metinlerde veya başlıklarda ara...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 20),
                      onPressed: () => setState(_searchController.clear),
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
          SavedArticlesFolderChips(
            articles: articles,
            folders: readingState.allFolders,
            selectedFolder: _filterFolder,
            onSelect: (folder) => setState(() => _filterFolder = folder),
            onDelete: _deleteFolder,
            onCreate: () => CreateFolderDialog.show(
              context,
              ref,
              onCreated: (folder) => setState(() => _filterFolder = folder),
            ),
          ),
          const Divider(height: 24),
          Expanded(
            child: articles.isEmpty || filtered.isEmpty
                ? _EmptyMessage(
                    icon: articles.isEmpty ? Icons.folder_open_rounded : Icons.search_off_rounded,
                    text: articles.isEmpty
                        ? 'Henüz kaydedilmiş bir okuma metni yok.'
                        : '"$_filterFolder" klasöründe aramanıza uygun metin bulunamadı.',
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final article = filtered[index];
                      return SavedArticleTile(
                        article: article,
                        onEdit: () => EditArticleDialog.show(context, ref, article),
                        onDelete: () => notifier.deleteArticle(article.id),
                        onOpen: () {
                          notifier.selectArticle(article);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyMessage({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
