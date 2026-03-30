# Database Migration Guide

This document defines how schema changes are added in WordFlow and where index definitions must live.

## How To Add A New Migration Step

1. Increase `expectedVersion` in `schemaVersion` inside [app_database.dart](app_database.dart).
2. Add a new migration function following the existing pattern:
   - Example: `_migrate9To10(WordFlowDatabase db)`.
3. Register the new step in `_migrationSteps` with the target version key:
   - `10: _migrate9To10,`
4. Put all required table/column/data migration SQL in that migration function.
5. Run `flutter analyze` and `flutter test`.

## Index Rule (Single Source Of Truth)

All index creation SQL must be declared in exactly one place:

- `WordFlowDatabase._createAllIndices(DatabaseConnectionUser db)`

Do not add ad-hoc `CREATE INDEX` statements anywhere else. Instead:

1. Add the new index SQL to `_createAllIndices` using `IF NOT EXISTS`.
2. Let `onCreate` and migrations call `_createAllIndices`.

This keeps index definitions centralized and prevents drift between fresh installs and upgraded installs.

## schemaVersion Assertion Guard

`schemaVersion` contains a debug assertion that compares:

- the declared `expectedVersion`, and
- the highest key in `_migrationSteps`.

If they do not match, the app throws an `AssertionError` in debug mode. This guard catches the common developer mistake of bumping schema version without adding the corresponding migration step.
