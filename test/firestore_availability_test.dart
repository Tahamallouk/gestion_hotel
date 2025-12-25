import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_hotel/models/reservation.dart';
import 'package:gestion_hotel/services/firestore_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore db;
  late FirestoreService service;

  setUp(() {
    db = FakeFirebaseFirestore();
    service = FirestoreService(firestore: db);
  });

  test(
    'isRoomAvailableForDates returns false when dates overlap confirmed booking',
    () async {
      final start = DateTime(2025, 1, 10);
      final end = DateTime(2025, 1, 15);

      final existing = Reservation(
        id: 'existing',
        userId: 'userA',
        hotelId: 'hotel1',
        roomId: 'room42',
        roomType: 'suite',
        viewType: 'mer',
        boardType: 'all_inclusive',
        basePrice: 200,
        viewExtra: 40,
        boardPrice: 350,
        nights: 5,
        startDate: start,
        endDate: end,
        status: 'confirmed',
      );

      await db
          .collection('reservations')
          .doc(existing.id)
          .set(existing.toMap());

      final available = await service.isRoomAvailableForDates(
        'room42',
        DateTime(2025, 1, 12),
        DateTime(2025, 1, 14),
      );

      expect(available, isFalse);
    },
  );

  test(
    'isRoomAvailableForDates returns true when dates do not overlap',
    () async {
      final existing = Reservation(
        id: 'existing',
        userId: 'userB',
        hotelId: 'hotel1',
        roomId: 'room99',
        roomType: 'double',
        viewType: 'jardin',
        boardType: 'demi-pension',
        basePrice: 120,
        viewExtra: 20,
        boardPrice: 150,
        nights: 3,
        startDate: DateTime(2025, 2, 1),
        endDate: DateTime(2025, 2, 4),
        status: 'confirmed',
      );

      await db
          .collection('reservations')
          .doc(existing.id)
          .set(existing.toMap());

      final available = await service.isRoomAvailableForDates(
        'room99',
        DateTime(2025, 2, 10),
        DateTime(2025, 2, 12),
      );

      expect(available, isTrue);
    },
  );
}
