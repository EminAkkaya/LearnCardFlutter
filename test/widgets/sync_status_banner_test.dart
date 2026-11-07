import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:learncard_flutter/providers/flashcard_provider.dart';
import 'package:learncard_flutter/providers/sync_status_provider.dart';
import 'package:learncard_flutter/views/widgets/sync_status_banner.dart';

void main() {
  group('computeSyncBanner', () {
    test('hidden when everything is fine', () {
      final s = computeSyncBanner(
        cloudAvailable: true,
        cardSaveError: null,
        cardSyncError: null,
        readingSyncError: null,
      );
      expect(s.kind, SyncBannerKind.none);
    });

    test('sync errors are retryable and remember which list failed', () {
      final s = computeSyncBanner(
        cloudAvailable: true,
        cardSaveError: null,
        cardSyncError: null,
        readingSyncError: 'timeout',
      );
      expect(s.kind, SyncBannerKind.syncFailed);
      expect(s.canRetry, isTrue);
      expect(s.cardsFailed, isFalse);
      expect(s.readingsFailed, isTrue);
    });

    test('offline mode and local save failures take priority', () {
      expect(
        computeSyncBanner(
          cloudAvailable: false,
          cardSaveError: null,
          cardSyncError: 'x',
          readingSyncError: null,
        ).kind,
        SyncBannerKind.offline,
      );
      expect(
        computeSyncBanner(
          cloudAvailable: false,
          cardSaveError: FlashcardNotifier.saveFailedMessage,
          cardSyncError: null,
          readingSyncError: null,
        ).kind,
        SyncBannerKind.saveFailed,
      );
    });
  });

  testWidgets('banner shows the Turkish message and a retry action', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        syncBannerProvider.overrideWithValue(
          const SyncBannerStatus(SyncBannerKind.syncFailed, cardsFailed: true),
        ),
      ],
      child: const MaterialApp(home: Scaffold(body: SyncStatusBanner())),
    ));

    expect(
      find.text('Bazı değişiklikler buluta gönderilemedi, sonra tekrar denenecek.'),
      findsOneWidget,
    );
    expect(find.text('Tekrar dene'), findsOneWidget);
    expect(find.byIcon(LucideIcons.refreshCwOff), findsOneWidget);
  });

  testWidgets('banner is empty when there is nothing to report', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [syncBannerProvider.overrideWithValue(SyncBannerStatus.hidden)],
      child: const MaterialApp(home: Scaffold(body: SyncStatusBanner())),
    ));
    expect(find.byType(TextButton), findsNothing);
    expect(find.byIcon(LucideIcons.refreshCwOff), findsNothing);
  });
}
