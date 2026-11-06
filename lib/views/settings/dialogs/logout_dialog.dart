import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/flashcard_provider.dart';
import '../../../providers/reading_provider.dart';

class LogoutDialog extends ConsumerWidget {
  const LogoutDialog({super.key});

  static Future<void> show(BuildContext context, WidgetRef ref) {
    return showDialog(
      context: context,
      builder: (_) => const LogoutDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.logout_rounded, color: Colors.redAccent),
          SizedBox(width: 10),
          Text('Çıkış Yap'),
        ],
      ),
      content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Vazgeç'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await ref.read(authProvider.notifier).signOut();
            ref.read(flashcardProvider.notifier).loadCards();
            ref.read(readingProvider.notifier).loadReadings();
            if (context.mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
          child: const Text('Çıkış Yap'),
        ),
      ],
    );
  }
}
