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

  group('Reservation flow (UI) tests', () {
    setUpAll(() async {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      try {
        FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      } catch (_) {}
      try {
        FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      } catch (_) {}

      // create a test hotel and a room for booking
      final db = FirebaseFirestore.instance;
      await db.collection('hotels').add({
        'name': 'E2E Hotel Reservation',
        'city': 'TestCity',
        'address': 'Test Addr',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    testWidgets('book room and verify reservation document', (WidgetTester tester) async {
      final auth = FirebaseAuth.instance;
      final email = 'e2e-user@example.com';
      final pass = 'password123';
      try {
        await auth.createUserWithEmailAndPassword(email: email, password: pass);
      } catch (_) {}
      await auth.signInWithEmailAndPassword(email: email, password: pass);

      // ensure user doc exists with role user
      final db = FirebaseFirestore.instance;
      final uid = auth.currentUser!.uid;
      await db.collection('users').doc(uid).set({'uid': uid, 'email': email, 'role': 'user'});

      // start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to the hotel created earlier
      final hotelFinder = find.text('E2E Hotel Reservation');
      expect(hotelFinder, findsWidgets);
      await tester.tap(hotelFinder.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find the room card by text and tap Book
      final bookButton = find.byKey(const Key('bookButton_1010'));
      expect(bookButton, findsOneWidget);
      await tester.tap(bookButton);
      await tester.pumpAndSettle();

      // Pick date range - simple approach: pick default and confirm
      await tester.tap(find.text('Sélectionner les dates'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // In emulator, date picker may not appear; skip explicit date pick and just press Réserver
      await tester.tap(find.text('Réserver'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify reservation created in Firestore - query by userId
      final reservations = await db.collection('reservations').where('userId', isEqualTo: uid).get();
      expect(reservations.docs, isNotEmpty);
      final res = reservations.docs.first.data();
      expect(res['roomId'], isNotNull);
      expect(res['hotelId'], isNotNull);

      // verify room is now not available
      final roomQuery = await db.collection('rooms').where('number', isEqualTo: 1010).get();
      expect(roomQuery.docs.first.data()['isAvailable'], false);
    }, timeout: Timeout(const Duration(minutes: 3)));
  });
}
