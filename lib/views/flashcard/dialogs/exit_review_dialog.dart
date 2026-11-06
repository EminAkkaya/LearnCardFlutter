import 'package:flutter/material.dart';

/// Tekrar oturumu yarıdayken çıkış onayı. Verilen derecelendirmeler zaten
/// kaydedildiği için yalnız kalan kartlar ertelenir.
class ExitReviewDialog extends StatelessWidget {
  final int remaining;

  const ExitReviewDialog({super.key, required this.remaining});

  static Future<bool> confirm(BuildContext context, {required int remaining}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ExitReviewDialog(remaining: remaining),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Oturumdan çıkılsın mı?'),
      content: Text(
        '$remaining kart kaldı. Şimdiye kadar verdiğin cevaplar kaydedildi; kalan kartlar sonraki tekrarda karşına çıkacak.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Devam et'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Çık'),
        ),
      ],
    );
  }
}
