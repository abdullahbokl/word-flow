import 'package:fpdart/fpdart.dart';

import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/features/text_analyzer/domain/entities/analysis_result.dart';

abstract interface class AnalyzerRepository {
  TaskEither<Failure, AnalysisResult> analyze({
    required String title,
    required String content,
  });
}
