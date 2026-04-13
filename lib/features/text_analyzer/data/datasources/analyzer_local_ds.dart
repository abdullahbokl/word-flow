import 'package:lexitrack/features/text_analyzer/data/models/analysis_result_model.dart';

abstract interface class AnalyzerLocalDataSource {
  Future<AnalysisResultModel> analyze({
    required String title,
    required String content,
  });

  Future<AnalysisResultModel> getAnalysisResult(int id);

  Future<void> updateAnalysisCounts(int id);
}
