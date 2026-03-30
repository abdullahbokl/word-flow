import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/settings_repository.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/get_text_analysis_config.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/analysis_settings_state.dart';

@injectable
class AnalysisSettingsCubit extends Cubit<AnalysisSettingsState> {
  AnalysisSettingsCubit(this._getConfig, this._repository)
      : super(const AnalysisSettingsState.initial());

  final GetTextAnalysisConfig _getConfig;
  final SettingsRepository _repository;

  Future<void> load() async {
    emit(const AnalysisSettingsState.loading());
    final result = await _getConfig();
    result.fold(
      (f) => emit(AnalysisSettingsState.error(f.message)),
      (config) => emit(AnalysisSettingsState.loaded(config: config)),
    );
  }

  Future<void> updateLanguage(String lang) async {
    await state.maybeWhen(
      loaded: (config, isSaving, error) async {
        final result = await _repository.updateLanguage(lang);
        result.fold(
          (f) => emit(AnalysisSettingsState.loaded(config: config, error: f.message)),
          (_) => load(),
        );
      },
      orElse: () {},
    );
  }

  Future<void> updateMinWordLength(int length) async {
    await state.maybeWhen(
      loaded: (config, isSaving, error) async {
        final result = await _repository.updateMinWordLength(length);
        result.fold(
          (f) => emit(AnalysisSettingsState.loaded(config: config, error: f.message)),
          (_) => load(),
        );
      },
      orElse: () {},
    );
  }

  Future<void> toggleContractions(bool enabled) async {
    await state.maybeWhen(
      loaded: (config, isSaving, error) async {
        final result = await _repository.updateIncludeContractions(enabled);
        result.fold(
          (f) => emit(AnalysisSettingsState.loaded(config: config, error: f.message)),
          (_) => load(),
        );
      },
      orElse: () {},
    );
  }

  Future<void> toggleStemming(bool enabled) async {
    await state.maybeWhen(
      loaded: (config, isSaving, error) async {
        final result = await _repository.updateUseStemming(enabled);
        result.fold(
          (f) => emit(AnalysisSettingsState.loaded(config: config, error: f.message)),
          (_) => load(),
        );
      },
      orElse: () {},
    );
  }

  Future<void> addStopword(String word) async {
    if (word.trim().isEmpty) return;
    await state.maybeWhen(
      loaded: (config, isSaving, error) async {
        final result = await _repository.addCustomStopword(word.trim().toLowerCase());
        result.fold(
          (f) => emit(AnalysisSettingsState.loaded(config: config, error: f.message)),
          (_) => load(),
        );
      },
      orElse: () {},
    );
  }

  Future<void> removeStopword(String word) async {
    await state.maybeWhen(
      loaded: (config, isSaving, error) async {
        final result = await _repository.removeCustomStopword(word);
        result.fold(
          (f) => emit(AnalysisSettingsState.loaded(config: config, error: f.message)),
          (_) => load(),
        );
      },
      orElse: () {},
    );
  }
}
