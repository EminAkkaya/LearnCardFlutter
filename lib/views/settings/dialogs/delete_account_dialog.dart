import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/flashcard_provider.dart';
import '../../../providers/reading_provider.dart';

/// Kalıcı hesap silme onayı. Yanlışlıkla silmeyi önlemek için kullanıcının
/// onay kelimesini yazması istenir.
class DeleteAccountDialog extends ConsumerStatefulWidget {
  static const confirmWord = 'SİL';

  const DeleteAccountDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const DeleteAccountDialog(),
    );
  }

  @override
  ConsumerState<DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<DeleteAccountDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Türkçe/İngilizce klavye farkı (İ/I, ı/i) onayı engellemesin.
  bool get _confirmed {
    final typed = _controller.text
        .trim()
        .replaceAll('İ', 'I')
        .replaceAll('ı', 'i')
        .toUpperCase();
    return typed == 'SIL';
  }

  Future<void> _delete() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await ref.read(authProvider.notifier).deleteAccount();
    if (!mounted) return;
    if (!ok) {
      final error = ref.read(authProvider).error ?? 'Hesap silinemedi.';
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    ref.read(flashcardProvider.notifier).loadCards();
    ref.read(readingProvider.notifier).loadReadings();
    navigator.popUntil((route) => route.isFirst);
    messenger.showSnackBar(
      const SnackBar(content: Text('Hesabın ve tüm verilerin silindi.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider.select((s) => s.isLoading));
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
          SizedBox(width: 10),
          Expanded(child: Text('Hesabı Sil')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hesabın, tüm kelime kartların, tekrar geçmişin ve kayıtlı metinlerin '
            'sunucudan ve bu cihazdan kalıcı olarak silinecek. Bu işlem geri alınamaz.',
          ),
          const SizedBox(height: 16),
          Text('Onaylamak için "${DeleteAccountDialog.confirmWord}" yaz:'),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text('Vazgeç'),
        ),
        ElevatedButton(
          onPressed: _confirmed && !isLoading ? _delete : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Kalıcı Olarak Sil'),
        ),
      ],
    );
  }
}
