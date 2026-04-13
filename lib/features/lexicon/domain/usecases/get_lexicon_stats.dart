import 'package:fpdart/fpdart.dart';

import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/core/usecase/usecase.dart';
import 'package:wordflow/features/lexicon/domain/entities/lexicon_stats.dart';
import 'package:wordflow/features/lexicon/domain/repositories/lexicon_repository.dart';

class GetLexiconStats extends AsyncUseCase<LexiconStats, NoParams> {
  const GetLexiconStats(this._repository);

  final LexiconRepository _repository;

  @override
  TaskEither<Failure, LexiconStats> call(NoParams params) => _repository.getStats();
}
