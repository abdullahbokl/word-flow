import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/usecases/usecase.dart';
import 'package:word_flow/features/vocabulary/domain/entities/word_entity.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/word_repository.dart';

class WatchWordsPaginatedParams extends Equatable {
  const WatchWordsPaginatedParams({
    required this.userId,
    required this.limit,
    required this.offset,
    this.searchQuery,
    this.isKnown,
  });

  final String? userId;
  final int limit;
  final int offset;
  final String? searchQuery;
  final bool? isKnown;

  @override
  List<Object?> get props => [userId, limit, offset, searchQuery, isKnown];
}

@lazySingleton
class WatchWordsPaginated
    extends BaseStreamUseCase<List<WordEntity>, WatchWordsPaginatedParams> {
  WatchWordsPaginated(this._repository);
  final WordRepository _repository;

  @override
  Stream<Either<Failure, List<WordEntity>>> call(
    WatchWordsPaginatedParams params,
  ) {
    return _repository
        .watchWordsPaginated(
          userId: params.userId,
          limit: params.limit,
          offset: params.offset,
          searchQuery: params.searchQuery,
          isKnown: params.isKnown,
        )
        .map((words) => Right(words));
  }
}
