import 'package:fpdart/fpdart.dart';
import 'package:lexitrack/core/common/models/word_with_local_freq.dart';
import 'package:lexitrack/core/data/mappers/word_row_mapper.dart';
import 'package:lexitrack/core/database/app_database.dart';
import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/features/history/data/datasources/history_local_ds.dart';
import 'package:lexitrack/features/history/data/mappers/history_mapper.dart';
import 'package:lexitrack/features/history/domain/entities/history_detail.dart';
import 'package:lexitrack/features/history/domain/entities/history_item.dart';
import 'package:lexitrack/features/history/domain/repositories/history_repository.dart';
import 'package:rxdart/rxdart.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  const HistoryRepositoryImpl(this._local);

  final HistoryLocalDataSource _local;

  @override
  Future<Either<Failure, List<HistoryItem>>> getHistory({int? limit, int? offset}) async {
    try {
      final rows = await _local.getHistory(limit: limit, offset: offset);
      return Right(rows.map((r) => r.toEntity()).toList());
    } catch (e, stack) {
      return Left(DatabaseFailure('$e', stack));
    }
  }

  @override
  Stream<Either<Failure, List<HistoryItem>>> watchHistory({int? limit, int? offset}) {
    return _local.watchHistory(limit: limit, offset: offset).map(
      (rows) => Right(rows.map((r) => r.toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, void>> deleteHistoryItem(int id,
      {bool deleteUniqueWords = false}) async {
    try {
      await _local.deleteHistoryItem(id, deleteUniqueWords: deleteUniqueWords);
      return const Right(null);
    } catch (e, stack) {
      return Left(DatabaseFailure('$e', stack));
    }
  }

  @override
  Future<Either<Failure, HistoryDetail>> getHistoryDetail(int id) async {
    try {
      final row = await _local.getHistoryItem(id);
      if (row == null) throw Exception('Analysis not found');

      final results = await _local.getAnalysisWords(id);
      return Right(HistoryDetail(
        item: row.toEntity(),
        words: results.map((r) {
          final wordRow = r.$1;
          final entryRow = r.$2;
          return WordWithLocalFreq(
            word: wordRow.toEntity(),
            localFrequency: entryRow.localFrequency,
          );
        }).toList(),
      ));
    } catch (e, stack) {
      return Left(DatabaseFailure('$e', stack));
    }
  }

  @override
  Stream<Either<Failure, HistoryDetail>> watchHistoryDetail(int id) {
    final itemStream = _local.watchHistoryItem(id);
    final wordsStream = _local.watchAnalysisWords(id);

    return Rx.combineLatest2<AnalyzedTextRow?, List<(WordRow, TextWordEntryRow)>,
        Either<Failure, HistoryDetail>>(
      itemStream,
      wordsStream,
      (item, words) {
        if (item == null) {
          return Left(DatabaseFailure('Analysis not found', StackTrace.current));
        }

        final detail = HistoryDetail(
          item: item.toEntity(),
          words: words.map((r) {
            final wordRow = r.$1;
            final entryRow = r.$2;
            return WordWithLocalFreq(
              word: wordRow.toEntity(),
              localFrequency: entryRow.localFrequency,
            );
          }).toList(),
        );

        return Right(detail);
      },
    );
  }
}
