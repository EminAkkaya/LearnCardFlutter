import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/offline_entry.dart';
import 'definition_picker.dart';
import 'offline_dictionary.dart';

class WordDefinitionResult {
  final String word;
  final String definition;
  final String trTranslation;
  final String phonetic;
  final String partOfSpeech;
  final String audioUrl;

  /// API'nin tüm anlamları; [forSense] doğru anlamı bunlardan seçer.
  final List<ApiMeaning> meanings;

  WordDefinitionResult({
    required this.word,
    required this.definition,
    required this.trTranslation,
    required this.phonetic,
    required this.partOfSpeech,
    required this.audioUrl,
    this.meanings = const [],
  });

  WordDefinitionResult _copy({String? definition, String? trTranslation, String? partOfSpeech}) =>
      WordDefinitionResult(
        word: word,
        definition: definition ?? this.definition,
        trTranslation: trTranslation ?? this.trTranslation,
        phonetic: phonetic,
        partOfSpeech: partOfSpeech ?? this.partOfSpeech,
        audioUrl: audioUrl,
        meanings: meanings,
      );

  WordDefinitionResult withTranslation(String tr) => _copy(trTranslation: tr);

  /// Tanımı ve türü çevrimdışı sözlükteki anlama göre seçer; anlam yoksa aynısı.
  WordDefinitionResult forSense(OfflineSense? sense) {
    if (sense == null) return this;
    final picked = pickDefinition(meanings, pos: sense.pos, gloss: sense.sense);
    if (picked == null) return this;
    return _copy(definition: picked.definition, partOfSpeech: picked.partOfSpeech);
  }
}

class DictionaryService {
  static final Map<String, WordDefinitionResult> _cache = {};
  static const String notFoundText = 'Çeviri bulunamadı';

  /// Translates English text into Turkish using Google Translate GTX API with MyMemory fallback
  static Future<String> translateToTurkish(String text) async {
    if (text.trim().isEmpty) return '';
    final String clean = text.trim();

    // 1. Primary: Google Translate GTX endpoint
    try {
      final uri = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=tr&dt=t&q=${Uri.encodeComponent(clean)}',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 4));
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
      final response = await http.get(fallbackUri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final Map data = jsonDecode(response.body);
        final String? translatedText = data['responseData']?['translatedText'];
        if (translatedText != null && translatedText.isNotEmpty) {
          return translatedText;
        }
      }
    } catch (_) {}

    return notFoundText;
  }

  /// Tanım, okunuş, ses ve Türkçe çeviri. Çeviri önce [offline] sözlükten alınır;
  /// orada yoksa çevrimiçi servise gidilir.
  static Future<WordDefinitionResult> fetchWordDefinition(String word, {OfflineDictionary? offline}) async {
    final entry = offline?.lookup(word);
    final offlineTr = entry?.primaryTranslation;
    final trFuture = offlineTr != null ? Future.value(offlineTr) : translateToTurkish(word.toLowerCase().trim());
    final details = await fetchEnglishDetails(word);
    return details.forSense(entry?.senses.first).withTranslation(await trFuture);
  }

  /// Yalnız İngilizce bilgiler (tanım, okunuş, tür, ses); çeviri boş döner.
  static Future<WordDefinitionResult> fetchEnglishDetails(String word) async {
    final String normalized = word.toLowerCase().trim();
    if (_cache.containsKey(normalized)) {
      return _cache[normalized]!;
    }

    String definition = 'Tanım bulunamadı.';
    String phonetic = '';
    String partOfSpeech = '';
    String audioUrl = '';
    final meanings = <ApiMeaning>[];

    try {
      final uri = Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/${Uri.encodeComponent(normalized)}');
      final response = await http.get(uri).timeout(const Duration(seconds: 4));
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

          // Birden çok sözcük girdisi (ör. "waves" hem "wave" hem "waive") olabilir.
          for (final e in data) {
            if (e is! Map || e['meanings'] is! List) continue;
            for (final m in e['meanings']) {
              if (m is! Map || m['definitions'] is! List) continue;
              meanings.add(ApiMeaning(
                partOfSpeech: m['partOfSpeech']?.toString() ?? '',
                definitions: [
                  for (final d in m['definitions'])
                    if (d is Map && d['definition'] != null) d['definition'].toString(),
                ],
              ));
            }
          }
          final first = pickDefinition(meanings);
          if (first != null) {
            definition = first.definition;
            partOfSpeech = first.partOfSpeech;
          }
        }
      }
    } catch (_) {}

    final result = WordDefinitionResult(
      word: normalized,
      definition: definition,
      trTranslation: '',
      phonetic: phonetic,
      partOfSpeech: partOfSpeech,
      audioUrl: audioUrl,
      meanings: meanings,
    );

    _cache[normalized] = result;
    return result;
  }
}
