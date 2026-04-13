import 'package:fpdart/fpdart.dart';
import 'package:wordflow/core/constants/default_excluded_words.dart';
import 'package:wordflow/core/database/app_database.dart';
import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/features/excluded_words/data/datasources/excluded_words_local_data_source.dart';
import 'package:wordflow/features/excluded_words/data/mappers/excluded_word_mapper.dart';
import 'package:wordflow/features/excluded_words/domain/entities/excluded_word.dart';
import 'package:wordflow/features/excluded_words/domain/repositories/excluded_words_repository.dart';

class ExcludedWordsRepositoryImpl implements ExcludedWordsRepository {
  ExcludedWordsRepositoryImpl({required this.localDataSource});
  final ExcludedWordsLocalDataSource localDataSource;

  @override
  TaskEither<Failure, List<ExcludedWord>> getExcludedWords() {
    return TaskEither.tryCatch(
      () async {
        final rows = await localDataSource.getExcludedWords();
        return rows.map((r) => r.toEntity()).toList();
      },
      (error, stackTrace) => DatabaseFailure(error.toString()),
    );
  }

  @override
  TaskEither<Failure, ExcludedWord> addExcludedWord(String word) {
    return TaskEither.tryCatch(
      () async {
        final row = await localDataSource.addExcludedWord(word);
        return row.toEntity();
      },
      (error, stackTrace) => DatabaseFailure(error.toString()),
    );
  }

  @override
  TaskEither<Failure, ExcludedWord> updateExcludedWord(ExcludedWord word) {
    return TaskEither.tryCatch(
      () async {
        final row = await localDataSource.updateExcludedWord(
          ExcludedWordRow(
            id: word.id!,
            word: word.word,
            createdAt: word.createdAt,
          ),
        );
        return row.toEntity();
      },
      (error, stackTrace) => DatabaseFailure(error.toString()),
    );
  }

  @override
  TaskEither<Failure, Unit> deleteExcludedWord(int id) {
    return TaskEither.tryCatch(
      () async {
        await localDataSource.deleteExcludedWord(id);
        return unit;
      },
      (error, stackTrace) => DatabaseFailure(error.toString()),
    );
  }

  @override
  TaskEither<Failure, List<ExcludedWord>> initializeDefaultExcludedWords() {
    return TaskEither.tryCatch(
      () async {
        const defaults = DefaultExcludedWords.words;
        final rows = await localDataSource.addMultipleExcludedWords(defaults);
        return rows.map((r) => r.toEntity()).toList();
      },
      (error, stackTrace) => DatabaseFailure(error.toString()),
    );
  }
}
