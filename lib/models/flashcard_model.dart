class FlashcardModel {
  final String id;
  final String? userId;
  final String word;
  final String definition;
  final String trTranslation;
  final String phonetic;
  final String partOfSpeech;
  final String exampleSentence;
  final String audioUrl;
  final String status; // 'new', 'learning', 'mastered'
  final int interval;
  final int repetitions;
  final int learningStep;
  final double easeFactor;
  final String nextReviewDate;
  final String createdAt;

  FlashcardModel({
    required this.id,
    this.userId,
    required this.word,
    this.definition = '',
    this.trTranslation = '',
    this.phonetic = '',
    this.partOfSpeech = '',
    this.exampleSentence = '',
    this.audioUrl = '',
    this.status = 'new',
    this.interval = 0,
    this.repetitions = 0,
    this.learningStep = 0,
    this.easeFactor = 2.5,
    required this.nextReviewDate,
    required this.createdAt,
  });

  /// Factory constructor to map Supabase table row (or Local JSON) to Dart object
  factory FlashcardModel.fromMap(Map<String, dynamic> map) {
    int parseInt(dynamic val, int defaultValue) {
      if (val == null) return defaultValue;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? defaultValue;
      return defaultValue;
    }

    double parseDouble(dynamic val, double defaultValue) {
      if (val == null) return defaultValue;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? defaultValue;
      return defaultValue;
    }

    return FlashcardModel(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? map['userId']?.toString(),
      word: map['word']?.toString() ?? '',
      definition: map['definition']?.toString() ?? '',
      trTranslation: map['tr_translation']?.toString() ?? map['trTranslation']?.toString() ?? '',
      phonetic: map['phonetic']?.toString() ?? '',
      partOfSpeech: map['part_of_speech']?.toString() ?? map['partOfSpeech']?.toString() ?? '',
      exampleSentence: map['example_sentence']?.toString() ?? map['exampleSentence']?.toString() ?? '',
      audioUrl: map['audio_url']?.toString() ?? map['audioUrl']?.toString() ?? '',
      status: map['status']?.toString() ?? 'new',
      interval: parseInt(map['interval'], 0),
      repetitions: parseInt(map['repetitions'], 0),
      learningStep: parseInt(map['learning_step'] ?? map['learningStep'], 0),
      easeFactor: parseDouble(map['ease_factor'] ?? map['easeFactor'], 2.5),
      nextReviewDate: map['next_review_date']?.toString() ?? map['nextReviewDate']?.toString() ?? DateTime.now().toIso8601String(),
      createdAt: map['created_at']?.toString() ?? map['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  /// Converts object to Map matching Supabase `flashcards` table columns
  Map<String, dynamic> toSupabaseRow() {
    final row = <String, dynamic>{
      'id': id,
      'word': word,
      'definition': definition,
      'tr_translation': trTranslation,
      'phonetic': phonetic,
      'part_of_speech': partOfSpeech,
      'example_sentence': exampleSentence,
      'audio_url': audioUrl,
      'status': status,
      'interval': interval,
      'repetitions': repetitions,
      'learning_step': learningStep,
      'ease_factor': easeFactor,
      'next_review_date': nextReviewDate,
      'created_at': createdAt,
    };
    if (userId != null && userId!.isNotEmpty) {
      row['user_id'] = userId;
    }
    return row;
  }

  Map<String, dynamic> toMap() => toSupabaseRow();

  FlashcardModel copyWith({
    String? id,
    String? userId,
    String? word,
    String? definition,
    String? trTranslation,
    String? phonetic,
    String? partOfSpeech,
    String? exampleSentence,
    String? audioUrl,
    String? status,
    int? interval,
    int? repetitions,
    int? learningStep,
    double? easeFactor,
    String? nextReviewDate,
    String? createdAt,
  }) {
    return FlashcardModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      word: word ?? this.word,
      definition: definition ?? this.definition,
      trTranslation: trTranslation ?? this.trTranslation,
      phonetic: phonetic ?? this.phonetic,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      exampleSentence: exampleSentence ?? this.exampleSentence,
      audioUrl: audioUrl ?? this.audioUrl,
      status: status ?? this.status,
      interval: interval ?? this.interval,
      repetitions: repetitions ?? this.repetitions,
      learningStep: learningStep ?? this.learningStep,
      easeFactor: easeFactor ?? this.easeFactor,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
