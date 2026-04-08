import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/analysis_result.dart';
import '../../domain/repositories/analyzer_repository.dart';
import '../datasources/analyzer_local_ds.dart';
import '../mappers/analysis_mapper.dart';

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
