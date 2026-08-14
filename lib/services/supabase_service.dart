import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/database/app_database.dart';
import '../models/flashcard_model.dart';
import '../models/reading_article_model.dart';

class SupabaseService {
  static SupabaseClient get _client => Supabase.instance.client;

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
  // FLASHCARDS TABLE OPERATIONS (DRIFT + SUPABASE)
  // ---------------------------------------------------------------------------

  static Future<List<FlashcardModel>> getSavedCards() async {
    List<FlashcardModel> localCards = await appDatabase.getAllFlashcards();

    try {
      final List<dynamic> data = await _client
          .from('flashcards')
          .select('*')
          .order('created_at', ascending: true);

      if (data.isNotEmpty) {
        final cards = data.map((row) => FlashcardModel.fromMap(row as Map<String, dynamic>)).toList();
        await appDatabase.batchUpsertFlashcards(cards);
        return cards;
      } else {
        if (localCards.isEmpty) {
          localCards = _seedCards.map((c) => FlashcardModel.fromMap(c)).toList();
        }
        await saveCardsToSupabase(localCards);
        return localCards;
      }
    } catch (_) {}

    if (localCards.isEmpty) {
      localCards = _seedCards.map((c) => FlashcardModel.fromMap(c)).toList();
      await appDatabase.batchUpsertFlashcards(localCards);
    }
    return localCards;
  }

  static Future<void> saveCardsToSupabase(List<FlashcardModel> cards) async {
    await appDatabase.batchUpsertFlashcards(cards);
    try {
      final rows = cards.map((c) => c.toSupabaseRow()).toList();
      await _client.from('flashcards').upsert(rows, onConflict: 'id');
    } catch (_) {
      try {
        final rows = cards.map((c) => c.toSupabaseRow()..remove('learning_step')).toList();
        await _client.from('flashcards').upsert(rows, onConflict: 'id');
      } catch (_) {}
    }
  }

  static Future<void> upsertCard(FlashcardModel card) async {
    await appDatabase.upsertFlashcard(card);

    try {
      await _client.from('flashcards').upsert(card.toSupabaseRow(), onConflict: 'id');
    } catch (_) {
      try {
        final row = card.toSupabaseRow()..remove('learning_step');
        await _client.from('flashcards').upsert(row, onConflict: 'id');
      } catch (_) {}
    }
  }

  static Future<void> deleteCard(String cardId) async {
    await appDatabase.deleteFlashcard(cardId);

    try {
      await _client.from('flashcards').delete().eq('id', cardId);
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // SAVED READINGS TABLE OPERATIONS (DRIFT + SUPABASE)
  // ---------------------------------------------------------------------------

  static Future<List<ReadingArticleModel>> getSavedReadings() async {
    try {
      final List<dynamic> data = await _client
          .from('saved_readings')
          .select('*')
          .order('created_at', ascending: false);

      final readings = data.map((row) => ReadingArticleModel.fromMap(row as Map<String, dynamic>)).toList();
      await appDatabase.batchUpsertReadingArticles(readings);
      return readings;
    } catch (_) {}

    return await appDatabase.getAllReadingArticles();
  }

  static Future<void> saveReadingArticle(ReadingArticleModel article) async {
    await appDatabase.upsertReadingArticle(article);

    try {
      await _client.from('saved_readings').upsert(article.toSupabaseRow(), onConflict: 'id');
    } catch (_) {}
  }

  static Future<void> deleteReadingArticle(String articleId) async {
    await appDatabase.deleteReadingArticle(articleId);

    try {
      await _client.from('saved_readings').delete().eq('id', articleId);
    } catch (_) {}
  }
}
