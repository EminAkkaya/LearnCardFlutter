import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/reading_article_model.dart';
import '../../../providers/reading_provider.dart';

class ReaderDialogs {
  static const Color emerald = Color(0xFF10B981);

  static void showCreateFolderDialog(BuildContext parentContext, WidgetRef ref, {Function(String)? onCreated}) {
    final folderCtrl = TextEditingController();
    showDialog(
      context: parentContext,
      builder: (ctx) => AlertDialog(
        title: const Text('Yeni Klasör Oluştur'),
        content: TextField(
          controller: folderCtrl,
          decoration: const InputDecoration(
            labelText: 'Klasör Adı',
            hintText: 'Örn: Hikayeler, Ders Notları',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = folderCtrl.text.trim();
              if (text.isNotEmpty) {
                await ref.read(readingProvider.notifier).addCustomFolder(text);
                if (onCreated != null) onCreated(text);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Oluştur'),
          ),
        ],
      ),
    );
  }

  static void showSaveArticleDialog(BuildContext context, WidgetRef ref, String currentText) {
    final titleController = TextEditingController();
    String selectedFolder = 'Genel';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final allFolders = ref.watch(readingProvider).allFolders;
          if (!allFolders.contains(selectedFolder)) {
            selectedFolder = allFolders.first;
          }

          return AlertDialog(
            title: const Text('Makaleyi Kaydet'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Makale Başlığı',
                    hintText: 'Örn: The Art of Learning',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Klasör Seçin',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      icon: const Icon(Icons.create_new_folder_outlined, size: 18),
                      label: const Text('Yeni Klasör', style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        showCreateFolderDialog(ctx, ref, onCreated: (newFolder) {
                          setDialogState(() {
                            selectedFolder = newFolder;
                          });
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: selectedFolder,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: allFolders.map((f) {
                    return DropdownMenuItem<String>(
                      value: f,
                      child: Row(
                        children: [
                          const Icon(Icons.folder_outlined, size: 18, color: emerald),
                          const SizedBox(width: 8),
                          Text(f),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedFolder = val);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (currentText.trim().isNotEmpty) {
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(ctx);

                    await ref
                        .read(readingProvider.notifier)
                        .saveArticle(
                          titleController.text,
                          currentText,
                          folder: selectedFolder,
                        );

                    navigator.pop();
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Makale "$selectedFolder" klasörüne kaydedildi!'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: emerald,
                      ),
                    );
                  }
                },
                child: const Text('Kaydet'),
              ),
            ],
          );
        },
      ),
    );
  }

  static void showEditArticleDialog(BuildContext parentContext, WidgetRef ref, ReadingArticleModel article) {
    final titleController = TextEditingController(text: article.title);
    String selectedFolder = article.folder;

    showDialog(
      context: parentContext,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final allFolders = ref.watch(readingProvider).allFolders;
          if (!allFolders.contains(selectedFolder)) {
            selectedFolder = allFolders.first;
          }

          return AlertDialog(
            title: const Text('Kaydı Düzenle'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Makale Başlığı',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Klasör',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      icon: const Icon(Icons.create_new_folder_outlined, size: 18),
                      label: const Text('Yeni Klasör', style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        showCreateFolderDialog(ctx, ref, onCreated: (newFolder) {
                          setDialogState(() {
                            selectedFolder = newFolder;
                          });
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: selectedFolder,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: allFolders.map((f) {
                    return DropdownMenuItem<String>(
                      value: f,
                      child: Row(
                        children: [
                          const Icon(Icons.folder_outlined, size: 18, color: emerald),
                          const SizedBox(width: 8),
                          Text(f),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedFolder = val);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(ctx);

                  final updated = article.copyWith(
                    title: titleController.text.trim().isEmpty ? 'Untitled' : titleController.text.trim(),
                    folder: selectedFolder,
                  );

                  await ref.read(readingProvider.notifier).updateArticle(updated);

                  navigator.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Metin güncellendi ("$selectedFolder")'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: emerald,
                    ),
                  );
                },
                child: const Text('Güncelle'),
              ),
            ],
          );
        },
      ),
    );
  }

  static void showSavedArticlesSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String searchQuery = '';
        String currentFilterFolder = 'Tümü';

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Consumer(
              builder: (context, ref, _) {
                final readingState = ref.watch(readingProvider);
                final allArticles = readingState.articles;
                final allFolders = readingState.allFolders;

                // Filter logic
                final filteredArticles = allArticles.where((article) {
                  final matchesFolder = currentFilterFolder == 'Tümü' || article.folder == currentFilterFolder;
                  final query = searchQuery.trim().toLowerCase();
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
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.folder_copy_rounded, color: emerald),
                              const SizedBox(width: 10),
                              Text(
                                'Kayıtlı Okuma Metinleri (${allArticles.length})',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Search bar
                      TextField(
                        onChanged: (val) => setSheetState(() => searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Metinlerde veya başlıklarda ara...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 20),
                                  onPressed: () => setSheetState(() => searchQuery = ''),
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

                      // Folder Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // "Tümü" chip
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text('Tümü (${allArticles.length})'),
                                selected: currentFilterFolder == 'Tümü',
                                onSelected: (sel) {
                                  if (sel) setSheetState(() => currentFilterFolder = 'Tümü');
                                },
                              ),
                            ),
                            // Specific folder chips
                            ...allFolders.map((folderName) {
                              final count = allArticles.where((a) => a.folder == folderName).length;
                              final isSel = currentFilterFolder == folderName;
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
                                    if (sel) setSheetState(() => currentFilterFolder = folderName);
                                  },
                                  onDeleted: isDefault ? null : () async {
                                    final confirm = await showDialog<bool>(
                                      context: ctx,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Klasörü Sil'),
                                        content: Text('"$folderName" klasörünü silmek istediğinize emin misiniz? (İçindeki metinler Genel klasörüne taşınacaktır.)'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('İptal'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                            child: const Text('Sil'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await ref.read(readingProvider.notifier).deleteCustomFolder(folderName);
                                      if (currentFilterFolder == folderName) {
                                        setSheetState(() => currentFilterFolder = 'Tümü');
                                      } else {
                                        setSheetState(() {});
                                      }
                                    }
                                  },
                                ),
                              );
                            }),
                            // Action to create new folder directly from sheet
                            ActionChip(
                              avatar: const Icon(Icons.add, size: 16),
                              label: const Text('Yeni Klasör'),
                              onPressed: () {
                                showCreateFolderDialog(ctx, ref, onCreated: (newFolder) {
                                  setSheetState(() => currentFilterFolder = newFolder);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 24),

                      // Content list
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
                                Text('"$currentFilterFolder" klasöründe aramanıza uygun metin bulunamadı.'),
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
                                        showEditArticleDialog(ctx, ref, article);
                                      } else if (action == 'delete') {
                                        await ref
                                            .read(readingProvider.notifier)
                                            .deleteArticle(article.id);
                                        setSheetState(() {});
                                      }
                                    },
                                    itemBuilder: (ctx) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit_outlined, size: 18),
                                            SizedBox(width: 8),
                                            Text('Düzenle / Klasör Değiştir'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
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
                                    ref
                                        .read(readingProvider.notifier)
                                        .selectArticle(article);
                                    Navigator.pop(ctx);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  static void showNewTextDialog(BuildContext context, WidgetRef ref, String currentText) {
    final inputCtrl = TextEditingController(text: currentText);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yeni Okuma Metni Girin'),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: inputCtrl,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'Metninizi buraya yapıştırın...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(readingProvider.notifier)
                  .updateCurrentText(inputCtrl.text);
              Navigator.pop(ctx);
            },
            child: const Text('Metni Yükle'),
          ),
        ],
      ),
    );
  }
}
