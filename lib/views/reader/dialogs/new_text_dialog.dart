import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/reading_provider.dart';

class NewTextDialog extends StatefulWidget {
  final WidgetRef ref;
  final String currentText;

  const NewTextDialog({
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
      builder: (_) => NewTextDialog(ref: ref, currentText: currentText),
    );
  }

  @override
  State<NewTextDialog> createState() => _NewTextDialogState();
}

class _NewTextDialogState extends State<NewTextDialog> {
  late final TextEditingController _inputCtrl;

  @override
  void initState() {
    super.initState();
    _inputCtrl = TextEditingController(text: widget.currentText);
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    widget.ref.read(readingProvider.notifier).updateCurrentText(_inputCtrl.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Okuma Metni Girin'),
      content: SizedBox(
        width: double.maxFinite,
        child: TextField(
          controller: _inputCtrl,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: 'Metninizi buraya yapıştırın...',
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Metni Yükle'),
        ),
      ],
    );
  }
}
