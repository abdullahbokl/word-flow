# Word-Flow: Complete Fix & Improvement Implementation Plan

## Overview
- **Project:** LexiTrack (Word-Flow) — Flutter English vocabulary tracker
- **Architecture:** Clean Architecture (Domain → Data → Presentation) with BLoC, Drift, fpdart, GetIt
- **Issues:** 102 total — 17 errors, 4 warnings, 81 info/lint
- **Status:** App does not compile due to broken imports and failing tests

---

## Phase 1: Critical Compilation Errors (3 fixes)

### Fix 1: `analyzer_page.dart` — Broken import path
**File:** `lib/features/text_analyzer/presentation/pages/analyzer_page.dart`

**Line 5:** Remove unused import:
```dart
// DELETE this line:
import '../../../../core/common/models/word_with_local_freq.dart';
```

**Line 18:** Fix relative import path:
```dart
// CHANGE from:
import '../domain/entities/analysis_result.dart';
// TO:
import '../../domain/entities/analysis_result.dart';
```

This cascading fix resolves errors on lines 68 and 82 (AnalysisResult type not found).

---

### Fix 2: `lexicon_repository_impl.dart` — Unnecessary cast
**File:** `lib/features/lexicon/data/repositories/lexicon_repository_impl.dart`

**Lines 30-31:** Remove unnecessary cast:
```dart
// CHANGE from:
return rows.map((r) => r.toEntity()).toList()
    as List<WordEntity>;
// TO:
return rows.map((r) => r.toEntity()).toList();
```

---

## Phase 2: Lint/Style Fixes (7 fixes)

### Fix 3: `bloc_status.dart` — sort_constructors_first
**File:** `lib/core/common/state/bloc_status.dart`

Reorder: Move all 6 constructors (lines 10-22) BEFORE the `status`, `error`, `data` fields (lines 6-8).

### Fix 4: `exceptions.dart` — sort_constructors_first
**File:** `lib/core/error/exceptions.dart`

Move constructors before field declarations in both `DatabaseException` and `ProcessingException`.

### Fix 5: `failures.dart` — sort_constructors_first
**File:** `lib/core/error/failures.dart`

Move `Failure` constructor before `message` and `stackTrace` fields.

### Fix 6: `app_database.dart` — use_super_parameters
**File:** `lib/core/database/app_database.dart:16`

```dart
// CHANGE from:
AppDatabase.forTesting(QueryExecutor e) : super(e);
// TO:
AppDatabase.forTesting({required super.e});
```

### Fix 7: `word_list_section.dart` — unnecessary_const
**File:** `lib/core/widgets/word_list_section.dart:117-123`

Remove redundant `const` keywords inside already-const context:
```dart
// CHANGE from:
ButtonSegment(value: 0, label: const Text(AppStrings.all), icon: const Icon(Icons.list)),
// TO:
ButtonSegment(value: 0, label: Text(AppStrings.all), icon: Icon(Icons.list)),
```
Apply same fix to lines 118-123 (all 3 ButtonSegment entries).

### Fix 8: `word_entity.dart` (lexicon) — dangling_library_doc_comments
**File:** `lib/features/lexicon/domain/entities/word_entity.dart:1`

```dart
// CHANGE from:
/// Re-export core canonical WordEntity to avoid duplicate types
export '../../../../core/domain/entities/word_entity.dart';
// TO:
// Re-export core canonical WordEntity to avoid duplicate types
export '../../../../core/domain/entities/word_entity.dart';
```
(Change doc comment `///` to regular comment `//` since re-export files can't have library-level doc comments.)

---

## Phase 3: Fix Broken Tests (6 test files)

### Fix 9: `test/bloc/history_bloc_test.dart`
**Problems:**
1. `MockHistoryRepository` tries to `implements HistoryRepository` but it's `abstract class` not `abstract interface class`
2. `const Failure()` — Failure is abstract and requires `message`
3. `HistoryBloc(repository: ...)` — constructor requires `watchHistory` and `deleteHistoryItem`, not `repository`
4. `MockHistoryRepository` missing `deleteHistoryItem` method
5. `TaskEither.fromFuture` doesn't exist in fpdart

**Fix:** Complete rewrite with proper mocktail:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lexitrack/features/history/presentation/bloc/history_bloc.dart';
import 'package:lexitrack/features/history/presentation/bloc/history_event.dart';
import 'package:lexitrack/features/history/presentation/bloc/history_state.dart';
import 'package:lexitrack/features/history/domain/repositories/history_repository.dart';
import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/features/history/domain/entities/history_item.dart';

class MockHistoryRepository extends Mock implements HistoryRepository {}

class FakeFailure extends Fake implements Failure {}

void main() {
  late MockHistoryRepository repository;
  late HistoryBloc bloc;

  setUpAll(() {
    registerFallbackValue(FakeFailure());
  });

  setUp(() {
    repository = MockHistoryRepository();
    bloc = HistoryBloc(
      watchHistory: repository.watchHistory,
      deleteHistoryItem: repository.deleteHistoryItem,
    );
  });

  tearDown(() => bloc.close());

  final testItems = [
    HistoryItem(
      id: 1,
      title: 'Test',
      totalWords: 100,
      uniqueWords: 50,
      createdAt: DateTime.now(),
      contentSnippet: 'test content',
    ),
  ];

  group('HistoryBloc', () {
    test('initial state is correct', () {
      expect(bloc.state.status.isInitial, true);
    });

    blocTest<HistoryBloc, HistoryState>(
      'emits [loading, success] when LoadHistory succeeds',
      build: () {
        when(() => repository.watchHistory()).thenAnswer(
          (_) => Stream.value(Right(testItems)),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadHistory()),
      expect: () => [
        isA<HistoryState>().having((s) => s.status.isLoading, 'isLoading', true),
        isA<HistoryState>().having((s) => s.status.isSuccess, 'isSuccess', true),
      ],
    );

    blocTest<HistoryBloc, HistoryState>(
      'emits [loading, failure] when LoadHistory fails',
      build: () {
        when(() => repository.watchHistory()).thenAnswer(
          (_) => Stream.value(Left(DatabaseFailure('error'))),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadHistory()),
      expect: () => [
        isA<HistoryState>().having((s) => s.status.isLoading, 'isLoading', true),
        isA<HistoryState>().having((s) => s.status.isFailed, 'isFailed', true),
      ],
    );

    blocTest<HistoryBloc, HistoryState>(
      'calls deleteHistoryItem when DeleteHistoryItemEvent is added',
      build: () {
        when(() => repository.deleteHistoryItem(1, deleteUniqueWords: false))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteHistoryItemEvent(1)),
      verify: (_) {
        verify(() => repository.deleteHistoryItem(1, deleteUniqueWords: false))
            .called(1);
      },
    );
  });
}
```

### Fix 10: `test/bloc/lexicon_bloc_test.dart`
**Problem:** All imports use relative paths (`../../lib/...`)

**Fix:** Change ALL imports to package imports:
```dart
// CHANGE all relative imports like:
import '../../lib/features/lexicon/...';
// TO:
import 'package:lexitrack/features/lexicon/...';
```

**Line 51:** `_stats` undefined function — replace with `const LexiconStats.empty()`.

### Fix 11: `test/unit/data/repositories/word_row_mapper_test.dart`
**Problems:**
1. Relative import paths (`../../../lib/...`)
2. `MockWordRow` can't implement Drift-generated `WordRow` class

**Fix:** Use package imports and create a real `WordRow` directly:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lexitrack/core/data/mappers/word_row_mapper.dart';
import 'package:lexitrack/core/database/app_database.dart';

void main() {
  group('WordRowMapper', () {
    test('toEntity maps all fields correctly', () {
      final now = DateTime.now();
      final row = WordRow(
        id: 1,
        word: 'test',
        frequency: 5,
        isKnown: false,
        createdAt: now,
        updatedAt: now,
        meaning: 'test meaning',
        description: 'test description',
      );

      final entity = row.toEntity();

      expect(entity.id, 1);
      expect(entity.text, 'test');
      expect(entity.frequency, 5);
      expect(entity.isKnown, false);
      expect(entity.meaning, 'test meaning');
      expect(entity.description, 'test description');
    });
  });
}
```

### Fix 12: `test/unit/domain/usecases/add_word_manually_test.dart`
**Problems:** Relative imports, mock setup, missing methods

**Fix:**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/features/lexicon/domain/entities/word_entity.dart';
import 'package:lexitrack/features/lexicon/domain/repositories/lexicon_repository.dart';
import 'package:lexitrack/features/lexicon/domain/usecases/add_word_manually.dart';

class MockLexiconRepository extends Mock implements LexiconRepository {}

void main() {
  late MockLexiconRepository repository;
  late AddWordManually usecase;

  setUp(() {
    repository = MockLexiconRepository();
    usecase = AddWordManually(repository);
  });

  group('AddWordManually', () {
    test('returns ValidationFailure for empty word', () async {
      final result = await usecase('  ').run();
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ValidationFailure>()),
        (r) => fail('Expected failure'),
      );
    });

    test('returns ValidationFailure for short word', () async {
      final result = await usecase('a').run();
      expect(result.isLeft(), true);
    });

    test('calls repository.addWord with normalized text', () async {
      final now = DateTime.now();
      final word = WordEntity(
        id: 1,
        text: 'test',
        frequency: 0,
        isKnown: false,
        createdAt: now,
        updatedAt: now,
      );
      when(() => repository.addWord('test')).thenReturn(
        TaskEither.right(word),
      );

      final result = await usecase('  TEST  ').run();

      result.fold(
        (l) => fail('Expected success'),
        (r) => expect(r.text, 'test'),
      );
      verify(() => repository.addWord('test')).called(1);
    });
  });
}
```

### Fix 13: `test/unit/domain/usecases/analyze_text_test.dart`
**Same pattern as Fix 12:**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/features/text_analyzer/domain/entities/analysis_result.dart';
import 'package:lexitrack/features/text_analyzer/domain/repositories/analyzer_repository.dart';
import 'package:lexitrack/features/text_analyzer/domain/usecases/analyze_text.dart';

class MockAnalyzerRepository extends Mock implements AnalyzerRepository {}

void main() {
  late MockAnalyzerRepository repository;
  late AnalyzeText usecase;

  setUp(() {
    repository = MockAnalyzerRepository();
    usecase = AnalyzeText(repository);
  });

  group('AnalyzeText', () {
    test('returns ValidationFailure for empty title', () async {
      final result = await usecase(title: '', content: 'test').run();
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ValidationFailure>()),
        (r) => fail('Expected failure'),
      );
    });

    test('returns ValidationFailure for empty content', () async {
      final result = await usecase(title: 'Test', content: '').run();
      expect(result.isLeft(), true);
    });

    test('calls repository.analyze with valid input', () async {
      final result = AnalysisResult(
        id: 1,
        title: 'Test',
        totalWords: 10,
        uniqueWords: 5,
        unknownWords: 3,
        knownWords: 7,
        newWordsCount: 2,
        words: const [],
      );
      when(() => repository.analyze(title: 'Test', content: 'hello world'))
          .thenReturn(TaskEither.right(result));

      final output = await usecase(title: 'Test', content: 'hello world').run();

      output.fold(
        (l) => fail('Expected success'),
        (r) => expect(r.title, 'Test'),
      );
      verify(() => repository.analyze(title: 'Test', content: 'hello world'))
          .called(1);
    });
  });
}
```

### Fix 14: `test/widget/core/status_view_test.dart`
**Lines 61, 76:** Invalid constant values

```dart
// CHANGE from (line ~61):
const StatusView(status: BlocStatus.success(data: someData), ...),
// TO (remove const if data is not const):
StatusView(status: BlocStatus.success(data: someData), ...),
```

---

## Phase 4: Architecture Improvements (3 fixes)

### Fix 15: Make `HistoryRepository` an interface class
**File:** `lib/features/history/domain/repositories/history_repository.dart:6`

```dart
// CHANGE from:
abstract class HistoryRepository {
// TO:
abstract interface class HistoryRepository {
```

This makes it consistent with `LexiconRepository` and `AnalyzerRepository`, and enables proper mocking.

### Fix 16: Fix `HistoryBloc` emit.forEach pattern
**File:** `lib/features/history/presentation/bloc/history_bloc.dart:23-32`

The current `emit.forEach` with `onData` returning `state.copyWith(...)` doesn't properly emit new states because `state` inside `onData` is captured at registration time.

**Fix:** Use proper `emit.forEach` with the `data` parameter:
```dart
Future<void> _onLoadHistory(LoadHistory event, Emitter<HistoryState> emit) async {
  emit(state.copyWith(status: const BlocStatus.loading()));
  await emit.forEach(
    _watchHistory(),
    onData: (result) => result.fold(
      (f) => state.copyWith(status: BlocStatus.failure(error: f.message)),
      (items) => HistoryState(status: BlocStatus.success(data: items)),
    ),
  );
}
```

### Fix 17: Add null safety to `StatusView`
**File:** `lib/core/widgets/status_view.dart:34`

```dart
// CHANGE from:
StateStatus.success => onSuccess?.call(status.data as T),
// TO:
StateStatus.success => onSuccess?.call(status.data!),
```

---

## Phase 5: Build Verification

### Step 18: Regenerate Drift database
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Step 19: Run Flutter analyzer
```bash
flutter analyze
```
**Target:** 0 errors, 0 warnings

### Step 20: Run all tests
```bash
flutter test
```
**Target:** All tests pass

---

## Execution Order & Dependencies

```
Phase 1 (Fix 1-2)  →  Phase 2 (Fix 3-8)  →  Phase 4 (Fix 15-17)
       ↓                                              ↓
Phase 3 (Fix 9-14) ←─────────────────────────────────┘
       ↓
Phase 5 (Step 18-20)
```

Phase 3 depends on Phase 4 (Fix 15) because the history test needs `HistoryRepository` to be an `abstract interface class`.

Phase 5 depends on all previous phases completing successfully.
