import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../lib/core/error/failures.dart';

import '../../lib/features/lexicon/domain/entities/word_entity.dart';
import '../../lib/features/lexicon/domain/entities/word_filter.dart';
import '../../lib/features/lexicon/domain/entities/word_sort.dart';
import '../../lib/features/lexicon/domain/repositories/lexicon_repository.dart';
import '../../lib/features/lexicon/domain/usecases/add_word_manually.dart';
import '../../lib/features/lexicon/domain/usecases/delete_word.dart';
import '../../lib/features/lexicon/domain/usecases/toggle_word_status.dart';
import '../../lib/features/lexicon/domain/usecases/update_word.dart';
import '../../lib/features/lexicon/domain/usecases/watch_lexicon_stats.dart';
import '../../lib/features/lexicon/domain/usecases/watch_words.dart';
import '../../lib/features/lexicon/presentation/bloc/lexicon_bloc.dart';
import '../../lib/features/lexicon/presentation/bloc/lexicon_event.dart';
import '../../lib/features/lexicon/presentation/bloc/lexicon_state.dart';

class MockLexiconRepository extends Mock implements LexiconRepository {}

WordEntity _makeWord({int id = 1, String text = 'hello'}) {
  return WordEntity(
    id: id,
    text: text,
    frequency: 1,
    isKnown: false,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
    meaning: null,
    description: null,
  );
}

void main() {
  late MockLexiconRepository repository;
  late LexiconBloc bloc;

  setUp(() {
    repository = MockLexiconRepository();

    when(() => repository.watchWords(
          filter: any(named: 'filter'),
          sort: any(named: 'sort'),
          query: any(named: 'query'),
        )).thenAnswer((_) => Stream.value(Right([_makeWord()])));

    when(() => repository.watchStats())
        .thenAnswer((_) => Stream.value(Right(_stats())));

    when(() => repository.addWord(any())).thenAnswer(
      (_) => TaskEither.right(_makeWord()),
    );
    when(() => repository.toggleStatus(any())).thenAnswer(
      (_) => TaskEither.right(_makeWord()),
    );
    when(() => repository.deleteWord(any())).thenAnswer(
      (_) => TaskEither.right(unit),
    );

    bloc = LexiconBloc(
      watchWords: WatchWords(repository),
      toggleWordStatus: ToggleWordStatus(repository),
      deleteWord: DeleteWord(repository),
      addWordManually: AddWordManually(repository),
      updateWord: UpdateWord(repository),
      watchStats: WatchLexiconStats(repository),
    );
  });

  tearDown(() async => bloc.close());

  group('LexiconBloc', () {
    test('starts with initial state', () {
      expect(bloc.state.status.isInitial, true);
      expect(bloc.state.filter, WordFilter.all);
      expect(bloc.state.sort, WordSort.frequencyDesc);
      expect(bloc.state.query, isEmpty);
    });

    blocTest<LexiconBloc, LexiconState>(
      'emits success when stream provides data',
      build: () => bloc,
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<LexiconState>().having((s) => s.status.isSuccess, 'isSuccess', true),
      ],
    );

    blocTest<LexiconBloc, LexiconState>(
      'emits failure when stream provides error',
      setUp: () {
        when(() => repository.watchWords(
              filter: any(named: 'filter'),
              sort: any(named: 'sort'),
              query: any(named: 'query'),
            )).thenAnswer(
              (_) => Stream.value(Left(DatabaseFailure('error'))),
            );
      },
      build: () => LexiconBloc(
        watchWords: WatchWords(repository),
        toggleWordStatus: ToggleWordStatus(repository),
        deleteWord: DeleteWord(repository),
        addWordManually: AddWordManually(repository),
        updateWord: UpdateWord(repository),
        watchStats: WatchLexiconStats(repository),
      ),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<LexiconState>().having((s) => s.status.isFailed, 'isFailed', true),
      ],
    );
  });
}
