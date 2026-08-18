import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/database/app_database.dart';
import '../models/flashcard_model.dart';
import '../models/reading_article_model.dart';
import 'auth_service.dart';

class SupabaseService {
  static SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  static String? get currentUserId => AuthService.currentUserId;

  static final List<Map<String, dynamic>> _seedCards = [
    {
      'id': 'seed-1',
      'word': 'serendipity',
      'definition': 'The occurrence and development of events by chance in a happy or beneficial way.',
      'tr_translation': 'tesadüf, şans eseri güzel bir şey bulma',
      'phonetic': '/ˌser.ənˈdɪp.ə.ti/',
      'part_of_speech': 'noun',
      'example_sentence': 'Finding this wonderful book in a second-hand shop was pure serendipity.',
      'status': 'new',
      'interval': 0,
      'repetitions': 0,
      'ease_factor': 2.5,
      'next_review_date': DateTime.now().toIso8601String().split('T')[0],
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'id': 'seed-2',
      'word': 'ephemeral',
      'definition': 'Lasting for a very short time; fleeting or transitory.',
      'tr_translation': 'gelip geçici, kısa ömürlü',
      'phonetic': '/ɪˈfem.ər.əl/',
      'part_of_speech': 'adjective',
      'example_sentence': 'Fame in the digital age can often be surprisingly ephemeral.',
      'status': 'new',
      'interval': 0,
      'repetitions': 0,
      'ease_factor': 2.5,
      'next_review_date': DateTime.now().toIso8601String().split('T')[0],
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'id': 'seed-3',
      'word': 'resilient',
      'definition': 'Able to withstand or recover quickly from difficult conditions.',
      'tr_translation': 'dayanıklı, dirençli, esnek',
      'phonetic': '/rɪˈzɪl.jənt/',
      'part_of_speech': 'adjective',
      'example_sentence': 'The team showed a resilient spirit after their initial setback.',
      'status': 'new',
      'interval': 0,
      'repetitions': 0,
      'ease_factor': 2.5,
      'next_review_date': DateTime.now().toIso8601String().split('T')[0],
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'id': 'seed-4',
      'word': 'ubiquitous',
      'definition': 'Present, appearing, or found everywhere at the same time.',
      'tr_translation': 'her yerde bulunan, yaygın',
      'phonetic': '/juːˈbɪk.wə.təs/',
      'part_of_speech': 'adjective',
      'example_sentence': 'Smartphones have become ubiquitous in modern daily life.',
      'status': 'new',
      'interval': 0,
      'repetitions': 0,
      'ease_factor': 2.5,
      'next_review_date': DateTime.now().toIso8601String().split('T')[0],
      'created_at': DateTime.now().toIso8601String(),
    },
  ];

  // ---------------------------------------------------------------------------
  // FLASHCARDS TABLE OPERATIONS (DRIFT + SUPABASE - OFFLINE FIRST)
  // ---------------------------------------------------------------------------

  static Future<List<FlashcardModel>> getSavedCards() async {
    final String? uid = currentUserId;
    List<FlashcardModel> localCards = await appDatabase.getAllFlashcards(userId: uid);

    // If local DB is empty (first install / cold run), populate with default seed cards
    if (localCards.isEmpty) {
      final seedList = _seedCards.map((c) => FlashcardModel.fromMap(c).copyWith(userId: uid)).toList();
      await appDatabase.batchUpsertFlashcards(seedList);
      localCards = seedList;
    }

    // If in Guest Mode or not logged in, return local SQLite cards immediately
    if (uid == null) {
      return localCards;
    }

    final client = _client;
    if (client == null) {
      return localCards;
    }

    // Authenticated User: Attempt cloud sync with a 4s timeout
    try {
      final response = await client
          .from('flashcards')
          .select('*')
          .order('created_at', ascending: true)
          .timeout(const Duration(seconds: 4));

      if (response is List && response.isNotEmpty) {
        final cloudCards = response.map((row) => FlashcardModel.fromMap(row as Map<String, dynamic>)).toList();
        await appDatabase.batchUpsertFlashcards(cloudCards);
        return cloudCards;
      } else if (response is List && response.isEmpty) {
        // Cloud is empty for this user, seed/upload local cards to cloud in background
        saveCardsToSupabase(localCards).catchError((_) {});
        return localCards;
      }
    } catch (_) {
      // Offline, network error or timeout -> safely return local SQLite cards
    }

    return localCards;
  }

  static Future<void> saveCardsToSupabase(List<FlashcardModel> cards) async {
    final String? uid = currentUserId;
    final userCards = cards.map((c) => c.userId == null && uid != null ? c.copyWith(userId: uid) : c).toList();

    // 1. Always write to local SQLite database first
    await appDatabase.batchUpsertFlashcards(userCards);
    if (uid == null) return;

    final client = _client;
    if (client == null) return;

    // 2. Sync to Supabase in background with timeout protection
    try {
      final rows = userCards.map((c) => c.toSupabaseRow()).toList();
      await client
          .from('flashcards')
          .upsert(rows, onConflict: 'id')
          .timeout(const Duration(seconds: 4));
    } catch (_) {
      try {
        final rows = userCards.map((c) => c.toSupabaseRow()..remove('learning_step')).toList();
        await client
            .from('flashcards')
            .upsert(rows, onConflict: 'id')
            .timeout(const Duration(seconds: 4));
      } catch (_) {}
    }
  }

  static Future<void> upsertCard(FlashcardModel card) async {
    final String? uid = currentUserId;
    final targetCard = (card.userId == null && uid != null) ? card.copyWith(userId: uid) : card;

    // 1. Always write to local SQLite database first
    await appDatabase.upsertFlashcard(targetCard);
    if (uid == null) return;

    final client = _client;
    if (client == null) return;

    // 2. Sync to Supabase in background with timeout protection
    try {
      await client
          .from('flashcards')
          .upsert(targetCard.toSupabaseRow(), onConflict: 'id')
          .timeout(const Duration(seconds: 4));
    } catch (_) {
      try {
        final row = targetCard.toSupabaseRow()..remove('learning_step');
        await client
            .from('flashcards')
            .upsert(row, onConflict: 'id')
            .timeout(const Duration(seconds: 4));
      } catch (_) {}
    }
  }

  static Future<void> deleteCard(String cardId) async {
    // 1. Always delete from local SQLite database first
    await appDatabase.deleteFlashcard(cardId);
    final String? uid = currentUserId;
    if (uid == null) return;

    final client = _client;
    if (client == null) return;

    // 2. Sync deletion to Supabase with timeout protection
    try {
      await client
          .from('flashcards')
          .delete()
          .eq('id', cardId)
          .timeout(const Duration(seconds: 4));
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // SAVED READINGS TABLE OPERATIONS (DRIFT + SUPABASE - OFFLINE FIRST)
  // ---------------------------------------------------------------------------

  static Future<List<ReadingArticleModel>> getSavedReadings() async {
    final String? uid = currentUserId;
    final localReadings = await appDatabase.getAllReadingArticles(userId: uid);

    if (uid == null) {
      return localReadings;
    }

    final client = _client;
    if (client == null) {
      return localReadings;
    }

    // Authenticated User: Attempt cloud sync with timeout
    try {
      final response = await client
          .from('saved_readings')
          .select('*')
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 4));

      if (response is List && response.isNotEmpty) {
        final readings = response
            .map((row) => ReadingArticleModel.fromMap(row as Map<String, dynamic>))
            .toList();
        await appDatabase.batchUpsertReadingArticles(readings);
        return readings;
      }
    } catch (_) {
      // Offline, network error or timeout -> safely return local SQLite readings
    }

    return localReadings;
  }

  static Future<void> saveReadingArticle(ReadingArticleModel article) async {
    final String? uid = currentUserId;
    final targetArticle = (article.userId == null && uid != null) ? article.copyWith(userId: uid) : article;

    // 1. Always write to local SQLite database first
    await appDatabase.upsertReadingArticle(targetArticle);
    if (uid == null) return;

    final client = _client;
    if (client == null) return;

    // 2. Sync to Supabase in background with timeout protection
    try {
      await client
          .from('saved_readings')
          .upsert(targetArticle.toSupabaseRow(), onConflict: 'id')
          .timeout(const Duration(seconds: 4));
    } catch (_) {}
  }

  static Future<void> deleteReadingArticle(String articleId) async {
    // 1. Always delete from local SQLite database first
    await appDatabase.deleteReadingArticle(articleId);
    final String? uid = currentUserId;
    if (uid == null) return;

    final client = _client;
    if (client == null) return;

    // 2. Sync deletion to Supabase with timeout protection
    try {
      await client
          .from('saved_readings')
          .delete()
          .eq('id', articleId)
          .timeout(const Duration(seconds: 4));
    } catch (_) {}
  }
}
