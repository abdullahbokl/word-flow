import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordflow/core/widgets/app_button.dart';

void main() {
  group('AppButton', () {
    testWidgets('renders label and is pressable', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Click Me',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
      await tester.tap(find.byType(AppButton));
      expect(pressed, true);
    });

    testWidgets('shows loading indicator when isLoading=true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Loading',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('disabled button has null onPressed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Disabled',
              onPressed: null,
            ),
          ),
        ),
      );

      final btn = tester.widget<AppButton>(find.byType(AppButton));
      expect(btn.onPressed, isNull);
    });
  });
}
