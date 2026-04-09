# Implementation Plan - Lexicon Enhancements

This plan outlines the steps to add definitions, examples, translations, and synonyms to the lexicon words, both in the database and the UI.

## Supervisor Selection
**Skills Activated:**
- `drift-database-management`: For handling table updates and migrations.
- `clean-architecture-modeling`: For updating entities and mappers.
- `flutter-ui-premium`: For enhancing the word card and edit dialog with modern aesthetics.

## Proposed Changes

### 1. Database Layer
- **File**: `lib/core/database/tables.dart`
  - Add `definitions`, `examples`, `translations`, and `synonyms` columns to the `Words` table.
- **File**: `lib/core/database/app_database.dart`
  - Incremet `schemaVersion` to `5`.
  - Add migration logic in `onUpgrade` to add these four columns.
- **Action**: Run `dart run build_runner build --delete-conflicting-outputs`.

### 2. Domain Layer
- **File**: `lib/core/domain/entities/word_entity.dart`
  - Add the new fields to the `WordEntity` class.
  - Update `copyWith` and `props`.

### 3. Data Layer
- **File**: `lib/core/data/mappers/word_row_mapper.dart`
  - Update `toEntity` to map the new columns.
- **File**: `lib/features/lexicon/data/datasources/lexicon_local_ds.dart` (and its implementation)
  - Update `updateWord` method signature to accept the new fields.
- **File**: `lib/features/lexicon/domain/repositories/lexicon_repository.dart`
  - Update `updateWord` method signature.
- **File**: `lib/features/lexicon/data/repositories/lexicon_repository_impl.dart`
  - Update `updateWord` implementation.

### 4. UI Layer
- **File**: `lib/features/lexicon/presentation/widgets/edit_word_dialog.dart`
  - Expand the dialog to include multiple `AppTextField`s for:
    - Definitions
    - Examples
    - Translations
    - Synonyms
  - Use a scrollable layout if necessary.
- **File**: `lib/features/lexicon/presentation/widgets/word_tile.dart`
  - Update the card design to show these values attractively.
  - Use subtle icons, chips, or styled text to differentiate the information.
  - Ensure it remains clean and "premium".

## Verification Plan
1.  Verify database migration runs without errors.
2.  Open Edit Dialog for a word and fill in all fields.
3.  Save and verify the data persists (reopen dialog or check list).
4.  Verify the `WordTile` displays the information correctly and beautifully.
5.  Test with empty optional fields.
