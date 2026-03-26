import '../entities/word.dart';
import '../repositories/word_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class WatchWords {
  final WordRepository _repository;

  WatchWords(this._repository);

  Stream<List<Word>> call({String? userId}) {
    return _repository.watchWords(userId: userId);
  }
}
