import 'package:fpdart/fpdart.dart';
import 'package:equatable/equatable.dart';
import 'package:word_flow/core/errors/failures.dart';

abstract class BaseUseCase<T, Params> {
  const BaseUseCase();
  Future<Either<Failure, T>> call(Params params);
}

class NoParams extends Equatable {
  const NoParams();
  @override
  List<Object?> get props => [];
}

abstract class BaseStreamUseCase<T, Params> {
  const BaseStreamUseCase();
  Stream<Either<Failure, T>> call(Params params);
}

class UserIdParams extends Equatable {
  const UserIdParams({this.userId});
  final String? userId;

  @override
  List<Object?> get props => [userId];
}
