import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/models/reading_article_model.dart';

void main() {
  group('ReadingArticleModel Tests', () {
    test('1. fromMap parses complete row and sets custom folder', () {
      final map = {
        'id': 'art_001',
        'title': 'The Science of Spaced Repetition',
        'text': 'Spaced repetition is an evidence-based learning technique...',
        'created_at': '2026-08-10T12:00:00.000Z',
        'folder': 'Bilim',
      };

      final article = ReadingArticleModel.fromMap(map);

      expect(article.id, equals('art_001'));
      expect(article.title, equals('The Science of Spaced Repetition'));
      expect(article.text, contains('Spaced repetition is an evidence-based'));
      expect(article.createdAt, equals('2026-08-10T12:00:00.000Z'));
      expect(article.folder, equals('Bilim'));
    });

    test('2. fromMap defaults to "Genel" folder if folder is null, empty, or whitespace', () {
      final mapNullFolder = {
        'id': 'art_002',
        'title': 'Empty Folder Test',
        'text': 'Some content...',
      };

      final articleNull = ReadingArticleModel.fromMap(mapNullFolder);
      expect(articleNull.folder, equals('Genel'));

      final mapWhitespaceFolder = {
        'id': 'art_003',
        'title': 'Whitespace Folder',
        'text': 'Some content...',
        'folder': '   ',
      };

      final articleWhitespace = ReadingArticleModel.fromMap(mapWhitespaceFolder);
      expect(articleWhitespace.folder, equals('Genel'));
    });

    test('3. toSupabaseRow matches database schema', () {
      final article = ReadingArticleModel(
        id: 'art_100',
        title: 'Quantum Computing Intro',
        text: 'Qubits represent information differently.',
        createdAt: '2026-08-14T10:00:00.000Z',
        folder: 'Teknoloji',
      );

      final row = article.toSupabaseRow();

      expect(row['id'], equals('art_100'));
      expect(row['title'], equals('Quantum Computing Intro'));
      expect(row['text'], equals('Qubits represent information differently.'));
      expect(row['created_at'], equals('2026-08-14T10:00:00.000Z'));
      expect(row['folder'], equals('Teknoloji'));
    });

    test('4. copyWith allows non-destructive updates', () {
      final original = ReadingArticleModel(
        id: 'art_200',
        title: 'Original Title',
        text: 'Original Text',
        createdAt: '2026-08-14',
        folder: 'Genel',
      );

      final updated = original.copyWith(
        title: 'New Title',
        folder: 'Makaleler',
      );

      expect(updated.id, equals(original.id));
      expect(updated.text, equals(original.text));
      expect(updated.title, equals('New Title'));
      expect(updated.folder, equals('Makaleler'));
      expect(original.title, equals('Original Title'));
    });
  });
}
