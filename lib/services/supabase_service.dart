import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/database/app_database.dart';
import '../models/flashcard_model.dart';
import '../models/reading_article_model.dart';
import 'auth_service.dart';
import 'srs_service.dart';
import 'sync/drift_sync_store.dart';
import 'sync/supabase_remote_store.dart';
import 'sync/sync_engine.dart';
import 'sync/sync_stores.dart';
import 'seed_gate.dart';

/// Yerel liste ve onu üreten eşitleme turunun sonucu.
typedef SyncedList<T> = ({List<T> items, SyncResult sync});

class SupabaseService {
  static SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  static String? get currentUserId => AuthService.currentUserId;

  static String _nowIso() => DateTime.now().toUtc().toIso8601String();

  static SupabaseClient? _engineClient;
  static SyncEngine<FlashcardModel>? _cardEngineCache;
  static SyncEngine<ReadingArticleModel>? _readingEngineCache;

  /// Bulut kullanılamıyorsa (Supabase başlatılmamış) null.
  static SupabaseClient? _clientForEngines() {
    final client = _client;
    if (!identical(client, _engineClient)) {
      _engineClient = client;
      _cardEngineCache = null;
      _readingEngineCache = null;
    }
    return client;
  }

  static SyncEngine<FlashcardModel>? get _cardEngine {
    final client = _clientForEngines();
    if (client == null) return null;
    return _cardEngineCache ??= SyncEngine(
      local: flashcardSyncStore(appDatabase),
      remote: SupabaseRemoteStore<FlashcardModel>(
        client: client,
        table: 'flashcards',
        fromRow: FlashcardModel.fromMap,
        toRow: (card) => card.toSupabaseRow(),
        optionalColumns: const ['learning_step', 'updated_at'],
      ),
    );
  }

  static SyncEngine<ReadingArticleModel>? get _readingEngine {
    final client = _clientForEngines();
    if (client == null) return null;
    return _readingEngineCache ??= SyncEngine(
      local: readingSyncStore(appDatabase),
      remote: SupabaseRemoteStore<ReadingArticleModel>(
        client: client,
        table: 'saved_readings',
        fromRow: ReadingArticleModel.fromMap,
        toRow: (article) => article.toSupabaseRow(),
        optionalColumns: const ['updated_at'],
      ),
    );
  }

  static SyncResult _report(String what, SyncResult result) {
    if (result.hasErrors) {
      debugPrint('[sync] $what: ${result.errorMessage}');
    }
    return result;
  }

  static final SeedGate _seedGate = SeedGate();

  static final List<Map<String, dynamic>> _seedCards = [
    {
      'id': 'seed-1',
      'word': 'serendipity',
      'definition':
          'The occurrence and development of events by chance in a happy or beneficial way.',
      'tr_translation': 'tesadüf, şans eseri güzel bir şey bulma',
      'phonetic': '/ˌser.ənˈdɪp.ə.ti/',
      'part_of_speech': 'noun',
      'example_sentence':
          'Finding this wonderful book in a second-hand shop was pure serendipity.',
      'status': 'new',
      'interval': 0,
      'repetitions': 0,
      'ease_factor': 2.5,
      'next_review_date': SRSService.formatReviewDate(DateTime.now()),
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'id': 'seed-2',
      'word': 'ephemeral',
      'definition': 'Lasting for a very short time; fleeting or transitory.',
      'tr_translation': 'gelip geçici, kısa ömürlü',
      'phonetic': '/ɪˈfem.ər.əl/',
      'part_of_speech': 'adjective',
      'example_sentence':
          'Fame in the digital age can often be surprisingly ephemeral.',
      'status': 'new',
      'interval': 0,
      'repetitions': 0,
      'ease_factor': 2.5,
      'next_review_date': SRSService.formatReviewDate(DateTime.now()),
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'id': 'seed-3',
      'word': 'resilient',
      'definition':
          'Able to withstand or recover quickly from difficult conditions.',
      'tr_translation': 'dayanıklı, dirençli, esnek',
      'phonetic': '/rɪˈzɪl.jənt/',
      'part_of_speech': 'adjective',
      'example_sentence':
          'The team showed a resilient spirit after their initial setback.',
      'status': 'new',
      'interval': 0,
      'repetitions': 0,
      'ease_factor': 2.5,
      'next_review_date': SRSService.formatReviewDate(DateTime.now()),
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'id': 'seed-4',
      'word': 'ubiquitous',
      'definition': 'Present, appearing, or found everywhere at the same time.',
      'tr_translation': 'her yerde bulunan, yaygın',
      'phonetic': '/juːˈbɪk.wə.təs/',
      'part_of_speech': 'adjective',
      'example_sentence':
          'Smartphones have become ubiquitous in modern daily life.',
      'status': 'new',
      'interval': 0,
      'repetitions': 0,
      'ease_factor': 2.5,
      'next_review_date': SRSService.formatReviewDate(DateTime.now()),
      'created_at': DateTime.now().toIso8601String(),
    },
  ];

  // ---------------------------------------------------------------------------
  // FLASHCARDS (DRIFT + SUPABASE - OFFLINE FIRST)
  // ---------------------------------------------------------------------------

  /// Giriş yapılmışsa önce eşitler, sonra yerel kartları döner. Çevrimdışıyken
  /// veya Supabase yoksa yerel veri olduğu gibi döner.
  static Future<SyncedList<FlashcardModel>> getSavedCards() async {
    final String? uid = currentUserId;
    final engine = uid == null ? null : _cardEngine;
    var result = SyncResult.skipped;
    if (uid != null && engine != null) {
      result = _report('flashcards', await engine.sync(uid));
    }

    var cards = await appDatabase.getAllFlashcards(userId: uid);
    if (cards.isEmpty) {
      cards = await _seedGate.fillIfEmpty(
        read: () => appDatabase.getAllFlashcards(userId: uid),
        seed: () => _insertSeedCards(uid, uploadable: result.pullSucceeded),
      );
    }
    return (items: cards, sync: result);
  }

  /// Boş desteye örnek kartları ekler. Hesap için bulutun da boş olduğu
  /// biliniyorsa ([uploadable]) kartlar yüklenir; aksi halde temiz yazılır ve
  /// bulutta karşılığı yoksa sonraki eşitlemede kaldırılır.
  static Future<void> _insertSeedCards(String? uid, {required bool uploadable}) async {
    final seeds = <FlashcardModel>[
      for (var i = 0; i < _seedCards.length; i++)
        FlashcardModel.fromMap(_seedCards[i]).copyWith(
          id: 'seed-${i + 1}-${const Uuid().v4().substring(0, 8)}',
          userId: uid,
        ),
    ];
    if (uid != null && uploadable) {
      await saveCardsToSupabase(seeds);
      return;
    }
    await appDatabase.batchUpsertFlashcards([
      for (final card in seeds)
        uid == null ? card : card.copyWith(updatedAt: kUnknownSyncTime),
    ]);
  }

  /// Verilen kartları yerel düzenleme olarak yazar ve yalnız kirli satırları
  /// buluta gönderir (tüm desteyi değil).
  static Future<SyncResult> saveCardsToSupabase(List<FlashcardModel> cards) async {
    if (cards.isEmpty) return SyncResult.skipped;
    final String? uid = currentUserId;
    final now = _nowIso();
    await appDatabase.saveLocalFlashcardEdits([
      for (final c in cards) c.copyWith(userId: c.userId ?? uid, updatedAt: now),
    ]);
    return _pushCards(uid);
  }

  static Future<SyncResult> upsertCard(FlashcardModel card) {
    return saveCardsToSupabase([card]);
  }

  /// Yumuşak siler; bulutta silinince yerelden de kalıcı kaldırılır.
  static Future<SyncResult> deleteCard(String cardId) async {
    await appDatabase.markFlashcardDeleted(cardId, _nowIso());
    return _pushCards(currentUserId);
  }

  static Future<SyncResult> _pushCards(String? uid) async {
    final engine = uid == null ? null : _cardEngine;
    if (uid == null || engine == null) return SyncResult.skipped;
    return _report('flashcards push', await engine.push(uid));
  }

  // ---------------------------------------------------------------------------
  // SAVED READINGS (DRIFT + SUPABASE - OFFLINE FIRST)
  // ---------------------------------------------------------------------------

  static Future<SyncedList<ReadingArticleModel>> getSavedReadings() async {
    final String? uid = currentUserId;
    final engine = uid == null ? null : _readingEngine;
    var result = SyncResult.skipped;
    if (uid != null && engine != null) {
      result = _report('readings', await engine.sync(uid));
    }
    final readings = await appDatabase.getAllReadingArticles(userId: uid);
    return (items: readings, sync: result);
  }

  static Future<SyncResult> saveReadingArticles(List<ReadingArticleModel> articles) async {
    if (articles.isEmpty) return SyncResult.skipped;
    final String? uid = currentUserId;
    final now = _nowIso();
    await appDatabase.saveLocalArticleEdits([
      for (final a in articles) a.copyWith(userId: a.userId ?? uid, updatedAt: now),
    ]);
    return _pushReadings(uid);
  }

  static Future<SyncResult> saveReadingArticle(ReadingArticleModel article) {
    return saveReadingArticles([article]);
  }

  static Future<SyncResult> deleteReadingArticle(String articleId) async {
    await appDatabase.markArticleDeleted(articleId, _nowIso());
    return _pushReadings(currentUserId);
  }

  static Future<SyncResult> _pushReadings(String? uid) async {
    final engine = uid == null ? null : _readingEngine;
    if (uid == null || engine == null) return SyncResult.skipped;
    return _report('readings push', await engine.push(uid));
  }
}
