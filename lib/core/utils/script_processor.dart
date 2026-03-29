import 'dart:isolate';
import 'package:equatable/equatable.dart';
import 'package:word_flow/core/utils/script_analysis.dart';

class ProcessedWord extends Equatable {

  const ProcessedWord({
    required this.wordText,
    required this.totalCount,
    this.isKnown = false,
  });
  final String wordText;
  final int totalCount;
  final bool isKnown;

  @override
  List<Object?> get props => [wordText, totalCount, isKnown];
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

     
      final wordRegExp = RegExp(r"[a-zA-Z']+");
      final matches = wordRegExp.allMatches(rawText);

      final wordCounts = <String, int>{};

      for (final match in matches) {
        final original = match.group(0)!;
        final normalized = original.toLowerCase();

       
        wordCounts[normalized] = (wordCounts[normalized] ?? 0) + 1;
      }

     
      final processed = <ProcessedWord>[];
      int newWordCount = 0;
      
      for (final entry in wordCounts.entries) {
        final wordText = entry.key;
        final isKnown = knownWords.contains(wordText);
        
        if (!isKnown) newWordCount++;

        processed.add(ProcessedWord(
          wordText: wordText,
          totalCount: entry.value,
          isKnown: isKnown,
        ));
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
