import 'package:wordflow/core/ai/ai_result.dart';

abstract interface class AiService {
  Stream<AiResult<String>> getWordMeaning(String word);
  Stream<AiResult<List<String>>> getWordExamples(String word);
  Stream<AiResult<String>> getWordTranslation(String word, String targetLang);
}
