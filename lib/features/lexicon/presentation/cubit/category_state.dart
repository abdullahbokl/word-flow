import 'package:equatable/equatable.dart';
import 'package:wordflow/features/lexicon/domain/entities/tag_entity.dart';

sealed class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

final class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

final class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

final class CategoryLoaded extends CategoryState {
  const CategoryLoaded(this.tags);
  final List<TagEntity> tags;

  @override
  List<Object?> get props => [tags];
}

final class CategoryError extends CategoryState {
  const CategoryError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
