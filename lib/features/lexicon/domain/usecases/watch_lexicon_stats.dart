import 'package:fpdart/fpdart.dart';

import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/core/usecase/usecase.dart';
import 'package:wordflow/features/lexicon/domain/entities/lexicon_stats.dart';
import 'package:wordflow/features/lexicon/domain/repositories/lexicon_repository.dart';

class WatchLexiconStats extends StreamUseCase<LexiconStats, NoParams> {
  const WatchLexiconStats(this._repository);
  final LexiconRepository _repository;

  @override
  Stream<Either<Failure, LexiconStats>> call(NoParams params) =>
      _repository.watchStats();
}
