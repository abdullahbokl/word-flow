import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/analysis_result.dart';

abstract interface class AnalyzerRepository {
  TaskEither<Failure, AnalysisResult> analyze({
    required String title,
    required String content,
  });
}
