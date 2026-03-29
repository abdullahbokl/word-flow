import 'package:word_flow/features/vocabulary/domain/entities/word.dart';
import 'package:word_flow/features/word_learning/domain/entities/processed_word.dart';
import 'package:word_flow/features/word_learning/domain/entities/script_analysis.dart';
import 'package:word_flow/features/vocabulary/data/models/word_model.dart';

// ============================================================================
// WORD ENTITY TEST FIXTURES
// ============================================================================

final testWord = WordEntity(
  id: 'test-id-1',
  userId: 'user-1',
  wordText: 'flutter',
  totalCount: 5,
  isKnown: false,
  lastUpdated: DateTime(2024, 1, 1),
);

final testKnownWord = testWord.copyWith(
  id: 'test-id-2',
  wordText: 'dart',
  isKnown: true,
);

final testGuestWord = WordEntity(
  id: 'test-id-3',
  userId: null,
  wordText: 'hello',
  totalCount: 5,
  isKnown: false,
  lastUpdated: DateTime(2024, 1, 1),
);

final testWord2 = testWord.copyWith(
  id: 'test-id-4',
  wordText: 'widget',
  totalCount: 3,
);

// ============================================================================
// PROCESSED WORD TEST FIXTURES
// ============================================================================

const testProcessedWord = ProcessedWord(
  wordText: 'flutter',
  totalCount: 5,
  isKnown: false,
);

const testProcessedKnownWord = ProcessedWord(
  wordText: 'dart',
  totalCount: 2,
  isKnown: true,
);

const testProcessedWord2 = ProcessedWord(
  wordText: 'widget',
  totalCount: 3,
  isKnown: false,
);

// ============================================================================
// SCRIPT SUMMARY & ANALYSIS TEST FIXTURES
// ============================================================================

const testScriptSummary = ScriptSummary(
  totalWords: 100,
  uniqueWords: 45,
  newWords: 20,
);

const testEmptyScriptSummary = ScriptSummary.empty();

const testScriptAnalysis = ScriptAnalysis(
  summary: testScriptSummary,
  words: [
    testProcessedWord,
    testProcessedKnownWord,
    testProcessedWord2,
  ],
);

const testScriptAnalysisEmpty = ScriptAnalysis(
  summary: testEmptyScriptSummary,
  words: [],
);

// ============================================================================
// WORD LIST TEST FIXTURES
// ============================================================================

final testWordList = [
  testWord,
  testKnownWord,
  testWord2,
];

final testEmptyWordList = <WordEntity>[];

// ============================================================================
// WORD MODEL TEST FIXTURES
// ============================================================================

// ============================================================================
// WORD MODEL TEST FIXTURES
// ============================================================================

final testWordModel = WordModel(
  id: 'test-id-1',
  userId: 'user-1',
  wordText: 'flutter',
  totalCount: 5,
  isKnown: false,
  lastUpdated: DateTime(2024, 1, 1),
);

final testKnownWordModel = WordModel(
  id: 'test-id-2',
  userId: 'user-1',
  wordText: 'dart',
  totalCount: 5,
  isKnown: true,
  lastUpdated: DateTime(2024, 1, 1),
);

final testGuestWordModel = WordModel(
  id: 'test-id-3',
  userId: null,
  wordText: 'hello',
  totalCount: 5,
  isKnown: false,
  lastUpdated: DateTime(2024, 1, 1),
);

final testWordModel2 = WordModel(
  id: 'test-id-4',
  userId: 'user-1',
  wordText: 'widget',
  totalCount: 3,
  isKnown: false,
  lastUpdated: DateTime(2024, 1, 1),
);

final testWordModelList = [
  testWordModel,
  testKnownWordModel,
  testWordModel2,
];

final testEmptyWordModelList = <WordModel>[];
