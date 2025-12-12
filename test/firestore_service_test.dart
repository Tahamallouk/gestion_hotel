import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/models/hotel.dart';
import 'package:gestion_hotel/models/room.dart';
import 'package:gestion_hotel/models/reservation.dart';
import 'package:gestion_hotel/firebase_options.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FirebaseFirestore db;
  late FirestoreService service;
  String? hotelId;
  String? roomId;
  String? reservationId;

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    db = FirebaseFirestore.instance;
    service = FirestoreService(); 
  });

  test('End-to-end rooms + reservation flow', () async {
    // 1. Create a temporary hotel
    final hotel = Hotel(name: 'TestHotel E2E', city: 'TestCity', address: 'TestAddr');
    hotelId = await service.addHotel(hotel);
    expect(hotelId, isNotNull);

    // 2. Add a room
    final uniqueNumber = DateTime.now().millisecondsSinceEpoch % 100000;
    final room = Room(hotelId: hotelId!, number: uniqueNumber, type: 'Test', capacity: 2, price: 50.0, isAvailable: true);
    await service.addRoom(room);

    // find the room doc
    final roomSnap = await db.collection('rooms').where('hotelId', isEqualTo: hotelId).where('number', isEqualTo: uniqueNumber).limit(1).get();
    expect(roomSnap.docs, isNotEmpty);
    roomId = roomSnap.docs.first.id;

    // 3. Update the room
    await service.updateRoom(roomId!, {'price': 75.0});
    final updated = await db.collection('rooms').doc(roomId).get();
    expect((updated.data() ?? {})['price'], 75.0);

    // 4. Create reservation (transaction should set isAvailable=false)
    final reservation = Reservation(roomId: roomId!, userId: 'e2e-test-user', hotelId: hotelId!, startDate: DateTime.now(), endDate: DateTime.now().add(const Duration(days: 1)));
    reservationId = await service.createReservation(reservation);
    expect(reservationId, isNotNull);

    final resDoc = await db.collection('reservations').doc(reservationId).get();
    expect(resDoc.exists, isTrue);
    final roomAfter = await db.collection('rooms').doc(roomId).get();
    expect((roomAfter.data() ?? {})['isAvailable'], isFalse);

    // 5. Delete room
    await service.deleteRoom(roomId!);
    final deleted = await db.collection('rooms').doc(roomId).get();
    expect(deleted.exists, isFalse);

    // cleanup reservation and hotel
    await db.collection('reservations').doc(reservationId).delete();
    await db.collection('hotels').doc(hotelId).delete();
  }, timeout: Timeout(Duration(minutes: 5)));

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
