import 'dart:isolate';

class TextProcessor {
  const TextProcessor._();

  static Future<Map<String, int>> process(String rawText) {
    return Isolate.run(() => _tokenizeAndCount(rawText));
  }

  static Map<String, int> _tokenizeAndCount(String rawText) {
    if (rawText.trim().isEmpty) return {};

    // Remove URLs first to prevent counting domain parts as words
    final withoutUrls = rawText.replaceAll(
      RegExp(r'https?://[^\s/$.?#].[^\s]*'),
      ' ',
    );

    final cleaned = withoutUrls
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z'\s]"), ' ');

    final tokens = cleaned
        .split(RegExp(r'\s+'))
        .map((t) => t.replaceAll(RegExp(r"^'+|'+$"), ''))
        .where((t) => t.isNotEmpty && t.contains(RegExp(r'[a-z]')));

    final freq = <String, int>{};
    for (final token in tokens) {
      freq[token] = (freq[token] ?? 0) + 1;
    }
    return freq;
  }

  static int totalTokenCount(Map<String, int> freq) {
    return freq.values.fold(0, (sum, v) => sum + v);
  }

  static Future<Map<String, Object?>> summarizeAnalysis({
    required int id,
    required String title,
    required int totalWords,
    required int uniqueWords,
    required int newWordsCount,
    required List<Map<String, Object?>> words,
    required List<String> excludedWordsFound,
  }) {
    return Isolate.run(
      () => _summarizeAnalysis(
        id: id,
        title: title,
        totalWords: totalWords,
        uniqueWords: uniqueWords,
        newWordsCount: newWordsCount,
        words: words,
        excludedWordsFound: excludedWordsFound,
      ),
    );
  }

  static Map<String, Object?> _summarizeAnalysis({
    required int id,
    required String title,
    required int totalWords,
    required int uniqueWords,
    required int newWordsCount,
    required List<Map<String, Object?>> words,
    required List<String> excludedWordsFound,
  }) {
    var knownUnique = 0;
    final sortedWords = List<Map<String, Object?>>.from(words);

    for (final word in sortedWords) {
      final isKnown = word['isKnown'] as bool;
      if (isKnown) {
        knownUnique++;
      }
    }

    sortedWords.sort(
      (left, right) => (right['localFrequency'] as int).compareTo(
        left['localFrequency'] as int,
      ),
    );

    return {
      'id': id,
      'title': title,
      'totalWords': totalWords,
      'uniqueWords': uniqueWords,
      'unknownWords': uniqueWords - knownUnique, // Changed to unique
      'knownWords': knownUnique, // Changed to unique
      'newWordsCount': newWordsCount,
      'words': sortedWords,
      'excludedWordsFound': excludedWordsFound,
    };
  }
}
