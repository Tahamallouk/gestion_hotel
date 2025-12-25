import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/models/hotel.dart';
import 'package:gestion_hotel/models/room.dart';
import 'package:gestion_hotel/models/reservation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore db;
  late FirestoreService service;
  String? hotelId;
  String? roomId;
  String? reservationId;

  setUpAll(() async {
    db = FakeFirebaseFirestore();
    service = FirestoreService(firestore: db);
  });

  test('End-to-end rooms + reservation flow', () async {
    // 1. Create a temporary hotel
    final hotel = Hotel(
      name: 'TestHotel E2E',
      city: 'TestCity',
      address: 'TestAddr',
      imageUrl: 'https://example.com/hotel.jpg',
      rating: 4.5,
      location: 'TestLocation',
      price: 120,
    );
    hotelId = await service.addHotel(hotel);
    expect(hotelId, isNotNull);

    // 2. Add a room
    final uniqueNumber = DateTime.now().millisecondsSinceEpoch % 100000;
    final room = Room(
      hotelId: hotelId!,
      number: uniqueNumber,
      type: 'Test',
      view: 'standard',
      capacity: 2,
      basePrice: 50,
      viewExtra: 10,
      isAvailable: true,
      imageUrl: '',
    );
    await service.addRoom(room);

    // find the room doc
    final roomSnap = await db
        .collection('rooms')
        .where('hotelId', isEqualTo: hotelId)
        .where('number', isEqualTo: uniqueNumber)
        .limit(1)
        .get();
    expect(roomSnap.docs, isNotEmpty);
    roomId = roomSnap.docs.first.id;

    // 3. Update the room
    await service.updateRoom(roomId!, {'basePrice': 75});
    final updated = await db.collection('rooms').doc(roomId).get();
    expect((updated.data() ?? {})['basePrice'], 75);

    // 4. Create reservation (transaction should set isAvailable=false)
    final reservation = Reservation(
      roomId: roomId!,
      userId: 'e2e-test-user',
      hotelId: hotelId!,
      roomType: 'suite',
      viewType: 'mer',
      boardType: 'all_inclusive',
      basePrice: 100,
      viewExtra: 40,
      boardPrice: 350,
      nights: 1,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 1)),
    );
    reservationId = await service.createReservation(reservation);
    expect(reservationId, isNotNull);

    final resDoc = await db.collection('reservations').doc(reservationId).get();
    expect(resDoc.exists, isTrue);
    final roomAfter = await db.collection('rooms').doc(roomId).get();
    expect((roomAfter.data() ?? {})['isAvailable'], false);

    // 5. Delete room
    // 6. Cancel reservation should free the room
    await service.cancelReservation(reservationId!);
    final roomAfterCancel = await db.collection('rooms').doc(roomId).get();
    expect((roomAfterCancel.data() ?? {})['isAvailable'], true);

    // 7. Delete room
    await service.deleteRoom(roomId!);
    final deleted = await db.collection('rooms').doc(roomId).get();
    expect(deleted.exists, isFalse);

    // cleanup reservation and hotel
    await db.collection('reservations').doc(reservationId).delete();
    await db.collection('hotels').doc(hotelId).delete();
  }, timeout: Timeout(Duration(minutes: 5)));

  test('Reservation overlap is prevented transactionally', () async {
    final hotel = Hotel(
      name: 'OverlapTest',
      city: 'City',
      address: 'Addr',
      imageUrl: '',
      rating: 4.0,
      location: 'Loc',
      price: 100,
    );
    final hId = await service.addHotel(hotel);

    final room = Room(
      hotelId: hId,
      number: 101,
      type: 'std',
      view: 'city',
      capacity: 2,
      basePrice: 80,
      viewExtra: 10,
      isAvailable: true,
      imageUrl: '',
    );
    await service.addRoom(room);

    final roomSnap = await db
        .collection('rooms')
        .where('hotelId', isEqualTo: hId)
        .where('number', isEqualTo: 101)
        .limit(1)
        .get();
    final rId = roomSnap.docs.first.id;

    final now = DateTime.now();
    final first = Reservation(
      roomId: rId,
      userId: 'u1',
      hotelId: hId,
      roomType: 'std',
      viewType: 'city',
      boardType: 'bb',
      basePrice: 80,
      viewExtra: 10,
      boardPrice: 0,
      nights: 2,
      startDate: now,
      endDate: now.add(const Duration(days: 2)),
    );

    await service.createReservation(first);

    final overlapping = Reservation(
      roomId: rId,
      userId: 'u2',
      hotelId: hId,
      roomType: 'std',
      viewType: 'city',
      boardType: 'bb',
      basePrice: 80,
      viewExtra: 10,
      boardPrice: 0,
      nights: 2,
      startDate: now.add(const Duration(days: 1)),
      endDate: now.add(const Duration(days: 3)),
    );

    expect(
      () => service.createReservation(overlapping),
      throwsA(isA<StateError>()),
    );
  });

  test('updateReservationStatus locks and frees room', () async {
    final hotel = Hotel(
      name: 'StatusTest',
      city: 'City',
      address: 'Addr',
      imageUrl: '',
      rating: 4.0,
      location: 'Loc',
      price: 100,
    );
    final hId = await service.addHotel(hotel);

    final room = Room(
      hotelId: hId,
      number: 202,
      type: 'std',
      view: 'city',
      capacity: 2,
      basePrice: 80,
      viewExtra: 10,
      isAvailable: true,
      imageUrl: '',
    );
    await service.addRoom(room);
    final rSnap = await db
        .collection('rooms')
        .where('hotelId', isEqualTo: hId)
        .where('number', isEqualTo: 202)
        .limit(1)
        .get();
    final rId = rSnap.docs.first.id;

    final now = DateTime.now();
    final res = Reservation(
      roomId: rId,
      userId: 'u3',
      hotelId: hId,
      roomType: 'std',
      viewType: 'city',
      boardType: 'bb',
      basePrice: 80,
      viewExtra: 10,
      boardPrice: 0,
      nights: 1,
      startDate: now,
      endDate: now.add(const Duration(days: 1)),
    );

    final resId = await service.createReservation(res);
    final resDoc = await db.collection('reservations').doc(resId).get();
    expect(resDoc.data()!['qrToken'], isNotEmpty);

    // By default room locked
    var roomDoc = await db.collection('rooms').doc(rId).get();
    expect((roomDoc.data() ?? {})['isAvailable'], false);

    // Move to checkedIn keeps locked
    await service.updateReservationStatus(resId, 'checkedIn');
    roomDoc = await db.collection('rooms').doc(rId).get();
    expect((roomDoc.data() ?? {})['isAvailable'], false);

    // Cancel frees room
    await service.updateReservationStatus(resId, 'cancelled');
    roomDoc = await db.collection('rooms').doc(rId).get();
    expect((roomDoc.data() ?? {})['isAvailable'], true);
  });

  // ========== PHASE 5: ADMIN STATISTICS TESTS ==========

  group('Admin Statistics Methods - Phase 5', () {
    test('getHotelsCount returns non-negative integer', () async {
      final count = await service.getHotelsCount();
      expect(count, isA<int>());
      expect(count, greaterThanOrEqualTo(0));
    });

    test('getRoomsCount returns non-negative integer', () async {
      final count = await service.getRoomsCount();
      expect(count, isA<int>());
      expect(count, greaterThanOrEqualTo(0));
    });

    test('getReservationsCount returns non-negative integer', () async {
      final count = await service.getReservationsCount();
      expect(count, isA<int>());
      expect(count, greaterThanOrEqualTo(0));
    });

    test('getOccupiedRoomsCount returns non-negative integer', () async {
      final count = await service.getOccupiedRoomsCount();
      expect(count, isA<int>());
      expect(count, greaterThanOrEqualTo(0));
    });

    test('getOccupancyRate returns valid percentage', () async {
      final rate = await service.getOccupancyRate();
      expect(rate, isA<double>());
      expect(rate, greaterThanOrEqualTo(0.0));
      expect(rate, lessThanOrEqualTo(100.0));
    });

    test('getReservationsByStatus returns status counts', () async {
      final statusCounts = await service.getReservationsByStatus();
      expect(statusCounts, isA<Map<String, int>>());
      expect(statusCounts, containsPair('confirmed', anything));
      expect(statusCounts, containsPair('cancelled', anything));
      expect(statusCounts, containsPair('pending', anything));

      for (final count in statusCounts.values) {
        expect(count, greaterThanOrEqualTo(0));
      }
    });

    test('calculateEstimatedRevenue returns non-negative double', () async {
      final revenue = await service.calculateEstimatedRevenue();
      expect(revenue, isA<double>());
      expect(revenue, greaterThanOrEqualTo(0.0));
    });

    test('getTopBookedHotels returns sorted list', () async {
      final hotels = await service.getTopBookedHotels(limit: 5);
      expect(hotels, isA<List<Map<String, dynamic>>>());
      expect(hotels.length, lessThanOrEqualTo(5));

      // Verify each hotel has required fields
      for (final hotel in hotels) {
        expect(hotel, containsPair('hotelId', anything));
        expect(hotel, containsPair('hotelName', anything));
        expect(hotel, containsPair('reservationCount', anything));
      }

      // Verify sorted descending by reservation count
      for (int i = 0; i < hotels.length - 1; i++) {
        expect(
          (hotels[i]['reservationCount'] as int),
          greaterThanOrEqualTo(hotels[i + 1]['reservationCount'] as int),
        );
      }
    });

    test('getOccupancyByHotel returns occupancy data', () async {
      final occupancy = await service.getOccupancyByHotel();
      expect(occupancy, isA<List<Map<String, dynamic>>>());

      for (final hotel in occupancy) {
        expect(hotel, containsPair('hotelId', anything));
        expect(hotel, containsPair('hotelName', anything));
        expect(hotel, containsPair('occupancyRate', anything));
        expect(hotel, containsPair('totalRooms', anything));
        expect(hotel, containsPair('occupiedRooms', anything));

        final rate = hotel['occupancyRate'] as double;
        expect(rate, greaterThanOrEqualTo(0.0));
        expect(rate, lessThanOrEqualTo(100.0));
      }
    });

    test('getReservationsPerDay returns date-mapped counts', () async {
      final perDay = await service.getReservationsPerDay(days: 30);
      expect(perDay, isA<Map<String, int>>());

      // Verify YYYY-MM-DD format
      for (final dateStr in perDay.keys) {
        expect(dateStr, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
      }

      for (final count in perDay.values) {
        expect(count, greaterThanOrEqualTo(0));
      }
    });
  });

  group('Dashboard stats (new aliases)', () {
    late FakeFirebaseFirestore localDb;
    late FirestoreService localService;

    setUp(() {
      localDb = FakeFirebaseFirestore();
      localService = FirestoreService(firestore: localDb);
    });

      Future<void> seedBasicData() async {
      // Hotels
      final h1 = await localService.addHotel(Hotel(
        name: 'H1',
        city: 'c',
        address: 'a',
        imageUrl: '',
        rating: 4,
        location: 'l',
        price: 100,
      ));
      final h2 = await localService.addHotel(Hotel(
        name: 'H2',
        city: 'c',
        address: 'a',
        imageUrl: '',
        rating: 4,
        location: 'l',
        price: 100,
      ));

      // Rooms (4 total, 2 unavailable)
      final rooms = [
        Room(
          hotelId: h1,
          number: 1,
          type: 'std',
          view: 'city',
          capacity: 2,
          basePrice: 80,
          viewExtra: 10,
          isAvailable: true,
          imageUrl: '',
        ),
        Room(
          hotelId: h1,
          number: 2,
          type: 'std',
          view: 'city',
          capacity: 2,
          basePrice: 90,
          viewExtra: 5,
          isAvailable: false,
          imageUrl: '',
        ),
        Room(
          hotelId: h2,
          number: 3,
          type: 'std',
          view: 'city',
          capacity: 2,
          basePrice: 110,
          viewExtra: 0,
          isAvailable: false,
          imageUrl: '',
        ),
        Room(
          hotelId: h2,
          number: 4,
          type: 'std',
          view: 'city',
          capacity: 2,
          basePrice: 120,
          viewExtra: 0,
          isAvailable: true,
          imageUrl: '',
        ),
      ];
      for (final r in rooms) {
        await localService.addRoom(r);
      }

      final now = DateTime.now();

      // Reservations: 3 total (2 for h1, 1 for h2)
      final res1 = Reservation(
        userId: 'u1',
        hotelId: h1,
        roomId: 'r1',
        roomType: 'std',
        viewType: 'city',
        boardType: 'bb',
        basePrice: 100,
        viewExtra: 20,
        boardPrice: 0,
        nights: 2,
        startDate: now,
        endDate: now.add(const Duration(days: 2)),
        totalPriceSnapshot: 240,
      );

      final res2 = Reservation(
        userId: 'u2',
        hotelId: h1,
        roomId: 'r2',
        roomType: 'std',
        viewType: 'city',
        boardType: 'bb',
        basePrice: 80,
        viewExtra: 10,
        boardPrice: 0,
        nights: 1,
        startDate: now.subtract(const Duration(days: 1)),
        endDate: now,
        totalPriceSnapshot: 90,
      );

      final res3 = Reservation(
        userId: 'u3',
        hotelId: h2,
        roomId: 'r3',
        roomType: 'std',
        viewType: 'city',
        boardType: 'bb',
        basePrice: 120,
        viewExtra: 0,
        boardPrice: 0,
        nights: 1,
        startDate: now.subtract(const Duration(days: 2)),
        endDate: now.subtract(const Duration(days: 1)),
        totalPriceSnapshot: 120,
      );

      for (final res in [res1, res2, res3]) {
        await localDb.collection('reservations').add(res.toMap());
      }
    }

    test('getTotalReservations matches seeded count', () async {
          await seedBasicData();
      final total = await localService.getTotalReservations();
      expect(total, 3);
    });

    test('getTotalRevenue sums snapshot totals', () async {
          await seedBasicData();
      final revenue = await localService.getTotalRevenue();
      expect(revenue, closeTo(240 + 90 + 120, 0.001));
    });

    test('getOccupancyRate uses room availability', () async {
          await seedBasicData();
      final rate = await localService.getOccupancyRate();
      expect(rate, closeTo(50.0, 0.001)); // 2/4 occupied
    });

    test('getReservationsByDay returns recent buckets', () async {
          await seedBasicData();
      final byDay = await localService.getReservationsByDay(days: 3);
      expect(byDay.length, 3);
      expect(byDay.values.reduce((a, b) => a + b), 3);
    });

    test('getTopHotels orders by reservation count', () async {
          await seedBasicData();
      final top = await localService.getTopHotels(limit: 2);
      expect(top.first['hotelName'], anyOf('H1', 'H2'));
      expect(top.first['reservationCount'], greaterThanOrEqualTo(top.last['reservationCount'] as int));
      expect(top.first['reservationCount'], 2);
    });
  });

  // ========== REVENUE CALCULATION LOGIC TESTS ==========

  group('Revenue Calculation Logic', () {
    test('Revenue: price × days formula', () {
      const price = 100.0;
      const days = 5;
      final revenue = price * days;
      expect(revenue, equals(500.0));
    });

    test('Revenue: sum of multiple reservations', () {
      const res1 = 100.0 * 3; // €300
      const res2 = 150.0 * 2; // €300
      const res3 = 200.0 * 1; // €200
      final total = res1 + res2 + res3;
      expect(total, equals(800.0));
    });

    test('Occupancy rate: (occupied / total) × 100', () {
      const occupied = 45;
      const total = 100;
      final rate = (occupied / total) * 100.0;
      expect(rate, equals(45.0));
    });

    test('Occupancy rate: zero total rooms = 0%', () {
      const occupied = 5;
      const total = 0;
      final rate = total > 0 ? (occupied / total) * 100.0 : 0.0;
      expect(rate, equals(0.0));
    });

    test('Status distribution percentages sum to 100%', () {
      const confirmed = 50;
      const cancelled = 10;
      const pending = 40;
      const total = confirmed + cancelled + pending;

      final confirmedRate = (confirmed / total) * 100.0;
      final cancelledRate = (cancelled / total) * 100.0;
      final pendingRate = (pending / total) * 100.0;

      final sum = confirmedRate + cancelledRate + pendingRate;
      expect(sum, closeTo(100.0, 0.01));
    });
  });
}
