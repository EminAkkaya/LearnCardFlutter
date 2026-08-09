class FlashcardModel {
  final String id;
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
    return FlashcardModel(
      id: map['id']?.toString() ?? '',
      word: map['word']?.toString() ?? '',
      definition: map['definition']?.toString() ?? '',
      trTranslation: map['tr_translation']?.toString() ?? map['trTranslation']?.toString() ?? '',
      phonetic: map['phonetic']?.toString() ?? '',
      partOfSpeech: map['part_of_speech']?.toString() ?? map['partOfSpeech']?.toString() ?? '',
      exampleSentence: map['example_sentence']?.toString() ?? map['exampleSentence']?.toString() ?? '',
      audioUrl: map['audio_url']?.toString() ?? map['audioUrl']?.toString() ?? '',
      status: map['status']?.toString() ?? 'new',
      interval: (map['interval'] is num) ? (map['interval'] as num).toInt() : 0,
      repetitions: (map['repetitions'] is num) ? (map['repetitions'] as num).toInt() : 0,
      learningStep: (map['learning_step'] is num)
          ? (map['learning_step'] as num).toInt()
          : (map['learningStep'] is num)
              ? (map['learningStep'] as num).toInt()
              : 0,
      easeFactor: (map['ease_factor'] is num)
          ? (map['ease_factor'] as num).toDouble()
          : (map['easeFactor'] is num)
              ? (map['easeFactor'] as num).toDouble()
              : 2.5,
      nextReviewDate: map['next_review_date']?.toString() ?? map['nextReviewDate']?.toString() ?? DateTime.now().toIso8601String(),
      createdAt: map['created_at']?.toString() ?? map['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  /// Converts object to Map matching Supabase `flashcards` table columns
  Map<String, dynamic> toSupabaseRow() {
    return {
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
  }

  Map<String, dynamic> toMap() => toSupabaseRow();

  FlashcardModel copyWith({
    String? id,
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
