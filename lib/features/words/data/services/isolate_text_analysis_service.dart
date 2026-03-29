import 'dart:isolate';

import 'package:injectable/injectable.dart';
import 'package:word_flow/features/words/domain/entities/processed_word.dart';
import 'package:word_flow/features/words/domain/entities/script_analysis.dart';
import 'package:word_flow/features/words/domain/services/text_analysis_service.dart';

const _stopWords = <String>{
  'the',
  'an',
  'and',
  'or',
  'but',
  'in',
  'on',
  'at',
  'to',
  'for',
  'of',
  'with',
  'by',
  'is',
  'am',
  'are',
  'was',
  'were',
  'be',
  'been',
  'being',
  'have',
  'has',
  'had',
  'do',
  'does',
  'did',
  'will',
  'would',
  'could',
  'should',
  'may',
  'might',
  'shall',
  'can',
  'need',
  'dare',
  'it',
  'its',
  'he',
  'she',
  'we',
  'they',
  'me',
  'him',
  'her',
  'us',
  'them',
  'my',
  'your',
  'his',
  'our',
  'their',
  'this',
  'that',
  'these',
  'those',
  'not',
  'no',
  'nor',
  'so',
  'if',
  'then',
  'than',
  'too',
  'very',
  'just',
  'about',
  'also',
  'as',
  'from',
  'up',
  'out',
  'into',
  'over',
  'after',
  'before',
  'between',
  'under',
  'again',
  'more',
  'most',
  'other',
  'some',
  'such',
  'only',
  'own',
  'same',
  'each',
  'every',
  'both',
  'few',
  'all',
  'any',
  'many',
  'much',
  'how',
  'when',
  'where',
  'why',
  'what',
  'which',
  'who',
  'whom',
};

@LazySingleton(as: TextAnalysisService)
class IsolateTextAnalysisService implements TextAnalysisService {
  @override
  Future<ScriptAnalysis> process({
    required String rawText,
    required Set<String> knownWords,
  }) async {
    return Isolate.run(() {
      if (rawText.isEmpty) {
        return const ScriptAnalysis(
          summary: ScriptSummary.empty(),
          words: <ProcessedWord>[],
        );
      }

      final wordRegExp = RegExp(r"\b[a-zA-Z]{2,}(?:'[a-zA-Z]+)?\b");
      final matches = wordRegExp.allMatches(rawText);

      final wordCounts = <String, int>{};
      for (final match in matches) {
        final normalizedWord = match.group(0)!.toLowerCase();
        if (_stopWords.contains(normalizedWord)) {
          continue;
        }
        wordCounts[normalizedWord] = (wordCounts[normalizedWord] ?? 0) + 1;
      }

      final processed = <ProcessedWord>[];
      int newWordCount = 0;

      for (final entry in wordCounts.entries) {
        final wordText = entry.key;
        final isKnown = knownWords.contains(wordText);
        if (!isKnown) {
          newWordCount++;
        }

        processed.add(
          ProcessedWord(
            wordText: wordText,
            totalCount: entry.value,
            isKnown: isKnown,
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
