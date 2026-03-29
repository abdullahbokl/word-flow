import '../../domain/entities/word.dart';
import 'library_state.dart';

mixin LibraryOptimisticUpdates {
  LibraryState applyOptimisticReplace(LibraryState state, WordEntity word, Set<String> pendingIds) {
    return state.maybeMap(
      loaded: (s) {
        final updated = s.words
            .map((w) => w.id == word.id ? word : w)
            .toList(growable: false);
        return s.copyWith(words: updated, pendingWordIds: pendingIds);
      },
      orElse: () => state,
    );
  }

  LibraryState applyOptimisticUpsert(LibraryState state, WordEntity word, Set<String> pendingIds) {
    return state.maybeMap(
      loaded: (s) {
        final exists = s.words.any((w) => w.id == word.id);
        final next = exists
            ? s.words.map((w) => w.id == word.id ? word : w).toList(growable: false)
            : <WordEntity>[word, ...s.words];
        return s.copyWith(words: next, pendingWordIds: pendingIds);
      },
      orElse: () => state,
    );
  }

  LibraryState applyOptimisticRemove(LibraryState state, String id, Set<String> pendingIds) {
    return state.maybeMap(
      loaded: (s) {
        final next = s.words.where((w) => w.id != id).toList(growable: false);
        return s.copyWith(words: next, pendingWordIds: pendingIds);
      },
      orElse: () => state,
    );
  }
}
