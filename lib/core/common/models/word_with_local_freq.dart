import 'package:equatable/equatable.dart';
import '../../../features/lexicon/domain/entities/word_entity.dart';

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
