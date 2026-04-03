import 'package:equatable/equatable.dart';

class TextAnalysisConfig extends Equatable {
  const TextAnalysisConfig({
    required this.stopWords,
    required this.language,
    this.minWordLength = 2,
    this.includeContractionsAsOne = true,
    this.useStemming = false,
  });

  final Set<String> stopWords;
  final String language;
  final int minWordLength;
  final bool includeContractionsAsOne;
  final bool useStemming;

  @override
  List<Object?> get props => [
    stopWords,
    language,
    minWordLength,
    includeContractionsAsOne,
    useStemming,
  ];
}

class ScriptSummary extends Equatable {
  const ScriptSummary({
    required this.totalWords,
    required this.uniqueWords,
    required this.newWords,
  });

  const ScriptSummary.empty()
    : this(totalWords: 0, uniqueWords: 0, newWords: 0);

  final int totalWords;
  final int uniqueWords;
  final int newWords;

  @override
  List<Object?> get props => [totalWords, uniqueWords, newWords];
}

class AnalyzedWord extends Equatable {
  const AnalyzedWord({
    required this.wordText,
    required this.totalCount,
    this.isKnown = false,
  });

  final String wordText;
  final int totalCount;
  final bool isKnown;

  @override
  List<Object?> get props => [wordText, totalCount, isKnown];
}

class ScriptAnalysis extends Equatable {
  const ScriptAnalysis({required this.summary, required this.words});

  final ScriptSummary summary;
  final List<AnalyzedWord> words;

  @override
  List<Object?> get props => [summary, words];
}
