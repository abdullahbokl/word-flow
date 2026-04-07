class DatabaseException implements Exception {
  const DatabaseException(this.message, [this.cause]);

  final String message;
  final dynamic cause;

  @override
  String toString() => 'DatabaseException: $message';
}

class ProcessingException implements Exception {
  const ProcessingException(this.message);

  final String message;

  @override
  String toString() => 'ProcessingException: $message';
}
