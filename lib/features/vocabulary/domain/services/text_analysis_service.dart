import 'package:word_flow/features/word_learning/domain/entities/script_analysis.dart';
import 'package:word_flow/features/vocabulary/domain/entities/text_analysis_config.dart';

abstract class TextAnalysisService {
  Future<ScriptAnalysis> process({
    required String rawText,
    required Set<String> knownWords,
    required TextAnalysisConfig config,
  });
}
