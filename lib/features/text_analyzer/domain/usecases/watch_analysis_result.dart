import 'package:fpdart/fpdart.dart';
import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/core/usecase/usecase.dart';
import 'package:wordflow/features/text_analyzer/domain/entities/analysis_result.dart';
import 'package:wordflow/features/text_analyzer/domain/repositories/analyzer_repository.dart';

class WatchAnalysisResult extends StreamUseCase<AnalysisResult, int> {
  const WatchAnalysisResult(this._repository);

  final AnalyzerRepository _repository;

  @override
  Stream<Either<Failure, AnalysisResult>> call(int id) {
    return _repository.watchAnalysisResult(id);
  }
}
