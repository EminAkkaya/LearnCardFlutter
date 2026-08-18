// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FlashcardEntriesTable extends FlashcardEntries
    with TableInfo<$FlashcardEntriesTable, FlashcardEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlashcardEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
    'word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _definitionMeta = const VerificationMeta(
    'definition',
  );
  @override
  late final GeneratedColumn<String> definition = GeneratedColumn<String>(
    'definition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _trTranslationMeta = const VerificationMeta(
    'trTranslation',
  );
  @override
  late final GeneratedColumn<String> trTranslation = GeneratedColumn<String>(
    'tr_translation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _phoneticMeta = const VerificationMeta(
    'phonetic',
  );
  @override
  late final GeneratedColumn<String> phonetic = GeneratedColumn<String>(
    'phonetic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _partOfSpeechMeta = const VerificationMeta(
    'partOfSpeech',
  );
  @override
  late final GeneratedColumn<String> partOfSpeech = GeneratedColumn<String>(
    'part_of_speech',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _exampleSentenceMeta = const VerificationMeta(
    'exampleSentence',
  );
  @override
  late final GeneratedColumn<String> exampleSentence = GeneratedColumn<String>(
    'example_sentence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _audioUrlMeta = const VerificationMeta(
    'audioUrl',
  );
  @override
  late final GeneratedColumn<String> audioUrl = GeneratedColumn<String>(
    'audio_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('new'),
  );
  static const VerificationMeta _intervalMeta = const VerificationMeta(
    'interval',
  );
  @override
  late final GeneratedColumn<int> interval = GeneratedColumn<int>(
    'interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _repetitionsMeta = const VerificationMeta(
    'repetitions',
  );
  @override
  late final GeneratedColumn<int> repetitions = GeneratedColumn<int>(
    'repetitions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _learningStepMeta = const VerificationMeta(
    'learningStep',
  );
  @override
  late final GeneratedColumn<int> learningStep = GeneratedColumn<int>(
    'learning_step',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _easeFactorMeta = const VerificationMeta(
    'easeFactor',
  );
  @override
  late final GeneratedColumn<double> easeFactor = GeneratedColumn<double>(
    'ease_factor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2.5),
  );
  static const VerificationMeta _nextReviewDateMeta = const VerificationMeta(
    'nextReviewDate',
  );
  @override
  late final GeneratedColumn<String> nextReviewDate = GeneratedColumn<String>(
    'next_review_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    word,
    definition,
    trTranslation,
    phonetic,
    partOfSpeech,
    exampleSentence,
    audioUrl,
    status,
    interval,
    repetitions,
    learningStep,
    easeFactor,
    nextReviewDate,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flashcard_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<FlashcardEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('word')) {
      context.handle(
        _wordMeta,
        word.isAcceptableOrUnknown(data['word']!, _wordMeta),
      );
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('definition')) {
      context.handle(
        _definitionMeta,
        definition.isAcceptableOrUnknown(data['definition']!, _definitionMeta),
      );
    }
    if (data.containsKey('tr_translation')) {
      context.handle(
        _trTranslationMeta,
        trTranslation.isAcceptableOrUnknown(
          data['tr_translation']!,
          _trTranslationMeta,
        ),
      );
    }
    if (data.containsKey('phonetic')) {
      context.handle(
        _phoneticMeta,
        phonetic.isAcceptableOrUnknown(data['phonetic']!, _phoneticMeta),
      );
    }
    if (data.containsKey('part_of_speech')) {
      context.handle(
        _partOfSpeechMeta,
        partOfSpeech.isAcceptableOrUnknown(
          data['part_of_speech']!,
          _partOfSpeechMeta,
        ),
      );
    }
    if (data.containsKey('example_sentence')) {
      context.handle(
        _exampleSentenceMeta,
        exampleSentence.isAcceptableOrUnknown(
          data['example_sentence']!,
          _exampleSentenceMeta,
        ),
      );
    }
    if (data.containsKey('audio_url')) {
      context.handle(
        _audioUrlMeta,
        audioUrl.isAcceptableOrUnknown(data['audio_url']!, _audioUrlMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('interval')) {
      context.handle(
        _intervalMeta,
        interval.isAcceptableOrUnknown(data['interval']!, _intervalMeta),
      );
    }
    if (data.containsKey('repetitions')) {
      context.handle(
        _repetitionsMeta,
        repetitions.isAcceptableOrUnknown(
          data['repetitions']!,
          _repetitionsMeta,
        ),
      );
    }
    if (data.containsKey('learning_step')) {
      context.handle(
        _learningStepMeta,
        learningStep.isAcceptableOrUnknown(
          data['learning_step']!,
          _learningStepMeta,
        ),
      );
    }
    if (data.containsKey('ease_factor')) {
      context.handle(
        _easeFactorMeta,
        easeFactor.isAcceptableOrUnknown(data['ease_factor']!, _easeFactorMeta),
      );
    }
    if (data.containsKey('next_review_date')) {
      context.handle(
        _nextReviewDateMeta,
        nextReviewDate.isAcceptableOrUnknown(
          data['next_review_date']!,
          _nextReviewDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextReviewDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FlashcardEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FlashcardEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      word: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word'],
      )!,
      definition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition'],
      )!,
      trTranslation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tr_translation'],
      )!,
      phonetic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phonetic'],
      )!,
      partOfSpeech: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_of_speech'],
      )!,
      exampleSentence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example_sentence'],
      )!,
      audioUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_url'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      interval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval'],
      )!,
      repetitions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repetitions'],
      )!,
      learningStep: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}learning_step'],
      )!,
      easeFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ease_factor'],
      )!,
      nextReviewDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_review_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FlashcardEntriesTable createAlias(String alias) {
    return $FlashcardEntriesTable(attachedDatabase, alias);
  }
}

class FlashcardEntry extends DataClass implements Insertable<FlashcardEntry> {
  final String id;
  final String? userId;
  final String word;
  final String definition;
  final String trTranslation;
  final String phonetic;
  final String partOfSpeech;
  final String exampleSentence;
  final String audioUrl;
  final String status;
  final int interval;
  final int repetitions;
  final int learningStep;
  final double easeFactor;
  final String nextReviewDate;
  final String createdAt;
  const FlashcardEntry({
    required this.id,
    this.userId,
    required this.word,
    required this.definition,
    required this.trTranslation,
    required this.phonetic,
    required this.partOfSpeech,
    required this.exampleSentence,
    required this.audioUrl,
    required this.status,
    required this.interval,
    required this.repetitions,
    required this.learningStep,
    required this.easeFactor,
    required this.nextReviewDate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['word'] = Variable<String>(word);
    map['definition'] = Variable<String>(definition);
    map['tr_translation'] = Variable<String>(trTranslation);
    map['phonetic'] = Variable<String>(phonetic);
    map['part_of_speech'] = Variable<String>(partOfSpeech);
    map['example_sentence'] = Variable<String>(exampleSentence);
    map['audio_url'] = Variable<String>(audioUrl);
    map['status'] = Variable<String>(status);
    map['interval'] = Variable<int>(interval);
    map['repetitions'] = Variable<int>(repetitions);
    map['learning_step'] = Variable<int>(learningStep);
    map['ease_factor'] = Variable<double>(easeFactor);
    map['next_review_date'] = Variable<String>(nextReviewDate);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  FlashcardEntriesCompanion toCompanion(bool nullToAbsent) {
    return FlashcardEntriesCompanion(
      id: Value(id),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      word: Value(word),
      definition: Value(definition),
      trTranslation: Value(trTranslation),
      phonetic: Value(phonetic),
      partOfSpeech: Value(partOfSpeech),
      exampleSentence: Value(exampleSentence),
      audioUrl: Value(audioUrl),
      status: Value(status),
      interval: Value(interval),
      repetitions: Value(repetitions),
      learningStep: Value(learningStep),
      easeFactor: Value(easeFactor),
      nextReviewDate: Value(nextReviewDate),
      createdAt: Value(createdAt),
    );
  }

  factory FlashcardEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FlashcardEntry(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      word: serializer.fromJson<String>(json['word']),
      definition: serializer.fromJson<String>(json['definition']),
      trTranslation: serializer.fromJson<String>(json['trTranslation']),
      phonetic: serializer.fromJson<String>(json['phonetic']),
      partOfSpeech: serializer.fromJson<String>(json['partOfSpeech']),
      exampleSentence: serializer.fromJson<String>(json['exampleSentence']),
      audioUrl: serializer.fromJson<String>(json['audioUrl']),
      status: serializer.fromJson<String>(json['status']),
      interval: serializer.fromJson<int>(json['interval']),
      repetitions: serializer.fromJson<int>(json['repetitions']),
      learningStep: serializer.fromJson<int>(json['learningStep']),
      easeFactor: serializer.fromJson<double>(json['easeFactor']),
      nextReviewDate: serializer.fromJson<String>(json['nextReviewDate']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'word': serializer.toJson<String>(word),
      'definition': serializer.toJson<String>(definition),
      'trTranslation': serializer.toJson<String>(trTranslation),
      'phonetic': serializer.toJson<String>(phonetic),
      'partOfSpeech': serializer.toJson<String>(partOfSpeech),
      'exampleSentence': serializer.toJson<String>(exampleSentence),
      'audioUrl': serializer.toJson<String>(audioUrl),
      'status': serializer.toJson<String>(status),
      'interval': serializer.toJson<int>(interval),
      'repetitions': serializer.toJson<int>(repetitions),
      'learningStep': serializer.toJson<int>(learningStep),
      'easeFactor': serializer.toJson<double>(easeFactor),
      'nextReviewDate': serializer.toJson<String>(nextReviewDate),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  FlashcardEntry copyWith({
    String? id,
    Value<String?> userId = const Value.absent(),
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
  }) => FlashcardEntry(
    id: id ?? this.id,
    userId: userId.present ? userId.value : this.userId,
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
  FlashcardEntry copyWithCompanion(FlashcardEntriesCompanion data) {
    return FlashcardEntry(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      word: data.word.present ? data.word.value : this.word,
      definition: data.definition.present
          ? data.definition.value
          : this.definition,
      trTranslation: data.trTranslation.present
          ? data.trTranslation.value
          : this.trTranslation,
      phonetic: data.phonetic.present ? data.phonetic.value : this.phonetic,
      partOfSpeech: data.partOfSpeech.present
          ? data.partOfSpeech.value
          : this.partOfSpeech,
      exampleSentence: data.exampleSentence.present
          ? data.exampleSentence.value
          : this.exampleSentence,
      audioUrl: data.audioUrl.present ? data.audioUrl.value : this.audioUrl,
      status: data.status.present ? data.status.value : this.status,
      interval: data.interval.present ? data.interval.value : this.interval,
      repetitions: data.repetitions.present
          ? data.repetitions.value
          : this.repetitions,
      learningStep: data.learningStep.present
          ? data.learningStep.value
          : this.learningStep,
      easeFactor: data.easeFactor.present
          ? data.easeFactor.value
          : this.easeFactor,
      nextReviewDate: data.nextReviewDate.present
          ? data.nextReviewDate.value
          : this.nextReviewDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardEntry(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('word: $word, ')
          ..write('definition: $definition, ')
          ..write('trTranslation: $trTranslation, ')
          ..write('phonetic: $phonetic, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('exampleSentence: $exampleSentence, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('status: $status, ')
          ..write('interval: $interval, ')
          ..write('repetitions: $repetitions, ')
          ..write('learningStep: $learningStep, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('nextReviewDate: $nextReviewDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    word,
    definition,
    trTranslation,
    phonetic,
    partOfSpeech,
    exampleSentence,
    audioUrl,
    status,
    interval,
    repetitions,
    learningStep,
    easeFactor,
    nextReviewDate,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FlashcardEntry &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.word == this.word &&
          other.definition == this.definition &&
          other.trTranslation == this.trTranslation &&
          other.phonetic == this.phonetic &&
          other.partOfSpeech == this.partOfSpeech &&
          other.exampleSentence == this.exampleSentence &&
          other.audioUrl == this.audioUrl &&
          other.status == this.status &&
          other.interval == this.interval &&
          other.repetitions == this.repetitions &&
          other.learningStep == this.learningStep &&
          other.easeFactor == this.easeFactor &&
          other.nextReviewDate == this.nextReviewDate &&
          other.createdAt == this.createdAt);
}

class FlashcardEntriesCompanion extends UpdateCompanion<FlashcardEntry> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<String> word;
  final Value<String> definition;
  final Value<String> trTranslation;
  final Value<String> phonetic;
  final Value<String> partOfSpeech;
  final Value<String> exampleSentence;
  final Value<String> audioUrl;
  final Value<String> status;
  final Value<int> interval;
  final Value<int> repetitions;
  final Value<int> learningStep;
  final Value<double> easeFactor;
  final Value<String> nextReviewDate;
  final Value<String> createdAt;
  final Value<int> rowid;
  const FlashcardEntriesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.word = const Value.absent(),
    this.definition = const Value.absent(),
    this.trTranslation = const Value.absent(),
    this.phonetic = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
    this.exampleSentence = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.status = const Value.absent(),
    this.interval = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.learningStep = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.nextReviewDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FlashcardEntriesCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required String word,
    this.definition = const Value.absent(),
    this.trTranslation = const Value.absent(),
    this.phonetic = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
    this.exampleSentence = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.status = const Value.absent(),
    this.interval = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.learningStep = const Value.absent(),
    this.easeFactor = const Value.absent(),
    required String nextReviewDate,
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       word = Value(word),
       nextReviewDate = Value(nextReviewDate),
       createdAt = Value(createdAt);
  static Insertable<FlashcardEntry> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? word,
    Expression<String>? definition,
    Expression<String>? trTranslation,
    Expression<String>? phonetic,
    Expression<String>? partOfSpeech,
    Expression<String>? exampleSentence,
    Expression<String>? audioUrl,
    Expression<String>? status,
    Expression<int>? interval,
    Expression<int>? repetitions,
    Expression<int>? learningStep,
    Expression<double>? easeFactor,
    Expression<String>? nextReviewDate,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (word != null) 'word': word,
      if (definition != null) 'definition': definition,
      if (trTranslation != null) 'tr_translation': trTranslation,
      if (phonetic != null) 'phonetic': phonetic,
      if (partOfSpeech != null) 'part_of_speech': partOfSpeech,
      if (exampleSentence != null) 'example_sentence': exampleSentence,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (status != null) 'status': status,
      if (interval != null) 'interval': interval,
      if (repetitions != null) 'repetitions': repetitions,
      if (learningStep != null) 'learning_step': learningStep,
      if (easeFactor != null) 'ease_factor': easeFactor,
      if (nextReviewDate != null) 'next_review_date': nextReviewDate,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FlashcardEntriesCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<String>? word,
    Value<String>? definition,
    Value<String>? trTranslation,
    Value<String>? phonetic,
    Value<String>? partOfSpeech,
    Value<String>? exampleSentence,
    Value<String>? audioUrl,
    Value<String>? status,
    Value<int>? interval,
    Value<int>? repetitions,
    Value<int>? learningStep,
    Value<double>? easeFactor,
    Value<String>? nextReviewDate,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return FlashcardEntriesCompanion(
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
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (definition.present) {
      map['definition'] = Variable<String>(definition.value);
    }
    if (trTranslation.present) {
      map['tr_translation'] = Variable<String>(trTranslation.value);
    }
    if (phonetic.present) {
      map['phonetic'] = Variable<String>(phonetic.value);
    }
    if (partOfSpeech.present) {
      map['part_of_speech'] = Variable<String>(partOfSpeech.value);
    }
    if (exampleSentence.present) {
      map['example_sentence'] = Variable<String>(exampleSentence.value);
    }
    if (audioUrl.present) {
      map['audio_url'] = Variable<String>(audioUrl.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (interval.present) {
      map['interval'] = Variable<int>(interval.value);
    }
    if (repetitions.present) {
      map['repetitions'] = Variable<int>(repetitions.value);
    }
    if (learningStep.present) {
      map['learning_step'] = Variable<int>(learningStep.value);
    }
    if (easeFactor.present) {
      map['ease_factor'] = Variable<double>(easeFactor.value);
    }
    if (nextReviewDate.present) {
      map['next_review_date'] = Variable<String>(nextReviewDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardEntriesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('word: $word, ')
          ..write('definition: $definition, ')
          ..write('trTranslation: $trTranslation, ')
          ..write('phonetic: $phonetic, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('exampleSentence: $exampleSentence, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('status: $status, ')
          ..write('interval: $interval, ')
          ..write('repetitions: $repetitions, ')
          ..write('learningStep: $learningStep, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('nextReviewDate: $nextReviewDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingArticleEntriesTable extends ReadingArticleEntries
    with TableInfo<$ReadingArticleEntriesTable, ReadingArticleEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingArticleEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textContentMeta = const VerificationMeta(
    'textContent',
  );
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
    'text_content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folderMeta = const VerificationMeta('folder');
  @override
  late final GeneratedColumn<String> folder = GeneratedColumn<String>(
    'folder',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Genel'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    title,
    textContent,
    createdAt,
    folder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_article_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingArticleEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('text_content')) {
      context.handle(
        _textContentMeta,
        textContent.isAcceptableOrUnknown(
          data['text_content']!,
          _textContentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_textContentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('folder')) {
      context.handle(
        _folderMeta,
        folder.isAcceptableOrUnknown(data['folder']!, _folderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingArticleEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingArticleEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      textContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_content'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      folder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder'],
      )!,
    );
  }

  @override
  $ReadingArticleEntriesTable createAlias(String alias) {
    return $ReadingArticleEntriesTable(attachedDatabase, alias);
  }
}

class ReadingArticleEntry extends DataClass
    implements Insertable<ReadingArticleEntry> {
  final String id;
  final String? userId;
  final String title;
  final String textContent;
  final String createdAt;
  final String folder;
  const ReadingArticleEntry({
    required this.id,
    this.userId,
    required this.title,
    required this.textContent,
    required this.createdAt,
    required this.folder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['title'] = Variable<String>(title);
    map['text_content'] = Variable<String>(textContent);
    map['created_at'] = Variable<String>(createdAt);
    map['folder'] = Variable<String>(folder);
    return map;
  }

  ReadingArticleEntriesCompanion toCompanion(bool nullToAbsent) {
    return ReadingArticleEntriesCompanion(
      id: Value(id),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      title: Value(title),
      textContent: Value(textContent),
      createdAt: Value(createdAt),
      folder: Value(folder),
    );
  }

  factory ReadingArticleEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingArticleEntry(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      textContent: serializer.fromJson<String>(json['textContent']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      folder: serializer.fromJson<String>(json['folder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'title': serializer.toJson<String>(title),
      'textContent': serializer.toJson<String>(textContent),
      'createdAt': serializer.toJson<String>(createdAt),
      'folder': serializer.toJson<String>(folder),
    };
  }

  ReadingArticleEntry copyWith({
    String? id,
    Value<String?> userId = const Value.absent(),
    String? title,
    String? textContent,
    String? createdAt,
    String? folder,
  }) => ReadingArticleEntry(
    id: id ?? this.id,
    userId: userId.present ? userId.value : this.userId,
    title: title ?? this.title,
    textContent: textContent ?? this.textContent,
    createdAt: createdAt ?? this.createdAt,
    folder: folder ?? this.folder,
  );
  ReadingArticleEntry copyWithCompanion(ReadingArticleEntriesCompanion data) {
    return ReadingArticleEntry(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      textContent: data.textContent.present
          ? data.textContent.value
          : this.textContent,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      folder: data.folder.present ? data.folder.value : this.folder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingArticleEntry(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('textContent: $textContent, ')
          ..write('createdAt: $createdAt, ')
          ..write('folder: $folder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, title, textContent, createdAt, folder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingArticleEntry &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.textContent == this.textContent &&
          other.createdAt == this.createdAt &&
          other.folder == this.folder);
}

class ReadingArticleEntriesCompanion
    extends UpdateCompanion<ReadingArticleEntry> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<String> title;
  final Value<String> textContent;
  final Value<String> createdAt;
  final Value<String> folder;
  final Value<int> rowid;
  const ReadingArticleEntriesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.textContent = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.folder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingArticleEntriesCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required String title,
    required String textContent,
    required String createdAt,
    this.folder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       textContent = Value(textContent),
       createdAt = Value(createdAt);
  static Insertable<ReadingArticleEntry> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? textContent,
    Expression<String>? createdAt,
    Expression<String>? folder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (textContent != null) 'text_content': textContent,
      if (createdAt != null) 'created_at': createdAt,
      if (folder != null) 'folder': folder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingArticleEntriesCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<String>? title,
    Value<String>? textContent,
    Value<String>? createdAt,
    Value<String>? folder,
    Value<int>? rowid,
  }) {
    return ReadingArticleEntriesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      textContent: textContent ?? this.textContent,
      createdAt: createdAt ?? this.createdAt,
      folder: folder ?? this.folder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (textContent.present) {
      map['text_content'] = Variable<String>(textContent.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (folder.present) {
      map['folder'] = Variable<String>(folder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingArticleEntriesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('textContent: $textContent, ')
          ..write('createdAt: $createdAt, ')
          ..write('folder: $folder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppPreferenceEntriesTable extends AppPreferenceEntries
    with TableInfo<$AppPreferenceEntriesTable, AppPreferenceEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppPreferenceEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_preference_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppPreferenceEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppPreferenceEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppPreferenceEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  $AppPreferenceEntriesTable createAlias(String alias) {
    return $AppPreferenceEntriesTable(attachedDatabase, alias);
  }
}

class AppPreferenceEntry extends DataClass
    implements Insertable<AppPreferenceEntry> {
  final String key;
  final String? value;
  const AppPreferenceEntry({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  AppPreferenceEntriesCompanion toCompanion(bool nullToAbsent) {
    return AppPreferenceEntriesCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory AppPreferenceEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppPreferenceEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  AppPreferenceEntry copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
  }) => AppPreferenceEntry(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  AppPreferenceEntry copyWithCompanion(AppPreferenceEntriesCompanion data) {
    return AppPreferenceEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppPreferenceEntry(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppPreferenceEntry &&
          other.key == this.key &&
          other.value == this.value);
}

class AppPreferenceEntriesCompanion
    extends UpdateCompanion<AppPreferenceEntry> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const AppPreferenceEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppPreferenceEntriesCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<AppPreferenceEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppPreferenceEntriesCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<int>? rowid,
  }) {
    return AppPreferenceEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppPreferenceEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FlashcardEntriesTable flashcardEntries = $FlashcardEntriesTable(
    this,
  );
  late final $ReadingArticleEntriesTable readingArticleEntries =
      $ReadingArticleEntriesTable(this);
  late final $AppPreferenceEntriesTable appPreferenceEntries =
      $AppPreferenceEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    flashcardEntries,
    readingArticleEntries,
    appPreferenceEntries,
  ];
}

typedef $$FlashcardEntriesTableCreateCompanionBuilder =
    FlashcardEntriesCompanion Function({
      required String id,
      Value<String?> userId,
      required String word,
      Value<String> definition,
      Value<String> trTranslation,
      Value<String> phonetic,
      Value<String> partOfSpeech,
      Value<String> exampleSentence,
      Value<String> audioUrl,
      Value<String> status,
      Value<int> interval,
      Value<int> repetitions,
      Value<int> learningStep,
      Value<double> easeFactor,
      required String nextReviewDate,
      required String createdAt,
      Value<int> rowid,
    });
typedef $$FlashcardEntriesTableUpdateCompanionBuilder =
    FlashcardEntriesCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String> word,
      Value<String> definition,
      Value<String> trTranslation,
      Value<String> phonetic,
      Value<String> partOfSpeech,
      Value<String> exampleSentence,
      Value<String> audioUrl,
      Value<String> status,
      Value<int> interval,
      Value<int> repetitions,
      Value<int> learningStep,
      Value<double> easeFactor,
      Value<String> nextReviewDate,
      Value<String> createdAt,
      Value<int> rowid,
    });

class $$FlashcardEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $FlashcardEntriesTable> {
  $$FlashcardEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trTranslation => $composableBuilder(
    column: $table.trTranslation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phonetic => $composableBuilder(
    column: $table.phonetic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exampleSentence => $composableBuilder(
    column: $table.exampleSentence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get learningStep => $composableBuilder(
    column: $table.learningStep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextReviewDate => $composableBuilder(
    column: $table.nextReviewDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FlashcardEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $FlashcardEntriesTable> {
  $$FlashcardEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trTranslation => $composableBuilder(
    column: $table.trTranslation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phonetic => $composableBuilder(
    column: $table.phonetic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exampleSentence => $composableBuilder(
    column: $table.exampleSentence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get learningStep => $composableBuilder(
    column: $table.learningStep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextReviewDate => $composableBuilder(
    column: $table.nextReviewDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FlashcardEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FlashcardEntriesTable> {
  $$FlashcardEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get trTranslation => $composableBuilder(
    column: $table.trTranslation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phonetic =>
      $composableBuilder(column: $table.phonetic, builder: (column) => column);

  GeneratedColumn<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exampleSentence => $composableBuilder(
    column: $table.exampleSentence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioUrl =>
      $composableBuilder(column: $table.audioUrl, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get interval =>
      $composableBuilder(column: $table.interval, builder: (column) => column);

  GeneratedColumn<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get learningStep => $composableBuilder(
    column: $table.learningStep,
    builder: (column) => column,
  );

  GeneratedColumn<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nextReviewDate => $composableBuilder(
    column: $table.nextReviewDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FlashcardEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FlashcardEntriesTable,
          FlashcardEntry,
          $$FlashcardEntriesTableFilterComposer,
          $$FlashcardEntriesTableOrderingComposer,
          $$FlashcardEntriesTableAnnotationComposer,
          $$FlashcardEntriesTableCreateCompanionBuilder,
          $$FlashcardEntriesTableUpdateCompanionBuilder,
          (
            FlashcardEntry,
            BaseReferences<
              _$AppDatabase,
              $FlashcardEntriesTable,
              FlashcardEntry
            >,
          ),
          FlashcardEntry,
          PrefetchHooks Function()
        > {
  $$FlashcardEntriesTableTableManager(
    _$AppDatabase db,
    $FlashcardEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlashcardEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlashcardEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlashcardEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> word = const Value.absent(),
                Value<String> definition = const Value.absent(),
                Value<String> trTranslation = const Value.absent(),
                Value<String> phonetic = const Value.absent(),
                Value<String> partOfSpeech = const Value.absent(),
                Value<String> exampleSentence = const Value.absent(),
                Value<String> audioUrl = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> interval = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<int> learningStep = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<String> nextReviewDate = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FlashcardEntriesCompanion(
                id: id,
                userId: userId,
                word: word,
                definition: definition,
                trTranslation: trTranslation,
                phonetic: phonetic,
                partOfSpeech: partOfSpeech,
                exampleSentence: exampleSentence,
                audioUrl: audioUrl,
                status: status,
                interval: interval,
                repetitions: repetitions,
                learningStep: learningStep,
                easeFactor: easeFactor,
                nextReviewDate: nextReviewDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> userId = const Value.absent(),
                required String word,
                Value<String> definition = const Value.absent(),
                Value<String> trTranslation = const Value.absent(),
                Value<String> phonetic = const Value.absent(),
                Value<String> partOfSpeech = const Value.absent(),
                Value<String> exampleSentence = const Value.absent(),
                Value<String> audioUrl = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> interval = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<int> learningStep = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                required String nextReviewDate,
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => FlashcardEntriesCompanion.insert(
                id: id,
                userId: userId,
                word: word,
                definition: definition,
                trTranslation: trTranslation,
                phonetic: phonetic,
                partOfSpeech: partOfSpeech,
                exampleSentence: exampleSentence,
                audioUrl: audioUrl,
                status: status,
                interval: interval,
                repetitions: repetitions,
                learningStep: learningStep,
                easeFactor: easeFactor,
                nextReviewDate: nextReviewDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FlashcardEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FlashcardEntriesTable,
      FlashcardEntry,
      $$FlashcardEntriesTableFilterComposer,
      $$FlashcardEntriesTableOrderingComposer,
      $$FlashcardEntriesTableAnnotationComposer,
      $$FlashcardEntriesTableCreateCompanionBuilder,
      $$FlashcardEntriesTableUpdateCompanionBuilder,
      (
        FlashcardEntry,
        BaseReferences<_$AppDatabase, $FlashcardEntriesTable, FlashcardEntry>,
      ),
      FlashcardEntry,
      PrefetchHooks Function()
    >;
typedef $$ReadingArticleEntriesTableCreateCompanionBuilder =
    ReadingArticleEntriesCompanion Function({
      required String id,
      Value<String?> userId,
      required String title,
      required String textContent,
      required String createdAt,
      Value<String> folder,
      Value<int> rowid,
    });
typedef $$ReadingArticleEntriesTableUpdateCompanionBuilder =
    ReadingArticleEntriesCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String> title,
      Value<String> textContent,
      Value<String> createdAt,
      Value<String> folder,
      Value<int> rowid,
    });

class $$ReadingArticleEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingArticleEntriesTable> {
  $$ReadingArticleEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folder => $composableBuilder(
    column: $table.folder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingArticleEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingArticleEntriesTable> {
  $$ReadingArticleEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folder => $composableBuilder(
    column: $table.folder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingArticleEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingArticleEntriesTable> {
  $$ReadingArticleEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get folder =>
      $composableBuilder(column: $table.folder, builder: (column) => column);
}

class $$ReadingArticleEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingArticleEntriesTable,
          ReadingArticleEntry,
          $$ReadingArticleEntriesTableFilterComposer,
          $$ReadingArticleEntriesTableOrderingComposer,
          $$ReadingArticleEntriesTableAnnotationComposer,
          $$ReadingArticleEntriesTableCreateCompanionBuilder,
          $$ReadingArticleEntriesTableUpdateCompanionBuilder,
          (
            ReadingArticleEntry,
            BaseReferences<
              _$AppDatabase,
              $ReadingArticleEntriesTable,
              ReadingArticleEntry
            >,
          ),
          ReadingArticleEntry,
          PrefetchHooks Function()
        > {
  $$ReadingArticleEntriesTableTableManager(
    _$AppDatabase db,
    $ReadingArticleEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingArticleEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ReadingArticleEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ReadingArticleEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> textContent = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> folder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingArticleEntriesCompanion(
                id: id,
                userId: userId,
                title: title,
                textContent: textContent,
                createdAt: createdAt,
                folder: folder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> userId = const Value.absent(),
                required String title,
                required String textContent,
                required String createdAt,
                Value<String> folder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingArticleEntriesCompanion.insert(
                id: id,
                userId: userId,
                title: title,
                textContent: textContent,
                createdAt: createdAt,
                folder: folder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingArticleEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingArticleEntriesTable,
      ReadingArticleEntry,
      $$ReadingArticleEntriesTableFilterComposer,
      $$ReadingArticleEntriesTableOrderingComposer,
      $$ReadingArticleEntriesTableAnnotationComposer,
      $$ReadingArticleEntriesTableCreateCompanionBuilder,
      $$ReadingArticleEntriesTableUpdateCompanionBuilder,
      (
        ReadingArticleEntry,
        BaseReferences<
          _$AppDatabase,
          $ReadingArticleEntriesTable,
          ReadingArticleEntry
        >,
      ),
      ReadingArticleEntry,
      PrefetchHooks Function()
    >;
typedef $$AppPreferenceEntriesTableCreateCompanionBuilder =
    AppPreferenceEntriesCompanion Function({
      required String key,
      Value<String?> value,
      Value<int> rowid,
    });
typedef $$AppPreferenceEntriesTableUpdateCompanionBuilder =
    AppPreferenceEntriesCompanion Function({
      Value<String> key,
      Value<String?> value,
      Value<int> rowid,
    });

class $$AppPreferenceEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $AppPreferenceEntriesTable> {
  $$AppPreferenceEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppPreferenceEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $AppPreferenceEntriesTable> {
  $$AppPreferenceEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppPreferenceEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppPreferenceEntriesTable> {
  $$AppPreferenceEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppPreferenceEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppPreferenceEntriesTable,
          AppPreferenceEntry,
          $$AppPreferenceEntriesTableFilterComposer,
          $$AppPreferenceEntriesTableOrderingComposer,
          $$AppPreferenceEntriesTableAnnotationComposer,
          $$AppPreferenceEntriesTableCreateCompanionBuilder,
          $$AppPreferenceEntriesTableUpdateCompanionBuilder,
          (
            AppPreferenceEntry,
            BaseReferences<
              _$AppDatabase,
              $AppPreferenceEntriesTable,
              AppPreferenceEntry
            >,
          ),
          AppPreferenceEntry,
          PrefetchHooks Function()
        > {
  $$AppPreferenceEntriesTableTableManager(
    _$AppDatabase db,
    $AppPreferenceEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppPreferenceEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppPreferenceEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AppPreferenceEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppPreferenceEntriesCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppPreferenceEntriesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppPreferenceEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppPreferenceEntriesTable,
      AppPreferenceEntry,
      $$AppPreferenceEntriesTableFilterComposer,
      $$AppPreferenceEntriesTableOrderingComposer,
      $$AppPreferenceEntriesTableAnnotationComposer,
      $$AppPreferenceEntriesTableCreateCompanionBuilder,
      $$AppPreferenceEntriesTableUpdateCompanionBuilder,
      (
        AppPreferenceEntry,
        BaseReferences<
          _$AppDatabase,
          $AppPreferenceEntriesTable,
          AppPreferenceEntry
        >,
      ),
      AppPreferenceEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FlashcardEntriesTableTableManager get flashcardEntries =>
      $$FlashcardEntriesTableTableManager(_db, _db.flashcardEntries);
  $$ReadingArticleEntriesTableTableManager get readingArticleEntries =>
      $$ReadingArticleEntriesTableTableManager(_db, _db.readingArticleEntries);
  $$AppPreferenceEntriesTableTableManager get appPreferenceEntries =>
      $$AppPreferenceEntriesTableTableManager(_db, _db.appPreferenceEntries);
}
