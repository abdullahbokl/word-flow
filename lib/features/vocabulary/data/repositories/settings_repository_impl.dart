import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/constants/stopwords_loader.dart';
import 'package:word_flow/core/database/app_database.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/vocabulary/domain/entities/text_analysis_config.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/settings_repository.dart';

@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  final WordFlowDatabase _db;
  final StopwordsLoader _loader;

  SettingsRepositoryImpl(this._db, this._loader);

  static const _keyLang = 'analysis_lang';
  static const _keyMinLen = 'analysis_min_len';
  static const _keyIncludeContractions = 'analysis_include_contractions';
  static const _keyUseStemming = 'analysis_use_stemming';
  static const _keyCustomStopwords = 'analysis_custom_stopwords';

  @override
  Future<Either<Failure, TextAnalysisConfig>> getAnalysisConfig() async {
    try {
      final lang = await _getSetting(_keyLang) ?? 'english';
      final minLenStr = await _getSetting(_keyMinLen) ?? '2';
      final includeContStr = await _getSetting(_keyIncludeContractions) ?? 'true';
      final useStemmingStr = await _getSetting(_keyUseStemming) ?? 'false';
      final customSwStr = await _getSetting(_keyCustomStopwords) ?? '[]';

      final assetStopwords = await _loader.load(lang);
      final List<dynamic> customList = json.decode(customSwStr);
      final customStopwords = customList.cast<String>().toSet();

      return Right(TextAnalysisConfig(
        stopWords: {...assetStopwords, ...customStopwords},
        language: lang,
        minWordLength: int.tryParse(minLenStr) ?? 2,
        includeContractionsAsOne: includeContStr == 'true',
        useStemming: useStemmingStr == 'true',
      ));
    } catch (e) {
      return Left(DatabaseFailure('Failed to load analysis settings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateLanguage(String language) async {
    await _saveSetting(_keyLang, language);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateMinWordLength(int length) async {
    await _saveSetting(_keyMinLen, length.toString());
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateIncludeContractions(bool include) async {
    await _saveSetting(_keyIncludeContractions, include.toString());
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateUseStemming(bool use) async {
    await _saveSetting(_keyUseStemming, use.toString());
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> addCustomStopword(String word) async {
    try {
      final customSwStr = await _getSetting(_keyCustomStopwords) ?? '[]';
      final List<dynamic> list = json.decode(customSwStr);
      final Set<String> set = list.cast<String>().toSet();
      set.add(word.toLowerCase());
      await _saveSetting(_keyCustomStopwords, json.encode(set.toList()));
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add stopword: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> removeCustomStopword(String word) async {
    try {
      final customSwStr = await _getSetting(_keyCustomStopwords) ?? '[]';
      final List<dynamic> list = json.decode(customSwStr);
      final Set<String> set = list.cast<String>().toSet();
      set.remove(word.toLowerCase());
      await _saveSetting(_keyCustomStopwords, json.encode(set.toList()));
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to remove stopword: ${e.toString()}'));
    }
  }

  Future<String?> _getSetting(String key) async {
    final query = _db.select(_db.appSettings)..where((t) => t.key.equals(key));
    final row = await query.getSingleOrNull();
    return row?.value;
  }

  Future<void> _saveSetting(String key, String value) async {
    await _db.into(_db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(key: key, value: value),
        );
  }
}
