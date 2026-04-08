import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/domain/entities/word_entity.dart';
import '../entities/lexicon_stats.dart';
import '../entities/word_filter.dart';
import '../entities/word_sort.dart';

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
  TaskEither<Failure, WordEntity> updateWord(
    int id, {
    String? meaning,
    String? description,
  });

  TaskEither<Failure, Unit> deleteWord(int wordId);

  TaskEither<Failure, WordEntity> addWord(String text);

  TaskEither<Failure, LexiconStats> getStats();

  Stream<Either<Failure, LexiconStats>> watchStats();
}
