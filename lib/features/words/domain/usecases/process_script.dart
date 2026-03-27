import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/script_analysis.dart';
import '../../../../core/utils/script_processor.dart';
import '../repositories/word_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ProcessScript {
  final WordRepository _repository;

  ProcessScript(this._repository);

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
