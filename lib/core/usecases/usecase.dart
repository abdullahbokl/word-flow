import 'package:fpdart/fpdart.dart';
import 'package:word_flow/core/errors/failures.dart';

abstract class UseCase<ReturnType, Params> {
  Future<Either<Failure, ReturnType>> call(Params params);
}

class NoParams {}
