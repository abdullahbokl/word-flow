import 'package:fpdart/fpdart.dart';

import 'package:lexitrack/core/domain/entities/word_entity.dart';
import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/features/lexicon/domain/commands/word_commands.dart';
import 'package:lexitrack/features/lexicon/domain/entities/lexicon_stats.dart';
import 'package:lexitrack/features/lexicon/domain/entities/word_filter.dart';
import 'package:lexitrack/features/lexicon/domain/entities/word_sort.dart';

abstract interface class LexiconRepository {
  TaskEither<Failure, List<WordEntity>> getWords({
    WordFilter filter = WordFilter.all,
    WordSort sort = WordSort.frequencyDesc,
    String query = '',
    int? limit,
    int? offset,
  });

  Stream<Either<Failure, List<WordEntity>>> watchWords({
    WordFilter filter = WordFilter.all,
    WordSort sort = WordSort.frequencyDesc,
    String query = '',
  });

  TaskEither<Failure, WordEntity> toggleStatus(int wordId);
  TaskEither<Failure, WordEntity> updateWord(UpdateWordCommand command);

  TaskEither<Failure, Unit> deleteWord(int wordId);

  TaskEither<Failure, WordEntity> addWord(AddWordCommand command);

  TaskEither<Failure, WordEntity> restoreWord(RestoreWordCommand command);

  TaskEither<Failure, WordEntity?> getWordByText(String text);

  TaskEither<Failure, LexiconStats> getStats();

  Stream<Either<Failure, LexiconStats>> watchStats();
}
