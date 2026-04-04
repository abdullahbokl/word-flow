import 'package:drift/drift.dart';

@DataClassName('WordRow')
class Words extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get word => text().unique()();
  IntColumn get frequency => integer().withDefault(const Constant(0))();
  BoolColumn get isKnown => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DataClassName('AnalyzedTextRow')
class AnalyzedTexts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  IntColumn get totalWords => integer()();
  IntColumn get uniqueWords => integer()();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('TextWordEntryRow')
class TextWordEntries extends Table {
  IntColumn get textId => integer().references(AnalyzedTexts, #id)();
  IntColumn get wordId => integer()();
  IntColumn get localFrequency => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {textId, wordId};
}
