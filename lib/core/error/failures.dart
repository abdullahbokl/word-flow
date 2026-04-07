import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.message, [this.stackTrace]);

  final String message;
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => [message];
}

final class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, [super.stackTrace]);
}

final class ProcessingFailure extends Failure {
  const ProcessingFailure(super.message, [super.stackTrace]);
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.stackTrace]);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
