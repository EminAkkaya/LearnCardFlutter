import 'package:flutter/material.dart';
import '../../../core/theme/feedback_colors.dart';

class DeleteFolderDialog extends StatelessWidget {
  final String folderName;

  const DeleteFolderDialog({super.key, required this.folderName});

  /// Kullanıcı onaylarsa `true` döner.
  static Future<bool> confirm(BuildContext context, String folderName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteFolderDialog(folderName: folderName),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final fb = FeedbackColors.of(context);
    return AlertDialog(
      title: const Text('Klasörü Sil'),
      content: Text(
        '"$folderName" klasörünü silmek istediğinize emin misiniz? (İçindeki metinler Genel klasörüne taşınacaktır.)',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: fb.danger,
            foregroundColor: fb.onAccent,
          ),
          child: const Text('Sil'),
        ),
      ],
    );
  }
}
