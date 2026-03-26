class ServerException implements Exception {
  final String? message;
  ServerException([this.message]);
}

class DatabaseException implements Exception {
  final String? message;
  DatabaseException([this.message]);
}

class AuthException implements Exception {
  final String? message;
  AuthException([this.message]);
}

class SyncException implements Exception {
  final String? message;
  SyncException([this.message]);
}

class ProcessingException implements Exception {
  final String? message;
  ProcessingException([this.message]);
}
