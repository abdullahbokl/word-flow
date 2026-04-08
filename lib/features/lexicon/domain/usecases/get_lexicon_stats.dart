import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/lexicon_stats.dart';
import '../repositories/lexicon_repository.dart';

class GetLexiconStats extends AsyncUseCase<LexiconStats, NoParams> {
  const GetLexiconStats(this._repository);

  final LexiconRepository _repository;

  @override
  TaskEither<Failure, LexiconStats> call(NoParams params) => _repository.getStats();
}
