class ServerException implements Exception {
  ServerException([this.message]);
  final String? message;
}

class DatabaseException implements Exception {
  DatabaseException([this.message]);
  final String? message;
}

class AuthException implements Exception {
  AuthException([this.message]);
  final String? message;
}

class SyncException implements Exception {
  SyncException([this.message]);
  final String? message;
}

class ProcessingException implements Exception {
  ProcessingException([this.message]);
  final String? message;
}
