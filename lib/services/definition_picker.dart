/// dictionaryapi.dev'in bir kelime türü altındaki tanımları (API sırasıyla).
class ApiMeaning {
  final String partOfSpeech;
  final List<String> definitions;

  const ApiMeaning({required this.partOfSpeech, required this.definitions});
}

/// Seçilen tanım ve ait olduğu kelime türü.
typedef PickedDefinition = ({String definition, String partOfSpeech});

/// API anlamları Wiktionary sırasıyla gelir; ilk sırada eski ya da nadir bir
/// anlam olabilir ("waves" → "waive", "brief" → mahkeme celbi). Bu yüzden
/// tanım, çevrimdışı sözlükteki anlamın türüne ([pos]) ve kısa açıklamasına
/// ([gloss]) en çok uyan anlamdan seçilir. Hiçbir ipucu tutmazsa API'nin ilk
/// tanımı döner.
PickedDefinition? pickDefinition(List<ApiMeaning> meanings, {String pos = '', String gloss = ''}) {
  final usable = [
    for (final m in meanings)
      if (m.definitions.any((d) => d.trim().isNotEmpty)) m,
  ];
  if (usable.isEmpty) return null;

  final apiPos = _apiPos[pos] ?? pos;
  final samePos = usable.where((m) => m.partOfSpeech == apiPos).toList();
  final candidates = samePos.isEmpty ? usable : samePos;

  final glossWords = _contentWords(gloss);
  PickedDefinition? best;
  var bestScore = -1;
  for (final m in candidates) {
    for (final d in m.definitions) {
      if (d.trim().isEmpty) continue;
      final score = glossWords.isEmpty ? 0 : _contentWords(d).intersection(glossWords).length;
      if (score > bestScore) {
        bestScore = score;
        best = (definition: d, partOfSpeech: m.partOfSpeech);
      }
    }
  }
  return best;
}

/// Çevrimdışı sözlüğün tür kodları → dictionaryapi.dev adları.
const Map<String, String> _apiPos = {
  'adj': 'adjective',
  'adv': 'adverb',
  'prep': 'preposition',
  'conj': 'conjunction',
  'pron': 'pronoun',
  'intj': 'interjection',
  'det': 'determiner',
  'num': 'numeral',
};

const Set<String> _stopWords = {
  'the', 'and', 'for', 'with', 'from', 'that', 'this', 'into', 'onto', 'which',
  'who', 'whom', 'any', 'some', 'are', 'was', 'were', 'has', 'have', 'had',
  'not', 'but', 'its', 'one', 'etc', 'used', 'being', 'very', 'such', 'other',
};

/// Küçük harfli, 3+ harfli, sondaki çoğul "s"i atılmış içerik sözcükleri.
Set<String> _contentWords(String text) {
  final words = <String>{};
  for (final raw in text.toLowerCase().split(RegExp(r'[^a-z]+'))) {
    if (raw.length < 3 || _stopWords.contains(raw)) continue;
    words.add(raw.length > 3 && raw.endsWith('s') && !raw.endsWith('ss') ? raw.substring(0, raw.length - 1) : raw);
  }
  return words;
}
