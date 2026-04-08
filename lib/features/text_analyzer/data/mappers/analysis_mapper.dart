import '../../../../core/common/models/word_with_local_freq.dart';
import '../../../../core/domain/entities/word_entity.dart';
import '../../domain/entities/analysis_result.dart';
import '../models/analysis_result_model.dart';

extension AnalysisResultModelMapper on AnalysisResultModel {
  AnalysisResult toEntity() {
    return AnalysisResult(
      id: id,
      title: title,
      totalWords: totalWords,
      uniqueWords: uniqueWords,
      unknownWords: unknownWords,
      knownWords: knownWords,
      newWordsCount: newWordsCount,
      words: words.map((w) => w.toEntity()).toList(),
    );
  }
}

extension WordWithLocalFreqModelMapper on WordWithLocalFreqModel {
  WordWithLocalFreq toEntity() {
    return WordWithLocalFreq(
      word: WordEntity(
        id: id,
        text: text,
        frequency: frequency,
        isKnown: isKnown,
        createdAt: createdAt,
        updatedAt: updatedAt,
        meaning: meaning,
        description: description,
      ),
      localFrequency: localFrequency,
    );
  }
}
