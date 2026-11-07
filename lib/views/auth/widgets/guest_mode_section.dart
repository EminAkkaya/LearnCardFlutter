import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../providers/auth_provider.dart';

class GuestModeSection extends ConsumerWidget {
  const GuestModeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = AppPalette.of(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: palette.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                'VEYA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                  color: palette.textMuted,
                ),
              ),
            ),
            Expanded(child: Divider(color: palette.border)),
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
          icon: const Icon(LucideIcons.userRound, size: 18),
          label: const Text('Giriş Yapmadan Kullan (Misafir Modu)'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'Verileriniz yalnızca bu cihazda yerel olarak saklanır',
            style: TextStyle(fontSize: 12, color: palette.textMuted),
          ),
        ),
      ],
    );
  }
}
