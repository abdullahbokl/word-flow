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
      final existingRows = await (_db.select(_db.words)
            ..where((w) => w.word.isIn(uniqueTokens)))
          .get();

      final existingMap = {for (final r in existingRows) r.word: r};
      final newTokens = uniqueTokens.where((t) => !existingMap.containsKey(t)).toList();
      final now = DateTime.now();

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

      final allWordRows = await (_db.select(_db.words)
            ..where((w) => w.word.isIn(uniqueTokens)))
          .get();

      final wordIdMap = {for (final r in allWordRows) r.word: r.id};
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

      final analyzedTextId = await _db.into(_db.analyzedTexts).insert(
            AnalyzedTextsCompanion.insert(
              title: title,
              content: content,
              totalWords: totalWords,
              uniqueWords: uniqueTokens.length,
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
        newWordsCount: newTokens.length,
        words: wordSnapshots,
      );

      return AnalysisResultModel.fromMap(analysisMap);
    });
  }
}
