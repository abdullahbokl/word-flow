# WordFlow V1 — Offline-First Foundation

## Summary

Replace the starter counter app with a single-workspace Flutter app built in Clean Architecture layers: `core`, `features/auth`, and `features/words`, with `lib/main.dart` reduced to bootstrap + DI startup.

Use `flutter_bloc` with Cubits for v1: `AuthCubit` for Supabase email/password session state, `WorkspaceCubit` for script input/extraction/save flows, and `SyncCubit` for queue/sync status.

Keep SQLite as the write-first source of truth and Supabase as the remote mirror. Every mutation writes locally, enqueues sync work, and only then attempts remote sync.

Use `supabase_flutter` for auth and all remote sync operations (PostgREST). No external HTTP client (like Dio) is used to minimize dependency surface.

Use `fpdart` for functional patterns and sealed error handling. 

---

## Skills Applied

| Skill | Role |
|-------|------|
| `flutter-best-practices` | Architecture baseline, directory layout, DI pattern |
| `bloc-state-management` | State design workflow, `@freezed` states, anti-patterns |
| `dart-clean-code` | ≤120 lines, naming, single-responsibility, no widget-returning helpers |
| `mobile-design` | Offline-first UX, empty states, connectivity feedback |

---

## Directory Structure

```
lib/
├── main.dart                          # runApp + bootstrap only
├── app/
│   ├── app.dart                       # MaterialApp + theme setup
│   └── di.dart                        # get_it + injectable config
├── core/
│   ├── config/
│   │   └── env_config.dart            # Supabase URL/Key via --dart-define
│   ├── error/
│   │   ├── failures.dart              # Failure sealed class hierarchy
│   │   └── exceptions.dart            # Raw exception wrappers
│   ├── database/
│   │   ├── app_database.dart          # Drift database + schema
│   │   └── tables.dart                # Table definitions
│   ├── sync/
│   │   ├── sync_service.dart          # Coordinator: triggers sync
│   │   ├── connectivity_monitor.dart  # Stream<ConnectivityStatus>
│   │   └── sync_queue_model.dart      # word_sync_queue row mapping
│   ├── theme/
│   │   ├── app_colors.dart            # Semantic color tokens
│   │   ├── app_text_styles.dart       # Typography scale
│   │   └── app_theme.dart             # ThemeData assembly
│   ├── utils/
│   │   ├── script_processor.dart      # Regex word extraction (Isolate)
│   │   └── uuid_generator.dart        # Client-side UUID helper
│   └── widgets/
│       ├── app_button.dart            # Reusable button widget
│       ├── word_card.dart             # Word display card widget
│       ├── empty_state_view.dart      # Empty/placeholder widget
│       └── sync_status_badge.dart     # Offline/syncing/synced indicator
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_source.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── sign_in_with_email.dart
│   │   │       ├── sign_up_with_email.dart
│   │   │       └── sign_out.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── auth_cubit.dart
│   │       │   └── auth_state.dart
│   │       └── widgets/
│   │           ├── auth_form.dart
│   │           └── auth_status_bar.dart
│   └── words/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── word_local_source.dart
│       │   │   └── word_remote_source.dart
│       │   ├── models/
│       │   │   └── word_model.dart
│       │   └── repositories/
│       │       ├── word_repository_impl.dart
│       │       └── sync_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── word.dart
│       │   ├── repositories/
│       │   │   ├── word_repository.dart
│       │   │   └── sync_repository.dart
│       │   └── usecases/
│       │       ├── process_script.dart
│       │       ├── save_processed_words.dart
│       │       ├── toggle_known_word.dart
│       │       ├── watch_words.dart
│       │       ├── sync_pending_words.dart
│       │       └── adopt_guest_words.dart
│       └── presentation/
│           ├── cubit/
│           │   ├── workspace_cubit.dart
│           │   ├── workspace_state.dart
│           │   ├── sync_cubit.dart
│           │   └── sync_state.dart
│           ├── pages/
│           │   └── workspace_page.dart
│           └── widgets/
│               ├── script_input_field.dart
│               ├── word_results_list.dart
│               └── analyze_button.dart
└── test/
    ├── core/
    │   └── utils/
    │       └── script_processor_test.dart
    ├── features/
    │   ├── auth/
    │   │   └── cubit/
    │   │       └── auth_cubit_test.dart
    │   └── words/
    │       ├── data/
    │       │   └── models/
    │       │       └── word_model_test.dart
    │       ├── domain/
    │       │   └── usecases/
    │       │       └── process_script_test.dart
    │       └── cubit/
    │           ├── workspace_cubit_test.dart
    │           └── sync_cubit_test.dart
    └── widget_test.dart               # Updated smoke test
```

---

## Dependency Strategy

### Production Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_bloc` | ^9.x | Cubit/BLoC state management |
| `freezed_annotation` | ^2.x | Union types for states & entities |
| `fpdart` | ^1.x | Functional programming primitives |
| `get_it` | ^8.x | Service locator DI |
| `injectable` | ^2.x | Code-gen DI wiring |
| `drift` | ^2.x | Local SQLite database (ORM) |
| `supabase_flutter` | ^2.x | Auth + Remote Storage (PostgREST) |
| `connectivity_plus` | ^6.x | Network reachability stream |
| `sentry_flutter` | ^9.x | Error reporting & monitoring |

### Dev Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `freezed` | ^3.x | Code generation for states |
| `build_runner` | ^2.x | Runs freezed + injectable generators |
| `injectable_generator` | ^2.x | DI setup generation |
| `bloc_test` | ^9.x | `blocTest()` for cubit testing |
| `mocktail` | ^1.x | Mocking for unit tests |

### Removed from Original Plan

| Original | Reason | Replacement |
|----------|--------|-------------|
| `dartz` | Maintenance-only mode | Replaced with `fpdart` |
| `dio` | Overkill for Supabase | Replaced with `supabase_flutter` client |
| `sqflite` | Low-level boilerplate | Replaced with `drift` (type-safe SQL) |

> [!NOTE]
> Environment secrets (`SUPABASE_URL`, `SUPABASE_ANON_KEY`) must be injected via `--dart-define` at build time, never hardcoded. `EnvConfig` reads them from `String.fromEnvironment`.

---

## Data Model

### `Word` Domain Entity (pure Dart, no Flutter imports)

```dart
class Word {
  final String id;        // Client-generated UUID
  final String? userId;   // null = guest row
  final String wordText;
  final int totalCount;
  final bool isKnown;
  final DateTime lastUpdated; // UTC always
}
```

### `WordModel` Data Model

Maps 1:1 to both SQLite and Supabase REST payloads. Centralizes normalization:

```dart
class WordModel extends Word {
  // SQLite stores bool as int (0/1), Supabase as true/false
  // SQLite stores DateTime as ISO string, PostgREST as ISO string
  factory WordModel.fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toMap();
}
```

### SQLite Schema — `words` table

| Column | Type | Notes |
|--------|------|-------|
| `id` | TEXT PRIMARY KEY | Client UUID |
| `user_id` | TEXT NULLABLE | `null` for guest |
| `word_text` | TEXT NOT NULL | |
| `total_count` | INTEGER DEFAULT 1 | |
| `is_known` | INTEGER DEFAULT 0 | 0=false, 1=true |
| `last_updated` | TEXT NOT NULL | ISO 8601 UTC |

### SQLite Schema — `word_sync_queue` (local-only)

| Column | Type | Notes |
|--------|------|-------|
| `id` | INTEGER PRIMARY KEY AUTOINCREMENT | Queue row ID |
| `word_id` | TEXT NOT NULL | FK to `words.id` |
| `operation` | TEXT NOT NULL | `upsert` or `delete` |
| `retry_count` | INTEGER DEFAULT 0 | |
| `last_error` | TEXT NULLABLE | Last failure message |
| `created_at` | TEXT NOT NULL | ISO 8601 UTC |

> [!IMPORTANT]
> Sync metadata lives in `word_sync_queue`, **never** in the `words` table. This keeps the mirror contract intact — `words` has identical columns locally and remotely.

### Database Migration Strategy

`database_helper.dart` uses `sqflite`'s `onUpgrade` with a versioned migration runner:

```dart
await openDatabase(
  path,
  version: 2, // bump per schema change
  onCreate: (db, version) => _runMigrations(db, 0, version),
  onUpgrade: (db, oldVer, newVer) => _runMigrations(db, oldVer, newVer),
);
```

Each migration is a numbered function in `migrations.dart`. No raw SQL scattered across the codebase.

---

## Error Handling Hierarchy

```dart
// core/error/failures.dart
sealed class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure { ... }
class DatabaseFailure extends Failure { ... }
class AuthFailure extends Failure { ... }
class SyncFailure extends Failure { ... }
class ProcessingFailure extends Failure { ... }
```

### Data Layer Response Wrapper

```dart
// Used by data sources (not by repositories)
sealed class DataResult<T> {
  const DataResult();
}
class DataSuccess<T> extends DataResult<T> {
  final T data;
  const DataSuccess(this.data);
}
class DataError<T> extends DataResult<T> {
  final Exception exception;
  const DataError(this.exception);
}
```

Repositories translate `DataResult` → `Either<Failure, T>` for the domain layer.

---

## Dependency Injection

Use `get_it` + `injectable` for service registration. **Not** `MultiRepositoryProvider` for DI — BlocProviders remain in the widget tree for scoped cubit lifecycle, but all non-UI services register through `get_it`.

```dart
// main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();   // get_it + injectable
  await Supabase.initialize(...);
  runApp(const WordFlowApp());
}
```

```dart
// app/di.dart
@InjectableInit()
Future<void> configureDependencies() async => getIt.init();
```

Cubits are provided via `BlocProvider` at the route/screen level:

```dart
BlocProvider(
  create: (_) => getIt<WorkspaceCubit>(),
  child: const WorkspacePage(),
);
```

---

## State Management — Cubit Design

### `AuthCubit`

```dart
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(UserEntity user) = _Authenticated;
  const factory AuthState.guest() = _Guest;
  const factory AuthState.error(String message) = _Error;
}
```

**Responsibilities:** Sign in → adopt guest words → emit authenticated. Sign out → clear user data → emit guest.

### `WorkspaceCubit`

```dart
@freezed
sealed class WorkspaceState with _$WorkspaceState {
  const factory WorkspaceState.initial() = _Initial;
  const factory WorkspaceState.processing() = _Processing;
  const factory WorkspaceState.results(List<Word> words) = _Results;
  const factory WorkspaceState.saved() = _Saved;
  const factory WorkspaceState.error(String message) = _Error;
}
```

**Responsibilities:** Accept raw script text → invoke `ProcessScript` usecase (on Isolate) → show extracted word list → save to local DB via `SaveProcessedWords`.

### `SyncCubit`

```dart
@freezed
sealed class SyncState with _$SyncState {
  const factory SyncState.idle({
    required int pendingCount,
    DateTime? lastSyncTime,
  }) = _Idle;
  const factory SyncState.syncing({required int pendingCount}) = _Syncing;
  const factory SyncState.error({
    required int pendingCount,
    required String message,
  }) = _Error;
}
```

**Responsibilities:** Exposes queue size, sync status, and last sync time. Triggered by `SyncService` events.

> [!TIP]
> Per `bloc-state-management` skill: use `BlocBuilder` for UI rebuilds, `BlocListener` for side effects (snackbars, navigation). Never put complex logic inside `BlocBuilder`.

---

## Guest vs. Authenticated Flow

### Guest Mode

- `WordRepository` interacts only with `WordLocalSource`.
- `userId` is `null` on all guest rows.
- No sync occurs; `SyncCubit` shows `pendingCount: 0`.
- User can process scripts, save words, and toggle `isKnown` fully offline.

### Sign-In → Guest Adoption

```
1. AuthCubit.signIn(email, password)
2. supabase_flutter authenticates → returns UID
3. AdoptGuestWords usecase runs in a local transaction:
   a. Fetch all words where user_id IS NULL
   b. Set user_id = authenticated UID
   c. Update last_updated to now (UTC)
   d. Enqueue each modified word in word_sync_queue (operation: upsert)
4. SyncService triggers immediate sync attempt
5. AuthCubit emits AuthState.authenticated(user)
```

### Sign-Out → Data Isolation

```
1. AuthCubit.signOut()
2. Clear authenticated user's word rows from local SQLite
3. Clear corresponding word_sync_queue entries
4. Reset to fresh guest workspace
5. AuthCubit emits AuthState.guest()
```

> [!CAUTION]
> On shared devices, sign-out **must** delete all authenticated data from local storage to prevent cross-account data leakage.

---

## Sync Architecture

### Sync Service Triggers

| Trigger | Mechanism |
|---------|-----------|
| App start | `SyncService.init()` in bootstrap |
| Auth change | `AuthCubit` listener |
| App resume | `WidgetsBindingObserver.didChangeAppLifecycleState` |
| Connectivity restored | `ConnectivityMonitor` stream |
| Manual retry | User tap on sync badge |

### Sync Flow

```
1. SyncService reads word_sync_queue (oldest first, max batch of 20)
2. For each queued item:
   a. Read the word from local words table
   b. Upsert to Supabase via `SupabaseClient` (PostgREST)
   c. On success: delete queue entry
   d. On failure: increment retry_count, store last_error
3. SyncCubit emits updated state with new pendingCount
4. If retry_count > 5, mark as "stale" — don't auto-retry, wait for manual
```

### Conflict Resolution

`last_updated` newest-wins. The Supabase upsert uses `ON CONFLICT (id)` with a `WHERE last_updated < excluded.last_updated` guard. If the remote row is newer, the local row is silently skipped, and the queue entry is deleted.

### Connectivity Monitor

```dart
// core/sync/connectivity_monitor.dart
// Wraps connectivity_plus to emit ConnectivityStatus
// SyncService listens and triggers flush on restored connectivity
```

---

### Networking — Supabase Client

WordFlow uses the official `supabase_flutter` SDK for all networking. This eliminates the need for manual Dio interceptors for auth headers or API key injection, as the SDK handles session persistence and header management natively.

Error handling is done at the repository level by catching `PostgrestException` and mapping it to domain `Failure` objects.

---

## ScriptProcessor — Isolate-Based

Runs in `Isolate.run` to avoid blocking the UI thread:

```dart
final result = await Isolate.run(() {
  return ScriptProcessor.process(
    rawText: script,
    knownWords: knownWordSet,
  );
});
```

**Processing steps:**
1. Normalize to lowercase
2. Extract words via regex: `RegExp(r"[a-zA-Z']+")` (supports contractions)
3. Count frequencies → `Map<String, int>`
4. Filter out known words
5. Sort by frequency descending
6. Return `List<ProcessedWord>` with `wordText` and `totalCount`

---

## Theme & Design Tokens

```dart
// core/theme/app_colors.dart
// Semantic color tokens derived from ColorScheme.fromSeed
// No hardcoded hex values in widgets

// core/theme/app_text_styles.dart
// Typography scale using Google Fonts (e.g., Inter)
// Referenced via Theme.of(context).textTheme

// core/theme/app_theme.dart
// Assembles ThemeData for light mode (dark mode deferred to v2)
```

All widgets reference `Theme.of(context)` — **never** inline `Color(0xFF...)` or `TextStyle(fontSize: ...)`.

---

## UI Structure (Single Route for V1)

```
WorkspacePage (Scaffold)
├── AppBar
│   ├── AuthStatusBar (shows guest/email + sign-in/out)
│   └── SyncStatusBadge (offline/syncing/synced/error)
├── Body (SingleChildScrollView or CustomScrollView)
│   ├── ScriptInputField (multiline TextField, large text support)
│   ├── AnalyzeButton (triggers ProcessScript)
│   ├── WordResultsList (ListView.builder of WordCard widgets)
│   └── EmptyStateView (shown when no words processed yet)
└── No FAB (explicit AnalyzeButton instead)
```

### Large Text Input Performance

- `ScriptInputField` uses `maxLines: null` with `TextEditingController`
- Processing runs on a separate Isolate — typing never lags
- Results list uses `ListView.builder` for lazy rendering
- `const` constructors on all leaf widgets

### Reusable Widgets (core/widgets/)

| Widget | Purpose |
|--------|---------|
| `AppButton` | Primary/secondary action button with loading state |
| `WordCard` | Displays word text, count, known toggle |
| `EmptyStateView` | Icon + message for empty states |
| `SyncStatusBadge` | Visual indicator of sync state |

---

## Use Cases

| UseCase | Input | Output | Layer |
|---------|-------|--------|-------|
| `SignInWithEmail` | email, password | `Either<Failure, UserEntity>` | auth/domain |
| `SignUpWithEmail` | email, password | `Either<Failure, UserEntity>` | auth/domain |
| `SignOut` | — | `Either<Failure, void>` | auth/domain |
| `ProcessScript` | raw text, known words | `Either<Failure, List<ProcessedWord>>` | words/domain |
| `SaveProcessedWords` | `List<ProcessedWord>` | `Either<Failure, void>` | words/domain |
| `ToggleKnownWord` | word ID | `Either<Failure, Word>` | words/domain |
| `WatchWords` | userId filter | `Stream<List<Word>>` | words/domain |
| `SyncPendingWords` | — | `Either<Failure, int>` (synced count) | words/domain |
| `AdoptGuestWords` | authenticated UID | `Either<Failure, int>` (adopted count) | words/domain |

---

## Test Plan

### Unit Tests

| Target | Key Scenarios | Tool |
|--------|---------------|------|
| `WordModel.fromMap / toMap` | SQLite ints↔bools, PostgREST formats, null `userId`, UTC timestamps | `flutter_test` |
| `ScriptProcessor` | Punctuation stripping, repeated words, mixed case, large input (10k+ words), known-word filtering, contraction handling | `flutter_test` |
| `AuthCubit` | Sign-in success/failure, sign-up, sign-out, guest→auth transition | `bloc_test` + `mocktail` |
| `WorkspaceCubit` | Processing loading→success→error, save flow, empty input | `bloc_test` + `mocktail` |
| `SyncCubit` | Idle→syncing→idle, error with retry, pending count updates | `bloc_test` + `mocktail` |
| Repositories | Guest-only local writes, auth write-through + queueing, adoption, newest-wins conflict, retry failures, sign-out clearing | `flutter_test` + `mocktail` |

### Widget Tests

| Test | Validates |
|------|-----------|
| Updated smoke test | App boots to workspace, empty state visible |
| Analyze action | Script input → tap Analyze → word results appear |
| Known-word toggle | Tap toggle on WordCard → state updates |

### Commands

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Static analysis
flutter analyze --fatal-infos

# Code generation (after model/state changes)
dart run build_runner build --delete-conflicting-outputs
```

---

## Implementation Phases

### Phase 1 — Scaffold & Core (no features yet)

- Create directory structure
- Add all dependencies to `pubspec.yaml`
- Implement `core/error/`, `core/config/`, `core/database/`, `core/theme/`
- Set up `get_it` + `injectable` in `app/di.dart`
- Wire `main.dart` → `app.dart` with theme
- Update smoke test to pass with new app shell

### Phase 2 — Words Feature (Offline-Only)

- Implement `Word` entity, `WordModel`, SQLite local source
- Implement `WordRepository` (local-only), use cases
- Implement `ScriptProcessor` with Isolate
- Build `WorkspaceCubit` + states
- Build workspace UI: input field, analyze button, word list, empty state
- Write unit + widget tests

### Phase 3 — Auth Feature

- Implement auth data/domain/presentation layers
- Wire `supabase_flutter` auth
- Build `AuthCubit` + auth UI (form, status bar)
- Implement `AdoptGuestWords` + sign-out clearing
- Write auth cubit + repository tests

### Phase 4 — Sync Layer

- Implement `word_sync_queue` schema
- Build Dio client + interceptor pipeline
- Implement `SyncService` + `ConnectivityMonitor`
- Build `SyncCubit` + `SyncStatusBadge`
- Implement retry logic + conflict resolution
- Write sync integration tests

---

## Assumptions

- Email/password auth is in scope for v1; stays lightweight, embedded in the single-workspace experience.
- `last_updated` is always UTC, written by the client on every mutation; sole conflict-resolution field.
- `go_router` is **not** introduced in v1 — single route. Navigation added if app grows past single workspace.
- The mirror guarantee means identical column names and stable model serialization; engine quirks normalized in one place.
- Dark mode is deferred to v2.
- Supabase RLS (Row Level Security) is expected on the remote `words` table filtering by `auth.uid()`.
