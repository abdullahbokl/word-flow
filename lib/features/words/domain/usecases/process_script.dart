import 'package:dartz/dartz.dart';
import 'package:word_flow/core/error/failures.dart';
import 'package:word_flow/core/utils/script_analysis.dart';
import 'package:word_flow/core/utils/script_processor.dart';
import 'package:word_flow/features/words/domain/repositories/word_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ProcessScript {

  ProcessScript(this._repository);
  final WordRepository _repository;

  Future<Either<Failure, ScriptAnalysis>> call(
    String rawText, {
    String? userId,
  }) async {
    try {
      final wordsResult = await _repository.getKnownWordTexts(userId: userId);
      final Set<String> knownWordTexts = wordsResult.fold(
        (failure) => {},
        (texts) => texts.toSet(),
      );

      final processed = await ScriptProcessor.process(
        rawText: rawText,
        knownWords: knownWordTexts,
      );

      return Right(processed);
    } catch (e) {
      return Left(ProcessingFailure(e.toString()));
    }
  }
}
