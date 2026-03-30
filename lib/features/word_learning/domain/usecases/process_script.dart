import 'package:fpdart/fpdart.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/word_learning/domain/entities/script_analysis.dart';
import 'package:word_flow/features/word_learning/domain/entities/processed_word.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/word_repository.dart';
import 'package:word_flow/features/vocabulary/domain/services/text_analysis_service.dart';
import 'package:word_flow/features/vocabulary/domain/entities/text_analysis_config.dart';
import 'package:word_flow/core/utils/porter_stemmer.dart';
import 'package:word_flow/core/utils/input_sanitizer.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ProcessScript {

  ProcessScript(this._repository, this._textAnalysisService);
  final WordRepository _repository;
  final TextAnalysisService _textAnalysisService;

  Future<Either<Failure, ScriptAnalysis>> call(
    String rawText, {
    String? userId,
    required TextAnalysisConfig config,
  }) async {
    try {
      final sanitizedResult = InputSanitizer.sanitizeScript(rawText);
      if (sanitizedResult.isLeft()) {
        return Left(sanitizedResult.fold((l) => l, (_) => const ProcessingFailure('unknown')));
      }
      final sanitizedText = sanitizedResult.getOrElse((_) => '');

      final wordsResult = await _repository.getKnownWordTexts(userId: userId);
      final Set<String> rawKnownTexts = wordsResult.fold(
        (failure) => {},
        (texts) => texts.toSet(),
      );

      final Set<String> knownWordTexts;
      if (config.useStemming) {
        final stemmer = PorterStemmer();
        knownWordTexts = rawKnownTexts.map((e) => stemmer.stem(e)).toSet();
      } else {
        knownWordTexts = rawKnownTexts;
      }

      final processed = await _textAnalysisService.process(
        rawText: sanitizedText,
        knownWords: knownWordTexts,
        config: config,
      );
      // Domain rule: sorting by frequency descending, known words last.
      // We create a mutable copy to avoid errors on fixed-length or unmodifiable lists.
      final sortedWords = List<ProcessedWord>.from(processed.words)
        ..sort((a, b) {
          if (a.isKnown != b.isKnown) return a.isKnown ? 1 : -1;
          return b.totalCount.compareTo(a.totalCount);
        });

      return Right(ScriptAnalysis(
        summary: processed.summary,
        words: sortedWords,
      ));
    } catch (e) {
      return Left(ProcessingFailure(e.toString()));
    }
  }
}
