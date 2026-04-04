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
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
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
  @override
  List<GeneratedColumn> get $columns =>
      [id, word, frequency, isKnown, createdAt, updatedAt];
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
    );
  }

  @override
  $WordsTable createAlias(String alias) {
    return $WordsTable(attachedDatabase, alias);
  }
}

class WordRow extends DataClass implements Insertable<WordRow> {
  final int id;
  final String word;
  final int frequency;
  final bool isKnown;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WordRow(
      {required this.id,
      required this.word,
      required this.frequency,
      required this.isKnown,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['word'] = Variable<String>(word);
    map['frequency'] = Variable<int>(frequency);
    map['is_known'] = Variable<bool>(isKnown);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
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
    };
  }

  WordRow copyWith(
          {int? id,
          String? word,
          int? frequency,
          bool? isKnown,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      WordRow(
        id: id ?? this.id,
        word: word ?? this.word,
        frequency: frequency ?? this.frequency,
        isKnown: isKnown ?? this.isKnown,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  WordRow copyWithCompanion(WordsCompanion data) {
    return WordRow(
      id: data.id.present ? data.id.value : this.id,
      word: data.word.present ? data.word.value : this.word,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      isKnown: data.isKnown.present ? data.isKnown.value : this.isKnown,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
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
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, word, frequency, isKnown, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordRow &&
          other.id == this.id &&
          other.word == this.word &&
          other.frequency == this.frequency &&
          other.isKnown == this.isKnown &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WordsCompanion extends UpdateCompanion<WordRow> {
  final Value<int> id;
  final Value<String> word;
  final Value<int> frequency;
  final Value<bool> isKnown;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const WordsCompanion({
    this.id = const Value.absent(),
    this.word = const Value.absent(),
    this.frequency = const Value.absent(),
    this.isKnown = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  WordsCompanion.insert({
    this.id = const Value.absent(),
    required String word,
    this.frequency = const Value.absent(),
    this.isKnown = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
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
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (word != null) 'word': word,
      if (frequency != null) 'frequency': frequency,
      if (isKnown != null) 'is_known': isKnown,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  WordsCompanion copyWith(
      {Value<int>? id,
      Value<String>? word,
      Value<int>? frequency,
      Value<bool>? isKnown,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return WordsCompanion(
      id: id ?? this.id,
      word: word ?? this.word,
      frequency: frequency ?? this.frequency,
      isKnown: isKnown ?? this.isKnown,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
          ..write('updatedAt: $updatedAt')
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
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, content, totalWords, uniqueWords, createdAt];
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
    );
  }

  @override
  $AnalyzedTextsTable createAlias(String alias) {
    return $AnalyzedTextsTable(attachedDatabase, alias);
  }
}

class AnalyzedTextRow extends DataClass implements Insertable<AnalyzedTextRow> {
  final int id;
  final String title;
  final String content;
  final int totalWords;
  final int uniqueWords;
  final DateTime createdAt;
  const AnalyzedTextRow(
      {required this.id,
      required this.title,
      required this.content,
      required this.totalWords,
      required this.uniqueWords,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    map['total_words'] = Variable<int>(totalWords);
    map['unique_words'] = Variable<int>(uniqueWords);
    map['created_at'] = Variable<DateTime>(createdAt);
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
    };
  }

  AnalyzedTextRow copyWith(
          {int? id,
          String? title,
          String? content,
          int? totalWords,
          int? uniqueWords,
          DateTime? createdAt}) =>
      AnalyzedTextRow(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        totalWords: totalWords ?? this.totalWords,
        uniqueWords: uniqueWords ?? this.uniqueWords,
        createdAt: createdAt ?? this.createdAt,
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
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, content, totalWords, uniqueWords, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnalyzedTextRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.content == this.content &&
          other.totalWords == this.totalWords &&
          other.uniqueWords == this.uniqueWords &&
          other.createdAt == this.createdAt);
}

class AnalyzedTextsCompanion extends UpdateCompanion<AnalyzedTextRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> content;
  final Value<int> totalWords;
  final Value<int> uniqueWords;
  final Value<DateTime> createdAt;
  const AnalyzedTextsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.totalWords = const Value.absent(),
    this.uniqueWords = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AnalyzedTextsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String content,
    required int totalWords,
    required int uniqueWords,
    required DateTime createdAt,
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
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (totalWords != null) 'total_words': totalWords,
      if (uniqueWords != null) 'unique_words': uniqueWords,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AnalyzedTextsCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String>? content,
      Value<int>? totalWords,
      Value<int>? uniqueWords,
      Value<DateTime>? createdAt}) {
    return AnalyzedTextsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      totalWords: totalWords ?? this.totalWords,
      uniqueWords: uniqueWords ?? this.uniqueWords,
      createdAt: createdAt ?? this.createdAt,
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
          ..write('createdAt: $createdAt')
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
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES analyzed_texts (id)'));
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
      'word_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WordsTable words = $WordsTable(this);
  late final $AnalyzedTextsTable analyzedTexts = $AnalyzedTextsTable(this);
  late final $TextWordEntriesTable textWordEntries =
      $TextWordEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [words, analyzedTexts, textWordEntries];
}

typedef $$WordsTableCreateCompanionBuilder = WordsCompanion Function({
  Value<int> id,
  required String word,
  Value<int> frequency,
  Value<bool> isKnown,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$WordsTableUpdateCompanionBuilder = WordsCompanion Function({
  Value<int> id,
  Value<String> word,
  Value<int> frequency,
  Value<bool> isKnown,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

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
    (WordRow, BaseReferences<_$AppDatabase, $WordsTable, WordRow>),
    WordRow,
    PrefetchHooks Function()> {
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
          }) =>
              WordsCompanion(
            id: id,
            word: word,
            frequency: frequency,
            isKnown: isKnown,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String word,
            Value<int> frequency = const Value.absent(),
            Value<bool> isKnown = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
          }) =>
              WordsCompanion.insert(
            id: id,
            word: word,
            frequency: frequency,
            isKnown: isKnown,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
    (WordRow, BaseReferences<_$AppDatabase, $WordsTable, WordRow>),
    WordRow,
    PrefetchHooks Function()>;
typedef $$AnalyzedTextsTableCreateCompanionBuilder = AnalyzedTextsCompanion
    Function({
  Value<int> id,
  required String title,
  required String content,
  required int totalWords,
  required int uniqueWords,
  required DateTime createdAt,
});
typedef $$AnalyzedTextsTableUpdateCompanionBuilder = AnalyzedTextsCompanion
    Function({
  Value<int> id,
  Value<String> title,
  Value<String> content,
  Value<int> totalWords,
  Value<int> uniqueWords,
  Value<DateTime> createdAt,
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
          }) =>
              AnalyzedTextsCompanion(
            id: id,
            title: title,
            content: content,
            totalWords: totalWords,
            uniqueWords: uniqueWords,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            required String content,
            required int totalWords,
            required int uniqueWords,
            required DateTime createdAt,
          }) =>
              AnalyzedTextsCompanion.insert(
            id: id,
            title: title,
            content: content,
            totalWords: totalWords,
            uniqueWords: uniqueWords,
            createdAt: createdAt,
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
  ColumnFilters<int> get wordId => $composableBuilder(
      column: $table.wordId, builder: (column) => ColumnFilters(column));

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
  ColumnOrderings<int> get wordId => $composableBuilder(
      column: $table.wordId, builder: (column) => ColumnOrderings(column));

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
  GeneratedColumn<int> get wordId =>
      $composableBuilder(column: $table.wordId, builder: (column) => column);

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
    PrefetchHooks Function({bool textId})> {
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
          prefetchHooksCallback: ({textId = false}) {
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
    PrefetchHooks Function({bool textId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WordsTableTableManager get words =>
      $$WordsTableTableManager(_db, _db.words);
  $$AnalyzedTextsTableTableManager get analyzedTexts =>
      $$AnalyzedTextsTableTableManager(_db, _db.analyzedTexts);
  $$TextWordEntriesTableTableManager get textWordEntries =>
      $$TextWordEntriesTableTableManager(_db, _db.textWordEntries);
}
