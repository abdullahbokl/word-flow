import 'package:fpdart/fpdart.dart';
import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/features/text_analyzer/data/datasources/analyzer_local_ds.dart';
import 'package:lexitrack/features/text_analyzer/data/mappers/analysis_mapper.dart';
import 'package:lexitrack/features/text_analyzer/domain/entities/analysis_result.dart';
import 'package:lexitrack/features/text_analyzer/domain/repositories/analyzer_repository.dart';

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
}
