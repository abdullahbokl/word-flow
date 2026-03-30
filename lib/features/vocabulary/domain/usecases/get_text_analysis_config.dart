import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/vocabulary/domain/entities/text_analysis_config.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/settings_repository.dart';

@lazySingleton
class GetTextAnalysisConfig {
  GetTextAnalysisConfig(this._repository);

  final SettingsRepository _repository;

  Future<Either<Failure, TextAnalysisConfig>> call() =>
      _repository.getAnalysisConfig();
}
