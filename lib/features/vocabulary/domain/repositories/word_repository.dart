import 'package:fpdart/fpdart.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/vocabulary/domain/entities/word_entity.dart';

abstract class WordRepository {
  Future<Either<Failure, void>> saveWords(List<WordEntity> words);
  Future<Either<Failure, void>> toggleKnown(String text, {String? userId});
  Future<Either<Failure, List<WordEntity>>> getKnownWords({String? userId});
  Future<Either<Failure, List<String>>> getKnownWordTexts({String? userId});
  Stream<List<WordEntity>> watchWords({String? userId});
  Future<Either<Failure, int>> adoptGuestWords(String userId);
  Future<Either<Failure, void>> clearLocalWords(String userId);
  Future<Either<Failure, void>> clearGuestWords();
  Future<Either<Failure, int>> getGuestWordsCount();
  Future<Either<Failure, void>> deleteWord(String id, {String? userId});
  Future<Either<Failure, void>> updateWord(WordEntity word);
}
