# Word-Flow Architecture Migration Guide

This project has been restructured from a monolithic/fragmented layout to a strict **Clean Architecture** pattern.

## New Folder Structure

```
lib/
├── core/
│   ├── di/              # Dependency Injection (GetIt + Injectable)
│   ├── constants/       # Global constants
│   ├── errors/          # Base Failure and Exception classes
│   ├── usecases/        # BaseUseCase and NoParams
│   ├── repositories/    # BaseRepository
│   ├── datasources/     # BaseDataSource
│   ├── network/         # API Client and networking (coming in Phase 2)
│   └── utils/           # Shared utilities
├── features/
│   ├── authentication/  # Login, Register, Profile-auth
│   ├── word_learning/   # Text analysis, Workspace, ProcessScript
│   ├── vocabulary/      # Library, Word management, Syncing
│   └── profile/         # User profile settings
└── main.dart            # Entry point
```

## Key Changes

1. **Dependency Injection**: Moved from `lib/app/di.dart` to `lib/core/di/injection.dart`. Always run `build_runner` after adding new `@injectable` classes.
2. **Base Classes**: Use `BaseUseCase<Type, Params>` for all new use cases to ensure consistency.
3. **States & Events**: All features should use `flutter_bloc` (Cubit or Bloc) with `freezed` for immutable states.
4. **Error Handling**: Use `Either<Failure, T>` from `fpdart` to handle functional errors.

## How to Migrate a Feature

1. Move layers (`data`, `domain`, `presentation`) into the target feature folder.
2. Update imports (use global search-and-replace for `features/words/` -> `features/vocabulary/`, etc.).
3. Wrap use cases in `BaseUseCase`.
4. Register repositories and usecases with `@lazySingleton`.
5. Run `dart run build_runner build --delete-conflicting-outputs`.
