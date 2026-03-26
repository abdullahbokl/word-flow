import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/word.dart';

abstract class WordRepository {
  Future<Either<Failure, void>> saveWords(List<Word> words);
  Future<Either<Failure, void>> toggleKnown(String text, {String? userId});
  Future<Either<Failure, List<Word>>> getKnownWords({String? userId});
  Stream<List<Word>> watchWords({String? userId});
  Future<Either<Failure, int>> adoptGuestWords(String userId);
  Future<Either<Failure, void>> clearLocalWords({String? userId});
}
