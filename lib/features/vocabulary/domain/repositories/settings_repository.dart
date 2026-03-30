import 'package:fpdart/fpdart.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/vocabulary/domain/entities/text_analysis_config.dart';

abstract class SettingsRepository {
  Future<Either<Failure, TextAnalysisConfig>> getAnalysisConfig();
  Future<Either<Failure, void>> updateLanguage(String language);
  Future<Either<Failure, void>> updateMinWordLength(int length);
  Future<Either<Failure, void>> updateIncludeContractions(bool include);
  Future<Either<Failure, void>> updateUseStemming(bool use);
  Future<Either<Failure, void>> addCustomStopword(String word);
  Future<Either<Failure, void>> removeCustomStopword(String word);
}
