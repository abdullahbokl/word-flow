import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wordflow/core/common/models/word_with_local_freq.dart';
import 'package:wordflow/core/domain/entities/word_entity.dart';
import 'package:wordflow/core/export/export_result.dart';
import 'package:wordflow/core/export/pdf_export_service.dart';
import 'package:wordflow/features/text_analyzer/domain/entities/analysis_result.dart';

void main() {
  late PdfExportService pdfExportService;
  const testWordsPath = '/tmp/test_words.pdf';
  const testAnalysisPath = '/tmp/test_analysis.pdf';

  setUp(() {
    pdfExportService = const PdfExportService();
  });

  tearDown(() {
    final wordsFile = File(testWordsPath);
    if (wordsFile.existsSync()) {
      wordsFile.deleteSync();
    }
    final analysisFile = File(testAnalysisPath);
    if (analysisFile.existsSync()) {
      analysisFile.deleteSync();
    }
  });

  group('PdfExportService', () {
    test('exportWords generates a non-empty PDF file', () async {
      final words = [
        WordEntity(
          id: 1,
          text: 'test',
          frequency: 10,
          isKnown: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isExcluded: false,
          meaning: 'a procedure intended to establish the quality',
        ),
        WordEntity(
          id: 2,
          text: 'flow',
          frequency: 5,
          isKnown: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isExcluded: false,
          meaning:
              'the action or fact of moving along in a steady, continuous stream',
        ),
      ];

      final result = await pdfExportService.exportWords(words, testWordsPath);

      expect(result, isA<ExportSuccess>());
      final file = File(testWordsPath);
      expect(file.existsSync(), isTrue);
      expect(file.lengthSync(), greaterThan(0));
    });

    test('exportAnalysis generates a non-empty PDF file', () async {
      final analysis = AnalysisResult(
        id: 1,
        title: 'Test Analysis',
        totalWords: 100,
        uniqueWords: 50,
        knownWords: 30,
        unknownWords: 20,
        newWordsCount: 5,
        words: [
          WordWithLocalFreq(
            word: WordEntity(
              id: 1,
              text: 'test',
              frequency: 10,
              isKnown: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              isExcluded: false,
            ),
            localFrequency: 3,
          ),
        ],
      );

      final result =
          await pdfExportService.exportAnalysis(analysis, testAnalysisPath);

      expect(result, isA<ExportSuccess>());
      final file = File(testAnalysisPath);
      expect(file.existsSync(), isTrue);
      expect(file.lengthSync(), greaterThan(0));
    });

    test('returns ExportFailure when path is invalid', () async {
      final words = <WordEntity>[];
      final result = await pdfExportService.exportWords(
          words, '/nonexistent/path/test.pdf');

      expect(result, isA<ExportFailure>());
      expect((result as ExportFailure).message,
          contains('Failed to export words to PDF'));
    });
  });
}
