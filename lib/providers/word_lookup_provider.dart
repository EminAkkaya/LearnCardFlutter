import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/offline_entry.dart';
import '../services/dictionary_service.dart';
import '../services/offline_dictionary.dart';

/// Uygulamayla gelen sözlük; açılamazsa null (çevrimiçi çeviri devreye girer).
final offlineDictionaryProvider = FutureProvider<OfflineDictionary?>((ref) async {
  try {
    final dict = await OfflineDictionary.openBundled();
    ref.onDispose(dict.dispose);
    return dict;
  } catch (_) {
    return null;
  }
});

typedef EnglishDetailsFetcher = Future<WordDefinitionResult> Function(String word);
typedef OnlineTranslator = Future<String> Function(String text);

final englishDetailsFetcherProvider = Provider<EnglishDetailsFetcher>((_) => DictionaryService.fetchEnglishDetails);
final onlineTranslatorProvider = Provider<OnlineTranslator>((_) => DictionaryService.translateToTurkish);

class WordLookupState {
  final bool isLoading;
  final WordDefinitionResult? details;
  final OfflineEntry? offline;

  /// Çevrimiçi çeviri sonucu; istenmediyse null.
  final String? online;
  final bool isOnlineLoading;

  const WordLookupState({
    this.isLoading = true,
    this.details,
    this.offline,
    this.online,
    this.isOnlineLoading = false,
  });

  bool get hasOffline => offline != null;

  /// Kart için başlangıç çevirisi.
  String get suggestedTranslation => offline?.primaryTranslation ?? online ?? '';

  WordLookupState copyWith({
    bool? isLoading,
    WordDefinitionResult? details,
    OfflineEntry? offline,
    String? online,
    bool? isOnlineLoading,
  }) =>
      WordLookupState(
        isLoading: isLoading ?? this.isLoading,
        details: details ?? this.details,
        offline: offline ?? this.offline,
        online: online ?? this.online,
        isOnlineLoading: isOnlineLoading ?? this.isOnlineLoading,
      );
}

/// Kelime sayfasının verisi: önce çevrimdışı sözlük; kelime orada yoksa
/// çevrimiçi çeviri otomatik, varsa yalnız kullanıcı isterse ([fetchOnline]).
class WordLookupNotifier extends StateNotifier<WordLookupState> {
  final Ref _ref;
  final String word;

  WordLookupNotifier(this._ref, this.word) : super(const WordLookupState()) {
    _load();
  }

  Future<void> _load() async {
    final dict = await _ref.read(offlineDictionaryProvider.future);
    final offline = dict?.lookup(word);
    final detailsFuture = _ref.read(englishDetailsFetcherProvider)(word).then<WordDefinitionResult?>((d) => d, onError: (_) => null);
    final onlineFuture = offline == null ? _translate() : Future<String?>.value(null);
    // Tanım, kartın varsayılan çevirisiyle aynı anlamdan seçilir.
    final details = (await detailsFuture)?.forSense(offline?.senses.first);
    final online = await onlineFuture;
    if (!mounted) return;
    state = WordLookupState(isLoading: false, details: details, offline: offline, online: online);
  }

  Future<String?> _translate() async {
    try {
      final tr = await _ref.read(onlineTranslatorProvider)(word.toLowerCase().trim());
      return tr.isEmpty || tr == DictionaryService.notFoundText ? null : tr;
    } catch (_) {
      return null;
    }
  }

  /// Sözlükte sonuç olsa da çevrimiçi çeviriyi getirir (bir kez).
  Future<void> fetchOnline() async {
    if (state.online != null || state.isOnlineLoading) return;
    state = state.copyWith(isOnlineLoading: true);
    final online = await _translate();
    if (!mounted) return;
    state = WordLookupState(
      isLoading: state.isLoading,
      details: state.details,
      offline: state.offline,
      online: online ?? DictionaryService.notFoundText,
    );
  }
}

final wordLookupProvider =
    StateNotifierProvider.autoDispose.family<WordLookupNotifier, WordLookupState, String>(
  (ref, word) => WordLookupNotifier(ref, word),
);
