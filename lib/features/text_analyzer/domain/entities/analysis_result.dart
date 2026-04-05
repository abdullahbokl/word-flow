import 'package:equatable/equatable.dart';
import '../../../../core/common/models/word_with_local_freq.dart';

class AnalysisResult extends Equatable {
  const AnalysisResult({
    required this.id,
    required this.title,
    required this.totalWords,
    required this.uniqueWords,
    required this.unknownWords,
    required this.knownWords,
    required this.newWordsCount,
    required this.words,
  });

  final int id;
  final String title;
  final int totalWords;
  final int uniqueWords;
  final int unknownWords;
  final int knownWords;
  final int newWordsCount;
  final List<WordWithLocalFreq> words;

  double get comprehension =>
      totalWords == 0 ? 100 : (knownWords / totalWords) * 100;

  AnalysisResult copyWith({
    int? id,
    String? title,
    int? totalWords,
    int? uniqueWords,
    int? unknownWords,
    int? knownWords,
    int? newWordsCount,
    List<WordWithLocalFreq>? words,
  }) {
    return AnalysisResult(
      id: id ?? this.id,
      title: title ?? this.title,
      totalWords: totalWords ?? this.totalWords,
      uniqueWords: uniqueWords ?? this.uniqueWords,
      unknownWords: unknownWords ?? this.unknownWords,
      knownWords: knownWords ?? this.knownWords,
      newWordsCount: newWordsCount ?? this.newWordsCount,
      words: words ?? this.words,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        totalWords,
        uniqueWords,
        unknownWords,
        knownWords,
        newWordsCount,
        words,
      ];
}
