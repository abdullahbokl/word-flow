import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/text_processor.dart';
import '../models/analysis_result_model.dart';
import 'analyzer_local_ds.dart';

class AnalyzerLocalDataSourceImpl implements AnalyzerLocalDataSource {
  const AnalyzerLocalDataSourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<AnalysisResultModel> analyze({
    required String title,
    required String content,
  }) async {
    final freq = await TextProcessor.process(content);
    final totalWords = TextProcessor.totalTokenCount(freq);
    final uniqueTokens = freq.keys.toList();

    return _db.transaction(() async {
      // 1. Get existing words info
      final existingRows = await (_db.select(_db.words)
            ..where((w) => w.word.isIn(uniqueTokens)))
          .get();

      final existingMap = {for (final r in existingRows) r.word: r};

      // 2. Insert new words
      final newTokens =
          uniqueTokens.where((t) => !existingMap.containsKey(t)).toList();
      final now = DateTime.now();

      // 2. Insert new words in batch
      if (newTokens.isNotEmpty) {
        await _db.batch((b) {
          for (final t in newTokens) {
            b.insert(
              _db.words,
              WordsCompanion.insert(
                word: t,
                frequency: const Value(0),
                isKnown: const Value(false),
                createdAt: now,
                updatedAt: now,
              ),
            );
          }
        });
      }

      // 3. Update frequencies and get final word IDs
      final allWordRows = await (_db.select(_db.words)
            ..where((w) => w.word.isIn(uniqueTokens)))
          .get();

      final wordIdMap = {for (final r in allWordRows) r.word: r.id};
      final knownMap = {for (final r in allWordRows) r.id: r.isKnown};

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

      // 4. Create AnalyzedText record
      final analyzedTextId = await _db.into(_db.analyzedTexts).insert(
            AnalyzedTextsCompanion.insert(
              title: title,
              content: content,
              totalWords: totalWords,
              uniqueWords: uniqueTokens.length,
              createdAt: now,
            ),
          );

      // 5. Create TextWordEntries records in batch
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

      // 6. Calculate summary
      var totalKnownTokens = 0;
      for (final entry in freq.entries) {
        final wordId = wordIdMap[entry.key]!;
        final isKnown = knownMap[wordId] ?? false;
        if (isKnown) {
          totalKnownTokens += entry.value;
        }
      }

      final unknownTokens = totalWords - totalKnownTokens;

      // 7. Map to models
      final wordsWithLocalFreq = allWordRows.map((row) {
        return WordWithLocalFreqModel(
          id: row.id,
          text: row.word,
          frequency: row.frequency,
          isKnown: row.isKnown,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
          meaning: row.meaning,
          description: row.description,
          localFrequency: freq[row.word] ?? 0,
        );
      }).toList()
        ..sort((a, b) => b.localFrequency.compareTo(a.localFrequency));

      return AnalysisResultModel(
        id: analyzedTextId,
        title: title,
        totalWords: totalWords,
        uniqueWords: uniqueTokens.length,
        unknownWords: unknownTokens,
        knownWords: totalKnownTokens,
        newWordsCount: newTokens.length,
        words: wordsWithLocalFreq,
      );
    });
  }
}
