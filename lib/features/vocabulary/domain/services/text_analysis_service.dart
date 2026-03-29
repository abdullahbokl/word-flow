import 'package:word_flow/features/word_learning/domain/entities/script_analysis.dart';

abstract class TextAnalysisService {
  Future<ScriptAnalysis> process({
    required String rawText,
    required Set<String> knownWords,
  });
}
