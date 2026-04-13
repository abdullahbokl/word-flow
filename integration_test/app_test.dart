import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wordflow/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('tap on the floating action button, verify counter',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify that we are on the home page
      expect(find.text('Analyze'), findsOneWidget);

      // Example of control: Tap something
      // await tester.tap(find.byIcon(Icons.add));
      // await tester.pumpAndSettle();
    });
  });
}
