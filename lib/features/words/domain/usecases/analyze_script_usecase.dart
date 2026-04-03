import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/usecases/usecase.dart';
import 'package:word_flow/features/words/models/analysis.dart';
import 'package:word_flow/features/words/repositories/text_analysis_service.dart';
import 'package:word_flow/features/words/repositories/word_repository.dart';

class AnalyzeScriptParams {
  const AnalyzeScriptParams({
    required this.text,
    required this.config,
  });

  final String text;
  final TextAnalysisConfig config;
}

@injectable
class AnalyzeScriptUseCase implements UseCase<ScriptAnalysis, AnalyzeScriptParams> {
  AnalyzeScriptUseCase(this._repository, this._analysisService);

  final WordRepository _repository;
  final TextAnalysisService _analysisService;

  @override
  Future<Either<Failure, ScriptAnalysis>> call(AnalyzeScriptParams params) async {
    try {
      if (params.text.trim().isEmpty) {
        return const Right(ScriptAnalysis(
          summary: ScriptSummary.empty(),
          words: [],
        ));
      }

      final knownWordsResult = await _repository.getKnownWordTexts();
      return knownWordsResult.fold(
        (failure) async => Left(failure),
        (knownWords) async {
          final analysis = await _analysisService.analyze(
            rawText: params.text,
            knownWords: knownWords.toSet(),
            config: params.config,
          );
          return Right(analysis);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
