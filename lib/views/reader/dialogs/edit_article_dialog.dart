import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/reading_article_model.dart';
import '../../../providers/reading_provider.dart';
import 'create_folder_dialog.dart';

class EditArticleDialog extends StatefulWidget {
  final WidgetRef ref;
  final ReadingArticleModel article;

  const EditArticleDialog({
    super.key,
    required this.ref,
    required this.article,
  });

  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
    ReadingArticleModel article,
  ) {
    return showDialog(
      context: context,
      builder: (_) => EditArticleDialog(ref: ref, article: article),
    );
  }

  @override
  State<EditArticleDialog> createState() => _EditArticleDialogState();
}

class _EditArticleDialogState extends State<EditArticleDialog> {
  static const Color emerald = Color(0xFF10B981);
  late final TextEditingController _titleController;
  late String _selectedFolder;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.article.title);
    _selectedFolder = widget.article.folder;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    final updated = widget.article.copyWith(
      title: _titleController.text.trim().isEmpty ? 'Untitled' : _titleController.text.trim(),
      folder: _selectedFolder,
    );

    await widget.ref.read(readingProvider.notifier).updateArticle(updated);

    nav.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Metin güncellendi ("$_selectedFolder")'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: emerald,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allFolders = widget.ref.watch(readingProvider).allFolders;
    if (!allFolders.contains(_selectedFolder)) {
      _selectedFolder = allFolders.first;
    }

    return AlertDialog(
      title: const Text('Kaydı Düzenle'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
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
                  CreateFolderDialog.show(
                    context,
                    widget.ref,
                    onCreated: (newFolder) {
                      setState(() => _selectedFolder = newFolder);
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            initialValue: _selectedFolder,
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
              if (val != null) setState(() => _selectedFolder = val);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _handleUpdate,
          child: const Text('Güncelle'),
        ),
      ],
    );
  }
}
