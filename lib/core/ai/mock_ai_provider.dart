import 'dart:async';
import 'package:wordflow/core/ai/ai_result.dart';
import 'package:wordflow/core/ai/ai_service.dart';

class MockAiProvider implements AiService {
  const MockAiProvider();

  static const _delay = Duration(seconds: 2);

  @override
  Stream<AiResult<String>> getWordMeaning(String word) async* {
    yield const AiLoading();
    await Future.delayed(_delay);

    final meaning = _mockMeanings[word.toLowerCase()] ??
        'A placeholder meaning for "$word". In a real app, this would come from an AI service.';

    yield AiLoaded(meaning);
  }

  @override
  Stream<AiResult<List<String>>> getWordExamples(String word) async* {
    yield const AiLoading();
    await Future.delayed(_delay);

    final examples = _mockExamples[word.toLowerCase()] ??
        [
          'This is a mock example sentence for "$word".',
          'Another example showing how "$word" might be used in context.',
        ];

    yield AiLoaded(examples);
  }

  @override
  Stream<AiResult<String>> getWordTranslation(
      String word, String targetLang) async* {
    yield const AiLoading();
    await Future.delayed(_delay);

    final translation =
        _mockTranslations['${word.toLowerCase()}_$targetLang'] ??
            'Translation of "$word" to $targetLang (Mock)';

    yield AiLoaded(translation);
  }

  static const _mockMeanings = {
    'flutter':
        'A UI framework by Google for building beautiful, natively compiled applications from a single codebase.',
    'dart':
        'A client-optimized programming language for fast apps on any platform.',
    'lexicon': 'The vocabulary of a person, language, or branch of knowledge.',
  };

  static const _mockExamples = {
    'flutter': [
      'I am learning Flutter to build cross-platform apps.',
      'The Flutter community is very active and helpful.',
    ],
    'dart': [
      'Dart is the language used to write Flutter apps.',
      'I like the strong typing in Dart.',
    ],
  };

  static const _mockTranslations = {
    'flutter_es': 'aleteo',
    'dart_es': 'dardo',
    'lexicon_es': 'léxico',
  };
}
