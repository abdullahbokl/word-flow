import 'dart:isolate';
import 'package:equatable/equatable.dart';
import 'script_analysis.dart';

class ProcessedWord extends Equatable {
  final String wordText;
  final int totalCount;

  const ProcessedWord({
    required this.wordText,
    required this.totalCount,
  });

  @override
  List<Object?> get props => [wordText, totalCount];
}

class ScriptProcessor {
  static Future<ScriptAnalysis> process({
    required String rawText,
    required Set<String> knownWords,
  }) async {
    return await Isolate.run(() {
      if (rawText.isEmpty) {
        return const ScriptAnalysis(
          summary: ScriptSummary.empty(),
          words: <ProcessedWord>[],
        );
      }

      // 1. Normalize and tokenize
      final wordRegExp = RegExp(r"[a-zA-Z']+");
      final matches = wordRegExp.allMatches(rawText);

      final wordCounts = <String, int>{};

      for (final match in matches) {
        final original = match.group(0)!;
        final normalized = original.toLowerCase();

        // 2. Count frequencies
        wordCounts[normalized] = (wordCounts[normalized] ?? 0) + 1;
      }

      // 3. Filter known words and convert to ProcessedWord
      final processed = <ProcessedWord>[];
      for (final entry in wordCounts.entries) {
        final word = entry.key;
        if (!knownWords.contains(word)) {
          processed.add(ProcessedWord(
            wordText: word,
            totalCount: entry.value,
          ));
        }
      }

      // 4. Sort by frequency descending
      processed.sort((a, b) => b.totalCount.compareTo(a.totalCount));

      return ScriptAnalysis(
        summary: ScriptSummary(
          totalWords: matches.length,
          uniqueWords: wordCounts.length,
          newWords: processed.length,
        ),
        words: processed,
      );
    });
  }
}
