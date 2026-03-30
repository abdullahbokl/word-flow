import 'package:word_flow/features/vocabulary/domain/entities/word.dart';
import 'package:word_flow/features/vocabulary/data/models/word_remote_dto.dart';
import 'package:word_flow/features/auth/domain/entities/auth_user.dart';
import 'package:word_flow/features/word_learning/domain/entities/script_analysis.dart';
import 'package:word_flow/features/word_learning/domain/entities/processed_word.dart';
import 'package:word_flow/core/database/app_database.dart';

// Sample Base Data
final tNow = DateTime.now().toUtc();
const tUserId = 'user-123';
const tGuestId = null;

// Word Entities
final tWordKnown = WordEntity(
  id: 'word-1',
  userId: tUserId,
  wordText: 'hello',
  isKnown: true,
  lastUpdated: tNow,
);

final tWordUnknown = WordEntity(
  id: 'word-2',
  userId: tUserId,
  wordText: 'word',
  isKnown: false,
  lastUpdated: tNow,
);

final tGuestWord = WordEntity(
  id: 'guest-1',
  userId: tGuestId,
  wordText: 'guest',
  isKnown: false,
  lastUpdated: tNow,
);

// Auth Users
const tAuthUser = AuthUser(
  id: tUserId,
  email: 'test@example.com',
);

// Script Analysis
const tScriptSummary = ScriptSummary(
  totalWords: 100,
  uniqueWords: 50,
  newWords: 10,
);

final tProcessedWords = [
  const ProcessedWord(wordText: 'hello', totalCount: 5, isKnown: true),
  const ProcessedWord(wordText: 'new', totalCount: 1, isKnown: false),
];

final tScriptAnalysis = ScriptAnalysis(
  summary: tScriptSummary,
  words: tProcessedWords,
);

// Remote DTOs
final tWordRemoteDto = WordRemoteDto(
  id: 'word-1',
  userId: tUserId,
  wordText: 'hello',
  isKnown: true,
  lastUpdated: tNow,
);

// Helper Functions
WordEntity createWord({
  String? id,
  String? userId = tUserId,
  String? wordText,
  bool? isKnown,
  DateTime? lastUpdated,
}) {
  return WordEntity(
    id: id ?? 'id-${wordText ?? "word"}',
    userId: userId,
    wordText: wordText ?? 'sample',
    isKnown: isKnown ?? false,
    lastUpdated: lastUpdated ?? tNow,
  );
}

AuthUser createAuthUser({String? id, String? email}) {
  return AuthUser(
    id: id ?? tUserId,
    email: email ?? 'test@test.com',
  );
}

WordSyncQueueData createSyncQueueItem({
  int? id,
  String? wordId,
  String? operation,
  int? retryCount,
}) {
  return WordSyncQueueData(
    id: id ?? 1,
    wordId: wordId ?? 'word-1',
    operation: operation ?? 'upsert',
    retryCount: retryCount ?? 0,
    createdAt: tNow,
    updatedAt: tNow,
  );
}
