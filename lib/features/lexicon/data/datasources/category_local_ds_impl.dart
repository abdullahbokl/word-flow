import 'package:drift/drift.dart';
import 'package:wordflow/core/database/app_database.dart';
import 'package:wordflow/features/lexicon/data/datasources/category_local_ds.dart';

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  const CategoryLocalDataSourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<CustomTagRow>> getCustomTags() {
    return _db.select(_db.customTags).get();
  }

  @override
  Stream<List<CustomTagRow>> watchCustomTags() {
    return _db.select(_db.customTags).watch();
  }

  @override
  Future<CustomTagRow> addCustomTag(String name) async {
    final id = await _db
        .into(_db.customTags)
        .insert(CustomTagsCompanion.insert(name: name));
    return (_db.select(_db.customTags)..where((t) => t.id.equals(id)))
        .getSingle();
  }

  @override
  Future<void> deleteCustomTag(int tagId) async {
    await (_db.delete(_db.customTags)..where((t) => t.id.equals(tagId))).go();
  }

  @override
  Future<void> assignTag(int wordId, int tagId) async {
    await _db.into(_db.wordCustomTags).insert(
          WordCustomTagsCompanion.insert(wordId: wordId, tagId: tagId),
          mode: InsertMode.insertOrIgnore,
        );
  }

  @override
  Future<void> removeTag(int wordId, int tagId) async {
    await (_db.delete(_db.wordCustomTags)
          ..where((t) => t.wordId.equals(wordId) & t.tagId.equals(tagId)))
        .go();
  }

  @override
  Future<List<CustomTagRow>> getWordTags(int wordId) async {
    final query = _db.select(_db.customTags).join([
      innerJoin(
        _db.wordCustomTags,
        _db.wordCustomTags.tagId.equalsExp(_db.customTags.id),
      ),
    ])
      ..where(_db.wordCustomTags.wordId.equals(wordId));

    final rows = await query.get();
    return rows.map((row) => row.readTable(_db.customTags)).toList();
  }

  @override
  Stream<List<CustomTagRow>> watchWordTags(int wordId) {
    final query = _db.select(_db.customTags).join([
      innerJoin(
        _db.wordCustomTags,
        _db.wordCustomTags.tagId.equalsExp(_db.customTags.id),
      ),
    ])
      ..where(_db.wordCustomTags.wordId.equals(wordId));

    return query.watch().map(
        (rows) => rows.map((row) => row.readTable(_db.customTags)).toList());
  }
}
