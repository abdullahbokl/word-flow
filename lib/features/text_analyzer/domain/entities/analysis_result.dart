import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wordflow/core/common/models/word_with_local_freq.dart';

part 'analysis_result.freezed.dart';

@freezed
abstract class AnalysisResult with _$AnalysisResult {
  const factory AnalysisResult({
    required int id,
    required String title,
    required int totalWords,
    required int uniqueWords,
    required int unknownWords,
    required int knownWords,
    required int newWordsCount,
    required List<WordWithLocalFreq> words,
    @Default([]) List<String> excludedWordsFound,
  }) = _AnalysisResult;

  const AnalysisResult._();

  double get comprehension =>
      uniqueWords == 0 ? 100 : (knownWords / uniqueWords) * 100;
}
