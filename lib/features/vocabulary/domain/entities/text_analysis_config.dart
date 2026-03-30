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
