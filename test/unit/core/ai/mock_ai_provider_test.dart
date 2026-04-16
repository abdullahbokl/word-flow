import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordflow/core/ai/ai_result.dart';
import 'package:wordflow/core/ai/mock_ai_provider.dart';

void main() {
  late MockAiProvider provider;

  setUp(() {
    provider = const MockAiProvider();
  });

  group('MockAiProvider', () {
    test('getWordMeaning emits loading then loaded with mock data after delay',
        () {
      fakeAsync((async) {
        final stream = provider.getWordMeaning('flutter');
        final results = <AiResult<String>>[];
        final sub = stream.listen(results.add);

        async.flushMicrotasks();
        expect(results, [const AiLoading<String>()]);

        async.elapse(const Duration(seconds: 2));
        expect(results.length, 2);
        expect(results[1], isA<AiLoaded<String>>());
        expect((results[1] as AiLoaded<String>).data, contains('UI framework'));

        unawaited(sub.cancel());
      });
    });

    test('getWordExamples emits loading then loaded with mock data after delay',
        () {
      fakeAsync((async) {
        final stream = provider.getWordExamples('dart');
        final results = <AiResult<List<String>>>[];
        final sub = stream.listen(results.add);

        async.flushMicrotasks();
        expect(results, [const AiLoading<List<String>>()]);

        async.elapse(const Duration(seconds: 2));
        expect(results.length, 2);
        expect(results[1], isA<AiLoaded<List<String>>>());
        expect((results[1] as AiLoaded<List<String>>).data, isNotEmpty);

        unawaited(sub.cancel());
      });
    });

    test(
        'getWordTranslation emits loading then loaded with mock data after delay',
        () {
      fakeAsync((async) {
        final stream = provider.getWordTranslation('lexicon', 'es');
        final results = <AiResult<String>>[];
        final sub = stream.listen(results.add);

        async.flushMicrotasks();
        expect(results, [const AiLoading<String>()]);

        async.elapse(const Duration(seconds: 2));
        expect(results.length, 2);
        expect(results[1], isA<AiLoaded<String>>());
        expect((results[1] as AiLoaded<String>).data, 'léxico');

        unawaited(sub.cancel());
      });
    });
  });
}
