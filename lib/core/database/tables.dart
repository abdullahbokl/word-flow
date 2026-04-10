import 'package:drift/drift.dart';
import 'package:lexitrack/core/database/converters/string_list_converter.dart';

@DataClassName('WordRow')
class Words extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get word => text().unique()();
  IntColumn get frequency => integer().withDefault(const Constant(0))();
  BoolColumn get isKnown => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get meaning => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get definitions =>
      text().map(const StringListConverter()).nullable()();
  TextColumn get examples =>
      text().map(const StringListConverter()).nullable()();
  TextColumn get translations =>
      text().map(const StringListConverter()).nullable()();
  TextColumn get synonyms =>
      text().map(const StringListConverter()).nullable()();
}

@DataClassName('AnalyzedTextRow')
class AnalyzedTexts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  IntColumn get totalWords => integer()();
  IntColumn get uniqueWords => integer()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get knownWords => integer().withDefault(const Constant(0))();
  IntColumn get unknownWords => integer().withDefault(const Constant(0))();
}

@DataClassName('TextWordEntryRow')
class TextWordEntries extends Table {
  IntColumn get textId =>
      integer().references(AnalyzedTexts, #id, onDelete: KeyAction.cascade)();
  IntColumn get wordId =>
      integer().references(Words, #id, onDelete: KeyAction.cascade)();
  IntColumn get localFrequency => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {textId, wordId};
}
