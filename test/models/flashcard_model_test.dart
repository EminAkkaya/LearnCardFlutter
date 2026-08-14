import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/models/flashcard_model.dart';

void main() {
  group('FlashcardModel Tests', () {
    test('1. fromMap correctly parses standard Supabase snake_case map', () {
      final map = {
        'id': 'card_123',
        'word': 'resilient',
        'definition': 'Able to withstand or recover quickly from difficult conditions.',
        'tr_translation': 'Dirençli, esnek',
        'phonetic': '/rɪˈzɪl.jənt/',
        'part_of_speech': 'adjective',
        'example_sentence': 'She is resilient in the face of challenges.',
        'audio_url': 'https://api.dictionary.dev/audio/resilient.mp3',
        'status': 'learning',
        'interval': 6,
        'repetitions': 2,
        'learning_step': 2,
        'ease_factor': 2.6,
        'next_review_date': '2026-08-20T12:00:00.000Z',
        'created_at': '2026-08-14T10:00:00.000Z',
      };

      final model = FlashcardModel.fromMap(map);

      expect(model.id, equals('card_123'));
      expect(model.word, equals('resilient'));
      expect(model.definition, equals('Able to withstand or recover quickly from difficult conditions.'));
      expect(model.trTranslation, equals('Dirençli, esnek'));
      expect(model.phonetic, equals('/rɪˈzɪl.jənt/'));
      expect(model.partOfSpeech, equals('adjective'));
      expect(model.exampleSentence, equals('She is resilient in the face of challenges.'));
      expect(model.audioUrl, equals('https://api.dictionary.dev/audio/resilient.mp3'));
      expect(model.status, equals('learning'));
      expect(model.interval, equals(6));
      expect(model.repetitions, equals(2));
      expect(model.learningStep, equals(2));
      expect(model.easeFactor, equals(2.6));
      expect(model.nextReviewDate, equals('2026-08-20T12:00:00.000Z'));
      expect(model.createdAt, equals('2026-08-14T10:00:00.000Z'));
    });

    test('2. fromMap gracefully handles camelCase and string numbers', () {
      final map = {
        'id': 'card_456',
        'word': 'pragmatic',
        'trTranslation': 'Uygulamacı',
        'partOfSpeech': 'adj',
        'exampleSentence': 'A pragmatic approach.',
        'audioUrl': 'https://example.com/audio.mp3',
        'interval': '14',
        'repetitions': '3',
        'learningStep': '2',
        'easeFactor': '2.45',
      };

      final model = FlashcardModel.fromMap(map);

      expect(model.id, equals('card_456'));
      expect(model.word, equals('pragmatic'));
      expect(model.trTranslation, equals('Uygulamacı'));
      expect(model.partOfSpeech, equals('adj'));
      expect(model.exampleSentence, equals('A pragmatic approach.'));
      expect(model.audioUrl, equals('https://example.com/audio.mp3'));
      expect(model.interval, equals(14));
      expect(model.repetitions, equals(3));
      expect(model.learningStep, equals(2));
      expect(model.easeFactor, equals(2.45));
      expect(model.status, equals('new')); // default
    });

    test('3. fromMap handles null/missing fields with safe defaults', () {
      final map = <String, dynamic>{
        'word': 'serendipity',
      };

      final model = FlashcardModel.fromMap(map);

      expect(model.id, isEmpty);
      expect(model.word, equals('serendipity'));
      expect(model.definition, isEmpty);
      expect(model.trTranslation, isEmpty);
      expect(model.phonetic, isEmpty);
      expect(model.status, equals('new'));
      expect(model.interval, equals(0));
      expect(model.repetitions, equals(0));
      expect(model.learningStep, equals(0));
      expect(model.easeFactor, equals(2.5));
      expect(model.nextReviewDate, isNotEmpty);
      expect(model.createdAt, isNotEmpty);
    });

    test('4. toSupabaseRow serializes all fields into exact table schema', () {
      final model = FlashcardModel(
        id: 'card_789',
        word: 'ubiquitous',
        definition: 'Present everywhere',
        trTranslation: 'Her yerde bulunan',
        phonetic: '/juːˈbɪk.wɪ.təs/',
        partOfSpeech: 'adjective',
        exampleSentence: 'Smartphones are ubiquitous.',
        audioUrl: 'https://example.com/ubiquitous.mp3',
        status: 'mastered',
        interval: 30,
        repetitions: 5,
        learningStep: 2,
        easeFactor: 2.7,
        nextReviewDate: '2026-09-01T00:00:00.000Z',
        createdAt: '2026-08-01T00:00:00.000Z',
      );

      final row = model.toSupabaseRow();

      expect(row['id'], equals('card_789'));
      expect(row['word'], equals('ubiquitous'));
      expect(row['definition'], equals('Present everywhere'));
      expect(row['tr_translation'], equals('Her yerde bulunan'));
      expect(row['phonetic'], equals('/juːˈbɪk.wɪ.təs/'));
      expect(row['part_of_speech'], equals('adjective'));
      expect(row['example_sentence'], equals('Smartphones are ubiquitous.'));
      expect(row['audio_url'], equals('https://example.com/ubiquitous.mp3'));
      expect(row['status'], equals('mastered'));
      expect(row['interval'], equals(30));
      expect(row['repetitions'], equals(5));
      expect(row['learning_step'], equals(2));
      expect(row['ease_factor'], equals(2.7));
      expect(row['next_review_date'], equals('2026-09-01T00:00:00.000Z'));
      expect(row['created_at'], equals('2026-08-01T00:00:00.000Z'));
    });

    test('5. copyWith creates an immutable copy with selectively updated values', () {
      final original = FlashcardModel(
        id: 'c1',
        word: 'ephemeral',
        definition: 'Short-lived',
        trTranslation: 'Geçici',
        status: 'new',
        interval: 0,
        repetitions: 0,
        learningStep: 0,
        easeFactor: 2.5,
        nextReviewDate: '2026-08-14',
        createdAt: '2026-08-14',
      );

      final updated = original.copyWith(
        status: 'learning',
        interval: 1,
        repetitions: 1,
        easeFactor: 2.4,
      );

      expect(updated.id, equals(original.id));
      expect(updated.word, equals(original.word));
      expect(updated.definition, equals(original.definition));
      expect(updated.status, equals('learning'));
      expect(updated.interval, equals(1));
      expect(updated.repetitions, equals(1));
      expect(updated.easeFactor, equals(2.4));

      // Original instance remained unchanged
      expect(original.status, equals('new'));
      expect(original.interval, equals(0));
    });
  });
}
