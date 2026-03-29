import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:word_flow/core/database/app_database.dart';

void main() {
  group('Database Migrations', () {
    test('fresh install (onCreate) creates exactly version 5 schema', () async {
      final executor = NativeDatabase.memory();
      final db = WordFlowDatabase.test(executor);

      // Trigger DB open
      await db.customSelect('SELECT 1').get();

      // Check tables exist
      final tables = await db.customSelect('SELECT name FROM sqlite_master WHERE type="table"').get();
      final tableNames = tables.map((r) => r.read<String>('name')).toList();

      expect(tableNames, contains('words'));
      expect(tableNames, contains('word_sync_queue'));

      // Verify schemaVersion getter functions normally
      expect(db.schemaVersion, 5);

      // Verify UNIQUE constraint on word_sync_queue
      final qResult = await db.customSelect("SELECT sql FROM sqlite_master WHERE name='word_sync_queue'").getSingle();
      final sql = qResult.read<String>('sql');
      expect(sql, contains('UNIQUE'), reason: 'UNIQUE constraint should be present in table SQL');

      await db.close();
    });

    test('migration 1 -> 5', () async {
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

      // Verify v5 schema features
      expect(wordFlowDb.schemaVersion, 5);

      // 1. Check unique index on words exists (from v3)
      final indices = await wordFlowDb.customSelect('SELECT name FROM sqlite_master WHERE type="index"').get();
      final indexNames = indices.map((r) => r.read<String>('name')).toList();
      expect(indexNames, contains('idx_words_user_word'));

      // 2. Check UNIQUE constraint on word_sync_queue (from v5)
      final qResult = await wordFlowDb.customSelect("SELECT sql FROM sqlite_master WHERE name='word_sync_queue'").getSingle();
      final sql = qResult.read<String>('sql');
      expect(sql, contains('UNIQUE'));

      await wordFlowDb.close();
    });

    test('migration 4 -> 5 explicitly', () async {
      final db = sqlite3.openInMemory();
      
      // Setup v4 schema
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
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL DEFAULT (datetime('now'))
        )
      ''');
      // Insert duplicate to test migration logic
      db.execute("INSERT INTO word_sync_queue (word_id, operation, created_at) VALUES ('w1', 'upsert', '2021-01-01')");
      db.execute("INSERT INTO word_sync_queue (word_id, operation, created_at) VALUES ('w1', 'upsert', '2021-01-02')");
      
      db.execute('PRAGMA user_version = 4;');

      final executor = NativeDatabase.opened(db);
      final wordFlowDb = WordFlowDatabase.test(executor);
      
      await wordFlowDb.customSelect('SELECT 1').get();

      expect(wordFlowDb.schemaVersion, 5);
      
      final qResult = await wordFlowDb.customSelect("SELECT sql FROM sqlite_master WHERE name='word_sync_queue'").getSingle();
      expect(qResult.read<String>('sql'), contains('UNIQUE'));

      // Verify duplicate was merged
      final rows = await wordFlowDb.customSelect("SELECT * FROM word_sync_queue WHERE word_id='w1'").get();
      expect(rows, hasLength(1));

      await wordFlowDb.close();
    });

    test('migration 3 -> 4', () async {
      final db = sqlite3.openInMemory();
      
      // Setup v3 schema
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
      db.execute('CREATE UNIQUE INDEX idx_words_user_word ON words(user_id, word_text)');
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
      db.execute('PRAGMA user_version = 3;');

      final executor = NativeDatabase.opened(db);
      final wordFlowDb = WordFlowDatabase.test(executor);
      
      await wordFlowDb.customSelect('SELECT 1').get();

      final columns = await wordFlowDb.customSelect('PRAGMA table_info(word_sync_queue)').get();
      final columnNames = columns.map((r) => r.read<String>('name')).toList();
      expect(columnNames, contains('updated_at'));

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

      // Reset version to 1 to force migration 1 -> 4 again on the identical schema
      db.execute('PRAGMA user_version = 1;');

      final executor2 = NativeDatabase.opened(db);
      final wordFlowDb2 = WordFlowDatabase.test(executor2);
      
      // This should run without throwing any SQlite duplicate column/index errors
      await wordFlowDb2.customSelect('SELECT 1').get();
      
      final columns = await wordFlowDb2.customSelect('PRAGMA table_info(word_sync_queue)').get();
      final columnNames = columns.map((r) => r.read<String>('name')).toList();
      expect(columnNames, contains('updated_at'));

      await wordFlowDb2.close();
      await wordFlowDb1.close();
      db.dispose();
    });
  });
}
