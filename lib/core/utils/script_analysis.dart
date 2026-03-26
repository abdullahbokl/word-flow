import 'package:equatable/equatable.dart';

import 'script_processor.dart';

class ScriptSummary extends Equatable {
  final int totalWords;
  final int uniqueWords;
  final int newWords;

  const ScriptSummary({
    required this.totalWords,
    required this.uniqueWords,
    required this.newWords,
  });

  const ScriptSummary.empty() : this(totalWords: 0, uniqueWords: 0, newWords: 0);

  @override
  List<Object?> get props => [totalWords, uniqueWords, newWords];
}

class ScriptAnalysis extends Equatable {
  final ScriptSummary summary;
  final List<ProcessedWord> words;

  const ScriptAnalysis({required this.summary, required this.words});

  @override
  List<Object?> get props => [summary, words];
}
