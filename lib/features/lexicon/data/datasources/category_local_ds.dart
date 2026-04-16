import 'package:wordflow/core/database/app_database.dart';

abstract interface class CategoryLocalDataSource {
  Future<List<CustomTagRow>> getCustomTags();
  Stream<List<CustomTagRow>> watchCustomTags();
  Future<CustomTagRow> addCustomTag(String name);
  Future<void> deleteCustomTag(int tagId);
  Future<void> assignTag(int wordId, int tagId);
  Future<void> removeTag(int wordId, int tagId);
  Future<List<CustomTagRow>> getWordTags(int wordId);
  Stream<List<CustomTagRow>> watchWordTags(int wordId);
}
