import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/flashcard_model.dart';
import '../services/srs_service.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

class FlashcardState {
  final List<FlashcardModel> cards;
  final bool isLoading;
  final String? error;
  final String filterStatus; // 'all', 'due', 'new', 'learning', 'mastered'
  final String searchQuery;

  FlashcardState({
    this.cards = const [],
    this.isLoading = false,
    this.error,
    this.filterStatus = 'all',
    this.searchQuery = '',
  });

  FlashcardState copyWith({
    List<FlashcardModel>? cards,
    bool? isLoading,
    String? error,
    String? filterStatus,
    String? searchQuery,
  }) {
    return FlashcardState(
      cards: cards ?? this.cards,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filterStatus: filterStatus ?? this.filterStatus,
      searchQuery: searchQuery ?? this.searchQuery,
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

class FlashcardNotifier extends StateNotifier<FlashcardState> {
  FlashcardNotifier([FlashcardState? initialState, bool autoLoad = true])
      : super(initialState ?? FlashcardState()) {
    if (autoLoad && initialState == null) {
      loadCards();
    }
  }

  Future<void> loadCards() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final cards = await SupabaseService.getSavedCards();
      state = state.copyWith(cards: cards, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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

    final String today = DateTime.now().toIso8601String().split('T')[0];
    final newCard = FlashcardModel(
      id: 'card_${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4().substring(0, 6)}',
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
      nextReviewDate: today,
      createdAt: DateTime.now().toIso8601String(),
    );

    final updated = [...state.cards, newCard];
    state = state.copyWith(cards: updated);
    await SupabaseService.upsertCard(newCard);
    return true;
  }

  Future<void> updateCard(FlashcardModel updatedCard) async {
    final updatedList = state.cards.map((c) => c.id == updatedCard.id ? updatedCard : c).toList();
    state = state.copyWith(cards: updatedList);
    await SupabaseService.upsertCard(updatedCard);
  }

  Future<void> deleteCard(String id) async {
    final updatedList = state.cards.where((c) => c.id != id).toList();
    state = state.copyWith(cards: updatedList);
    await SupabaseService.deleteCard(id);
  }

  Future<void> reviewCard(String id, ReviewRating rating) async {
    final index = state.cards.indexWhere((c) => c.id == id);
    if (index == -1) return;

    final card = state.cards[index];
    final updatedCard = SRSService.calculateSRS(card, rating);
    final updatedList = [...state.cards];
    updatedList[index] = updatedCard;

    state = state.copyWith(cards: updatedList);
    await SupabaseService.upsertCard(updatedCard);
  }

  Future<int> bulkAddCards(List<Map<String, String>> newCardsData) async {
    final existingWords = state.cards.map((c) => c.word.toLowerCase()).toSet();
    final List<FlashcardModel> addedList = [];
    final String today = DateTime.now().toIso8601String().split('T')[0];

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
        nextReviewDate: today,
        createdAt: DateTime.now().toIso8601String(),
      );
      addedList.add(card);
    }

    if (addedList.isNotEmpty) {
      final updatedCards = [...state.cards, ...addedList];
      state = state.copyWith(cards: updatedCards);
      await SupabaseService.saveCardsToSupabase(updatedCards);
    }

    return addedList.length;
  }
}

final flashcardProvider = StateNotifierProvider<FlashcardNotifier, FlashcardState>((ref) {
  final notifier = FlashcardNotifier();
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
