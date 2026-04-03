import 'package:drift/drift.dart';

@DataClassName('WordRow')
class Words extends Table {
  TextColumn get id => text()();
  TextColumn get wordText => text().named('word_text')();
  IntColumn get totalCount =>
      integer().named('total_count').withDefault(const Constant(1))();
  BoolColumn get isKnown =>
      boolean().named('is_known').withDefault(const Constant(false))();
  DateTimeColumn get lastUpdated => dateTime().named('last_updated')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {wordText},
  ];
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
