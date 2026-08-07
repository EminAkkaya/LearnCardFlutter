import 'stop_words.dart';

class TextToken {
  final String id;
  final String text;
  final bool isWord;
  final String cleanWord;

  TextToken({
    required this.id,
    required this.text,
    required this.isWord,
    required this.cleanWord,
  });
}

class ExtractedWordItem {
  final String word;
  int count;
  final String sentence;

  ExtractedWordItem({
    required this.word,
    required this.count,
    required this.sentence,
  });
}

class TextParser {
  /// Tokenizes raw text into interactive word tokens and non-word spacers
  static List<TextToken> parseTextToTokens(String text) {
    if (text.isEmpty) return [];

    final RegExp regex = RegExp(r"([a-zA-Z']+)|([^a-zA-Z']+)");
    final Iterable<RegExpMatch> matches = regex.allMatches(text);

    final List<TextToken> tokens = [];
    int index = 0;

    for (final match in matches) {
      final String rawMatch = match.group(0) ?? '';
      final bool isWord = RegExp(r"^[a-zA-Z']+$").hasMatch(rawMatch);
      final String clean = isWord
          ? rawMatch.toLowerCase().replaceAll(RegExp(r"^'+|'+$"), '')
          : '';

      tokens.add(
        TextToken(
          id: 'token_$index',
          text: rawMatch,
          isWord: isWord && clean.isNotEmpty,
          cleanWord: clean,
        ),
      );
      index++;
    }

    return tokens;
  }

  /// Extracts the sentence containing the target word from text
  static String extractSentence(String text, String clickedWord) {
    if (text.isEmpty || clickedWord.isEmpty) return '';

    final List<String> sentences = text
        .split(RegExp(r'(?<=[.!?\n])\s+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final String cleanTarget = clickedWord.toLowerCase().trim();
    final RegExp wordRegex = RegExp('\\b${RegExp.escape(cleanTarget)}\\b', caseSensitive: false);

    for (final sentence in sentences) {
      if (wordRegex.hasMatch(sentence)) {
        return sentence.replaceAll(RegExp(r'\s+'), ' ').trim();
      }
    }

    return text.length > 100 ? text.substring(0, 100).trim() : text.trim();
  }

  /// Extracts unique words from text with frequency counts and sample sentences
  static List<ExtractedWordItem> extractUniqueWords(
    String text, {
    bool filterStopWords = true,
    int minWordLength = 3,
  }) {
    if (text.isEmpty) return [];

    final RegExp sentenceRegex = RegExp(r'[^.!?\n]+[.!?\n]+');
    final Iterable<RegExpMatch> rawSentences = sentenceRegex.allMatches(text);
    final List<String> sentences = rawSentences.isNotEmpty
        ? rawSentences.map((m) => m.group(0)!.trim()).where((s) => s.isNotEmpty).toList()
        : [text.trim()];

    final Map<String, ExtractedWordItem> wordMap = {};

    for (final sentence in sentences) {
      final Iterable<RegExpMatch> tokens = RegExp(r"\b[a-zA-Z']+\b").allMatches(sentence.toLowerCase());
      for (final match in tokens) {
        String token = match.group(0) ?? '';
        token = token.replaceAll(RegExp(r"^'+|'+$"), '');

        if (token.length < minWordLength) continue;
        if (filterStopWords && stopWords.contains(token)) continue;

        if (wordMap.containsKey(token)) {
          wordMap[token]!.count += 1;
        } else {
          wordMap[token] = ExtractedWordItem(
            word: token,
            count: 1,
            sentence: sentence.replaceAll(RegExp(r'\s+'), ' ').trim(),
          );
        }
      }
    }

    final List<ExtractedWordItem> result = wordMap.values.toList();
    result.sort((a, b) => b.count.compareTo(a.count));
    return result;
  }
}
