import 'package:fpdart/fpdart.dart';
import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/features/text_analyzer/data/datasources/analyzer_local_ds.dart';
import 'package:wordflow/features/text_analyzer/data/mappers/analysis_mapper.dart';
import 'package:wordflow/features/text_analyzer/domain/entities/analysis_result.dart';
import 'package:wordflow/features/text_analyzer/domain/repositories/analyzer_repository.dart';

class AnalyzerRepositoryImpl implements AnalyzerRepository {
  const AnalyzerRepositoryImpl(this._local);

  final AnalyzerLocalDataSource _local;

  @override
  TaskEither<Failure, AnalysisResult> analyze({
    required String title,
    required String content,
  }) {
    return TaskEither.tryCatch(
      () async {
        final model = await _local.analyze(title: title, content: content);
        return model.toEntity();
      },
      (error, stack) => DatabaseFailure('$error', stack),
    );
  }

  @override
  TaskEither<Failure, AnalysisResult> getAnalysisResult(int id) {
    return TaskEither.tryCatch(
      () async {
        final model = await _local.getAnalysisResult(id);
        return model.toEntity();
      },
      (error, stack) => DatabaseFailure('$error', stack),
    );
  }

  @override
  Stream<Either<Failure, AnalysisResult>> watchAnalysisResult(int id) {
    return _local.watchAnalysisResult(id).map(
          (model) => Right(model.toEntity()),
        );
  }

  @override
  TaskEither<Failure, Unit> updateAnalysisCounts(int id) {
    return TaskEither.tryCatch(
      () async {
        await _local.updateAnalysisCounts(id);
        return unit;
      },
      (error, stack) => DatabaseFailure('$error', stack),
    );
  }
}
