import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:wordflow/core/domain/entities/word_entity.dart';
import 'package:wordflow/core/export/export_result.dart';
import 'package:wordflow/features/text_analyzer/domain/entities/analysis_result.dart';

class PdfExportService {
  const PdfExportService();

  Future<ExportResult> exportWords(
    List<WordEntity> words,
    String filePath,
  ) async {
    try {
      final pdf = pw.Document()
        ..addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            build: (context) => [
              pw.Header(
                level: 0,
                child: pw.Text('Word List Export',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headers: const [
                  'Word',
                  'Meaning',
                  'Freq',
                  'Status',
                  'Category'
                ],
                data: words.map((word) {
                  return [
                    word.text,
                    word.meaning ?? '',
                    word.frequency.toString(),
                    word.isKnown ? 'Known' : 'Unknown',
                    word.category?.name ?? '',
                  ];
                }).toList(),
                border: pw.TableBorder.all(),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey300),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ],
            footer: (context) => pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 10),
              child: pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: const pw.TextStyle(color: PdfColors.grey),
              ),
            ),
          ),
        );

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return ExportSuccess(filePath);
    } catch (e) {
      return ExportFailure('Failed to export words to PDF: $e');
    }
  }

  Future<ExportResult> exportAnalysis(
    AnalysisResult analysis,
    String filePath,
  ) async {
    try {
      final pdf = pw.Document()
        ..addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            build: (context) => [
              pw.Header(
                level: 0,
                child: pw.Text('Analysis Report: ${analysis.title}',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Summary Statistics',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                data: [
                  ['Total Words', analysis.totalWords.toString()],
                  ['Unique Words', analysis.uniqueWords.toString()],
                  ['Known Words', analysis.knownWords.toString()],
                  ['Unknown Words', analysis.unknownWords.toString()],
                  ['New Words', analysis.newWordsCount.toString()],
                  [
                    'Comprehension',
                    '${analysis.comprehension.toStringAsFixed(1)}%'
                  ],
                ],
                border: pw.TableBorder.all(),
                cellAlignment: pw.Alignment.centerLeft,
              ),
              pw.SizedBox(height: 30),
              pw.Text('Word Details',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headers: const ['Word', 'Local Freq', 'Global Freq', 'Status'],
                data: analysis.words.map((wordFreq) {
                  return [
                    wordFreq.word.text,
                    wordFreq.localFrequency.toString(),
                    wordFreq.word.frequency.toString(),
                    wordFreq.word.isKnown ? 'Known' : 'Unknown',
                  ];
                }).toList(),
                border: pw.TableBorder.all(),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey300),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ],
            footer: (context) => pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 10),
              child: pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: const pw.TextStyle(color: PdfColors.grey),
              ),
            ),
          ),
        );

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return ExportSuccess(filePath);
    } catch (e) {
      return ExportFailure('Failed to export analysis to PDF: $e');
    }
  }
}
