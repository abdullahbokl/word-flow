import 'package:equatable/equatable.dart';
import 'package:lexitrack/core/domain/entities/word_entity.dart';

class WordWithLocalFreq extends Equatable {
  const WordWithLocalFreq({
    required this.word,
    required this.localFrequency,
  });

  final WordEntity word;
  final int localFrequency;

  @override
  List<Object?> get props => [word, localFrequency];
}
