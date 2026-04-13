import 'package:drift/drift.dart';

import 'package:wordflow/core/database/app_database.dart';
import 'package:wordflow/features/lexicon/domain/entities/word_filter.dart';
import 'package:wordflow/features/lexicon/domain/entities/word_sort.dart';

Selectable<WordRow> buildWordQuery(
  AppDatabase db, {
  required WordFilter filter,
  required String query,
  required WordSort sort,
  int? limit,
  int? offset,
}) {
  final selectable = db.select(db.words);
  if (filter == WordFilter.known) {
    selectable.where((table) => table.isKnown.equals(true));
  } else if (filter == WordFilter.unknown) {
    selectable.where((table) => table.isKnown.equals(false));
  }

  if (query.isNotEmpty) {
    selectable.where((table) => table.word.like('%$query%'));
  }

  _applySorting(selectable, sort);
  if (limit != null) {
    selectable.limit(limit, offset: offset);
  }
  return selectable;
}

void _applySorting(
    SimpleSelectStatement<dynamic, WordRow> query, WordSort sort) {
  switch (sort) {
    case WordSort.frequencyDesc:
      query.orderBy([
        (table) => OrderingTerm.desc(table.frequency),
        (table) => OrderingTerm.asc(table.word),
      ]);
    case WordSort.frequencyAsc:
      query.orderBy([
        (table) => OrderingTerm.asc(table.frequency),
        (table) => OrderingTerm.asc(table.word),
      ]);
    case WordSort.recent:
      query.orderBy([
        (table) => OrderingTerm.desc(table.updatedAt),
        (table) => OrderingTerm.asc(table.word),
      ]);
    case WordSort.alphabetical:
      query.orderBy([
        (table) => OrderingTerm.asc(table.word),
      ]);
  }
}
