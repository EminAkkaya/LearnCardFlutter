import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/feedback_colors.dart';
import '../../providers/sync_status_provider.dart';

/// Eşitleme veya yerel kayıt sorunlarını gösteren, akışı engellemeyen şerit.
///
/// K2 satır içi banner: durum rengi + ikon + metin birlikte; sayfa düzenini bozmaz.
/// Kayıt hatası tehlike, çevrimdışı/eşitleme sorunu uyarı tonundadır.
class SyncStatusBanner extends ConsumerWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncBannerProvider);
    if (status.kind == SyncBannerKind.none) return const SizedBox.shrink();

    final palette = AppPalette.of(context);
    final feedback = FeedbackColors.of(context);
    final isError = status.kind == SyncBannerKind.saveFailed;
    final tone = isError ? feedback.danger : feedback.warning;
    final container = isError ? feedback.dangerContainer : feedback.warningContainer;
    final icon = switch (status.kind) {
      SyncBannerKind.offline => LucideIcons.cloudOff,
      SyncBannerKind.saveFailed => LucideIcons.circleAlert,
      _ => LucideIcons.refreshCwOff,
    };

    return Container(
      decoration: BoxDecoration(
        color: Color.alphaBlend(container, palette.card),
        border: Border(
          top: BorderSide(color: palette.border),
          left: BorderSide(color: tone, width: 3),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: tone),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              status.message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          if (status.canRetry)
            TextButton.icon(
              onPressed: () => retrySync(ref, status),
              style: TextButton.styleFrom(foregroundColor: tone),
              icon: const Icon(LucideIcons.rotateCw, size: 16),
              label: const Text('Tekrar dene'),
            ),
        ],
      ),
    );
  }
}
