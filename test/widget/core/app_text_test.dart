import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordflow/core/widgets/app_text.dart';

void main() {
  testWidgets('AppText renders text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppText('Hello World')),
      ),
    );
    expect(find.text('Hello World'), findsOneWidget);
  });

  testWidgets('AppText.headline constructor renders with bold font weight',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppText.headline('Big Title')),
      ),
    );
    expect(find.text('Big Title'), findsOneWidget);
  });

  testWidgets('AppText.body is the default', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppText('Default body')),
      ),
    );
    expect(find.text('Default body'), findsOneWidget);
  });

  testWidgets('AppText.label renders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppText.label('Label text')),
      ),
    );
    expect(find.text('Label text'), findsOneWidget);
  });

  testWidgets('respects maxLines', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 100,
            child: AppText(
              'This is a very long text that should be truncated to 1 line',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
    final textWidget = tester.widget<Text>(find.byType(Text));
    expect(textWidget.maxLines, 1);
  });
}
