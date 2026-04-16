import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wordflow/core/domain/entities/word_entity.dart';

part 'review_state.freezed.dart';

@freezed
sealed class ReviewState with _$ReviewState {
  const factory ReviewState.initial() = ReviewInitial;
  const factory ReviewState.loading() = ReviewLoading;
  const factory ReviewState.loaded({
    required List<WordEntity> dueWords,
  }) = ReviewLoaded;
  const factory ReviewState.completed() = ReviewCompleted;
  const factory ReviewState.error(String message) = ReviewError;
}
