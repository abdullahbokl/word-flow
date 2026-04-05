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
}
