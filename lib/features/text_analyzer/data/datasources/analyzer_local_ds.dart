import '../models/analysis_result_model.dart';

abstract interface class AnalyzerLocalDataSource {
  Future<AnalysisResultModel> analyze({
    required String title,
    required String content,
  });
}
