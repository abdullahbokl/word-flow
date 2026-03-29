class SyncQueueModel {

  SyncQueueModel({
    required this.id,
    required this.wordId,
    required this.operation,
    required this.retryCount,
    this.lastError,
    required this.createdAt,
  });

  factory SyncQueueModel.fromMap(Map<String, dynamic> map) {
    return SyncQueueModel(
      id: map['id'] as int,
      wordId: map['word_id'] as String,
      operation: map['operation'] as String,
      retryCount: map['retry_count'] as int,
      lastError: map['last_error'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
  final int id;
  final String wordId;
  final String operation;
  final int retryCount;
  final String? lastError;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'word_id': wordId,
      'operation': operation,
      'retry_count': retryCount,
      'last_error': lastError,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
