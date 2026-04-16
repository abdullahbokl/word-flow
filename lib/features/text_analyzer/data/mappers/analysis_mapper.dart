import 'package:wordflow/core/common/models/word_with_local_freq.dart';
import 'package:wordflow/core/domain/entities/word_entity.dart';
import 'package:wordflow/features/text_analyzer/data/models/analysis_result_model.dart';
import 'package:wordflow/features/text_analyzer/domain/entities/analysis_result.dart';

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
      excludedWordsFound: excludedWordsFound,
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
        isExcluded: false, // Default for analysis results
        meaning: meaning,
        description: description,
      ),
      localFrequency: localFrequency,
    );
  }
}
