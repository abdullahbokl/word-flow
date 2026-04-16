import 'package:fpdart/fpdart.dart';

import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/features/text_analyzer/domain/entities/analysis_result.dart';

abstract interface class AnalyzerRepository {
  TaskEither<Failure, AnalysisResult> analyze({
    required String title,
    required String content,
  });

  TaskEither<Failure, AnalysisResult> getAnalysisResult(int id);

  Stream<Either<Failure, AnalysisResult>> watchAnalysisResult(int id);

  TaskEither<Failure, Unit> updateAnalysisCounts(int id);
}
