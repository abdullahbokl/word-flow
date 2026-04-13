import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wordflow/features/text_analyzer/data/datasources/analyzer_local_ds.dart';
import 'package:wordflow/features/text_analyzer/data/models/analysis_result_model.dart';
import 'package:wordflow/features/text_analyzer/data/repositories/analyzer_repository_impl.dart';

class MockAnalyzerLocalDataSource extends Mock
    implements AnalyzerLocalDataSource {}

void main() {
  late AnalyzerRepositoryImpl repository;
  late MockAnalyzerLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockAnalyzerLocalDataSource();
    repository = AnalyzerRepositoryImpl(mockDataSource);
  });

  const tResultModel = AnalysisResultModel(
    id: 1,
    title: 'Test',
    totalWords: 10,
    uniqueWords: 5,
    unknownWords: 2,
    knownWords: 3,
    newWordsCount: 2,
    words: [],
    excludedWordsFound: [],
  );

  test('should call data source and return AnalysisResult', () async {
    when(() => mockDataSource.analyze(
          title: any(named: 'title'),
          content: any(named: 'content'),
        )).thenAnswer((_) async => tResultModel);

    final result =
        await repository.analyze(title: 'Test', content: 'Content').run();

    expect(result.isRight(), true);
    result.fold((_) {}, (r) => expect(r.title, 'Test'));
    verify(() => mockDataSource.analyze(title: 'Test', content: 'Content'))
        .called(1);
  });
}
