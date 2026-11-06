import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/flashcard_model.dart';
import '../services/flashcard_store.dart';
import '../services/srs_service.dart';
import '../services/sync/sync_engine.dart';
import 'auth_provider.dart';
import 'load_tracker.dart';
import 'stats_provider.dart';

class FlashcardState {
  final List<FlashcardModel> cards;
  final bool isLoading;
  final String? error;
  final String filterStatus; // 'all', 'due', 'new', 'learning', 'mastered'
  final String searchQuery;

  /// Son eşitleme hatası (veri yerelde güvende, sonraki eşitlemede yeniden denenir).
  final String? syncError;

  FlashcardState({
    this.cards = const [],
    this.isLoading = false,
    this.error,
    this.filterStatus = 'all',
    this.searchQuery = '',
    this.syncError,
  });

  FlashcardState copyWith({
    List<FlashcardModel>? cards,
    bool? isLoading,
    String? error,
    String? filterStatus,
    String? searchQuery,
    Object? syncError = _keep,
  }) {
    return FlashcardState(
      cards: cards ?? this.cards,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filterStatus: filterStatus ?? this.filterStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      syncError: syncError == _keep ? this.syncError : syncError as String?,
    );
  }

  List<FlashcardModel> get filteredCards {
    return cards.where((card) {
      final matchesSearch = card.word.toLowerCase().contains(searchQuery.toLowerCase()) ||
          card.trTranslation.toLowerCase().contains(searchQuery.toLowerCase()) ||
          card.definition.toLowerCase().contains(searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (filterStatus == 'due') return SRSService.isCardDue(card);
      if (filterStatus == 'new') return card.status == 'new';
      if (filterStatus == 'learning') return card.status == 'learning';
      if (filterStatus == 'mastered') return card.status == 'mastered';

      return true;
    }).toList();
  }

  List<FlashcardModel> get dueCards => cards.where((c) => SRSService.isCardDue(c)).toList();
  List<FlashcardModel> get newCards => cards.where((c) => c.status == 'new').toList();
  List<FlashcardModel> get learningCards => cards.where((c) => c.status == 'learning').toList();
  List<FlashcardModel> get masteredCards => cards.where((c) => c.status == 'mastered').toList();
}

const Object _keep = Object();

class FlashcardNotifier extends StateNotifier<FlashcardState> {
  static const String saveFailedMessage =
      'Değişiklik cihaza kaydedilemedi. Lütfen tekrar dene.';

  final Ref? _ref;
  final FlashcardStore _store;
  final LoadTracker<FlashcardModel> _loads = LoadTracker((card) => card.id);

  /// Son derecelendirmeden önceki kart; tek adım geri alma için.
  FlashcardModel? _beforeLastReview;
  bool get canUndoReview => _beforeLastReview != null;

  FlashcardNotifier([
    FlashcardState? initialState,
    bool autoLoad = true,
    this._ref,
    FlashcardStore? store,
  ])  : _store = store ?? const FlashcardStore(),
        super(initialState ?? FlashcardState()) {
    if (autoLoad && initialState == null) {
      loadCards();
    }
  }

  /// Oturum değişimi ve ekran açılışı aynı anda yükleme başlatabilir; yalnız
  /// en son yükleme durumu yazar ve yükleme sırasındaki düzenlemeler korunur.
  Future<void> loadCards() async {
    final generation = _loads.begin();
    state = state.copyWith(isLoading: true, error: null);
    try {
      final loaded = await _store.load();
      if (!mounted || !_loads.isLatest(generation)) return;
      state = state.copyWith(
        cards: _loads.complete(generation, loaded.items),
        isLoading: false,
        syncError: loaded.sync.errorMessage,
      );
    } catch (e) {
      if (!mounted || !_loads.isLatest(generation)) return;
      _loads.fail(generation);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _recordSync(SyncResult result) {
    if (!mounted) return;
    state = state.copyWith(syncError: result.errorMessage);
  }

  /// İyimser güncellemeyi kalıcılaştırır. Yerel yazma başarısızsa [rollback]
  /// uygulanır ve hata durumda gösterilir; sessizce yutulmaz.
  Future<bool> _persist(Future<SyncResult> Function() write, void Function() rollback) async {
    try {
      _recordSync(await write());
      return true;
    } catch (e) {
      debugPrint('[flashcards] local write failed: $e');
      if (mounted) {
        rollback();
        state = state.copyWith(error: saveFailedMessage);
      }
      return false;
    }
  }

  void _putCards(List<FlashcardModel> cards) {
    final byId = {for (final c in cards) c.id: c};
    final kept = state.cards.map((c) => byId.remove(c.id) ?? c).toList();
    state = state.copyWith(cards: [...kept, ...byId.values]);
    for (final c in cards) {
      _loads.recordUpsert(c);
    }
  }

  void _removeCards(Set<String> ids) {
    state = state.copyWith(cards: state.cards.where((c) => !ids.contains(c.id)).toList());
    for (final id in ids) {
      _loads.recordDelete(id);
    }
  }

  void setFilterStatus(String status) {
    state = state.copyWith(filterStatus: status);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<bool> addCard({
    required String word,
    String definition = '',
    String trTranslation = '',
    String phonetic = '',
    String partOfSpeech = '',
    String exampleSentence = '',
    String audioUrl = '',
  }) async {
    final String cleanWord = word.trim().toLowerCase();
    if (cleanWord.isEmpty) return false;

    // Check if word already exists
    final bool exists = state.cards.any((c) => c.word.toLowerCase() == cleanWord);
    if (exists) return false;

    final now = DateTime.now();
    final newCard = FlashcardModel(
      id: 'card_${now.millisecondsSinceEpoch}_${const Uuid().v4().substring(0, 6)}',
      word: cleanWord,
      definition: definition,
      trTranslation: trTranslation,
      phonetic: phonetic,
      partOfSpeech: partOfSpeech,
      exampleSentence: exampleSentence,
      audioUrl: audioUrl,
      status: 'new',
      interval: 0,
      repetitions: 0,
      easeFactor: 2.5,
      nextReviewDate: SRSService.formatReviewDate(now),
      createdAt: now.toIso8601String(),
    );

    _putCards([newCard]);
    final saved = await _persist(
      () => _store.save([newCard]),
      () => _removeCards({newCard.id}),
    );
    if (!saved) return false;
    _ref?.read(statsProvider.notifier).recordCardAdded();
    return true;
  }

  Future<void> updateCard(FlashcardModel updatedCard) async {
    final previous = _findCard(updatedCard.id);
    _putCards([updatedCard]);
    await _persist(
      () => _store.save([updatedCard]),
      () => previous == null ? _removeCards({updatedCard.id}) : _putCards([previous]),
    );
  }

  Future<void> deleteCard(String id) async {
    final previous = _findCard(id);
    _removeCards({id});
    await _persist(
      () => _store.delete(id),
      () {
        if (previous != null) _putCards([previous]);
      },
    );
  }

  Future<void> reviewCard(String id, ReviewRating rating) async {
    final card = _findCard(id);
    if (card == null) return;

    final updatedCard = SRSService.calculateSRS(card, rating);
    _putCards([updatedCard]);
    final saved = await _persist(
      () => _store.save([updatedCard]),
      () => _putCards([card]),
    );
    if (saved) {
      _beforeLastReview = card;
      _ref?.read(statsProvider.notifier).recordCardReviewed();
    }
  }

  /// Son derecelendirmeyi geri alır: kart önceki SRS durumuna döner.
  Future<bool> undoLastReview() async {
    final previous = _beforeLastReview;
    if (previous == null) return false;
    _beforeLastReview = null;
    await updateCard(previous);
    return true;
  }

  FlashcardModel? _findCard(String id) {
    for (final c in state.cards) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<int> bulkAddCards(List<Map<String, String>> newCardsData) async {
    final existingWords = state.cards.map((c) => c.word.toLowerCase()).toSet();
    final List<FlashcardModel> addedList = [];
    final now = DateTime.now();

    for (final item in newCardsData) {
      final String w = item['word']?.trim().toLowerCase() ?? '';
      if (w.isEmpty || existingWords.contains(w)) continue;

      existingWords.add(w);
      final card = FlashcardModel(
        id: 'card_${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4().substring(0, 6)}',
        word: w,
        definition: item['definition'] ?? 'No definition added',
        trTranslation: item['trTranslation'] ?? 'Çeviri girilmedi',
        phonetic: item['phonetic'] ?? '',
        partOfSpeech: item['partOfSpeech'] ?? '',
        exampleSentence: item['sentence'] ?? item['exampleSentence'] ?? '',
        audioUrl: item['audioUrl'] ?? '',
        status: 'new',
        interval: 0,
        repetitions: 0,
        easeFactor: 2.5,
        nextReviewDate: SRSService.formatReviewDate(now),
        createdAt: now.toIso8601String(),
      );
      addedList.add(card);
    }

    if (addedList.isEmpty) return 0;

    _putCards(addedList);
    // Yalnız yeni kartlar yazılır ve gönderilir; tüm deste yeniden yüklenmez.
    final saved = await _persist(
      () => _store.save(addedList),
      () => _removeCards({for (final c in addedList) c.id}),
    );
    if (!saved) return 0;
    _ref?.read(statsProvider.notifier).recordCardAdded(addedList.length);
    return addedList.length;
  }
}

final flashcardProvider = StateNotifierProvider<FlashcardNotifier, FlashcardState>((ref) {
  final notifier = FlashcardNotifier(null, true, ref);
  ref.listen<AppAuthState>(authProvider, (previous, next) {
    final prevUserId = previous?.user?.id;
    final nextUserId = next.user?.id;
    final prevGuest = previous?.isGuestMode;
    final nextGuest = next.isGuestMode;

    if (prevUserId != nextUserId || prevGuest != nextGuest) {
      notifier.loadCards();
    }
  });
  return notifier;
});
