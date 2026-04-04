import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/lexicon_stats.dart';
import '../repositories/lexicon_repository.dart';

class GetLexiconStats {
  const GetLexiconStats(this._repository);

  final LexiconRepository _repository;

  TaskEither<Failure, LexiconStats> call() => _repository.getStats();
}
