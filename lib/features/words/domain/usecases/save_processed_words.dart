import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/script_processor.dart';
import '../entities/word.dart';
import '../repositories/word_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

@lazySingleton
class SaveProcessedWords {
  final WordRepository _repository;

  SaveProcessedWords(this._repository);

  Future<Either<Failure, void>> call(List<ProcessedWord> processedWords, {String? userId}) async {
    try {
      final now = DateTime.now().toUtc();
      final words = processedWords.map((e) => Word(
        id: const Uuid().v4(),
        userId: userId,
        wordText: e.wordText,
        totalCount: e.totalCount,
        isKnown: false,
        lastUpdated: now,
      )).toList();

      return await _repository.saveWords(words);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
