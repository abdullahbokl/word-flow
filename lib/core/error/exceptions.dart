class DatabaseException implements Exception {
  final String message;
  final dynamic cause;

  const DatabaseException(this.message, [this.cause]);

  @override
  String toString() => 'DatabaseException: $message';
}

class ProcessingException implements Exception {
  final String message;

  const ProcessingException(this.message);

  @override
  String toString() => 'ProcessingException: $message';
}
