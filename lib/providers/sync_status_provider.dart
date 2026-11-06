import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'flashcard_provider.dart';
import 'reading_provider.dart';

/// Supabase başlatılabildi mi? `main` başlatma sonucuyla override eder;
/// false ise uygulama çevrimdışı modda (yalnız yerel veri) çalışır.
final cloudAvailableProvider = Provider<bool>((ref) => true);

enum SyncBannerKind { none, offline, saveFailed, syncFailed }

/// Ana ekrandaki eşitleme şeridinin göstereceği durum.
class SyncBannerStatus {
  final SyncBannerKind kind;
  final bool cardsFailed;
  final bool readingsFailed;

  const SyncBannerStatus(this.kind, {this.cardsFailed = false, this.readingsFailed = false});

  static const SyncBannerStatus hidden = SyncBannerStatus(SyncBannerKind.none);

  bool get canRetry => kind == SyncBannerKind.syncFailed;

  String get message => switch (kind) {
        SyncBannerKind.none => '',
        SyncBannerKind.offline => 'Çevrimdışı mod: değişiklikler yalnız bu cihazda saklanıyor.',
        SyncBannerKind.saveFailed => 'Değişiklik cihaza kaydedilemedi. Lütfen tekrar dene.',
        SyncBannerKind.syncFailed =>
          'Bazı değişiklikler buluta gönderilemedi, sonra tekrar denenecek.',
      };
}

/// Durumu sağlayıcı alanlarından türeten saf fonksiyon (UI'sız test edilebilir).
SyncBannerStatus computeSyncBanner({
  required bool cloudAvailable,
  required String? cardSaveError,
  required String? cardSyncError,
  required String? readingSyncError,
}) {
  if (cardSaveError == FlashcardNotifier.saveFailedMessage) {
    return const SyncBannerStatus(SyncBannerKind.saveFailed);
  }
  if (!cloudAvailable) return const SyncBannerStatus(SyncBannerKind.offline);
  final cardsFailed = cardSyncError != null;
  final readingsFailed = readingSyncError != null;
  if (!cardsFailed && !readingsFailed) return SyncBannerStatus.hidden;
  return SyncBannerStatus(
    SyncBannerKind.syncFailed,
    cardsFailed: cardsFailed,
    readingsFailed: readingsFailed,
  );
}

final syncBannerProvider = Provider<SyncBannerStatus>((ref) {
  final cards = ref.watch(flashcardProvider);
  final readingSyncError = ref.watch(readingProvider.select((s) => s.syncError));
  return computeSyncBanner(
    cloudAvailable: ref.watch(cloudAvailableProvider),
    cardSaveError: cards.error,
    cardSyncError: cards.syncError,
    readingSyncError: readingSyncError,
  );
});

/// Başarısız eşitlemeyi yeniden dener (yalnız hata veren listeler).
Future<void> retrySync(WidgetRef ref, SyncBannerStatus status) async {
  await Future.wait([
    if (status.cardsFailed) ref.read(flashcardProvider.notifier).loadCards(),
    if (status.readingsFailed) ref.read(readingProvider.notifier).loadReadings(),
  ]);
}
