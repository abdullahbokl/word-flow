import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/common/models/word_with_local_freq.dart';

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
  }) = _AnalysisResult;

  const AnalysisResult._();

  double get comprehension =>
      totalWords == 0 ? 100 : (knownWords / totalWords) * 100;
}
