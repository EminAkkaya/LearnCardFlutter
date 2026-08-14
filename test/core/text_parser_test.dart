import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/core/utils/stop_words.dart';
import 'package:learncard_flutter/core/utils/text_parser.dart';

void main() {
  group('TextParser & StopWords Tests', () {
    test('1. StopWords list contains essential common English words and is non-empty', () {
      expect(stopWords, isNotEmpty);
      expect(stopWords.contains('the'), isTrue);
      expect(stopWords.contains('is'), isTrue);
      expect(stopWords.contains('and'), isTrue);
      expect(stopWords.contains('which'), isTrue);
      expect(stopWords.contains('between'), isTrue);
    });

    test('2. parseTextToTokens splits text into interactive word tokens and non-word separators', () {
      const input = "Hello, world! It's a sunny day.";
      final tokens = TextParser.parseTextToTokens(input);

      expect(tokens, isNotEmpty);

      // Verify words
      final wordTokens = tokens.where((t) => t.isWord).toList();
      expect(wordTokens.map((t) => t.cleanWord).toList(), containsAll([
        'hello',
        'world',
        "it's",
        'a',
        'sunny',
        'day',
      ]));

      // Verify punctuations / non-words
      final nonWordTokens = tokens.where((t) => !t.isWord).toList();
      expect(nonWordTokens.any((t) => t.text.contains(', ')), isTrue);
      expect(nonWordTokens.any((t) => t.text.contains('! ')), isTrue);
    });

    test('3. parseTextToTokens returns empty list on empty string input', () {
      expect(TextParser.parseTextToTokens(''), isEmpty);
    });

    test('4. extractSentence extracts the exact sentence matching the target word', () {
      const paragraph = "Spaced repetition helps you remember. Learning vocabulary takes patience. Serendipity is a wonderful concept.";

      final sentence1 = TextParser.extractSentence(paragraph, 'remember');
      expect(sentence1, equals('Spaced repetition helps you remember.'));

      final sentence2 = TextParser.extractSentence(paragraph, 'vocabulary');
      expect(sentence2, equals('Learning vocabulary takes patience.'));

      final sentence3 = TextParser.extractSentence(paragraph, 'Serendipity');
      expect(sentence3, equals('Serendipity is a wonderful concept.'));
    });

    test('5. extractSentence returns empty string for empty inputs', () {
      expect(TextParser.extractSentence('', 'word'), equals(''));
      expect(TextParser.extractSentence('Some text here.', ''), equals(''));
    });

    test('6. extractUniqueWords filters stop words and ranks words by occurrence frequency', () {
      const text = "Flutter is awesome. Flutter is fast. Developing apps with Flutter brings immense joy.";

      final extracted = TextParser.extractUniqueWords(
        text,
        filterStopWords: true,
        minWordLength: 3,
      );

      expect(extracted, isNotEmpty);

      // 'flutter' appears 3 times and is not a stop word
      final flutterItem = extracted.firstWhere((item) => item.word == 'flutter');
      expect(flutterItem.count, equals(3));
      expect(flutterItem.sentence, isNotEmpty);

      // Stop words like 'is', 'with' should be filtered out
      expect(extracted.any((item) => item.word == 'is'), isFalse);
      expect(extracted.any((item) => item.word == 'with'), isFalse);

      // List must be sorted in descending frequency order
      for (int i = 0; i < extracted.length - 1; i++) {
        expect(extracted[i].count, greaterThanOrEqualTo(extracted[i + 1].count));
      }
    });

    test('7. extractUniqueWords respects minWordLength threshold', () {
      const text = "Go to an ox at me on no.";
      final extracted = TextParser.extractUniqueWords(
        text,
        filterStopWords: false,
        minWordLength: 3,
      );

      // All words are 2 letters -> extracted list should be empty
      expect(extracted, isEmpty);
    });
  });
}
