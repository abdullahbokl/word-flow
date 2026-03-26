import 'package:injectable/injectable.dart';
import '../../../../core/database/database_helper.dart';
import '../models/word_model.dart';
import 'package:sqflite/sqflite.dart';

abstract class WordLocalSource {
  Future<void> saveWord(WordModel word);
  Future<void> saveWords(List<WordModel> words);
  Future<List<WordModel>> getWords({String? userId});
  Future<WordModel?> getWordById(String id);
  Future<WordModel?> getWordByText(String text, {String? userId});
  Future<void> deleteWord(String id);
  Stream<List<WordModel>> watchWords({String? userId});

  // Sync Queue Operations
  Future<void> enqueueSyncOperation(String wordId, String operation);
  Future<List<Map<String, dynamic>>> getSyncQueue(int limit);
  Future<void> removeFromSyncQueue(int queueId);
  Future<void> updateSyncQueueRetry(int queueId, String error);
  Future<int> getSyncQueueCount();
  Future<int> adoptGuestWords(String userId);
  Future<void> clearLocalWords({String? userId});
}

@LazySingleton(as: WordLocalSource)
class WordLocalSourceImpl implements WordLocalSource {
  final DatabaseHelper _dbHelper;

  WordLocalSourceImpl(this._dbHelper);

  @override
  Future<void> saveWord(WordModel word) async {
    final db = await _dbHelper.database;
    await db.insert(
      'words',
      word.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> saveWords(List<WordModel> words) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      for (final word in words) {
        await txn.insert(
          'words',
          word.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<List<WordModel>> getWords({String? userId}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: userId != null ? 'user_id = ?' : 'user_id IS NULL',
      whereArgs: userId != null ? [userId] : [],
    );
    return List.generate(maps.length, (i) => WordModel.fromMap(maps[i]));
  }

  @override
  Future<WordModel?> getWordById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return WordModel.fromMap(maps.first);
  }

  @override
  Future<WordModel?> getWordByText(String text, {String? userId}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'word_text = ? AND (user_id = ? OR (user_id IS NULL AND ? IS NULL))',
      whereArgs: [text, userId, userId],
    );
    if (maps.isEmpty) return null;
    return WordModel.fromMap(maps.first);
  }

  @override
  Future<void> deleteWord(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'words',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Stream<List<WordModel>> watchWords({String? userId}) async* {
    // Basic reactive approach: polling for now or using sqflite_common_ffi if needed
    // In a real app, I'd use a dedicated reactive library or hive for streams,
    // but for sqflite let's stick to manual refresh triggers in the repository or a simpler stream.
    // For Phase 2, a simple polling stream is sufficient for demonstration.
    while (true) {
      yield await getWords(userId: userId);
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  Future<void> enqueueSyncOperation(String wordId, String operation) async {
    final db = await _dbHelper.database;
    await db.insert('word_sync_queue', {
      'word_id': wordId,
      'operation': operation,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getSyncQueue(int limit) async {
    final db = await _dbHelper.database;
    return await db.query(
      'word_sync_queue',
      orderBy: 'created_at ASC',
      limit: limit,
    );
  }

  @override
  Future<void> removeFromSyncQueue(int queueId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'word_sync_queue',
      where: 'id = ?',
      whereArgs: [queueId],
    );
  }

  @override
  Future<void> updateSyncQueueRetry(int queueId, String error) async {
    final db = await _dbHelper.database;
    await db.rawUpdate('''
      UPDATE word_sync_queue 
      SET retry_count = retry_count + 1, last_error = ? 
      WHERE id = ?
    ''', [error, queueId]);
  }

  @override
  Future<int> getSyncQueueCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM word_sync_queue');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<int> adoptGuestWords(String userId) async {
    final db = await _dbHelper.database;
    return await db.transaction((txn) async {
      final now = DateTime.now().toUtc().toIso8601String();
      
      // Update words
      final count = await txn.rawUpdate('''
        UPDATE words 
        SET user_id = ?, last_updated = ? 
        WHERE user_id IS NULL
      ''', [userId, now]);

      if (count > 0) {
        // Find the IDs of the words we just updated to enqueue sync
        final List<Map<String, dynamic>> updatedWords = await txn.query(
          'words',
          columns: ['id'],
          where: 'user_id = ? AND last_updated = ?',
          whereArgs: [userId, now],
        );

        for (final row in updatedWords) {
          await txn.insert('word_sync_queue', {
            'word_id': row['id'],
            'operation': 'upsert',
            'created_at': now,
          });
        }
      }
      return count;
    });
  }

  @override
  Future<void> clearLocalWords({String? userId}) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete(
        'words',
        where: userId != null ? 'user_id = ?' : 'user_id IS NULL',
        whereArgs: userId != null ? [userId] : [],
      );
      // Also clear their sync queue (orphaned entries)
      // Actually we should only clear the words that had that user_id?
      // word_sync_queue doesn't have a user_id, it joins on word_id.
      // Easiest is to clear entries whose word_id no longer exists.
      await txn.rawDelete('''
        DELETE FROM word_sync_queue 
        WHERE word_id NOT IN (SELECT id FROM words)
      ''');
    });
  }
}
