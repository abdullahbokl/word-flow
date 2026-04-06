import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexitrack/core/common/state/bloc_status.dart';
import 'package:lexitrack/core/widgets/app_loader.dart';
import 'package:lexitrack/core/widgets/app_error_widget.dart';
import 'package:lexitrack/core/widgets/status_view.dart';

void main() {
  group('StatusView', () {
    testWidgets('shows loading widget by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusView<String>(
              status: BlocStatus<String>.loading(),
            ),
          ),
        ),
      );

      expect(find.byType(AppLoader), findsOneWidget);
    });

    testWidgets('shows success callback when status is success',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusView<String>(
              status: const BlocStatus<String>.success(data: 'Hello'),
              onSuccess: (data) => Text(data),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('shows error widget by default when status is failure',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusView<String>(
              status: BlocStatus<String>.failure(error: 'Oops'),
            ),
          ),
        ),
      );

      expect(find.byType(AppErrorWidget), findsOneWidget);
    });

    testWidgets('shows custom empty callback', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusView<String>(
              status: BlocStatus<String>.empty(),
              onEmpty: Text('No data'),
            ),
          ),
        ),
      );

      expect(find.text('No data'), findsOneWidget);
    });

    testWidgets('shows initial callback when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusView<String>(
              status: BlocStatus<String>.initial(),
              onInitial: Text('Initializing...'),
            ),
          ),
        ),
      );

      expect(find.text('Initializing...'), findsOneWidget);
    });
  });
}
