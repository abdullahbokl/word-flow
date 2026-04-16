import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:wordflow/core/constants/default_excluded_words.dart';
import 'package:wordflow/core/data/mappers/word_row_mapper.dart';
import 'package:wordflow/core/domain/entities/word_entity.dart';
import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/features/lexicon/data/datasources/lexicon_local_ds.dart';
import 'package:wordflow/features/lexicon/domain/commands/word_commands.dart';
import 'package:wordflow/features/lexicon/domain/entities/lexicon_stats.dart';
import 'package:wordflow/features/lexicon/domain/entities/word_filter.dart';
import 'package:wordflow/features/lexicon/domain/entities/word_sort.dart';
import 'package:wordflow/features/lexicon/domain/repositories/lexicon_repository.dart';

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
          return compute((r) => r.toEntities(), rows);
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
          .asyncMap((rows) async {
        var entities = await compute((r) => r.toEntities(), rows);
        if (filter == WordFilter.due) {
          final now = DateTime.now();
          entities = entities
              .where((e) =>
                  e.reviewSchedule != null &&
                  !e.reviewSchedule!.nextReviewDate.isAfter(now))
              .toList();
        }
        return Right(entities);
      });

  @override
  TaskEither<Failure, WordEntity> toggleStatus(int wordId) =>
      TaskEither.tryCatch(
        () async => (await _local.toggleStatus(wordId)).toEntity(),
        (error, stack) => DatabaseFailure('$error', stack),
      );

  @override
  TaskEither<Failure, WordEntity> excludeWord(int wordId) =>
      TaskEither.tryCatch(
        () async => (await _local.excludeWord(wordId)).toEntity(),
        (error, stack) => DatabaseFailure('$error', stack),
      );

  @override
  TaskEither<Failure, WordEntity> unexcludeWord(int wordId) =>
      TaskEither.tryCatch(
        () async => (await _local.unexcludeWord(wordId)).toEntity(),
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
          isExcluded: command.isExcluded,
          reviewSchedule: command.reviewSchedule?.toJson(),
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
        () async =>
            (await _local.addWord(command.text, isExcluded: command.isExcluded))
                .toEntity(),
        (error, stack) => DatabaseFailure('$error', stack),
      );

  @override
  TaskEither<Failure, WordEntity> restoreWord(RestoreWordCommand command) =>
      TaskEither.tryCatch(
        () async => (await _local.restoreWord(
          command.text,
          command.previousId,
          command.previousFrequency,
          command.wasFullyDeleted,
        ))
            .toEntity(),
        (error, stack) => DatabaseFailure('$error', stack),
      );

  @override
  TaskEither<Failure, WordEntity?> getWordByText(String text) =>
      TaskEither.tryCatch(
        () async => (await _local.getWordByText(text))?.toEntity(),
        (error, stack) => DatabaseFailure('$error', stack),
      );

  @override
  TaskEither<Failure, List<WordEntity>> initializeDefaultExcludedWords() =>
      TaskEither.tryCatch(
        () async {
          final rows = await _local.addMultipleWords(DefaultExcludedWords.words,
              isExcluded: true);
          return compute((r) => r.toEntities(), rows);
        },
        (error, stack) => DatabaseFailure('$error', stack),
      );

  @override
  TaskEither<Failure, LexiconStats> getStats() =>
      TaskEither.tryCatch(_local.getStats, (e, s) => DatabaseFailure('$e', s));

  @override
  Stream<Either<Failure, LexiconStats>> watchStats() =>
      _local.watchStats().map(Right.new);
}
