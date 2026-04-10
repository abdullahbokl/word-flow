import 'package:fpdart/fpdart.dart';

import '../../../../core/domain/entities/word_entity.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/lexicon_repository.dart';

class UpdateWord extends AsyncUseCase<WordEntity, int> {
  const UpdateWord(this._repository);

  final LexiconRepository _repository;

  @override
  TaskEither<Failure, WordEntity> call(
    int id, {
    String? text,
    String? meaning,
    String? description,
    List<String>? definitions,
    List<String>? examples,
    List<String>? translations,
    List<String>? synonyms,
  }) {
    return _repository.updateWord(
      id,
      text: text,
      meaning: meaning,
      description: description,
      definitions: definitions,
      examples: examples,
      translations: translations,
      synonyms: synonyms,
    );
  }
}
