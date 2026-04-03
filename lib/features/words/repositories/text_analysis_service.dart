import 'dart:isolate';
import 'package:injectable/injectable.dart';
import 'package:word_flow/features/words/models/analysis.dart';
import 'package:word_flow/core/utils/porter_stemmer.dart';

@lazySingleton
class TextAnalysisService {
  Future<ScriptAnalysis> analyze({
    required String rawText,
    required Set<String> knownWords,
    required TextAnalysisConfig config,
  }) async {
    return Isolate.run(() {
      if (rawText.isEmpty) {
        return const ScriptAnalysis(
          summary: ScriptSummary.empty(),
          words: <AnalyzedWord>[],
        );
      }

      final minLen = config.minWordLength;
      final contractions = config.includeContractionsAsOne
          ? '(?:\'[a-zA-Z]+)?'
          : '';
      final wordRegExp = RegExp('\\b[a-zA-Z]{$minLen,}$contractions\\b');

      final matches = wordRegExp.allMatches(rawText);
      final wordCounts = <String, int>{};
      final stopWords = config.stopWords;
      final stemmer = config.useStemming ? PorterStemmer() : null;

      for (final match in matches) {
        final originalWord = match.group(0)!.toLowerCase();
        if (stopWords.contains(originalWord)) continue;

        final targetKey = stemmer?.stem(originalWord) ?? originalWord;
        wordCounts[targetKey] = (wordCounts[targetKey] ?? 0) + 1;
      }

      final processed = <AnalyzedWord>[];
      int newWordCount = 0;

      for (final entry in wordCounts.entries) {
        final wordText = entry.key;
        final isKnown = knownWords.contains(wordText);
        if (!isKnown) newWordCount++;

        processed.add(
          AnalyzedWord(
            wordText: wordText,
            totalCount: entry.value,
            isKnown: isKnown,
          ),
        );
      }

      processed.sort((a, b) {
        if (a.isKnown != b.isKnown) return a.isKnown ? 1 : -1;
        return b.totalCount.compareTo(a.totalCount);
      });

      return ScriptAnalysis(
        summary: ScriptSummary(
          totalWords: matches.length,
          uniqueWords: wordCounts.length,
          newWords: newWordCount,
        ),
        words: processed,
      );
    });
  }
}
