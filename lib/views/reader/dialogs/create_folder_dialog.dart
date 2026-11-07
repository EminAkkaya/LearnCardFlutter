import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/reading_provider.dart';

class CreateFolderDialog extends StatefulWidget {
  final WidgetRef ref;
  final ValueChanged<String>? onCreated;

  const CreateFolderDialog({super.key, required this.ref, this.onCreated});

  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    ValueChanged<String>? onCreated,
  }) {
    return showDialog(
      context: context,
      builder: (_) => CreateFolderDialog(ref: ref, onCreated: onCreated),
    );
  }

  @override
  State<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  final TextEditingController _folderCtrl = TextEditingController();

  @override
  void dispose() {
    _folderCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _folderCtrl.text.trim();
    if (text.isNotEmpty) {
      await widget.ref.read(readingProvider.notifier).addCustomFolder(text);
      widget.onCreated?.call(text);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Klasör Oluştur'),
      content: TextField(
        controller: _folderCtrl,
        decoration: const InputDecoration(
          labelText: 'Klasör Adı',
          hintText: 'Örn: Hikayeler, Ders Notları',
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Oluştur'),
        ),
      ],
    );
  }
}
