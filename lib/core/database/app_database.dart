import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/flashcard_model.dart';
import '../../models/reading_article_model.dart';

part 'app_database.g.dart';

// -----------------------------------------------------------------------------
// 1. TABLES
// -----------------------------------------------------------------------------

@DataClassName('FlashcardEntry')
class FlashcardEntries extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get word => text()();
  TextColumn get definition => text().withDefault(const Constant(''))();
  TextColumn get trTranslation => text().withDefault(const Constant(''))();
  TextColumn get phonetic => text().withDefault(const Constant(''))();
  TextColumn get partOfSpeech => text().withDefault(const Constant(''))();
  TextColumn get exampleSentence => text().withDefault(const Constant(''))();
  TextColumn get audioUrl => text().withDefault(const Constant(''))();
  TextColumn get status => text().withDefault(const Constant('new'))();
  IntColumn get interval => integer().withDefault(const Constant(0))();
  IntColumn get repetitions => integer().withDefault(const Constant(0))();
  IntColumn get learningStep => integer().withDefault(const Constant(0))();
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();
  TextColumn get nextReviewDate => text()();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ReadingArticleEntry')
class ReadingArticleEntries extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get textContent => text()();
  TextColumn get createdAt => text()();
  TextColumn get folder => text().withDefault(const Constant('Genel'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AppPreferenceEntry')
class AppPreferenceEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

// -----------------------------------------------------------------------------
// 2. DATABASE IMPLEMENTATION
// -----------------------------------------------------------------------------

@DriftDatabase(tables: [FlashcardEntries, ReadingArticleEntries, AppPreferenceEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(flashcardEntries, flashcardEntries.userId);
          await m.addColumn(readingArticleEntries, readingArticleEntries.userId);
        }
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'learncard_drift_db');
  }

  // ---------------------------------------------------------------------------
  // FLASHCARD OPERATIONS
  // ---------------------------------------------------------------------------

  Future<List<FlashcardModel>> getAllFlashcards({String? userId}) async {
    final query = select(flashcardEntries);
    if (userId != null && userId.isNotEmpty) {
      query.where((t) => t.userId.equals(userId) | t.userId.isNull());
    }
    query.orderBy([(t) => OrderingTerm(expression: t.createdAt)]);
    final rows = await query.get();
    return rows.map(_mapEntryToFlashcard).toList();
  }

  Future<void> upsertFlashcard(FlashcardModel card) async {
    await into(flashcardEntries).insertOnConflictUpdate(_mapFlashcardToCompanion(card));
  }

  Future<void> batchUpsertFlashcards(List<FlashcardModel> cards) async {
    await batch((batch) {
      for (final card in cards) {
        batch.insert(
          flashcardEntries,
          _mapFlashcardToCompanion(card),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> deleteFlashcard(String id) async {
    await (delete(flashcardEntries)..where((t) => t.id.equals(id))).go();
  }

  Future<void> clearAllFlashcards({String? userId}) async {
    if (userId != null && userId.isNotEmpty) {
      await (delete(flashcardEntries)..where((t) => t.userId.equals(userId))).go();
    } else {
      await delete(flashcardEntries).go();
    }
  }

  FlashcardModel _mapEntryToFlashcard(FlashcardEntry row) {
    return FlashcardModel(
      id: row.id,
      userId: row.userId,
      word: row.word,
      definition: row.definition,
      trTranslation: row.trTranslation,
      phonetic: row.phonetic,
      partOfSpeech: row.partOfSpeech,
      exampleSentence: row.exampleSentence,
      audioUrl: row.audioUrl,
      status: row.status,
      interval: row.interval,
      repetitions: row.repetitions,
      learningStep: row.learningStep,
      easeFactor: row.easeFactor,
      nextReviewDate: row.nextReviewDate,
      createdAt: row.createdAt,
    );
  }

  FlashcardEntriesCompanion _mapFlashcardToCompanion(FlashcardModel card) {
    return FlashcardEntriesCompanion(
      id: Value(card.id),
      userId: Value(card.userId),
      word: Value(card.word),
      definition: Value(card.definition),
      trTranslation: Value(card.trTranslation),
      phonetic: Value(card.phonetic),
      partOfSpeech: Value(card.partOfSpeech),
      exampleSentence: Value(card.exampleSentence),
      audioUrl: Value(card.audioUrl),
      status: Value(card.status),
      interval: Value(card.interval),
      repetitions: Value(card.repetitions),
      learningStep: Value(card.learningStep),
      easeFactor: Value(card.easeFactor),
      nextReviewDate: Value(card.nextReviewDate),
      createdAt: Value(card.createdAt),
    );
  }

  // ---------------------------------------------------------------------------
  // READING ARTICLE OPERATIONS
  // ---------------------------------------------------------------------------

  Future<List<ReadingArticleModel>> getAllReadingArticles({String? userId}) async {
    final query = select(readingArticleEntries);
    if (userId != null && userId.isNotEmpty) {
      query.where((t) => t.userId.equals(userId) | t.userId.isNull());
    }
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    final rows = await query.get();
    return rows.map(_mapEntryToArticle).toList();
  }

  Future<void> upsertReadingArticle(ReadingArticleModel article) async {
    await into(readingArticleEntries).insertOnConflictUpdate(_mapArticleToCompanion(article));
  }

  Future<void> batchUpsertReadingArticles(List<ReadingArticleModel> articles) async {
    await batch((batch) {
      for (final article in articles) {
        batch.insert(
          readingArticleEntries,
          _mapArticleToCompanion(article),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> deleteReadingArticle(String id) async {
    await (delete(readingArticleEntries)..where((t) => t.id.equals(id))).go();
  }

  Future<void> clearAllReadingArticles({String? userId}) async {
    if (userId != null && userId.isNotEmpty) {
      await (delete(readingArticleEntries)..where((t) => t.userId.equals(userId))).go();
    } else {
      await delete(readingArticleEntries).go();
    }
  }

  ReadingArticleModel _mapEntryToArticle(ReadingArticleEntry row) {
    return ReadingArticleModel(
      id: row.id,
      userId: row.userId,
      title: row.title,
      text: row.textContent,
      createdAt: row.createdAt,
      folder: row.folder,
    );
  }

  ReadingArticleEntriesCompanion _mapArticleToCompanion(ReadingArticleModel article) {
    return ReadingArticleEntriesCompanion(
      id: Value(article.id),
      userId: Value(article.userId),
      title: Value(article.title),
      textContent: Value(article.text),
      createdAt: Value(article.createdAt),
      folder: Value(article.folder),
    );
  }

  // ---------------------------------------------------------------------------
  // APP PREFERENCES KEY-VALUE STORE (SHARED_PREFERENCES REPLACEMENT)
  // ---------------------------------------------------------------------------

  Future<String?> getString(String key) async {
    final row = await (select(appPreferenceEntries)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> setString(String key, String value) async {
    await into(appPreferenceEntries).insertOnConflictUpdate(
      AppPreferenceEntriesCompanion(
        key: Value(key),
        value: Value(value),
      ),
    );
  }

  Future<int?> getInt(String key) async {
    final str = await getString(key);
    if (str == null) return null;
    return int.tryParse(str);
  }

  Future<void> setInt(String key, int value) async {
    await setString(key, value.toString());
  }

  Future<double?> getDouble(String key) async {
    final str = await getString(key);
    if (str == null) return null;
    return double.tryParse(str);
  }

  Future<void> setDouble(String key, double value) async {
    await setString(key, value.toString());
  }

  Future<bool?> getBool(String key) async {
    final str = await getString(key);
    if (str == null) return null;
    return str.toLowerCase() == 'true';
  }

  Future<void> setBool(String key, bool value) async {
    await setString(key, value.toString());
  }

  Future<List<String>?> getStringList(String key) async {
    final str = await getString(key);
    if (str == null || str.isEmpty) return null;
    try {
      final List decoded = jsonDecode(str);
      return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> setStringList(String key, List<String> value) async {
    final encoded = jsonEncode(value);
    await setString(key, encoded);
  }

  Future<void> removeKey(String key) async {
    await (delete(appPreferenceEntries)..where((t) => t.key.equals(key))).go();
  }
}

// -----------------------------------------------------------------------------
// 3. SINGLETON & PROVIDER
// -----------------------------------------------------------------------------

final appDatabase = AppDatabase();

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return appDatabase;
});
