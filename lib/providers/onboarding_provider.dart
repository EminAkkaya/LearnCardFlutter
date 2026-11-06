import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/app_database.dart';

/// İlk açılış tanıtımının görülüp görülmediği. `null` = henüz okunmadı.
class OnboardingNotifier extends StateNotifier<bool?> {
  static const storageKey = 'onboarding_completed';
  final AppDatabase _db;

  OnboardingNotifier(this._db) : super(null) {
    _load();
  }

  Future<void> _load() async {
    bool loaded;
    try {
      loaded = await _db.getBool(storageKey) ?? false;
    } catch (_) {
      // Okunamazsa tanıtımı göstermek yerine uygulamayı açık tut.
      loaded = true;
    }
    // Okuma sürerken complete() çağrıldıysa onu ezme.
    if (mounted && state == null) state = loaded;
  }

  Future<void> complete() async {
    state = true;
    try {
      await _db.setBool(storageKey, true);
    } catch (_) {}
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, bool?>((ref) {
  return OnboardingNotifier(ref.watch(appDatabaseProvider));
});
