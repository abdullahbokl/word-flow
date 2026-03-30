import 'package:drift/drift.dart';

@DataClassName('WordRow')
class Words extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable().named('user_id')();
  TextColumn get wordText => text().named('word_text')();
  IntColumn get totalCount => integer().named('total_count').withDefault(const Constant(1))();
  BoolColumn get isKnown =>
      boolean().named('is_known').withDefault(const Constant(false))();
  DateTimeColumn get lastUpdated => dateTime().named('last_updated')();


  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {userId, wordText},
      ];
}

class WordSyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get wordId => text()
      .references(Words, #id, onDelete: KeyAction.cascade)
      .named('word_id')();
  TextColumn get operation => text()();
  IntColumn get retryCount =>
      integer().named('retry_count').withDefault(const Constant(0))();
  TextColumn get lastError => text().named('last_error').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();


  @override
  List<Set<Column>> get uniqueKeys => [
        {wordId, operation},
      ];
}
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
