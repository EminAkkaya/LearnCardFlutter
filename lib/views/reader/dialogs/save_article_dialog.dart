import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/reading_provider.dart';
import 'create_folder_dialog.dart';

class SaveArticleDialog extends StatefulWidget {
  final WidgetRef ref;
  final String currentText;

  const SaveArticleDialog({
    super.key,
    required this.ref,
    required this.currentText,
  });

  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
    String currentText,
  ) {
    return showDialog(
      context: context,
      builder: (_) => SaveArticleDialog(ref: ref, currentText: currentText),
    );
  }

  @override
  State<SaveArticleDialog> createState() => _SaveArticleDialogState();
}

class _SaveArticleDialogState extends State<SaveArticleDialog> {
  static const Color emerald = Color(0xFF10B981);
  final TextEditingController _titleController = TextEditingController();
  String _selectedFolder = 'Genel';

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (widget.currentText.trim().isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    await widget.ref.read(readingProvider.notifier).saveArticle(
          _titleController.text,
          widget.currentText,
          folder: _selectedFolder,
        );

    nav.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Makale "$_selectedFolder" klasörüne kaydedildi!'),
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
      title: const Text('Makaleyi Kaydet'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
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
          onPressed: _handleSave,
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}
