import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:word_flow/features/vocabulary/domain/entities/text_analysis_config.dart';

part 'analysis_settings_state.freezed.dart';

@freezed
class AnalysisSettingsState with _$AnalysisSettingsState {
  const factory AnalysisSettingsState.initial() = _Initial;
  const factory AnalysisSettingsState.loading() = _Loading;
  const factory AnalysisSettingsState.loaded({
    required TextAnalysisConfig config,
    @Default(false) bool isSaving,
    String? error,
  }) = _Loaded;
  const factory AnalysisSettingsState.error(String message) = _Error;
}
