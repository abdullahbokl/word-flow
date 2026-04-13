import 'package:drift/drift.dart';
import 'package:wordflow/core/constants/default_excluded_words.dart';
import 'package:wordflow/core/database/app_database.dart';
import 'package:wordflow/core/utils/text_processor.dart';
import 'package:wordflow/features/text_analyzer/data/datasources/analyzer_local_ds.dart';
import 'package:wordflow/features/text_analyzer/data/datasources/analyzer_local_ds_helpers.dart';
import 'package:wordflow/features/text_analyzer/data/models/analysis_result_model.dart';

class AnalyzerLocalDataSourceImpl implements AnalyzerLocalDataSource {
  AnalyzerLocalDataSourceImpl(this._db);

  final AppDatabase _db;
  bool _excludedDefaultsInitialized = false;

  Future<void> _ensureExcludedDefaults() async {
    if (_excludedDefaultsInitialized) return;

    final excludedRows = await _db.select(_db.excludedWords).get();
    if (excludedRows.isEmpty) {
      const defaults = DefaultExcludedWords.words;
      final now = DateTime.now();
      await _db.batch((batch) {
        for (final word in defaults) {
          batch.insert(
            _db.excludedWords,
            ExcludedWordsCompanion.insert(
              word: word,
              createdAt: now,
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }
      });
    }

    _excludedDefaultsInitialized = true;
  }

  @override
  Future<AnalysisResultModel> analyze({
    required String title,
    required String content,
  }) async {
    final freq = await TextProcessor.process(content);
    await _ensureExcludedDefaults();

    final excludedRows = await _db.select(_db.excludedWords).get();

    final excludedSet =
        excludedRows.map((r) => r.word.trim().toLowerCase()).toSet();

    final excludedWordsFound = freq.keys
        .where((word) => excludedSet.contains(word.trim().toLowerCase()))
        .toList();

    freq.removeWhere(
        (word, _) => excludedSet.contains(word.trim().toLowerCase()));

    final totalWords = TextProcessor.totalTokenCount(freq);
    final uniqueTokens = freq.keys.toList();

    return _db.transaction(() async {
      final now = DateTime.now();

      // 1. Ensure all unique words exist in the database (Idempotent batch insert)
      await _db.batch((b) {
        for (final t in uniqueTokens) {
          final normalized = t.trim().toLowerCase();
          b.insert(
            _db.words,
            WordsCompanion.insert(
              word: normalized,
              frequency: const Value(0),
              isKnown: const Value(false),
              createdAt: now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }
      });

      // 2. Retrieve all words for the current analysis to get IDs and metadata
      final allWordRows = await (_db.select(_db.words)
            ..where((w) => w.word.isIn(uniqueTokens)))
          .get();

      final wordIdMap = {for (final r in allWordRows) r.word: r.id};

      // Calculate new words count for the summary (words created in this transaction or with 0 freq)
      // Note: This is an approximation since words with 0 freq might have been added before but never seen.
      final newWordsCount = allWordRows
          .where((r) => r.createdAt == now || r.frequency == 0)
          .length;

      final wordSnapshots = allWordRows.map((row) {
        return {
          'id': row.id,
          'text': row.word,
          'frequency': row.frequency,
          'isKnown': row.isKnown,
          'createdAtMs': row.createdAt.millisecondsSinceEpoch,
          'updatedAtMs': row.updatedAt.millisecondsSinceEpoch,
          'meaning': row.meaning,
          'description': row.description,
          'localFrequency': freq[row.word] ?? 0,
        };
      }).toList(growable: false);

      await _db.batch((b) {
        for (final row in allWordRows) {
          final occurrences = freq[row.word] ?? 0;
          b.update(
            _db.words,
            WordsCompanion(
              frequency: Value(row.frequency + occurrences),
              updatedAt: Value(now),
            ),
            where: (w) => w.id.equals(row.id),
          );
        }
      });

      // Calculate unique word stats for the DB item
      final uniqueKnown = allWordRows.where((r) => r.isKnown).length;
      final uniqueUnknown = uniqueTokens.length - uniqueKnown;

      final analyzedTextId = await _db.into(_db.analyzedTexts).insert(
            AnalyzedTextsCompanion.insert(
              title: title,
              content: content,
              totalWords: totalWords,
              uniqueWords: uniqueTokens.length,
              knownWords: Value(uniqueKnown),
              unknownWords: Value(uniqueUnknown),
              createdAt: now,
            ),
          );

      await _db.batch((b) {
        for (final entry in freq.entries) {
          final wordId = wordIdMap[entry.key]!;
          b.insert(
            _db.textWordEntries,
            TextWordEntriesCompanion.insert(
              textId: analyzedTextId,
              wordId: wordId,
              localFrequency: Value(entry.value),
            ),
          );
        }
      });

      final analysisMap = await TextProcessor.summarizeAnalysis(
        id: analyzedTextId,
        title: title,
        totalWords: totalWords,
        uniqueWords: uniqueTokens.length,
        newWordsCount: newWordsCount,
        words: wordSnapshots,
        excludedWordsFound: excludedWordsFound,
      );

      return AnalysisResultModel.fromMap(analysisMap);
    });
  }

  @override
  Future<AnalysisResultModel> getAnalysisResult(int id) async {
    final text = await (_db.select(_db.analyzedTexts)
          ..where((t) => t.id.equals(id)))
        .getSingle();

    final query = _db.select(_db.textWordEntries).join([
      innerJoin(_db.words, _db.words.id.equalsExp(_db.textWordEntries.wordId)),
    ])
      ..where(_db.textWordEntries.textId.equals(id));

    final results = await query.get();

    final wordSnapshots = results.map((r) {
      final word = r.readTable(_db.words);
      final entry = r.readTable(_db.textWordEntries);
      return {
        'id': word.id,
        'text': word.word,
        'frequency': word.frequency,
        'isKnown': word.isKnown,
        'createdAtMs': word.createdAt.millisecondsSinceEpoch,
        'updatedAtMs': word.updatedAt.millisecondsSinceEpoch,
        'meaning': word.meaning,
        'description': word.description,
        'localFrequency': entry.localFrequency,
      };
    }).toList();

    final analysisMap = await TextProcessor.summarizeAnalysis(
      id: text.id,
      title: text.title,
      totalWords: text.totalWords,
      uniqueWords: text.uniqueWords,
      newWordsCount: 0, // Not relevant for retrieval
      words: wordSnapshots,
      excludedWordsFound: [], // Not stored separately in DB currently, would need a fetch if critical
    );

    return AnalysisResultModel.fromMap(analysisMap);
  }

  @override
  Future<void> updateAnalysisCounts(int id) async {
    await updateAnalyzedTextCounts(_db, id);
  }
}
