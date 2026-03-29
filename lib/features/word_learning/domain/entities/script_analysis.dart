import 'package:equatable/equatable.dart';
import 'package:word_flow/features/word_learning/domain/entities/processed_word.dart';

class ScriptSummary extends Equatable {
  const ScriptSummary({
    required this.totalWords,
    required this.uniqueWords,
    required this.newWords,
  });

  const ScriptSummary.empty()
      : this(
          totalWords: 0,
          uniqueWords: 0,
          newWords: 0,
        );

  final int totalWords;
  final int uniqueWords;
  final int newWords;

  @override
  List<Object?> get props => [totalWords, uniqueWords, newWords];
}

class ScriptAnalysis extends Equatable {
  const ScriptAnalysis({required this.summary, required this.words});

  final ScriptSummary summary;
  final List<ProcessedWord> words;

  @override
  List<Object?> get props => [summary, words];
}
