import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:gestion_hotel/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('basic smoke test - app starts', (WidgetTester tester) async {
    // Launch app (main() returns void, not awaitable)
    app.main();

    // Let the app settle
    await tester.pumpAndSettle();

    // Verify app root widget is present.
    expect(find.byType(app.MyApp), findsOneWidget);
  }, timeout: const Timeout(Duration(minutes: 3)));
}
