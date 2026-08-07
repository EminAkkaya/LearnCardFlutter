import 'dart:convert';
import 'package:http/http.dart' as http;

class WordDefinitionResult {
  final String word;
  final String definition;
  final String trTranslation;
  final String phonetic;
  final String partOfSpeech;
  final String audioUrl;

  WordDefinitionResult({
    required this.word,
    required this.definition,
    required this.trTranslation,
    required this.phonetic,
    required this.partOfSpeech,
    required this.audioUrl,
  });
}

class DictionaryService {
  static final Map<String, WordDefinitionResult> _cache = {};

  /// Translates English text into Turkish using Google Translate GTX API with MyMemory fallback
  static Future<String> translateToTurkish(String text) async {
    if (text.trim().isEmpty) return '';
    final String clean = text.trim();

    // 1. Primary: Google Translate GTX endpoint
    try {
      final uri = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=tr&dt=t&q=${Uri.encodeComponent(clean)}',
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (data.isNotEmpty && data[0] is List) {
          final List parts = data[0];
          final String translatedStr = parts.map((item) => item[0]).join();
          if (translatedStr.isNotEmpty) {
            return translatedStr;
          }
        }
      }
    } catch (_) {}

    // 2. Fallback: MyMemory Translation API
    try {
      final fallbackUri = Uri.parse(
        'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(clean)}&langpair=en|tr',
      );
      final response = await http.get(fallbackUri);
      if (response.statusCode == 200) {
        final Map data = jsonDecode(response.body);
        final String? translatedText = data['responseData']?['translatedText'];
        if (translatedText != null && translatedText.isNotEmpty) {
          return translatedText;
        }
      }
    } catch (_) {}

    return 'Çeviri bulunamadı';
  }

  /// Fetches dictionary definitions, phonetics, audio, and Turkish translation
  static Future<WordDefinitionResult> fetchWordDefinition(String word) async {
    final String normalized = word.toLowerCase().trim();
    if (_cache.containsKey(normalized)) {
      return _cache[normalized]!;
    }

    final Future<String> trFuture = translateToTurkish(normalized);

    String definition = 'Tanım bulunamadı.';
    String phonetic = '';
    String partOfSpeech = '';
    String audioUrl = '';

    try {
      final uri = Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/${Uri.encodeComponent(normalized)}');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final Map entry = data[0];

          phonetic = entry['phonetic']?.toString() ?? '';
          if (phonetic.isEmpty && entry['phonetics'] is List) {
            for (final p in entry['phonetics']) {
              if (p['text'] != null && p['text'].toString().isNotEmpty) {
                phonetic = p['text'].toString();
                break;
              }
            }
          }

          if (entry['phonetics'] is List) {
            for (final p in entry['phonetics']) {
              final String? audio = p['audio']?.toString();
              if (audio != null && audio.isNotEmpty) {
                audioUrl = audio;
                break;
              }
            }
          }

          if (entry['meanings'] is List && (entry['meanings'] as List).isNotEmpty) {
            final Map meaning = entry['meanings'][0];
            partOfSpeech = meaning['partOfSpeech']?.toString() ?? '';
            if (meaning['definitions'] is List && (meaning['definitions'] as List).isNotEmpty) {
              definition = meaning['definitions'][0]['definition']?.toString() ?? '';
            }
          }
        }
      }
    } catch (_) {}

    final String trTranslation = await trFuture;

    final result = WordDefinitionResult(
      word: normalized,
      definition: definition,
      trTranslation: trTranslation,
      phonetic: phonetic,
      partOfSpeech: partOfSpeech,
      audioUrl: audioUrl,
    );

    _cache[normalized] = result;
    return result;
  }
}
