import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/word.dart';

abstract class WordRepository {
  Future<Either<Failure, void>> saveWords(List<WordEntity> words);
  Future<Either<Failure, void>> toggleKnown(String text, {String? userId});
  Future<Either<Failure, List<WordEntity>>> getKnownWords({String? userId});
  Future<Either<Failure, List<String>>> getKnownWordTexts({String? userId});
  Stream<List<WordEntity>> watchWords({String? userId});
  Future<Either<Failure, int>> adoptGuestWords(String userId);
  Future<Either<Failure, void>> clearLocalWords({String? userId});
  Future<Either<Failure, int>> getGuestWordsCount();
  Future<Either<Failure, void>> deleteWord(String id, {String? userId});
  Future<Either<Failure, void>> updateWord(WordEntity word);
}
