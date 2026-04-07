import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/database/app_database.dart'; // Ensure AppDatabase and WordRow are imported
import '../../../../core/data/mappers/word_row_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/lexicon_stats.dart';
import '../../domain/entities/word_entity.dart';
import '../../domain/entities/word_filter.dart';
import '../../domain/entities/word_sort.dart';
import '../../domain/repositories/lexicon_repository.dart';
import '../datasources/lexicon_local_ds.dart';

List<WordEntity> _mapRowsToEntities(List<WordRow> rows) {
  return rows.map((r) => r.toEntity()).toList();
}

class LexiconRepositoryImpl implements LexiconRepository {
  const LexiconRepositoryImpl(this._local);

  final LexiconLocalDataSource _local;

  @override
  TaskEither<Failure, List<WordEntity>> getWords({
    WordFilter filter = WordFilter.all,
    WordSort sort = WordSort.frequencyDesc,
    String query = '',
  }) {
    return TaskEither.tryCatch(
      () async {
        final rows = await _local.getWords(
          filter: filter,
          sort: sort,
          query: query,
        );
        return await compute(_mapRowsToEntities, rows);
      },
      (error, stack) => DatabaseFailure('$error', stack),
    );
  }

  @override
  Stream<Either<Failure, List<WordEntity>>> watchWords({
    WordFilter filter = WordFilter.all,
    WordSort sort = WordSort.frequencyDesc,
    String query = '',
  }) {
    return _local.watchWords(filter: filter, sort: sort, query: query).asyncMap(
          (rows) async {
            final mapped = await compute(_mapRowsToEntities, rows);
            return Right<Failure, List<WordEntity>>(mapped);
          },
        );
  }

  @override
  TaskEither<Failure, WordEntity> toggleStatus(int wordId) {
    return TaskEither.tryCatch(
      () async {
        final row = await _local.toggleStatus(wordId);
        return row.toEntity();
      },
      (error, stack) => DatabaseFailure('$error', stack),
    );
  }

  @override
  TaskEither<Failure, WordEntity> updateWord(
    int id, {
    String? meaning,
    String? description,
  }) {
    return TaskEither.tryCatch(
      () async {
        final row = await _local.updateWord(
          id,
          meaning: meaning,
          description: description,
        );
        return row.toEntity();
      },
      (error, stack) => DatabaseFailure('$error', stack),
    );
  }

  @override
  TaskEither<Failure, Unit> deleteWord(int wordId) {
    return TaskEither.tryCatch(
      () async {
        await _local.deleteWord(wordId);
        return unit;
      },
      (error, stack) => DatabaseFailure('$error', stack),
    );
  }

  @override
  TaskEither<Failure, WordEntity> addWord(String text) {
    return TaskEither.tryCatch(
      () async {
        final row = await _local.addWord(text);
        return row.toEntity();
      },
      (error, stack) => DatabaseFailure('$error', stack),
    );
  }

  @override
  TaskEither<Failure, LexiconStats> getStats() {
    return TaskEither.tryCatch(
      () => _local.getStats(),
      (error, stack) => DatabaseFailure('$error', stack),
    );
  }

  @override
  Stream<Either<Failure, LexiconStats>> watchStats() {
    return _local.watchStats().map((stats) => Right(stats));
  }
}
