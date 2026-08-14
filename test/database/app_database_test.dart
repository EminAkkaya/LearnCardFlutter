import 'dart:ffi';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/core/database/app_database.dart';
import 'package:learncard_flutter/models/flashcard_model.dart';
import 'package:learncard_flutter/models/reading_article_model.dart';
import 'package:sqlite3/open.dart';

void main() {
  setUpAll(() {
    if (Platform.isLinux) {
      open.overrideFor(OperatingSystem.linux, () {
        try {
          return DynamicLibrary.open('libsqlite3.so');
        } catch (_) {
          return DynamicLibrary.open('libsqlite3.so.0');
        }
      });
    }
  });

  late AppDatabase db;

  setUp(() {
    // Instantiate an in-memory SQLite database for isolated testing
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Drift AppDatabase - Flashcards Table Tests', () {
    test('1. Insert and retrieve flashcards correctly', () async {
      final card1 = FlashcardModel(
        id: 'card-1',
        word: 'serendipity',
        definition: 'Happy accident',
        trTranslation: 'Tesadüf',
        phonetic: '/ˌser.ənˈdɪp.ə.ti/',
        partOfSpeech: 'noun',
        exampleSentence: 'Finding this book was serendipity.',
        audioUrl: 'https://example.com/audio1.mp3',
        status: 'new',
        interval: 0,
        repetitions: 0,
        learningStep: 0,
        easeFactor: 2.5,
        nextReviewDate: '2026-08-14',
        createdAt: '2026-08-14T10:00:00.000Z',
      );

      await db.upsertFlashcard(card1);

      final cards = await db.getAllFlashcards();
      expect(cards.length, equals(1));
      expect(cards.first.id, equals('card-1'));
      expect(cards.first.word, equals('serendipity'));
      expect(cards.first.definition, equals('Happy accident'));
      expect(cards.first.trTranslation, equals('Tesadüf'));
      expect(cards.first.audioUrl, equals('https://example.com/audio1.mp3'));
      expect(cards.first.status, equals('new'));
    });

    test('2. Upsert updates existing flashcard without duplicating', () async {
      final card = FlashcardModel(
        id: 'card-10',
        word: 'ephemeral',
        definition: 'Short lived',
        trTranslation: 'Geçici',
        status: 'new',
        interval: 0,
        repetitions: 0,
        learningStep: 0,
        easeFactor: 2.5,
        nextReviewDate: '2026-08-14',
        createdAt: '2026-08-14T10:00:00.000Z',
      );

      await db.upsertFlashcard(card);

      final updatedCard = card.copyWith(
        status: 'learning',
        interval: 3,
        repetitions: 2,
        easeFactor: 2.3,
      );

      await db.upsertFlashcard(updatedCard);

      final cards = await db.getAllFlashcards();
      expect(cards.length, equals(1));
      expect(cards.first.id, equals('card-10'));
      expect(cards.first.status, equals('learning'));
      expect(cards.first.interval, equals(3));
      expect(cards.first.repetitions, equals(2));
      expect(cards.first.easeFactor, equals(2.3));
    });

    test('3. Batch upsert inserts multiple flashcards atomically', () async {
      final cards = [
        FlashcardModel(
          id: 'b1',
          word: 'resilient',
          nextReviewDate: '2026-08-14',
          createdAt: '2026-08-14T10:00:00.000Z',
        ),
        FlashcardModel(
          id: 'b2',
          word: 'ubiquitous',
          nextReviewDate: '2026-08-14',
          createdAt: '2026-08-14T10:01:00.000Z',
        ),
      ];

      await db.batchUpsertFlashcards(cards);

      final allCards = await db.getAllFlashcards();
      expect(allCards.length, equals(2));
      expect(allCards.map((c) => c.word), containsAll(['resilient', 'ubiquitous']));
    });

    test('4. Delete flashcard removes entry by ID', () async {
      final card = FlashcardModel(
        id: 'del-1',
        word: 'delete_me',
        nextReviewDate: '2026-08-14',
        createdAt: '2026-08-14',
      );

      await db.upsertFlashcard(card);
      expect((await db.getAllFlashcards()).length, equals(1));

      await db.deleteFlashcard('del-1');
      expect((await db.getAllFlashcards()), isEmpty);
    });
  });

  group('Drift AppDatabase - Reading Articles Table Tests', () {
    test('1. Insert, retrieve and order reading articles', () async {
      final article1 = ReadingArticleModel(
        id: 'art-1',
        title: 'Article 1',
        text: 'First text content',
        createdAt: '2026-08-14T09:00:00.000Z',
        folder: 'Genel',
      );

      final article2 = ReadingArticleModel(
        id: 'art-2',
        title: 'Article 2',
        text: 'Second text content',
        createdAt: '2026-08-14T10:00:00.000Z',
        folder: 'Teknoloji',
      );

      await db.upsertReadingArticle(article1);
      await db.upsertReadingArticle(article2);

      final articles = await db.getAllReadingArticles();
      expect(articles.length, equals(2));
      // Ordered descending by createdAt -> article2 first
      expect(articles.first.id, equals('art-2'));
      expect(articles.first.folder, equals('Teknoloji'));
      expect(articles.last.id, equals('art-1'));
    });

    test('2. Delete reading article removes target entry', () async {
      final article = ReadingArticleModel(
        id: 'art-del',
        title: 'To be deleted',
        text: 'Text',
        createdAt: '2026-08-14',
      );

      await db.upsertReadingArticle(article);
      expect((await db.getAllReadingArticles()).length, equals(1));

      await db.deleteReadingArticle('art-del');
      expect((await db.getAllReadingArticles()), isEmpty);
    });
  });

  group('Drift AppDatabase - AppPreferences Key-Value Tests', () {
    test('1. String preference set, get and remove', () async {
      expect(await db.getString('non_existent'), isNull);

      await db.setString('test_string', 'hello_drift');
      expect(await db.getString('test_string'), equals('hello_drift'));

      await db.removeKey('test_string');
      expect(await db.getString('test_string'), isNull);
    });

    test('2. Int and Double preferences persistence', () async {
      await db.setInt('app_color', 0xFF6366F1);
      expect(await db.getInt('app_color'), equals(0xFF6366F1));

      await db.setDouble('font_size', 22.5);
      expect(await db.getDouble('font_size'), equals(22.5));
    });

    test('3. Boolean preference persistence', () async {
      await db.setBool('is_dark', true);
      expect(await db.getBool('is_dark'), isTrue);

      await db.setBool('is_dark', false);
      expect(await db.getBool('is_dark'), isFalse);
    });

    test('4. StringList preference JSON persistence', () async {
      final folders = ['Genel', 'Makaleler', 'Teknoloji', 'Felsefe'];

      await db.setStringList('reader_folders', folders);

      final retrieved = await db.getStringList('reader_folders');
      expect(retrieved, isNotNull);
      expect(retrieved, equals(folders));
    });
  });
}
