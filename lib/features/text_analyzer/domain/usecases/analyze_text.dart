import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/analysis_result.dart';
import '../repositories/analyzer_repository.dart';

class AnalyzeText extends AsyncUseCase<AnalysisResult, void> {
  const AnalyzeText(this._repository);

  final AnalyzerRepository _repository;

  TaskEither<Failure, AnalysisResult> call({
    required String title,
    required String content,
  }) {
    if (title.trim().isEmpty) {
      return TaskEither.left(const ValidationFailure('Title cannot be empty'));
    }
    if (content.trim().isEmpty) {
      return TaskEither.left(const ValidationFailure('Content cannot be empty'));
    }
    return _repository.analyze(title: title, content: content);
  }
}
