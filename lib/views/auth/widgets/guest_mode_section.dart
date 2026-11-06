import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';

class GuestModeSection extends ConsumerWidget {
  const GuestModeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: theme.dividerColor.withValues(alpha: 0.3))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                'VEYA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                ),
              ),
            ),
            Expanded(child: Divider(color: theme.dividerColor.withValues(alpha: 0.3))),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () async {
            await ref.read(authProvider.notifier).continueAsGuest();
            if (context.mounted && Navigator.canPop(context)) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
          icon: const Icon(Icons.person_outline_rounded),
          label: const Text('Giriş Yapmadan Kullan (Misafir Modu)'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            side: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'Verileriniz yalnızca bu cihazda yerel olarak saklanır',
            style: TextStyle(
              fontSize: 11,
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}
