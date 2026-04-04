import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/analysis_result.dart';
import '../../domain/repositories/analyzer_repository.dart';
import '../datasources/analyzer_local_ds.dart';

class AnalyzerRepositoryImpl implements AnalyzerRepository {
  const AnalyzerRepositoryImpl(this._local);

  final AnalyzerLocalDataSource _local;

  @override
  TaskEither<Failure, AnalysisResult> analyze({
    required String title,
    required String content,
  }) {
    return TaskEither.tryCatch(
      () => _local.analyze(title: title, content: content),
      (error, stack) => DatabaseFailure('$error', stack),
    );
  }
}
