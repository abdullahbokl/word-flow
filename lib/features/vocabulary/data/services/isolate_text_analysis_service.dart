import 'dart:isolate';

import 'package:injectable/injectable.dart';
import 'package:word_flow/features/word_learning/domain/entities/processed_word.dart';
import 'package:word_flow/features/word_learning/domain/entities/script_analysis.dart';
import 'package:word_flow/features/vocabulary/domain/services/text_analysis_service.dart';
import 'package:word_flow/features/vocabulary/domain/entities/text_analysis_config.dart';
import 'package:word_flow/core/utils/porter_stemmer.dart';

@LazySingleton(as: TextAnalysisService)
class IsolateTextAnalysisService implements TextAnalysisService {
  @override
  Future<ScriptAnalysis> process({
    required String rawText,
    required Set<String> knownWords,
    required TextAnalysisConfig config,
  }) async {
    // We pass individual properties that are Sendable to the isolate.
    // TextAnalysisConfig is a plain class, so it can be passed if all its
    // fields are sendable (Set, String, int, bool are all sendable).
    return Isolate.run(() {
      if (rawText.isEmpty) {
        return const ScriptAnalysis(
          summary: ScriptSummary.empty(),
          words: <ProcessedWord>[],
        );
      }

      // Build regex based on config
      final minLen = config.minWordLength;
      final contractions = config.includeContractionsAsOne ? '(?:\'[a-zA-Z]+)?' : '';
      final wordRegExp = RegExp('\\b[a-zA-Z]{$minLen,}$contractions\\b');
      
      final matches = wordRegExp.allMatches(rawText);

      final wordCounts = <String, int>{};
      final stemToVariants = <String, Set<String>>{};
      final stopWords = config.stopWords;
      final stemmer = config.useStemming ? PorterStemmer() : null;

      for (final match in matches) {
        final originalWord = match.group(0)!.toLowerCase();
        if (stopWords.contains(originalWord)) {
          continue;
        }

        final targetKey = stemmer?.stem(originalWord) ?? originalWord;
        
        wordCounts[targetKey] = (wordCounts[targetKey] ?? 0) + 1;
        if (config.useStemming) {
          stemToVariants.putIfAbsent(targetKey, () => <String>{}).add(originalWord);
        }
      }

      final processed = <ProcessedWord>[];
      int newWordCount = 0;

      for (final entry in wordCounts.entries) {
        final wordText = entry.key;
        final isKnown = knownWords.contains(wordText);
        if (!isKnown) {
          newWordCount++;
        }

        final variants = stemToVariants[wordText]?.toList() ?? const <String>[];

        processed.add(
          ProcessedWord(
            wordText: wordText,
            totalCount: entry.value,
            isKnown: isKnown,
            variants: variants,
          ),
        );
      }

      processed.sort((a, b) {
        if (a.isKnown != b.isKnown) {
          return a.isKnown ? 1 : -1;
        }
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
