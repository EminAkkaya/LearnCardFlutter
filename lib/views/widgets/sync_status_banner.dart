import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/sync_status_provider.dart';

/// Eşitleme veya yerel kayıt sorunlarını gösteren, akışı engellemeyen şerit.
class SyncStatusBanner extends ConsumerWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncBannerProvider);
    if (status.kind == SyncBannerKind.none) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final isError = status.kind == SyncBannerKind.saveFailed;
    final background = isError ? scheme.errorContainer : scheme.secondaryContainer;
    final foreground = isError ? scheme.onErrorContainer : scheme.onSecondaryContainer;

    return Material(
      color: background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
        child: Row(
          children: [
            Icon(
              status.kind == SyncBannerKind.offline
                  ? Icons.cloud_off_rounded
                  : Icons.sync_problem_rounded,
              size: 18,
              color: foreground,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                status.message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: foreground),
              ),
            ),
            if (status.canRetry)
              TextButton(
                onPressed: () => retrySync(ref, status),
                style: TextButton.styleFrom(foregroundColor: foreground),
                child: const Text('Tekrar dene'),
              ),
          ],
        ),
      ),
    );
  }
}
