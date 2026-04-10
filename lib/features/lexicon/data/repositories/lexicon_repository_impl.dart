import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/data/mappers/word_row_mapper.dart';
import '../../../../core/domain/entities/word_entity.dart';
import '../../../../core/error/failures.dart';
import '../../domain/commands/word_commands.dart';
import '../../domain/entities/lexicon_stats.dart';
import '../../domain/entities/word_filter.dart';
import '../../domain/entities/word_sort.dart';
import '../../domain/repositories/lexicon_repository.dart';
import '../datasources/lexicon_local_ds.dart';

class LexiconRepositoryImpl implements LexiconRepository {
  const LexiconRepositoryImpl(this._local);
  final LexiconLocalDataSource _local;

  @override
  TaskEither<Failure, List<WordEntity>> getWords({
    WordFilter filter = WordFilter.all,
    WordSort sort = WordSort.frequencyDesc,
    String query = '',
    int? limit,
    int? offset,
  }) =>
      TaskEither.tryCatch(
        () async {
          final rows = await _local.getWords(
              filter: filter,
              sort: sort,
              query: query,
              limit: limit,
              offset: offset);
          return await compute((r) => r.toEntities(), rows);
        },
        (error, stack) => DatabaseFailure('$error', stack),
      );

  @override
  Stream<Either<Failure, List<WordEntity>>> watchWords({
    WordFilter filter = WordFilter.all,
    WordSort sort = WordSort.frequencyDesc,
    String query = '',
  }) =>
      _local
          .watchWords(filter: filter, sort: sort, query: query)
          .map((rows) => Right(rows.toEntities()));

  @override
  TaskEither<Failure, WordEntity> toggleStatus(int wordId) =>
      TaskEither.tryCatch(
        () async => (await _local.toggleStatus(wordId)).toEntity(),
        (error, stack) => DatabaseFailure('$error', stack),
      );

  @override
  TaskEither<Failure, WordEntity> updateWord(UpdateWordCommand command) =>
      TaskEither.tryCatch(
        () async => (await _local.updateWord(
          command.id,
          text: command.text,
          meaning: command.meaning,
          description: command.description,
          definitions: command.definitions,
          examples: command.examples,
          translations: command.translations,
          synonyms: command.synonyms,
          isKnown: command.isKnown,
        ))
            .toEntity(),
        (error, stack) => DatabaseFailure('$error', stack),
      );

  @override
  TaskEither<Failure, Unit> deleteWord(int wordId) => TaskEither.tryCatch(
        () async {
          await _local.deleteWord(wordId);
          return unit;
        },
        (error, stack) => DatabaseFailure('$error', stack),
      );

  @override
  TaskEither<Failure, WordEntity> addWord(AddWordCommand command) =>
      TaskEither.tryCatch(
        () async => (await _local.addWord(command.text)).toEntity(),
        (error, stack) => DatabaseFailure('$error', stack),
      );

  @override
  TaskEither<Failure, LexiconStats> getStats() => TaskEither.tryCatch(
      () => _local.getStats(), (e, s) => DatabaseFailure('$e', s));

  @override
  Stream<Either<Failure, LexiconStats>> watchStats() =>
      _local.watchStats().map((stats) => Right(stats));
}
