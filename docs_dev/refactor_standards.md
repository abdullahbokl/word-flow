# WordFlow Refactor Standards

These standards represent the "Clean Architecture + High Performance" baseline for WordFlow. All refactoring phases must adhere to these rules.

## 1. Code Cleanliness (Dart)
- **File Length**: Maximum **120 lines** per handwritten file.
- **Widget Limit**: Exactly **one public widget** class per file.
- **Naming**: Use descriptive domain-driven names. Avoid `Helper`, `Utils` if a more specific name fits.
- **Constants**: Extract magic strings and numbers to shared constants.

## 2. State Management (flutter_bloc)
- **Interaction**: Leaf widgets in feature layers (e.g., `WordResultsList`) should use `context.read<Cubit>().method()` instead of callback prop-drilling.
- **Efficiency**: Use `context.select` or `BlocSelector` to scope rebuilds to the smallest possible widget tree.
- **Side Effects**: Use `BlocListener` for navigation, showing dialogs, or snackbars.

## 3. Architecture (Clean Architecture)
- **Boundaries**: Presentation layer must never touch the Data layer directly.
- **Use Cases**: Every business action belongs in a UseCase.
- **Entities**: Business logic should only know about Domain Entities, not Data Models.

## 4. Navigation (go_router)
- **Centralization**: All navigation logic is defined in `AppRouter`.
- **API**: Prefer `context.go()` for state-changing navigation and `context.push()` for stack-based navigation.
- **No Imperative Nav**: Avoid `Navigator.of(context).push(...)` in widgets.

## 5. UI & Performance
- **Slivers**: Use `Sliver` architectures for all long lists to ensure 60 FPS scrolling.
- **Optimism**: Implement optimistic UI for state-changing actions (e.g., toggling words) where database latency might be perceived.
- **Const**: Use `const` constructors aggressively.
