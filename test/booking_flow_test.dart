import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:gestion_hotel/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Booking Flow Test', () {
    testWidgets('User can navigate to booking screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Look for hotel cards
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Find and tap on a "Réserver maintenant" button
      final bookingButtons = find.text('Réserver maintenant');
      if (bookingButtons.evaluate().isNotEmpty) {
        await tester.tap(bookingButtons.first);
        await tester.pumpAndSettle();
        
        // Should navigate to hotel detail screen
        expect(find.text('Chambres'), findsOneWidget);
        
        // Tap on the Chambres tab
        await tester.tap(find.text('Chambres'));
        await tester.pumpAndSettle();
        
        // Look for room booking buttons
        final roomBookButtons = find.text('Réserver maintenant');
        if (roomBookButtons.evaluate().isNotEmpty) {
          await tester.tap(roomBookButtons.first);
          await tester.pumpAndSettle();
          
          // Should be on BookRoomScreen
          expect(find.text('Réserver une chambre'), findsOneWidget);
          expect(find.text('Confirmer la réservation'), findsOneWidget);
        }
      }
    });

    testWidgets('Booking guide card is visible', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Wait for hotels to load
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Look for booking guide
      expect(find.text('Comment réserver ?'), findsOneWidget);
      expect(find.text('Touchez "Réserver maintenant" sur une carte d\'hôtel'), findsOneWidget);
    });
  });
}