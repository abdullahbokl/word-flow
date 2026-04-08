import 'package:equatable/equatable.dart';

class WordWithLocalFreqModel extends Equatable {
  const WordWithLocalFreqModel({
    required this.id,
    required this.text,
    required this.frequency,
    required this.isKnown,
    required this.createdAt,
    required this.updatedAt,
    this.meaning,
    this.description,
    required this.localFrequency,
  });

  final int id;
  final String text;
  final int frequency;
  final bool isKnown;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? meaning;
  final String? description;
  final int localFrequency;

  @override
  List<Object?> get props => [
        id,
        text,
        frequency,
        isKnown,
        createdAt,
        updatedAt,
        meaning,
        description,
        localFrequency,
      ];
}

class AnalysisResultModel extends Equatable {
  const AnalysisResultModel({
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
  final List<WordWithLocalFreqModel> words;

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
