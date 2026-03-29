import 'package:word_flow/features/words/domain/entities/word.dart';
import 'package:word_flow/features/words/domain/repositories/word_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class WatchWords {

  WatchWords(this._repository);
  final WordRepository _repository;

  Stream<List<WordEntity>> call({String? userId}) {
    return _repository.watchWords(userId: userId);
  }
}
