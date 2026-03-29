import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class SyncFailure extends Failure {
  const SyncFailure(super.message);
}

class ProcessingFailure extends Failure {
  const ProcessingFailure(super.message);
}

class ConnectionFailure extends Failure {
  const ConnectionFailure(super.message);
}
