import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
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
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Klasör Seçin',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: palette.textSecondary),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                icon: const Icon(LucideIcons.folderPlus, size: 16),
                label: const Text('Yeni Klasör', style: TextStyle(fontSize: 13)),
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
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: allFolders.map((f) {
              return DropdownMenuItem<String>(
                value: f,
                child: Row(
                  children: [
                    Icon(LucideIcons.folder, size: 16, color: palette.textSecondary),
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
