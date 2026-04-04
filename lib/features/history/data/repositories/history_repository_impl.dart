import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/database/app_database.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/history_detail.dart';
import '../../domain/entities/history_item.dart';
import '../../domain/repositories/history_repository.dart';
import '../../../lexicon/data/mappers/word_mapper.dart';
import '../datasources/history_local_ds.dart';
import '../mappers/history_mapper.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  const HistoryRepositoryImpl(this._local);

  final HistoryLocalDataSource _local;

  @override
  TaskEither<Failure, List<HistoryItem>> getHistory() {
    return TaskEither.tryCatch(
      () async {
        final rows = await _local.getHistory();
        return rows.map((r) => r.toEntity()).toList();
      },
      (error, stack) => DatabaseFailure('$error', stack),
    );
  }

  @override
  Stream<Either<Failure, List<HistoryItem>>> watchHistory() {
    return _local.watchHistory().map(
      (rows) => Right(rows.map((r) => r.toEntity()).toList()),
    );
  }

  @override
  TaskEither<Failure, Unit> deleteHistoryItem(int id, {bool deleteUniqueWords = false}) {
    return TaskEither.tryCatch(
      () async {
        await _local.deleteHistoryItem(id, deleteUniqueWords: deleteUniqueWords);
        return unit;
      },
      (error, stack) => DatabaseFailure('$error', stack),
    );
  }
  @override
  TaskEither<Failure, HistoryDetail> getHistoryDetail(int id) {
    return TaskEither.tryCatch(
      () async {
        final row = await _local.getHistoryItem(id);
        if (row == null) throw Exception('Analysis not found');

        final results = await _local.getAnalysisWords(id);
        return HistoryDetail(
          item: row.toEntity(),
          words: results.map((r) {
            final wordRow = r.readTable(_local.db.words);
            final entryRow = r.readTable(_local.db.textWordEntries);
            return WordWithLocalFreq(
              word: wordRow.toEntity(),
              localFrequency: entryRow.localFrequency,
            );
          }).toList(),
        );
      },
      (error, stack) => DatabaseFailure('$error', stack),
    );
  }

  @override
  Stream<Either<Failure, HistoryDetail>> watchHistoryDetail(int id) {
    final itemStream = (_local.db.select(_local.db.analyzedTexts)
          ..where((t) => t.id.equals(id)))
        .watchSingleOrNull();

    final wordsStream = _local.watchAnalysisWords(id);

    return Rx.combineLatest2<AnalyzedTextRow?, List<TypedResult>,
        Either<Failure, HistoryDetail>>(itemStream, wordsStream, (item, words) {
      if (item == null) {
        return Left(DatabaseFailure('Analysis not found', StackTrace.current));
      }

      final detail = HistoryDetail(
        item: item.toEntity(),
        words: words.map((r) {
          final wordRow = r.readTable(_local.db.words);
          final entryRow = r.readTable(_local.db.textWordEntries);
          return WordWithLocalFreq(
            word: wordRow.toEntity(),
            localFrequency: entryRow.localFrequency,
          );
        }).toList(),
      );

      return Right(detail);
    });
  }
}
