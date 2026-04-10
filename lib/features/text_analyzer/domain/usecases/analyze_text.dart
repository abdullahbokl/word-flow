import 'package:fpdart/fpdart.dart';

import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/core/usecase/usecase.dart';
import 'package:lexitrack/features/text_analyzer/domain/entities/analysis_result.dart';
import 'package:lexitrack/features/text_analyzer/domain/repositories/analyzer_repository.dart';

class AnalyzeTextParams {
  const AnalyzeTextParams({required this.title, required this.content});
  final String title;
  final String content;
}

class AnalyzeText extends AsyncUseCase<AnalysisResult, AnalyzeTextParams> {
  const AnalyzeText(this._repository);

  final AnalyzerRepository _repository;

  @override
  TaskEither<Failure, AnalysisResult> call(AnalyzeTextParams params) {
    if (params.title.trim().isEmpty) {
      return TaskEither.left(const ValidationFailure('Title cannot be empty'));
    }
    if (params.content.trim().isEmpty) {
      return TaskEither.left(const ValidationFailure('Content cannot be empty'));
    }
    return _repository.analyze(title: params.title, content: params.content);
  }
}
