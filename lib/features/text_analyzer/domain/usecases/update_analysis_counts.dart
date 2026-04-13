import 'package:fpdart/fpdart.dart';
import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/core/usecase/usecase.dart';
import 'package:lexitrack/features/text_analyzer/domain/repositories/analyzer_repository.dart';

class UpdateAnalysisCounts extends AsyncUseCase<Unit, int> {
  const UpdateAnalysisCounts(this._repository);

  final AnalyzerRepository _repository;

  @override
  TaskEither<Failure, Unit> call(int id) {
    return _repository.updateAnalysisCounts(id);
  }
}
