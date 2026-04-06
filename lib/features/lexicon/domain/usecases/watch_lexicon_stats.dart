import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/lexicon_stats.dart';
import '../repositories/lexicon_repository.dart';

class WatchLexiconStats extends StreamUseCase<LexiconStats, NoParams> {
  const WatchLexiconStats(this._repository);
  final LexiconRepository _repository;

  Stream<Either<Failure, LexiconStats>> call() => _repository.watchStats();
}
