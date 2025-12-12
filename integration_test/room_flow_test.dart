import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:gestion_hotel/main.dart' as app;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestion_hotel/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Room flow (UI) tests', () {
    setUpAll(() async {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      // configure emulators if available
      try {
        FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      } catch (_) {}
      try {
        FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      } catch (_) {}

      // create a test hotel document used by tests
      final db = FirebaseFirestore.instance;
      await db.collection('hotels').add({
        'name': 'E2E Hotel',
        'city': 'TestCity',
        'address': 'Test Address',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    testWidgets('add -> edit -> delete room (admin)', (WidgetTester tester) async {
      // create admin test user in auth emulator
      final auth = FirebaseAuth.instance;
      final email = 'e2e-admin@example.com';
      final pass = 'password123';
      try {
        await auth.createUserWithEmailAndPassword(email: email, password: pass);
      } catch (_) {
        // user may already exist
      }
      await auth.signInWithEmailAndPassword(email: email, password: pass);

      // create users doc with role admin
      final db = FirebaseFirestore.instance;
      final uid = auth.currentUser!.uid;
      await db.collection('users').doc(uid).set({'uid': uid, 'email': email, 'role': 'admin'});

      // start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Hotels list and select the test hotel - look for text 'E2E Hotel'
      final hotelFinder = find.text('E2E Hotel');
      expect(hotelFinder, findsWidgets);
      await tester.tap(hotelFinder.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap add room button
      final addButton = find.byKey(const Key('addRoomButton'));
      expect(addButton, findsOneWidget);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(find.byKey(const Key('roomNumberField')), '777');
      await tester.enterText(find.byKey(const Key('roomTypeField')), 'Suite');
      await tester.enterText(find.byKey(const Key('roomCapacityField')), '3');
      await tester.enterText(find.byKey(const Key('roomPriceField')), '150');
      await tester.tap(find.byKey(const Key('submitAddRoomButton')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify new room appears by number in list
      expect(find.textContaining('777'), findsWidgets);

      // Open edit (tap the room card by visible text)
      await tester.tap(find.textContaining('Chambre 777').first);
      await tester.pumpAndSettle();

      // Update price
      await tester.enterText(find.byKey(const Key('editRoomPriceField')), '200');
      await tester.tap(find.byKey(const Key('saveRoomButton')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify price updated in UI
      expect(find.textContaining('200'), findsWidgets);

      // Delete the room
      await tester.tap(find.byKey(const Key('deleteRoomButton')));
      await tester.pumpAndSettle();
      // confirm delete dialog
      await tester.tap(find.text('Supprimer'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Room should not be found anymore
      expect(find.textContaining('777'), findsNothing);
    }, timeout: Timeout(const Duration(minutes: 3)));
  });
}
