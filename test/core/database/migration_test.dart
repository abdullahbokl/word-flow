import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:word_flow/core/database/app_database.dart';

void main() {
  group('Database Migrations', () {
    test('fresh install (onCreate) creates exactly version 6 schema', () async {
      final executor = NativeDatabase.memory();
      final db = WordFlowDatabase.test(executor);

      // Trigger DB open
      await db.customSelect('SELECT 1').get();

      // Check tables exist
      final tables = await db
          .customSelect('SELECT name FROM sqlite_master WHERE type="table"')
          .get();
      final tableNames = tables.map((r) => r.read<String>('name')).toList();

      expect(tableNames, contains('words'));
      expect(tableNames, contains('word_sync_queue'));

      // Verify schemaVersion
      expect(db.schemaVersion, 6);

      // Verify UNIQUE constraint on word_sync_queue
      final qResult = await db
          .customSelect(
            "SELECT sql FROM sqlite_master WHERE name='word_sync_queue'",
          )
          .getSingle();
      final sql = qResult.read<String>('sql');
      expect(sql, contains('UNIQUE'),
          reason: 'UNIQUE constraint should be present in table SQL');

      // Verify new indices in v6
      final indices = await db
          .customSelect('SELECT name FROM sqlite_master WHERE type="index"')
          .get();
      final indexNames = indices.map((r) => r.read<String>('name')).toList();
      expect(indexNames, contains('idx_words_known_partial'));
      expect(indexNames, contains('idx_words_last_updated'));

      await db.close();
    });

    test('migration 1 -> 6', () async {
      final db = sqlite3.openInMemory();

      // Setup v1 schema
      db.execute('''
        CREATE TABLE words (
          id TEXT PRIMARY KEY,
          user_id TEXT,
          word_text TEXT NOT NULL,
          total_count INTEGER DEFAULT 1,
          is_known INTEGER DEFAULT 0,
          last_updated TEXT NOT NULL
        )
      ''');
      db.execute('''
        CREATE TABLE word_sync_queue (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          word_id TEXT NOT NULL,
          operation TEXT NOT NULL,
          retry_count INTEGER DEFAULT 0,
          last_error TEXT,
          created_at TEXT NOT NULL
        )
      ''');
      db.execute('PRAGMA user_version = 1;');

      final executor = NativeDatabase.opened(db);
      final wordFlowDb = WordFlowDatabase.test(executor);

      // trigger DB open, running onUpgrade
      await wordFlowDb.customSelect('SELECT 1').get();

      // Verify v6 schema features
      expect(wordFlowDb.schemaVersion, 6);

      // 1. Check unique index on words exists (from v3)
      final indices = await wordFlowDb
          .customSelect('SELECT name FROM sqlite_master WHERE type="index"')
          .get();
      final indexNames = indices.map((r) => r.read<String>('name')).toList();
      expect(indexNames, contains('idx_words_user_word'));
      expect(indexNames, contains('idx_words_known_partial'));
      expect(indexNames, contains('idx_words_last_updated'));

      // 2. Check UNIQUE constraint on word_sync_queue (from v5)
      final qResult = await wordFlowDb
          .customSelect(
            "SELECT sql FROM sqlite_master WHERE name='word_sync_queue'",
          )
          .getSingle();
      final sql = qResult.read<String>('sql');
      expect(sql, contains('UNIQUE'));

      await wordFlowDb.close();
    });

    test('migration 5 -> 6 explicitly', () async {
      final db = sqlite3.openInMemory();

      // Setup v5 schema
      db.execute('''
        CREATE TABLE words (
          id TEXT PRIMARY KEY,
          user_id TEXT,
          word_text TEXT NOT NULL,
          total_count INTEGER DEFAULT 1,
          is_known INTEGER NOT NULL DEFAULT 0,
          last_updated INTEGER NOT NULL
        )
      ''');
      db.execute('''
        CREATE TABLE word_sync_queue (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          word_id TEXT NOT NULL,
          operation TEXT NOT NULL,
          retry_count INTEGER DEFAULT 0,
          last_error TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          UNIQUE (word_id, operation)
        )
      ''');
      db.execute('PRAGMA user_version = 5;');

      final executor = NativeDatabase.opened(db);
      final wordFlowDb = WordFlowDatabase.test(executor);

      await wordFlowDb.customSelect('SELECT 1').get();

      expect(wordFlowDb.schemaVersion, 6);

      final indices = await wordFlowDb
          .customSelect('SELECT name FROM sqlite_master WHERE type="index"')
          .get();
      final indexNames = indices.map((r) => r.read<String>('name')).toList();
      expect(indexNames, contains('idx_words_known_partial'));
      expect(indexNames, contains('idx_words_last_updated'));

      await wordFlowDb.close();
    });

    test('migration is fully idempotent', () async {
      final db = sqlite3.openInMemory();

      // Setup v1 schema
      db.execute('''
        CREATE TABLE words (
          id TEXT PRIMARY KEY,
          user_id TEXT,
          word_text TEXT NOT NULL,
          total_count INTEGER DEFAULT 1,
          is_known INTEGER DEFAULT 0,
          last_updated TEXT NOT NULL
        )
      ''');
      db.execute('''
        CREATE TABLE word_sync_queue (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          word_id TEXT NOT NULL,
          operation TEXT NOT NULL,
          retry_count INTEGER DEFAULT 0,
          last_error TEXT,
          created_at TEXT NOT NULL
        )
      ''');
      db.execute('PRAGMA user_version = 1;');

      final executor1 = NativeDatabase.opened(db);
      final wordFlowDb1 = WordFlowDatabase.test(executor1);

      await wordFlowDb1.customSelect('SELECT 1').get();
      // DO NOT close wordFlowDb1 here because it closes the underlying SQLite DB

      // Reset version to 1 to force migration again on the identical schema
      db.execute('PRAGMA user_version = 1;');

      final executor2 = NativeDatabase.opened(db);
      final wordFlowDb2 = WordFlowDatabase.test(executor2);

      // This should run without throwing any SQlite duplicate column/index errors
      await wordFlowDb2.customSelect('SELECT 1').get();

      expect(wordFlowDb2.schemaVersion, 6);

      final columns = await wordFlowDb2
          .customSelect('PRAGMA table_info(word_sync_queue)')
          .get();
      final columnNames = columns.map((r) => r.read<String>('name')).toList();
      expect(columnNames, contains('updated_at'));

      await wordFlowDb2.close();
      await wordFlowDb1.close();
      db.dispose();
    });
  });
}
