// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WordsTable extends Words with TableInfo<$WordsTable, WordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
      'word', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'UNIQUE NOT NULL COLLATE NOCASE');
  static const VerificationMeta _frequencyMeta =
      const VerificationMeta('frequency');
  @override
  late final GeneratedColumn<int> frequency = GeneratedColumn<int>(
      'frequency', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isKnownMeta =
      const VerificationMeta('isKnown');
  @override
  late final GeneratedColumn<bool> isKnown = GeneratedColumn<bool>(
      'is_known', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_known" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _meaningMeta =
      const VerificationMeta('meaning');
  @override
  late final GeneratedColumn<String> meaning = GeneratedColumn<String>(
      'meaning', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String>
      definitions = GeneratedColumn<String>('definitions', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<List<String>?>($WordsTable.$converterdefinitionsn);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String> examples =
      GeneratedColumn<String>('examples', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<List<String>?>($WordsTable.$converterexamplesn);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String>
      translations = GeneratedColumn<String>('translations', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<List<String>?>($WordsTable.$convertertranslationsn);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String> synonyms =
      GeneratedColumn<String>('synonyms', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<List<String>?>($WordsTable.$convertersynonymsn);
  static const VerificationMeta _isExcludedMeta =
      const VerificationMeta('isExcluded');
  @override
  late final GeneratedColumn<bool> isExcluded = GeneratedColumn<bool>(
      'is_excluded', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_excluded" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _reviewScheduleMeta =
      const VerificationMeta('reviewSchedule');
  @override
  late final GeneratedColumn<String> reviewSchedule = GeneratedColumn<String>(
      'review_schedule', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        word,
        frequency,
        isKnown,
        createdAt,
        updatedAt,
        meaning,
        description,
        definitions,
        examples,
        translations,
        synonyms,
        isExcluded,
        category,
        reviewSchedule
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'words';
  @override
  VerificationContext validateIntegrity(Insertable<WordRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('word')) {
      context.handle(
          _wordMeta, word.isAcceptableOrUnknown(data['word']!, _wordMeta));
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(_frequencyMeta,
          frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta));
    }
    if (data.containsKey('is_known')) {
      context.handle(_isKnownMeta,
          isKnown.isAcceptableOrUnknown(data['is_known']!, _isKnownMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('meaning')) {
      context.handle(_meaningMeta,
          meaning.isAcceptableOrUnknown(data['meaning']!, _meaningMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('is_excluded')) {
      context.handle(
          _isExcludedMeta,
          isExcluded.isAcceptableOrUnknown(
              data['is_excluded']!, _isExcludedMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('review_schedule')) {
      context.handle(
          _reviewScheduleMeta,
          reviewSchedule.isAcceptableOrUnknown(
              data['review_schedule']!, _reviewScheduleMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      word: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}word'])!,
      frequency: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}frequency'])!,
      isKnown: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_known'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      meaning: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meaning']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      definitions: $WordsTable.$converterdefinitionsn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}definitions'])),
      examples: $WordsTable.$converterexamplesn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}examples'])),
      translations: $WordsTable.$convertertranslationsn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}translations'])),
      synonyms: $WordsTable.$convertersynonymsn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}synonyms'])),
      isExcluded: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_excluded'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      reviewSchedule: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}review_schedule']),
    );
  }

  @override
  $WordsTable createAlias(String alias) {
    return $WordsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterdefinitions =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $converterdefinitionsn =
      NullAwareTypeConverter.wrap($converterdefinitions);
  static TypeConverter<List<String>, String> $converterexamples =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $converterexamplesn =
      NullAwareTypeConverter.wrap($converterexamples);
  static TypeConverter<List<String>, String> $convertertranslations =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $convertertranslationsn =
      NullAwareTypeConverter.wrap($convertertranslations);
  static TypeConverter<List<String>, String> $convertersynonyms =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $convertersynonymsn =
      NullAwareTypeConverter.wrap($convertersynonyms);
}

class WordRow extends DataClass implements Insertable<WordRow> {
  final int id;
  final String word;
  final int frequency;
  final bool isKnown;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? meaning;
  final String? description;
  final List<String>? definitions;
  final List<String>? examples;
  final List<String>? translations;
  final List<String>? synonyms;
  final bool isExcluded;
  final String? category;
  final String? reviewSchedule;
  const WordRow(
      {required this.id,
      required this.word,
      required this.frequency,
      required this.isKnown,
      required this.createdAt,
      required this.updatedAt,
      this.meaning,
      this.description,
      this.definitions,
      this.examples,
      this.translations,
      this.synonyms,
      required this.isExcluded,
      this.category,
      this.reviewSchedule});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['word'] = Variable<String>(word);
    map['frequency'] = Variable<int>(frequency);
    map['is_known'] = Variable<bool>(isKnown);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || meaning != null) {
      map['meaning'] = Variable<String>(meaning);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || definitions != null) {
      map['definitions'] = Variable<String>(
          $WordsTable.$converterdefinitionsn.toSql(definitions));
    }
    if (!nullToAbsent || examples != null) {
      map['examples'] =
          Variable<String>($WordsTable.$converterexamplesn.toSql(examples));
    }
    if (!nullToAbsent || translations != null) {
      map['translations'] = Variable<String>(
          $WordsTable.$convertertranslationsn.toSql(translations));
    }
    if (!nullToAbsent || synonyms != null) {
      map['synonyms'] =
          Variable<String>($WordsTable.$convertersynonymsn.toSql(synonyms));
    }
    map['is_excluded'] = Variable<bool>(isExcluded);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || reviewSchedule != null) {
      map['review_schedule'] = Variable<String>(reviewSchedule);
    }
    return map;
  }

  WordsCompanion toCompanion(bool nullToAbsent) {
    return WordsCompanion(
      id: Value(id),
      word: Value(word),
      frequency: Value(frequency),
      isKnown: Value(isKnown),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      meaning: meaning == null && nullToAbsent
          ? const Value.absent()
          : Value(meaning),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      definitions: definitions == null && nullToAbsent
          ? const Value.absent()
          : Value(definitions),
      examples: examples == null && nullToAbsent
          ? const Value.absent()
          : Value(examples),
      translations: translations == null && nullToAbsent
          ? const Value.absent()
          : Value(translations),
      synonyms: synonyms == null && nullToAbsent
          ? const Value.absent()
          : Value(synonyms),
      isExcluded: Value(isExcluded),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      reviewSchedule: reviewSchedule == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewSchedule),
    );
  }

  factory WordRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordRow(
      id: serializer.fromJson<int>(json['id']),
      word: serializer.fromJson<String>(json['word']),
      frequency: serializer.fromJson<int>(json['frequency']),
      isKnown: serializer.fromJson<bool>(json['isKnown']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      meaning: serializer.fromJson<String?>(json['meaning']),
      description: serializer.fromJson<String?>(json['description']),
      definitions: serializer.fromJson<List<String>?>(json['definitions']),
      examples: serializer.fromJson<List<String>?>(json['examples']),
      translations: serializer.fromJson<List<String>?>(json['translations']),
      synonyms: serializer.fromJson<List<String>?>(json['synonyms']),
      isExcluded: serializer.fromJson<bool>(json['isExcluded']),
      category: serializer.fromJson<String?>(json['category']),
      reviewSchedule: serializer.fromJson<String?>(json['reviewSchedule']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'word': serializer.toJson<String>(word),
      'frequency': serializer.toJson<int>(frequency),
      'isKnown': serializer.toJson<bool>(isKnown),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'meaning': serializer.toJson<String?>(meaning),
      'description': serializer.toJson<String?>(description),
      'definitions': serializer.toJson<List<String>?>(definitions),
      'examples': serializer.toJson<List<String>?>(examples),
      'translations': serializer.toJson<List<String>?>(translations),
      'synonyms': serializer.toJson<List<String>?>(synonyms),
      'isExcluded': serializer.toJson<bool>(isExcluded),
      'category': serializer.toJson<String?>(category),
      'reviewSchedule': serializer.toJson<String?>(reviewSchedule),
    };
  }

  WordRow copyWith(
          {int? id,
          String? word,
          int? frequency,
          bool? isKnown,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<String?> meaning = const Value.absent(),
          Value<String?> description = const Value.absent(),
          Value<List<String>?> definitions = const Value.absent(),
          Value<List<String>?> examples = const Value.absent(),
          Value<List<String>?> translations = const Value.absent(),
          Value<List<String>?> synonyms = const Value.absent(),
          bool? isExcluded,
          Value<String?> category = const Value.absent(),
          Value<String?> reviewSchedule = const Value.absent()}) =>
      WordRow(
        id: id ?? this.id,
        word: word ?? this.word,
        frequency: frequency ?? this.frequency,
        isKnown: isKnown ?? this.isKnown,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        meaning: meaning.present ? meaning.value : this.meaning,
        description: description.present ? description.value : this.description,
        definitions: definitions.present ? definitions.value : this.definitions,
        examples: examples.present ? examples.value : this.examples,
        translations:
            translations.present ? translations.value : this.translations,
        synonyms: synonyms.present ? synonyms.value : this.synonyms,
        isExcluded: isExcluded ?? this.isExcluded,
        category: category.present ? category.value : this.category,
        reviewSchedule:
            reviewSchedule.present ? reviewSchedule.value : this.reviewSchedule,
      );
  WordRow copyWithCompanion(WordsCompanion data) {
    return WordRow(
      id: data.id.present ? data.id.value : this.id,
      word: data.word.present ? data.word.value : this.word,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      isKnown: data.isKnown.present ? data.isKnown.value : this.isKnown,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      description:
          data.description.present ? data.description.value : this.description,
      definitions:
          data.definitions.present ? data.definitions.value : this.definitions,
      examples: data.examples.present ? data.examples.value : this.examples,
      translations: data.translations.present
          ? data.translations.value
          : this.translations,
      synonyms: data.synonyms.present ? data.synonyms.value : this.synonyms,
      isExcluded:
          data.isExcluded.present ? data.isExcluded.value : this.isExcluded,
      category: data.category.present ? data.category.value : this.category,
      reviewSchedule: data.reviewSchedule.present
          ? data.reviewSchedule.value
          : this.reviewSchedule,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordRow(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('frequency: $frequency, ')
          ..write('isKnown: $isKnown, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('meaning: $meaning, ')
          ..write('description: $description, ')
          ..write('definitions: $definitions, ')
          ..write('examples: $examples, ')
          ..write('translations: $translations, ')
          ..write('synonyms: $synonyms, ')
          ..write('isExcluded: $isExcluded, ')
          ..write('category: $category, ')
          ..write('reviewSchedule: $reviewSchedule')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      word,
      frequency,
      isKnown,
      createdAt,
      updatedAt,
      meaning,
      description,
      definitions,
      examples,
      translations,
      synonyms,
      isExcluded,
      category,
      reviewSchedule);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordRow &&
          other.id == this.id &&
          other.word == this.word &&
          other.frequency == this.frequency &&
          other.isKnown == this.isKnown &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.meaning == this.meaning &&
          other.description == this.description &&
          other.definitions == this.definitions &&
          other.examples == this.examples &&
          other.translations == this.translations &&
          other.synonyms == this.synonyms &&
          other.isExcluded == this.isExcluded &&
          other.category == this.category &&
          other.reviewSchedule == this.reviewSchedule);
}

class WordsCompanion extends UpdateCompanion<WordRow> {
  final Value<int> id;
  final Value<String> word;
  final Value<int> frequency;
  final Value<bool> isKnown;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> meaning;
  final Value<String?> description;
  final Value<List<String>?> definitions;
  final Value<List<String>?> examples;
  final Value<List<String>?> translations;
  final Value<List<String>?> synonyms;
  final Value<bool> isExcluded;
  final Value<String?> category;
  final Value<String?> reviewSchedule;
  const WordsCompanion({
    this.id = const Value.absent(),
    this.word = const Value.absent(),
    this.frequency = const Value.absent(),
    this.isKnown = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.meaning = const Value.absent(),
    this.description = const Value.absent(),
    this.definitions = const Value.absent(),
    this.examples = const Value.absent(),
    this.translations = const Value.absent(),
    this.synonyms = const Value.absent(),
    this.isExcluded = const Value.absent(),
    this.category = const Value.absent(),
    this.reviewSchedule = const Value.absent(),
  });
  WordsCompanion.insert({
    this.id = const Value.absent(),
    required String word,
    this.frequency = const Value.absent(),
    this.isKnown = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.meaning = const Value.absent(),
    this.description = const Value.absent(),
    this.definitions = const Value.absent(),
    this.examples = const Value.absent(),
    this.translations = const Value.absent(),
    this.synonyms = const Value.absent(),
    this.isExcluded = const Value.absent(),
    this.category = const Value.absent(),
    this.reviewSchedule = const Value.absent(),
  })  : word = Value(word),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<WordRow> custom({
    Expression<int>? id,
    Expression<String>? word,
    Expression<int>? frequency,
    Expression<bool>? isKnown,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? meaning,
    Expression<String>? description,
    Expression<String>? definitions,
    Expression<String>? examples,
    Expression<String>? translations,
    Expression<String>? synonyms,
    Expression<bool>? isExcluded,
    Expression<String>? category,
    Expression<String>? reviewSchedule,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (word != null) 'word': word,
      if (frequency != null) 'frequency': frequency,
      if (isKnown != null) 'is_known': isKnown,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (meaning != null) 'meaning': meaning,
      if (description != null) 'description': description,
      if (definitions != null) 'definitions': definitions,
      if (examples != null) 'examples': examples,
      if (translations != null) 'translations': translations,
      if (synonyms != null) 'synonyms': synonyms,
      if (isExcluded != null) 'is_excluded': isExcluded,
      if (category != null) 'category': category,
      if (reviewSchedule != null) 'review_schedule': reviewSchedule,
    });
  }

  WordsCompanion copyWith(
      {Value<int>? id,
      Value<String>? word,
      Value<int>? frequency,
      Value<bool>? isKnown,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String?>? meaning,
      Value<String?>? description,
      Value<List<String>?>? definitions,
      Value<List<String>?>? examples,
      Value<List<String>?>? translations,
      Value<List<String>?>? synonyms,
      Value<bool>? isExcluded,
      Value<String?>? category,
      Value<String?>? reviewSchedule}) {
    return WordsCompanion(
      id: id ?? this.id,
      word: word ?? this.word,
      frequency: frequency ?? this.frequency,
      isKnown: isKnown ?? this.isKnown,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      meaning: meaning ?? this.meaning,
      description: description ?? this.description,
      definitions: definitions ?? this.definitions,
      examples: examples ?? this.examples,
      translations: translations ?? this.translations,
      synonyms: synonyms ?? this.synonyms,
      isExcluded: isExcluded ?? this.isExcluded,
      category: category ?? this.category,
      reviewSchedule: reviewSchedule ?? this.reviewSchedule,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<int>(frequency.value);
    }
    if (isKnown.present) {
      map['is_known'] = Variable<bool>(isKnown.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (definitions.present) {
      map['definitions'] = Variable<String>(
          $WordsTable.$converterdefinitionsn.toSql(definitions.value));
    }
    if (examples.present) {
      map['examples'] = Variable<String>(
          $WordsTable.$converterexamplesn.toSql(examples.value));
    }
    if (translations.present) {
      map['translations'] = Variable<String>(
          $WordsTable.$convertertranslationsn.toSql(translations.value));
    }
    if (synonyms.present) {
      map['synonyms'] = Variable<String>(
          $WordsTable.$convertersynonymsn.toSql(synonyms.value));
    }
    if (isExcluded.present) {
      map['is_excluded'] = Variable<bool>(isExcluded.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (reviewSchedule.present) {
      map['review_schedule'] = Variable<String>(reviewSchedule.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordsCompanion(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('frequency: $frequency, ')
          ..write('isKnown: $isKnown, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('meaning: $meaning, ')
          ..write('description: $description, ')
          ..write('definitions: $definitions, ')
          ..write('examples: $examples, ')
          ..write('translations: $translations, ')
          ..write('synonyms: $synonyms, ')
          ..write('isExcluded: $isExcluded, ')
          ..write('category: $category, ')
          ..write('reviewSchedule: $reviewSchedule')
          ..write(')'))
        .toString();
  }
}

class $AnalyzedTextsTable extends AnalyzedTexts
    with TableInfo<$AnalyzedTextsTable, AnalyzedTextRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnalyzedTextsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalWordsMeta =
      const VerificationMeta('totalWords');
  @override
  late final GeneratedColumn<int> totalWords = GeneratedColumn<int>(
      'total_words', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _uniqueWordsMeta =
      const VerificationMeta('uniqueWords');
  @override
  late final GeneratedColumn<int> uniqueWords = GeneratedColumn<int>(
      'unique_words', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _knownWordsMeta =
      const VerificationMeta('knownWords');
  @override
  late final GeneratedColumn<int> knownWords = GeneratedColumn<int>(
      'known_words', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _unknownWordsMeta =
      const VerificationMeta('unknownWords');
  @override
  late final GeneratedColumn<int> unknownWords = GeneratedColumn<int>(
      'unknown_words', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String>
      excludedWords = GeneratedColumn<String>(
              'excluded_words', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<List<String>?>(
              $AnalyzedTextsTable.$converterexcludedWordsn);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        content,
        totalWords,
        uniqueWords,
        createdAt,
        knownWords,
        unknownWords,
        excludedWords
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'analyzed_texts';
  @override
  VerificationContext validateIntegrity(Insertable<AnalyzedTextRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('total_words')) {
      context.handle(
          _totalWordsMeta,
          totalWords.isAcceptableOrUnknown(
              data['total_words']!, _totalWordsMeta));
    } else if (isInserting) {
      context.missing(_totalWordsMeta);
    }
    if (data.containsKey('unique_words')) {
      context.handle(
          _uniqueWordsMeta,
          uniqueWords.isAcceptableOrUnknown(
              data['unique_words']!, _uniqueWordsMeta));
    } else if (isInserting) {
      context.missing(_uniqueWordsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('known_words')) {
      context.handle(
          _knownWordsMeta,
          knownWords.isAcceptableOrUnknown(
              data['known_words']!, _knownWordsMeta));
    }
    if (data.containsKey('unknown_words')) {
      context.handle(
          _unknownWordsMeta,
          unknownWords.isAcceptableOrUnknown(
              data['unknown_words']!, _unknownWordsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnalyzedTextRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnalyzedTextRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      totalWords: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_words'])!,
      uniqueWords: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unique_words'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      knownWords: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}known_words'])!,
      unknownWords: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unknown_words'])!,
      excludedWords: $AnalyzedTextsTable.$converterexcludedWordsn.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}excluded_words'])),
    );
  }

  @override
  $AnalyzedTextsTable createAlias(String alias) {
    return $AnalyzedTextsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterexcludedWords =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $converterexcludedWordsn =
      NullAwareTypeConverter.wrap($converterexcludedWords);
}

class AnalyzedTextRow extends DataClass implements Insertable<AnalyzedTextRow> {
  final int id;
  final String title;
  final String content;
  final int totalWords;
  final int uniqueWords;
  final DateTime createdAt;
  final int knownWords;
  final int unknownWords;
  final List<String>? excludedWords;
  const AnalyzedTextRow(
      {required this.id,
      required this.title,
      required this.content,
      required this.totalWords,
      required this.uniqueWords,
      required this.createdAt,
      required this.knownWords,
      required this.unknownWords,
      this.excludedWords});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    map['total_words'] = Variable<int>(totalWords);
    map['unique_words'] = Variable<int>(uniqueWords);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['known_words'] = Variable<int>(knownWords);
    map['unknown_words'] = Variable<int>(unknownWords);
    if (!nullToAbsent || excludedWords != null) {
      map['excluded_words'] = Variable<String>(
          $AnalyzedTextsTable.$converterexcludedWordsn.toSql(excludedWords));
    }
    return map;
  }

  AnalyzedTextsCompanion toCompanion(bool nullToAbsent) {
    return AnalyzedTextsCompanion(
      id: Value(id),
      title: Value(title),
      content: Value(content),
      totalWords: Value(totalWords),
      uniqueWords: Value(uniqueWords),
      createdAt: Value(createdAt),
      knownWords: Value(knownWords),
      unknownWords: Value(unknownWords),
      excludedWords: excludedWords == null && nullToAbsent
          ? const Value.absent()
          : Value(excludedWords),
    );
  }

  factory AnalyzedTextRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnalyzedTextRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      totalWords: serializer.fromJson<int>(json['totalWords']),
      uniqueWords: serializer.fromJson<int>(json['uniqueWords']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      knownWords: serializer.fromJson<int>(json['knownWords']),
      unknownWords: serializer.fromJson<int>(json['unknownWords']),
      excludedWords: serializer.fromJson<List<String>?>(json['excludedWords']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'totalWords': serializer.toJson<int>(totalWords),
      'uniqueWords': serializer.toJson<int>(uniqueWords),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'knownWords': serializer.toJson<int>(knownWords),
      'unknownWords': serializer.toJson<int>(unknownWords),
      'excludedWords': serializer.toJson<List<String>?>(excludedWords),
    };
  }

  AnalyzedTextRow copyWith(
          {int? id,
          String? title,
          String? content,
          int? totalWords,
          int? uniqueWords,
          DateTime? createdAt,
          int? knownWords,
          int? unknownWords,
          Value<List<String>?> excludedWords = const Value.absent()}) =>
      AnalyzedTextRow(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        totalWords: totalWords ?? this.totalWords,
        uniqueWords: uniqueWords ?? this.uniqueWords,
        createdAt: createdAt ?? this.createdAt,
        knownWords: knownWords ?? this.knownWords,
        unknownWords: unknownWords ?? this.unknownWords,
        excludedWords:
            excludedWords.present ? excludedWords.value : this.excludedWords,
      );
  AnalyzedTextRow copyWithCompanion(AnalyzedTextsCompanion data) {
    return AnalyzedTextRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      totalWords:
          data.totalWords.present ? data.totalWords.value : this.totalWords,
      uniqueWords:
          data.uniqueWords.present ? data.uniqueWords.value : this.uniqueWords,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      knownWords:
          data.knownWords.present ? data.knownWords.value : this.knownWords,
      unknownWords: data.unknownWords.present
          ? data.unknownWords.value
          : this.unknownWords,
      excludedWords: data.excludedWords.present
          ? data.excludedWords.value
          : this.excludedWords,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnalyzedTextRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('totalWords: $totalWords, ')
          ..write('uniqueWords: $uniqueWords, ')
          ..write('createdAt: $createdAt, ')
          ..write('knownWords: $knownWords, ')
          ..write('unknownWords: $unknownWords, ')
          ..write('excludedWords: $excludedWords')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, content, totalWords, uniqueWords,
      createdAt, knownWords, unknownWords, excludedWords);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnalyzedTextRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.content == this.content &&
          other.totalWords == this.totalWords &&
          other.uniqueWords == this.uniqueWords &&
          other.createdAt == this.createdAt &&
          other.knownWords == this.knownWords &&
          other.unknownWords == this.unknownWords &&
          other.excludedWords == this.excludedWords);
}

class AnalyzedTextsCompanion extends UpdateCompanion<AnalyzedTextRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> content;
  final Value<int> totalWords;
  final Value<int> uniqueWords;
  final Value<DateTime> createdAt;
  final Value<int> knownWords;
  final Value<int> unknownWords;
  final Value<List<String>?> excludedWords;
  const AnalyzedTextsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.totalWords = const Value.absent(),
    this.uniqueWords = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.knownWords = const Value.absent(),
    this.unknownWords = const Value.absent(),
    this.excludedWords = const Value.absent(),
  });
  AnalyzedTextsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String content,
    required int totalWords,
    required int uniqueWords,
    required DateTime createdAt,
    this.knownWords = const Value.absent(),
    this.unknownWords = const Value.absent(),
    this.excludedWords = const Value.absent(),
  })  : title = Value(title),
        content = Value(content),
        totalWords = Value(totalWords),
        uniqueWords = Value(uniqueWords),
        createdAt = Value(createdAt);
  static Insertable<AnalyzedTextRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? content,
    Expression<int>? totalWords,
    Expression<int>? uniqueWords,
    Expression<DateTime>? createdAt,
    Expression<int>? knownWords,
    Expression<int>? unknownWords,
    Expression<String>? excludedWords,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (totalWords != null) 'total_words': totalWords,
      if (uniqueWords != null) 'unique_words': uniqueWords,
      if (createdAt != null) 'created_at': createdAt,
      if (knownWords != null) 'known_words': knownWords,
      if (unknownWords != null) 'unknown_words': unknownWords,
      if (excludedWords != null) 'excluded_words': excludedWords,
    });
  }

  AnalyzedTextsCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String>? content,
      Value<int>? totalWords,
      Value<int>? uniqueWords,
      Value<DateTime>? createdAt,
      Value<int>? knownWords,
      Value<int>? unknownWords,
      Value<List<String>?>? excludedWords}) {
    return AnalyzedTextsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      totalWords: totalWords ?? this.totalWords,
      uniqueWords: uniqueWords ?? this.uniqueWords,
      createdAt: createdAt ?? this.createdAt,
      knownWords: knownWords ?? this.knownWords,
      unknownWords: unknownWords ?? this.unknownWords,
      excludedWords: excludedWords ?? this.excludedWords,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (totalWords.present) {
      map['total_words'] = Variable<int>(totalWords.value);
    }
    if (uniqueWords.present) {
      map['unique_words'] = Variable<int>(uniqueWords.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (knownWords.present) {
      map['known_words'] = Variable<int>(knownWords.value);
    }
    if (unknownWords.present) {
      map['unknown_words'] = Variable<int>(unknownWords.value);
    }
    if (excludedWords.present) {
      map['excluded_words'] = Variable<String>($AnalyzedTextsTable
          .$converterexcludedWordsn
          .toSql(excludedWords.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnalyzedTextsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('totalWords: $totalWords, ')
          ..write('uniqueWords: $uniqueWords, ')
          ..write('createdAt: $createdAt, ')
          ..write('knownWords: $knownWords, ')
          ..write('unknownWords: $unknownWords, ')
          ..write('excludedWords: $excludedWords')
          ..write(')'))
        .toString();
  }
}

class $TextWordEntriesTable extends TextWordEntries
    with TableInfo<$TextWordEntriesTable, TextWordEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TextWordEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _textIdMeta = const VerificationMeta('textId');
  @override
  late final GeneratedColumn<int> textId = GeneratedColumn<int>(
      'text_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES analyzed_texts (id) ON DELETE CASCADE'));
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
      'word_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES words (id) ON DELETE CASCADE'));
  static const VerificationMeta _localFrequencyMeta =
      const VerificationMeta('localFrequency');
  @override
  late final GeneratedColumn<int> localFrequency = GeneratedColumn<int>(
      'local_frequency', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns => [textId, wordId, localFrequency];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'text_word_entries';
  @override
  VerificationContext validateIntegrity(Insertable<TextWordEntryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('text_id')) {
      context.handle(_textIdMeta,
          textId.isAcceptableOrUnknown(data['text_id']!, _textIdMeta));
    } else if (isInserting) {
      context.missing(_textIdMeta);
    }
    if (data.containsKey('word_id')) {
      context.handle(_wordIdMeta,
          wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta));
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('local_frequency')) {
      context.handle(
          _localFrequencyMeta,
          localFrequency.isAcceptableOrUnknown(
              data['local_frequency']!, _localFrequencyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {textId, wordId};
  @override
  TextWordEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TextWordEntryRow(
      textId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}text_id'])!,
      wordId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}word_id'])!,
      localFrequency: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}local_frequency'])!,
    );
  }

  @override
  $TextWordEntriesTable createAlias(String alias) {
    return $TextWordEntriesTable(attachedDatabase, alias);
  }
}

class TextWordEntryRow extends DataClass
    implements Insertable<TextWordEntryRow> {
  final int textId;
  final int wordId;
  final int localFrequency;
  const TextWordEntryRow(
      {required this.textId,
      required this.wordId,
      required this.localFrequency});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['text_id'] = Variable<int>(textId);
    map['word_id'] = Variable<int>(wordId);
    map['local_frequency'] = Variable<int>(localFrequency);
    return map;
  }

  TextWordEntriesCompanion toCompanion(bool nullToAbsent) {
    return TextWordEntriesCompanion(
      textId: Value(textId),
      wordId: Value(wordId),
      localFrequency: Value(localFrequency),
    );
  }

  factory TextWordEntryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TextWordEntryRow(
      textId: serializer.fromJson<int>(json['textId']),
      wordId: serializer.fromJson<int>(json['wordId']),
      localFrequency: serializer.fromJson<int>(json['localFrequency']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'textId': serializer.toJson<int>(textId),
      'wordId': serializer.toJson<int>(wordId),
      'localFrequency': serializer.toJson<int>(localFrequency),
    };
  }

  TextWordEntryRow copyWith({int? textId, int? wordId, int? localFrequency}) =>
      TextWordEntryRow(
        textId: textId ?? this.textId,
        wordId: wordId ?? this.wordId,
        localFrequency: localFrequency ?? this.localFrequency,
      );
  TextWordEntryRow copyWithCompanion(TextWordEntriesCompanion data) {
    return TextWordEntryRow(
      textId: data.textId.present ? data.textId.value : this.textId,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      localFrequency: data.localFrequency.present
          ? data.localFrequency.value
          : this.localFrequency,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TextWordEntryRow(')
          ..write('textId: $textId, ')
          ..write('wordId: $wordId, ')
          ..write('localFrequency: $localFrequency')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(textId, wordId, localFrequency);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TextWordEntryRow &&
          other.textId == this.textId &&
          other.wordId == this.wordId &&
          other.localFrequency == this.localFrequency);
}

class TextWordEntriesCompanion extends UpdateCompanion<TextWordEntryRow> {
  final Value<int> textId;
  final Value<int> wordId;
  final Value<int> localFrequency;
  final Value<int> rowid;
  const TextWordEntriesCompanion({
    this.textId = const Value.absent(),
    this.wordId = const Value.absent(),
    this.localFrequency = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TextWordEntriesCompanion.insert({
    required int textId,
    required int wordId,
    this.localFrequency = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : textId = Value(textId),
        wordId = Value(wordId);
  static Insertable<TextWordEntryRow> custom({
    Expression<int>? textId,
    Expression<int>? wordId,
    Expression<int>? localFrequency,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (textId != null) 'text_id': textId,
      if (wordId != null) 'word_id': wordId,
      if (localFrequency != null) 'local_frequency': localFrequency,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TextWordEntriesCompanion copyWith(
      {Value<int>? textId,
      Value<int>? wordId,
      Value<int>? localFrequency,
      Value<int>? rowid}) {
    return TextWordEntriesCompanion(
      textId: textId ?? this.textId,
      wordId: wordId ?? this.wordId,
      localFrequency: localFrequency ?? this.localFrequency,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (textId.present) {
      map['text_id'] = Variable<int>(textId.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (localFrequency.present) {
      map['local_frequency'] = Variable<int>(localFrequency.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TextWordEntriesCompanion(')
          ..write('textId: $textId, ')
          ..write('wordId: $wordId, ')
          ..write('localFrequency: $localFrequency, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomTagsTable extends CustomTags
    with TableInfo<$CustomTagsTable, CustomTagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_tags';
  @override
  VerificationContext validateIntegrity(Insertable<CustomTagRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomTagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomTagRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $CustomTagsTable createAlias(String alias) {
    return $CustomTagsTable(attachedDatabase, alias);
  }
}

class CustomTagRow extends DataClass implements Insertable<CustomTagRow> {
  final int id;
  final String name;
  const CustomTagRow({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  CustomTagsCompanion toCompanion(bool nullToAbsent) {
    return CustomTagsCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory CustomTagRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomTagRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  CustomTagRow copyWith({int? id, String? name}) => CustomTagRow(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  CustomTagRow copyWithCompanion(CustomTagsCompanion data) {
    return CustomTagRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomTagRow(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomTagRow && other.id == this.id && other.name == this.name);
}

class CustomTagsCompanion extends UpdateCompanion<CustomTagRow> {
  final Value<int> id;
  final Value<String> name;
  const CustomTagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  CustomTagsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<CustomTagRow> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  CustomTagsCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return CustomTagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomTagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $WordCustomTagsTable extends WordCustomTags
    with TableInfo<$WordCustomTagsTable, WordCustomTagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordCustomTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
      'word_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES words (id) ON DELETE CASCADE'));
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES custom_tags (id) ON DELETE CASCADE'));
  @override
  List<GeneratedColumn> get $columns => [wordId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_custom_tags';
  @override
  VerificationContext validateIntegrity(Insertable<WordCustomTagRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('word_id')) {
      context.handle(_wordIdMeta,
          wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta));
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {wordId, tagId};
  @override
  WordCustomTagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordCustomTagRow(
      wordId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}word_id'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tag_id'])!,
    );
  }

  @override
  $WordCustomTagsTable createAlias(String alias) {
    return $WordCustomTagsTable(attachedDatabase, alias);
  }
}

class WordCustomTagRow extends DataClass
    implements Insertable<WordCustomTagRow> {
  final int wordId;
  final int tagId;
  const WordCustomTagRow({required this.wordId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['word_id'] = Variable<int>(wordId);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  WordCustomTagsCompanion toCompanion(bool nullToAbsent) {
    return WordCustomTagsCompanion(
      wordId: Value(wordId),
      tagId: Value(tagId),
    );
  }

  factory WordCustomTagRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordCustomTagRow(
      wordId: serializer.fromJson<int>(json['wordId']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'wordId': serializer.toJson<int>(wordId),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  WordCustomTagRow copyWith({int? wordId, int? tagId}) => WordCustomTagRow(
        wordId: wordId ?? this.wordId,
        tagId: tagId ?? this.tagId,
      );
  WordCustomTagRow copyWithCompanion(WordCustomTagsCompanion data) {
    return WordCustomTagRow(
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordCustomTagRow(')
          ..write('wordId: $wordId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(wordId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordCustomTagRow &&
          other.wordId == this.wordId &&
          other.tagId == this.tagId);
}

class WordCustomTagsCompanion extends UpdateCompanion<WordCustomTagRow> {
  final Value<int> wordId;
  final Value<int> tagId;
  final Value<int> rowid;
  const WordCustomTagsCompanion({
    this.wordId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WordCustomTagsCompanion.insert({
    required int wordId,
    required int tagId,
    this.rowid = const Value.absent(),
  })  : wordId = Value(wordId),
        tagId = Value(tagId);
  static Insertable<WordCustomTagRow> custom({
    Expression<int>? wordId,
    Expression<int>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (wordId != null) 'word_id': wordId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WordCustomTagsCompanion copyWith(
      {Value<int>? wordId, Value<int>? tagId, Value<int>? rowid}) {
    return WordCustomTagsCompanion(
      wordId: wordId ?? this.wordId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordCustomTagsCompanion(')
          ..write('wordId: $wordId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WordsTable words = $WordsTable(this);
  late final $AnalyzedTextsTable analyzedTexts = $AnalyzedTextsTable(this);
  late final $TextWordEntriesTable textWordEntries =
      $TextWordEntriesTable(this);
  late final $CustomTagsTable customTags = $CustomTagsTable(this);
  late final $WordCustomTagsTable wordCustomTags = $WordCustomTagsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [words, analyzedTexts, textWordEntries, customTags, wordCustomTags];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('analyzed_texts',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('text_word_entries', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('words',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('text_word_entries', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('words',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('word_custom_tags', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('custom_tags',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('word_custom_tags', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$WordsTableCreateCompanionBuilder = WordsCompanion Function({
  Value<int> id,
  required String word,
  Value<int> frequency,
  Value<bool> isKnown,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String?> meaning,
  Value<String?> description,
  Value<List<String>?> definitions,
  Value<List<String>?> examples,
  Value<List<String>?> translations,
  Value<List<String>?> synonyms,
  Value<bool> isExcluded,
  Value<String?> category,
  Value<String?> reviewSchedule,
});
typedef $$WordsTableUpdateCompanionBuilder = WordsCompanion Function({
  Value<int> id,
  Value<String> word,
  Value<int> frequency,
  Value<bool> isKnown,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String?> meaning,
  Value<String?> description,
  Value<List<String>?> definitions,
  Value<List<String>?> examples,
  Value<List<String>?> translations,
  Value<List<String>?> synonyms,
  Value<bool> isExcluded,
  Value<String?> category,
  Value<String?> reviewSchedule,
});

final class $$WordsTableReferences
    extends BaseReferences<_$AppDatabase, $WordsTable, WordRow> {
  $$WordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TextWordEntriesTable, List<TextWordEntryRow>>
      _textWordEntriesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.textWordEntries,
              aliasName:
                  $_aliasNameGenerator(db.words.id, db.textWordEntries.wordId));

  $$TextWordEntriesTableProcessedTableManager get textWordEntriesRefs {
    final manager =
        $$TextWordEntriesTableTableManager($_db, $_db.textWordEntries)
            .filter((f) => f.wordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_textWordEntriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$WordCustomTagsTable, List<WordCustomTagRow>>
      _wordCustomTagsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.wordCustomTags,
              aliasName:
                  $_aliasNameGenerator(db.words.id, db.wordCustomTags.wordId));

  $$WordCustomTagsTableProcessedTableManager get wordCustomTagsRefs {
    final manager = $$WordCustomTagsTableTableManager($_db, $_db.wordCustomTags)
        .filter((f) => f.wordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordCustomTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$WordsTableFilterComposer extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isKnown => $composableBuilder(
      column: $table.isKnown, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get meaning => $composableBuilder(
      column: $table.meaning, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
      get definitions => $composableBuilder(
          column: $table.definitions,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
      get examples => $composableBuilder(
          column: $table.examples,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
      get translations => $composableBuilder(
          column: $table.translations,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
      get synonyms => $composableBuilder(
          column: $table.synonyms,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get isExcluded => $composableBuilder(
      column: $table.isExcluded, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reviewSchedule => $composableBuilder(
      column: $table.reviewSchedule,
      builder: (column) => ColumnFilters(column));

  Expression<bool> textWordEntriesRefs(
      Expression<bool> Function($$TextWordEntriesTableFilterComposer f) f) {
    final $$TextWordEntriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.textWordEntries,
        getReferencedColumn: (t) => t.wordId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TextWordEntriesTableFilterComposer(
              $db: $db,
              $table: $db.textWordEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> wordCustomTagsRefs(
      Expression<bool> Function($$WordCustomTagsTableFilterComposer f) f) {
    final $$WordCustomTagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.wordCustomTags,
        getReferencedColumn: (t) => t.wordId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordCustomTagsTableFilterComposer(
              $db: $db,
              $table: $db.wordCustomTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isKnown => $composableBuilder(
      column: $table.isKnown, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get meaning => $composableBuilder(
      column: $table.meaning, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get definitions => $composableBuilder(
      column: $table.definitions, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get examples => $composableBuilder(
      column: $table.examples, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get translations => $composableBuilder(
      column: $table.translations,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get synonyms => $composableBuilder(
      column: $table.synonyms, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isExcluded => $composableBuilder(
      column: $table.isExcluded, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reviewSchedule => $composableBuilder(
      column: $table.reviewSchedule,
      builder: (column) => ColumnOrderings(column));
}

class $$WordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<int> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<bool> get isKnown =>
      $composableBuilder(column: $table.isKnown, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get definitions =>
      $composableBuilder(
          column: $table.definitions, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get examples =>
      $composableBuilder(column: $table.examples, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get translations =>
      $composableBuilder(
          column: $table.translations, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get synonyms =>
      $composableBuilder(column: $table.synonyms, builder: (column) => column);

  GeneratedColumn<bool> get isExcluded => $composableBuilder(
      column: $table.isExcluded, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get reviewSchedule => $composableBuilder(
      column: $table.reviewSchedule, builder: (column) => column);

  Expression<T> textWordEntriesRefs<T extends Object>(
      Expression<T> Function($$TextWordEntriesTableAnnotationComposer a) f) {
    final $$TextWordEntriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.textWordEntries,
        getReferencedColumn: (t) => t.wordId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TextWordEntriesTableAnnotationComposer(
              $db: $db,
              $table: $db.textWordEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> wordCustomTagsRefs<T extends Object>(
      Expression<T> Function($$WordCustomTagsTableAnnotationComposer a) f) {
    final $$WordCustomTagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.wordCustomTags,
        getReferencedColumn: (t) => t.wordId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordCustomTagsTableAnnotationComposer(
              $db: $db,
              $table: $db.wordCustomTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WordsTable,
    WordRow,
    $$WordsTableFilterComposer,
    $$WordsTableOrderingComposer,
    $$WordsTableAnnotationComposer,
    $$WordsTableCreateCompanionBuilder,
    $$WordsTableUpdateCompanionBuilder,
    (WordRow, $$WordsTableReferences),
    WordRow,
    PrefetchHooks Function(
        {bool textWordEntriesRefs, bool wordCustomTagsRefs})> {
  $$WordsTableTableManager(_$AppDatabase db, $WordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> word = const Value.absent(),
            Value<int> frequency = const Value.absent(),
            Value<bool> isKnown = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String?> meaning = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<List<String>?> definitions = const Value.absent(),
            Value<List<String>?> examples = const Value.absent(),
            Value<List<String>?> translations = const Value.absent(),
            Value<List<String>?> synonyms = const Value.absent(),
            Value<bool> isExcluded = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> reviewSchedule = const Value.absent(),
          }) =>
              WordsCompanion(
            id: id,
            word: word,
            frequency: frequency,
            isKnown: isKnown,
            createdAt: createdAt,
            updatedAt: updatedAt,
            meaning: meaning,
            description: description,
            definitions: definitions,
            examples: examples,
            translations: translations,
            synonyms: synonyms,
            isExcluded: isExcluded,
            category: category,
            reviewSchedule: reviewSchedule,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String word,
            Value<int> frequency = const Value.absent(),
            Value<bool> isKnown = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String?> meaning = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<List<String>?> definitions = const Value.absent(),
            Value<List<String>?> examples = const Value.absent(),
            Value<List<String>?> translations = const Value.absent(),
            Value<List<String>?> synonyms = const Value.absent(),
            Value<bool> isExcluded = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> reviewSchedule = const Value.absent(),
          }) =>
              WordsCompanion.insert(
            id: id,
            word: word,
            frequency: frequency,
            isKnown: isKnown,
            createdAt: createdAt,
            updatedAt: updatedAt,
            meaning: meaning,
            description: description,
            definitions: definitions,
            examples: examples,
            translations: translations,
            synonyms: synonyms,
            isExcluded: isExcluded,
            category: category,
            reviewSchedule: reviewSchedule,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$WordsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {textWordEntriesRefs = false, wordCustomTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (textWordEntriesRefs) db.textWordEntries,
                if (wordCustomTagsRefs) db.wordCustomTags
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (textWordEntriesRefs)
                    await $_getPrefetchedData<WordRow, $WordsTable,
                            TextWordEntryRow>(
                        currentTable: table,
                        referencedTable: $$WordsTableReferences
                            ._textWordEntriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WordsTableReferences(db, table, p0)
                                .textWordEntriesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.wordId == item.id),
                        typedResults: items),
                  if (wordCustomTagsRefs)
                    await $_getPrefetchedData<WordRow, $WordsTable,
                            WordCustomTagRow>(
                        currentTable: table,
                        referencedTable:
                            $$WordsTableReferences._wordCustomTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WordsTableReferences(db, table, p0)
                                .wordCustomTagsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.wordId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$WordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WordsTable,
    WordRow,
    $$WordsTableFilterComposer,
    $$WordsTableOrderingComposer,
    $$WordsTableAnnotationComposer,
    $$WordsTableCreateCompanionBuilder,
    $$WordsTableUpdateCompanionBuilder,
    (WordRow, $$WordsTableReferences),
    WordRow,
    PrefetchHooks Function(
        {bool textWordEntriesRefs, bool wordCustomTagsRefs})>;
typedef $$AnalyzedTextsTableCreateCompanionBuilder = AnalyzedTextsCompanion
    Function({
  Value<int> id,
  required String title,
  required String content,
  required int totalWords,
  required int uniqueWords,
  required DateTime createdAt,
  Value<int> knownWords,
  Value<int> unknownWords,
  Value<List<String>?> excludedWords,
});
typedef $$AnalyzedTextsTableUpdateCompanionBuilder = AnalyzedTextsCompanion
    Function({
  Value<int> id,
  Value<String> title,
  Value<String> content,
  Value<int> totalWords,
  Value<int> uniqueWords,
  Value<DateTime> createdAt,
  Value<int> knownWords,
  Value<int> unknownWords,
  Value<List<String>?> excludedWords,
});

final class $$AnalyzedTextsTableReferences extends BaseReferences<_$AppDatabase,
    $AnalyzedTextsTable, AnalyzedTextRow> {
  $$AnalyzedTextsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TextWordEntriesTable, List<TextWordEntryRow>>
      _textWordEntriesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.textWordEntries,
              aliasName: $_aliasNameGenerator(
                  db.analyzedTexts.id, db.textWordEntries.textId));

  $$TextWordEntriesTableProcessedTableManager get textWordEntriesRefs {
    final manager =
        $$TextWordEntriesTableTableManager($_db, $_db.textWordEntries)
            .filter((f) => f.textId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_textWordEntriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AnalyzedTextsTableFilterComposer
    extends Composer<_$AppDatabase, $AnalyzedTextsTable> {
  $$AnalyzedTextsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalWords => $composableBuilder(
      column: $table.totalWords, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get uniqueWords => $composableBuilder(
      column: $table.uniqueWords, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get knownWords => $composableBuilder(
      column: $table.knownWords, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unknownWords => $composableBuilder(
      column: $table.unknownWords, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
      get excludedWords => $composableBuilder(
          column: $table.excludedWords,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  Expression<bool> textWordEntriesRefs(
      Expression<bool> Function($$TextWordEntriesTableFilterComposer f) f) {
    final $$TextWordEntriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.textWordEntries,
        getReferencedColumn: (t) => t.textId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TextWordEntriesTableFilterComposer(
              $db: $db,
              $table: $db.textWordEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AnalyzedTextsTableOrderingComposer
    extends Composer<_$AppDatabase, $AnalyzedTextsTable> {
  $$AnalyzedTextsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalWords => $composableBuilder(
      column: $table.totalWords, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get uniqueWords => $composableBuilder(
      column: $table.uniqueWords, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get knownWords => $composableBuilder(
      column: $table.knownWords, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unknownWords => $composableBuilder(
      column: $table.unknownWords,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get excludedWords => $composableBuilder(
      column: $table.excludedWords,
      builder: (column) => ColumnOrderings(column));
}

class $$AnalyzedTextsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnalyzedTextsTable> {
  $$AnalyzedTextsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get totalWords => $composableBuilder(
      column: $table.totalWords, builder: (column) => column);

  GeneratedColumn<int> get uniqueWords => $composableBuilder(
      column: $table.uniqueWords, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get knownWords => $composableBuilder(
      column: $table.knownWords, builder: (column) => column);

  GeneratedColumn<int> get unknownWords => $composableBuilder(
      column: $table.unknownWords, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get excludedWords =>
      $composableBuilder(
          column: $table.excludedWords, builder: (column) => column);

  Expression<T> textWordEntriesRefs<T extends Object>(
      Expression<T> Function($$TextWordEntriesTableAnnotationComposer a) f) {
    final $$TextWordEntriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.textWordEntries,
        getReferencedColumn: (t) => t.textId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TextWordEntriesTableAnnotationComposer(
              $db: $db,
              $table: $db.textWordEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AnalyzedTextsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AnalyzedTextsTable,
    AnalyzedTextRow,
    $$AnalyzedTextsTableFilterComposer,
    $$AnalyzedTextsTableOrderingComposer,
    $$AnalyzedTextsTableAnnotationComposer,
    $$AnalyzedTextsTableCreateCompanionBuilder,
    $$AnalyzedTextsTableUpdateCompanionBuilder,
    (AnalyzedTextRow, $$AnalyzedTextsTableReferences),
    AnalyzedTextRow,
    PrefetchHooks Function({bool textWordEntriesRefs})> {
  $$AnalyzedTextsTableTableManager(_$AppDatabase db, $AnalyzedTextsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnalyzedTextsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnalyzedTextsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnalyzedTextsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<int> totalWords = const Value.absent(),
            Value<int> uniqueWords = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> knownWords = const Value.absent(),
            Value<int> unknownWords = const Value.absent(),
            Value<List<String>?> excludedWords = const Value.absent(),
          }) =>
              AnalyzedTextsCompanion(
            id: id,
            title: title,
            content: content,
            totalWords: totalWords,
            uniqueWords: uniqueWords,
            createdAt: createdAt,
            knownWords: knownWords,
            unknownWords: unknownWords,
            excludedWords: excludedWords,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            required String content,
            required int totalWords,
            required int uniqueWords,
            required DateTime createdAt,
            Value<int> knownWords = const Value.absent(),
            Value<int> unknownWords = const Value.absent(),
            Value<List<String>?> excludedWords = const Value.absent(),
          }) =>
              AnalyzedTextsCompanion.insert(
            id: id,
            title: title,
            content: content,
            totalWords: totalWords,
            uniqueWords: uniqueWords,
            createdAt: createdAt,
            knownWords: knownWords,
            unknownWords: unknownWords,
            excludedWords: excludedWords,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AnalyzedTextsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({textWordEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (textWordEntriesRefs) db.textWordEntries
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (textWordEntriesRefs)
                    await $_getPrefetchedData<AnalyzedTextRow,
                            $AnalyzedTextsTable, TextWordEntryRow>(
                        currentTable: table,
                        referencedTable: $$AnalyzedTextsTableReferences
                            ._textWordEntriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AnalyzedTextsTableReferences(db, table, p0)
                                .textWordEntriesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.textId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AnalyzedTextsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AnalyzedTextsTable,
    AnalyzedTextRow,
    $$AnalyzedTextsTableFilterComposer,
    $$AnalyzedTextsTableOrderingComposer,
    $$AnalyzedTextsTableAnnotationComposer,
    $$AnalyzedTextsTableCreateCompanionBuilder,
    $$AnalyzedTextsTableUpdateCompanionBuilder,
    (AnalyzedTextRow, $$AnalyzedTextsTableReferences),
    AnalyzedTextRow,
    PrefetchHooks Function({bool textWordEntriesRefs})>;
typedef $$TextWordEntriesTableCreateCompanionBuilder = TextWordEntriesCompanion
    Function({
  required int textId,
  required int wordId,
  Value<int> localFrequency,
  Value<int> rowid,
});
typedef $$TextWordEntriesTableUpdateCompanionBuilder = TextWordEntriesCompanion
    Function({
  Value<int> textId,
  Value<int> wordId,
  Value<int> localFrequency,
  Value<int> rowid,
});

final class $$TextWordEntriesTableReferences extends BaseReferences<
    _$AppDatabase, $TextWordEntriesTable, TextWordEntryRow> {
  $$TextWordEntriesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $AnalyzedTextsTable _textIdTable(_$AppDatabase db) =>
      db.analyzedTexts.createAlias(
          $_aliasNameGenerator(db.textWordEntries.textId, db.analyzedTexts.id));

  $$AnalyzedTextsTableProcessedTableManager get textId {
    final $_column = $_itemColumn<int>('text_id')!;

    final manager = $$AnalyzedTextsTableTableManager($_db, $_db.analyzedTexts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_textIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $WordsTable _wordIdTable(_$AppDatabase db) => db.words.createAlias(
      $_aliasNameGenerator(db.textWordEntries.wordId, db.words.id));

  $$WordsTableProcessedTableManager get wordId {
    final $_column = $_itemColumn<int>('word_id')!;

    final manager = $$WordsTableTableManager($_db, $_db.words)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TextWordEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $TextWordEntriesTable> {
  $$TextWordEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localFrequency => $composableBuilder(
      column: $table.localFrequency,
      builder: (column) => ColumnFilters(column));

  $$AnalyzedTextsTableFilterComposer get textId {
    final $$AnalyzedTextsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.textId,
        referencedTable: $db.analyzedTexts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnalyzedTextsTableFilterComposer(
              $db: $db,
              $table: $db.analyzedTexts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.wordId,
        referencedTable: $db.words,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordsTableFilterComposer(
              $db: $db,
              $table: $db.words,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TextWordEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TextWordEntriesTable> {
  $$TextWordEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localFrequency => $composableBuilder(
      column: $table.localFrequency,
      builder: (column) => ColumnOrderings(column));

  $$AnalyzedTextsTableOrderingComposer get textId {
    final $$AnalyzedTextsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.textId,
        referencedTable: $db.analyzedTexts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnalyzedTextsTableOrderingComposer(
              $db: $db,
              $table: $db.analyzedTexts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.wordId,
        referencedTable: $db.words,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordsTableOrderingComposer(
              $db: $db,
              $table: $db.words,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TextWordEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TextWordEntriesTable> {
  $$TextWordEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localFrequency => $composableBuilder(
      column: $table.localFrequency, builder: (column) => column);

  $$AnalyzedTextsTableAnnotationComposer get textId {
    final $$AnalyzedTextsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.textId,
        referencedTable: $db.analyzedTexts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnalyzedTextsTableAnnotationComposer(
              $db: $db,
              $table: $db.analyzedTexts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.wordId,
        referencedTable: $db.words,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordsTableAnnotationComposer(
              $db: $db,
              $table: $db.words,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TextWordEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TextWordEntriesTable,
    TextWordEntryRow,
    $$TextWordEntriesTableFilterComposer,
    $$TextWordEntriesTableOrderingComposer,
    $$TextWordEntriesTableAnnotationComposer,
    $$TextWordEntriesTableCreateCompanionBuilder,
    $$TextWordEntriesTableUpdateCompanionBuilder,
    (TextWordEntryRow, $$TextWordEntriesTableReferences),
    TextWordEntryRow,
    PrefetchHooks Function({bool textId, bool wordId})> {
  $$TextWordEntriesTableTableManager(
      _$AppDatabase db, $TextWordEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TextWordEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TextWordEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TextWordEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> textId = const Value.absent(),
            Value<int> wordId = const Value.absent(),
            Value<int> localFrequency = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TextWordEntriesCompanion(
            textId: textId,
            wordId: wordId,
            localFrequency: localFrequency,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int textId,
            required int wordId,
            Value<int> localFrequency = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TextWordEntriesCompanion.insert(
            textId: textId,
            wordId: wordId,
            localFrequency: localFrequency,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TextWordEntriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({textId = false, wordId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (textId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.textId,
                    referencedTable:
                        $$TextWordEntriesTableReferences._textIdTable(db),
                    referencedColumn:
                        $$TextWordEntriesTableReferences._textIdTable(db).id,
                  ) as T;
                }
                if (wordId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.wordId,
                    referencedTable:
                        $$TextWordEntriesTableReferences._wordIdTable(db),
                    referencedColumn:
                        $$TextWordEntriesTableReferences._wordIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TextWordEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TextWordEntriesTable,
    TextWordEntryRow,
    $$TextWordEntriesTableFilterComposer,
    $$TextWordEntriesTableOrderingComposer,
    $$TextWordEntriesTableAnnotationComposer,
    $$TextWordEntriesTableCreateCompanionBuilder,
    $$TextWordEntriesTableUpdateCompanionBuilder,
    (TextWordEntryRow, $$TextWordEntriesTableReferences),
    TextWordEntryRow,
    PrefetchHooks Function({bool textId, bool wordId})>;
typedef $$CustomTagsTableCreateCompanionBuilder = CustomTagsCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$CustomTagsTableUpdateCompanionBuilder = CustomTagsCompanion Function({
  Value<int> id,
  Value<String> name,
});

final class $$CustomTagsTableReferences
    extends BaseReferences<_$AppDatabase, $CustomTagsTable, CustomTagRow> {
  $$CustomTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WordCustomTagsTable, List<WordCustomTagRow>>
      _wordCustomTagsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.wordCustomTags,
              aliasName: $_aliasNameGenerator(
                  db.customTags.id, db.wordCustomTags.tagId));

  $$WordCustomTagsTableProcessedTableManager get wordCustomTagsRefs {
    final manager = $$WordCustomTagsTableTableManager($_db, $_db.wordCustomTags)
        .filter((f) => f.tagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordCustomTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CustomTagsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomTagsTable> {
  $$CustomTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  Expression<bool> wordCustomTagsRefs(
      Expression<bool> Function($$WordCustomTagsTableFilterComposer f) f) {
    final $$WordCustomTagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.wordCustomTags,
        getReferencedColumn: (t) => t.tagId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordCustomTagsTableFilterComposer(
              $db: $db,
              $table: $db.wordCustomTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CustomTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomTagsTable> {
  $$CustomTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$CustomTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomTagsTable> {
  $$CustomTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> wordCustomTagsRefs<T extends Object>(
      Expression<T> Function($$WordCustomTagsTableAnnotationComposer a) f) {
    final $$WordCustomTagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.wordCustomTags,
        getReferencedColumn: (t) => t.tagId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordCustomTagsTableAnnotationComposer(
              $db: $db,
              $table: $db.wordCustomTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CustomTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CustomTagsTable,
    CustomTagRow,
    $$CustomTagsTableFilterComposer,
    $$CustomTagsTableOrderingComposer,
    $$CustomTagsTableAnnotationComposer,
    $$CustomTagsTableCreateCompanionBuilder,
    $$CustomTagsTableUpdateCompanionBuilder,
    (CustomTagRow, $$CustomTagsTableReferences),
    CustomTagRow,
    PrefetchHooks Function({bool wordCustomTagsRefs})> {
  $$CustomTagsTableTableManager(_$AppDatabase db, $CustomTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) =>
              CustomTagsCompanion(
            id: id,
            name: name,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) =>
              CustomTagsCompanion.insert(
            id: id,
            name: name,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CustomTagsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({wordCustomTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (wordCustomTagsRefs) db.wordCustomTags
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (wordCustomTagsRefs)
                    await $_getPrefetchedData<CustomTagRow, $CustomTagsTable,
                            WordCustomTagRow>(
                        currentTable: table,
                        referencedTable: $$CustomTagsTableReferences
                            ._wordCustomTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CustomTagsTableReferences(db, table, p0)
                                .wordCustomTagsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.tagId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CustomTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CustomTagsTable,
    CustomTagRow,
    $$CustomTagsTableFilterComposer,
    $$CustomTagsTableOrderingComposer,
    $$CustomTagsTableAnnotationComposer,
    $$CustomTagsTableCreateCompanionBuilder,
    $$CustomTagsTableUpdateCompanionBuilder,
    (CustomTagRow, $$CustomTagsTableReferences),
    CustomTagRow,
    PrefetchHooks Function({bool wordCustomTagsRefs})>;
typedef $$WordCustomTagsTableCreateCompanionBuilder = WordCustomTagsCompanion
    Function({
  required int wordId,
  required int tagId,
  Value<int> rowid,
});
typedef $$WordCustomTagsTableUpdateCompanionBuilder = WordCustomTagsCompanion
    Function({
  Value<int> wordId,
  Value<int> tagId,
  Value<int> rowid,
});

final class $$WordCustomTagsTableReferences extends BaseReferences<
    _$AppDatabase, $WordCustomTagsTable, WordCustomTagRow> {
  $$WordCustomTagsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $WordsTable _wordIdTable(_$AppDatabase db) => db.words
      .createAlias($_aliasNameGenerator(db.wordCustomTags.wordId, db.words.id));

  $$WordsTableProcessedTableManager get wordId {
    final $_column = $_itemColumn<int>('word_id')!;

    final manager = $$WordsTableTableManager($_db, $_db.words)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $CustomTagsTable _tagIdTable(_$AppDatabase db) =>
      db.customTags.createAlias(
          $_aliasNameGenerator(db.wordCustomTags.tagId, db.customTags.id));

  $$CustomTagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<int>('tag_id')!;

    final manager = $$CustomTagsTableTableManager($_db, $_db.customTags)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$WordCustomTagsTableFilterComposer
    extends Composer<_$AppDatabase, $WordCustomTagsTable> {
  $$WordCustomTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.wordId,
        referencedTable: $db.words,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordsTableFilterComposer(
              $db: $db,
              $table: $db.words,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CustomTagsTableFilterComposer get tagId {
    final $$CustomTagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $db.customTags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomTagsTableFilterComposer(
              $db: $db,
              $table: $db.customTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WordCustomTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordCustomTagsTable> {
  $$WordCustomTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.wordId,
        referencedTable: $db.words,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordsTableOrderingComposer(
              $db: $db,
              $table: $db.words,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CustomTagsTableOrderingComposer get tagId {
    final $$CustomTagsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $db.customTags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomTagsTableOrderingComposer(
              $db: $db,
              $table: $db.customTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WordCustomTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordCustomTagsTable> {
  $$WordCustomTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.wordId,
        referencedTable: $db.words,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordsTableAnnotationComposer(
              $db: $db,
              $table: $db.words,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CustomTagsTableAnnotationComposer get tagId {
    final $$CustomTagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $db.customTags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomTagsTableAnnotationComposer(
              $db: $db,
              $table: $db.customTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WordCustomTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WordCustomTagsTable,
    WordCustomTagRow,
    $$WordCustomTagsTableFilterComposer,
    $$WordCustomTagsTableOrderingComposer,
    $$WordCustomTagsTableAnnotationComposer,
    $$WordCustomTagsTableCreateCompanionBuilder,
    $$WordCustomTagsTableUpdateCompanionBuilder,
    (WordCustomTagRow, $$WordCustomTagsTableReferences),
    WordCustomTagRow,
    PrefetchHooks Function({bool wordId, bool tagId})> {
  $$WordCustomTagsTableTableManager(
      _$AppDatabase db, $WordCustomTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordCustomTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordCustomTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordCustomTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> wordId = const Value.absent(),
            Value<int> tagId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WordCustomTagsCompanion(
            wordId: wordId,
            tagId: tagId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int wordId,
            required int tagId,
            Value<int> rowid = const Value.absent(),
          }) =>
              WordCustomTagsCompanion.insert(
            wordId: wordId,
            tagId: tagId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$WordCustomTagsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({wordId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (wordId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.wordId,
                    referencedTable:
                        $$WordCustomTagsTableReferences._wordIdTable(db),
                    referencedColumn:
                        $$WordCustomTagsTableReferences._wordIdTable(db).id,
                  ) as T;
                }
                if (tagId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.tagId,
                    referencedTable:
                        $$WordCustomTagsTableReferences._tagIdTable(db),
                    referencedColumn:
                        $$WordCustomTagsTableReferences._tagIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$WordCustomTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WordCustomTagsTable,
    WordCustomTagRow,
    $$WordCustomTagsTableFilterComposer,
    $$WordCustomTagsTableOrderingComposer,
    $$WordCustomTagsTableAnnotationComposer,
    $$WordCustomTagsTableCreateCompanionBuilder,
    $$WordCustomTagsTableUpdateCompanionBuilder,
    (WordCustomTagRow, $$WordCustomTagsTableReferences),
    WordCustomTagRow,
    PrefetchHooks Function({bool wordId, bool tagId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WordsTableTableManager get words =>
      $$WordsTableTableManager(_db, _db.words);
  $$AnalyzedTextsTableTableManager get analyzedTexts =>
      $$AnalyzedTextsTableTableManager(_db, _db.analyzedTexts);
  $$TextWordEntriesTableTableManager get textWordEntries =>
      $$TextWordEntriesTableTableManager(_db, _db.textWordEntries);
  $$CustomTagsTableTableManager get customTags =>
      $$CustomTagsTableTableManager(_db, _db.customTags);
  $$WordCustomTagsTableTableManager get wordCustomTags =>
      $$WordCustomTagsTableTableManager(_db, _db.wordCustomTags);
}
