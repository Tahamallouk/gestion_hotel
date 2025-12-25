import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/hotel.dart';
import '../models/room.dart';
import '../models/reservation.dart';
import '../utils/paginated_result.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Save a user document (keep existing behaviour)
  Future<void> createUser({
    required String uid,
    required String email,
    required String fullName,
    required String phone,
  }) async {
    try {
      // 1. Vérifier si le document existe déjà
      final userDoc = await _db.collection('users').doc(uid).get();
      
      if (userDoc.exists) {
        // Document existe déjà - NE PAS écraser
        debugPrint('✅ User document already exists for UID: $uid - preserving existing role');
        return;
      }
      
      // 2. Document n'existe pas - créer avec role "user" par défaut
      debugPrint('📝 Creating new user document for UID: $uid');
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'fullName': fullName,
        'phone': phone,
        'role': 'user', // Valeur par défaut UNIQUEMENT à la création
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });
      debugPrint('✅ User document created successfully with role: user');
    } catch (e) {
      debugPrint('Error creating user in Firestore: $e');
      rethrow;
    }
  }

  /// Get user role from Firestore
  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['role'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user role: $e');
      rethrow;
    }
  }

  /// Update user role in Firestore (dev tool)
  Future<void> updateUserRole(String uid, String role) async {
    try {
      await _db.collection('users').doc(uid).update({
        'role': role,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      debugPrint('✅ User $uid role updated to: $role');
    } catch (e) {
      debugPrint('Error updating user role: $e');
      rethrow;
    }
  }

  /// Add a Hotel and return the document id
  Future<String> addHotel(Hotel hotel) async {
    try {
      final docRef = await _db.collection('hotels').add(hotel.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding hotel: $e');
      rethrow;
    }
  }

  /// Get all hotels
  Future<List<Hotel>> getHotels() async {
    try {
      final snapshot = await _db.collection('hotels').get();
      return snapshot.docs.map((d) {
        final data = d.data() as Map<String, dynamic>? ?? {};
        data['id'] = d.id;
        return Hotel.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting hotels: $e');
      rethrow;
    }
  }

  /// Stream all hotels (real-time updates)
  Stream<List<Hotel>> getHotelsStream() {
    try {
      return _db.collection('hotels').snapshots().map(
        (snapshot) => snapshot.docs.map((d) {
          final data = d.data() as Map<String, dynamic>? ?? {};
          data['id'] = d.id;
          return Hotel.fromMap(data);
        }).toList(),
      );
    } catch (e) {
      debugPrint('Error streaming hotels: $e');
      rethrow;
    }
  }

  /// Add a Room and return document id
  /// Add a Room
  Future<void> addRoom(Room room) async {
    try {
      await _db.collection('rooms').add(room.toMap());
    } catch (e) {
      debugPrint('Error adding room: $e');
      rethrow;
    }
  }

  /// Update a room document
  Future<void> updateRoom(String roomId, Map<String, dynamic> data) async {
    try {
      await _db.collection('rooms').doc(roomId).update(data);
    } catch (e) {
      debugPrint('Error updating room $roomId: $e');
      rethrow;
    }
  }

  /// Delete a room document
  Future<void> deleteRoom(String roomId) async {
    try {
      await _db.collection('rooms').doc(roomId).delete();
    } catch (e) {
      debugPrint('Error deleting room $roomId: $e');
      rethrow;
    }
  }

  /// Stream rooms by hotelId
  Stream<List<Room>> getRoomsByHotel(String hotelId) {
    try {
      return _db
          .collection('rooms')
          .where('hotelId', isEqualTo: hotelId)
          .snapshots()
          .map(
            (snap) => snap.docs.map((d) {
              final data = d.data() as Map<String, dynamic>? ?? {};
              data['id'] = d.id;
              return Room.fromMap(data);
            }).toList(),
          );
    } catch (e) {
      debugPrint('Error streaming rooms for hotel $hotelId: $e');
      rethrow;
    }
  }

  /// Validate dates (start < end)
  void _assertValidDateRange(DateTime start, DateTime end) {
    if (!start.isBefore(end)) {
      throw ArgumentError('startDate must be before endDate');
    }
  }

  /// Public availability check (non-transactional) for UI pre-checks
  Future<bool> isRoomAvailableForDates(
    String roomId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    _assertValidDateRange(startDate, endDate);
    final reservationQuery = await _db
      .collection('reservations')
      .where('roomId', isEqualTo: roomId)
      .where('status', whereIn: ['confirmed', 'checkedIn', 'pending'])
      .get();

    for (final doc in reservationQuery.docs) {
      final data = doc.data();
      final sd = data['startDate'];
      final ed = data['endDate'];

      final existingStart = sd is Timestamp
          ? sd.toDate()
          : DateTime.tryParse(sd.toString()) ?? DateTime.now();
      final existingEnd = ed is Timestamp
          ? ed.toDate()
          : DateTime.tryParse(ed.toString()) ?? DateTime.now();

      final overlaps = startDate.isBefore(existingEnd) && endDate.isAfter(existingStart);
      if (overlaps) return false;
    }
    return true;
  }

  bool _shouldMakeRoomAvailable(String status) {
    return status == 'cancelled';
  }

  bool _shouldLockRoom(String status) {
    return status == 'confirmed' || status == 'checkedIn';
  }

  /// Internal overlap check used inside transactions
  Future<void> _ensureNoOverlap({
    required String roomId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final reservationQuery = await _db
        .collection('reservations')
        .where('roomId', isEqualTo: roomId)
        .where('status', whereIn: ['confirmed', 'checkedIn'])
        .get();

    for (final doc in reservationQuery.docs) {
      final data = doc.data();
      final sd = data['startDate'];
      final ed = data['endDate'];

      final existingStart = sd is Timestamp
          ? sd.toDate()
          : DateTime.tryParse(sd.toString()) ?? DateTime.now();
      final existingEnd = ed is Timestamp
          ? ed.toDate()
          : DateTime.tryParse(ed.toString()) ?? DateTime.now();

      final overlaps = startDate.isBefore(existingEnd) && endDate.isAfter(existingStart);
      if (overlaps) {
        throw StateError('Room not available for selected dates');
      }
    }
  }

  /// Create a reservation transactionally with overlap check and room lock
  Future<String> createReservation(Reservation reservation) async {
    _assertValidDateRange(reservation.startDate, reservation.endDate);

    final resRef = _db.collection('reservations').doc();
    final roomRef = _db.collection('rooms').doc(reservation.roomId);

    try {
      await _db.runTransaction((tx) async {
        final roomSnap = await tx.get(roomRef);
        if (!roomSnap.exists) {
          throw StateError('Room not found');
        }

        // overlap check on confirmed/checkedIn reservations
        await _ensureNoOverlap(
          roomId: reservation.roomId,
          startDate: reservation.startDate,
          endDate: reservation.endDate,
        );

        // lock room availability
        tx.update(roomRef, {'isAvailable': false});

        // snapshot total price and default status (treat empty/pending as confirmed)
        final statusToPersist =
            (reservation.status.isEmpty || reservation.status == 'pending')
                ? 'confirmed'
                : reservation.status;

        final payload = reservation
            .copyWith(
              status: statusToPersist,
              totalPriceSnapshot: reservation.totalPrice.toDouble(),
              qrToken: reservation.qrToken ?? resRef.id,
            )
            .toMap();

        tx.set(resRef, payload);
      });
      return resRef.id;
    } catch (e) {
      debugPrint('Error creating reservation transactionally: $e');
      rethrow;
    }
  }

  /// Create a reservation without locking a room document (for mock/offline rooms)
  Future<String> createReservationSimple(Reservation reservation) async {
    _assertValidDateRange(reservation.startDate, reservation.endDate);

    final resRef = _db.collection('reservations').doc();
    final statusToPersist =
        (reservation.status.isEmpty || reservation.status == 'pending') ? 'confirmed' : reservation.status;

    final payload = reservation
        .copyWith(
          status: statusToPersist,
          totalPriceSnapshot: reservation.totalPrice.toDouble(),
          qrToken: reservation.qrToken ?? resRef.id,
        )
        .toMap();

    try {
      await resRef.set(payload);
      return resRef.id;
    } catch (e) {
      debugPrint('Error creating simple reservation: $e');
      rethrow;
    }
  }

  /// Get reservations for a specific user
  Future<List<Reservation>> getReservationsByUser(String userId) async {
    try {
      final snapshot = await _db
          .collection('reservations')
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs.map((d) {
        final data = d.data() as Map<String, dynamic>? ?? {};
        data['id'] = d.id;
        return Reservation.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting reservations for user $userId: $e');
      rethrow;
    }
  }

  /// Stream reservations by user
  Stream<List<Reservation>> getReservationsByUserStream(String userId) {
    return _db
        .collection('reservations')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final data = d.data();
            data['id'] = d.id;
            return Reservation.fromMap(data);
          }).toList(),
        );
  }

  /// Stream reservations by hotel
  Stream<List<Reservation>> getReservationsByHotel(String hotelId) {
    return _db
        .collection('reservations')
        .where('hotelId', isEqualTo: hotelId)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final data = d.data();
            data['id'] = d.id;
            return Reservation.fromMap(data);
          }).toList(),
        );
  }

  /// Stream all reservations (admin)
  Stream<List<Reservation>> getAllReservations() {
    return _db
        .collection('reservations')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final data = d.data();
            data['id'] = d.id;
            return Reservation.fromMap(data);
          }).toList(),
        );
  }

  /// Update reservation status
  Future<void> updateReservationStatus(
    String reservationId,
    String status,
  ) async {
    final resRef = _db.collection('reservations').doc(reservationId);
    try {
      await _db.runTransaction((tx) async {
        final resSnap = await tx.get(resRef);
        if (!resSnap.exists) throw StateError('Reservation not found');
        final data = resSnap.data();
        final roomId = data?['roomId'] as String?;
        if (roomId == null) throw StateError('Reservation missing roomId');

        // Update reservation status
        tx.update(resRef, {'status': status});

        // Skip room update for mock rooms
        if (roomId.startsWith('mock-')) {
          debugPrint('🔹 Room mock ignorée: $roomId (pas d\'update status nécessaire)');
          return;
        }

        // Verify room document exists before updating
        final roomRef = _db.collection('rooms').doc(roomId);
        final roomSnap = await tx.get(roomRef);
        
        if (roomSnap.exists) {
          if (_shouldMakeRoomAvailable(status)) {
            tx.update(roomRef, {'isAvailable': true});
            debugPrint('✅ Room $roomId status updated: isAvailable = true');
          } else if (_shouldLockRoom(status)) {
            tx.update(roomRef, {'isAvailable': false});
            debugPrint('✅ Room $roomId status updated: isAvailable = false');
          }
        } else {
          debugPrint('⚠️ Room document $roomId not found, skipping room status update');
        }
      });
    } catch (e) {
      debugPrint(
        'Error updating reservation $reservationId status to $status: $e',
      );
      rethrow;
    }
  }

  /// Cancel reservation and set room available (transaction)
  Future<void> cancelReservation(String reservationId) async {
    final resRef = _db.collection('reservations').doc(reservationId);
    try {
      await _db.runTransaction((tx) async {
        final resSnap = await tx.get(resRef);
        if (!resSnap.exists) throw Exception('Reservation not found');
        final data = resSnap.data();
        final roomId = data?['roomId'] as String?;
        if (roomId == null) throw Exception('Reservation missing roomId');

        // Update reservation status
        tx.update(resRef, {'status': 'cancelled'});
        
        // Check if room is mock or if document exists before updating
        if (roomId.startsWith('mock-')) {
          debugPrint('🔹 Room mock ignorée: $roomId (pas d\'update Firestore nécessaire)');
          return; // Skip room update for mock rooms
        }
        
        // Verify room document exists before updating
        final roomRef = _db.collection('rooms').doc(roomId);
        final roomSnap = await tx.get(roomRef);
        if (roomSnap.exists) {
          tx.update(roomRef, {'isAvailable': true});
          debugPrint('✅ Room $roomId mis à jour: isAvailable = true');
        } else {
          debugPrint('⚠️ Room document $roomId not found, skipping room update');
        }
      });
    } catch (e) {
      debugPrint('Error cancelling reservation $reservationId: $e');
      rethrow;
    }
  }

  /// Fetch a reservation by its qrToken
  Future<Reservation?> getReservationByQrToken(String qrToken) async {
    try {
      final snap = await _db
          .collection('reservations')
          .where('qrToken', isEqualTo: qrToken)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      final data = snap.docs.first.data();
      data['id'] = snap.docs.first.id;
      return Reservation.fromMap(data);
    } catch (e) {
      debugPrint('Error fetching reservation by qrToken: $e');
      rethrow;
    }
  }

  /// Get user profile data (fullName, phone, role, email if stored)
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      final data = doc.data();
      return data;
    } catch (e) {
      debugPrint('Error fetching user profile for $uid: $e');
      rethrow;
    }
  }

  // ========== ADMIN STATISTICS METHODS (Phase 5) ==========

  /// Get total number of hotels
  /// Returns count of documents in hotels collection
  Future<int> getHotelsCount() async {
    try {
      final snapshot = await _db.collection('hotels').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting hotels count: $e');
      rethrow;
    }
  }

  /// Get total number of rooms
  /// Returns count of documents in rooms collection
  Future<int> getRoomsCount() async {
    try {
      final snapshot = await _db.collection('rooms').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting rooms count: $e');
      rethrow;
    }
  }

  /// Get total number of reservations
  /// Returns count of documents in reservations collection
  Future<int> getReservationsCount() async {
    try {
      final snapshot = await _db.collection('reservations').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting reservations count: $e');
      rethrow;
    }
  }

  /// Get number of occupied rooms (not available)
  /// Returns count where isAvailable == false
  Future<int> getOccupiedRoomsCount() async {
    try {
      final snapshot = await _db
          .collection('rooms')
          .where('isAvailable', isEqualTo: false)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting occupied rooms count: $e');
      rethrow;
    }
  }

  /// Get occupancy rate (percentage: 0-100)
  /// Calculation: (occupied / total) * 100
  Future<double> getOccupancyRate() async {
    try {
      final totalCount = await getRoomsCount();
      if (totalCount == 0) return 0.0;

      final occupiedCount = await getOccupiedRoomsCount();
      return (occupiedCount / totalCount) * 100.0;
    } catch (e) {
      debugPrint('Error calculating occupancy rate: $e');
      rethrow;
    }
  }

  /// Dashboard: total reservations (all statuses)
  Future<int> getTotalReservations() async {
    try {
      final snapshot = await _db.collection('reservations').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting total reservations: $e');
      rethrow;
    }
  }

  /// Dashboard: total revenue from confirmed + checkedIn reservations.
  /// Uses totalPriceSnapshot when present, otherwise falls back to price components.
  Future<double> getTotalRevenue() async {
    try {
        final snap = await _db.collection('reservations').get();

      double total = 0.0;
      for (final doc in snap.docs) {
        final data = doc.data();
        final snapshotPrice = (data['totalPriceSnapshot'] as num?)?.toDouble();
        if (snapshotPrice != null) {
          total += snapshotPrice;
          continue;
        }

        final base = (data['basePrice'] as num?)?.toDouble() ?? 0.0;
        final view = (data['viewExtra'] as num?)?.toDouble() ?? 0.0;
        final board = (data['boardPrice'] as num?)?.toDouble() ?? 0.0;
        final nights = (data['nights'] as num?)?.toInt() ?? 0;
        total += (base + view + board) * nights;
      }
      return total;
    } catch (e) {
      debugPrint('Error calculating total revenue: $e');
      rethrow;
    }
  }

  /// Get reservations count by status
  /// Returns map: {'confirmed': count, 'cancelled': count, 'pending': count}
  Future<Map<String, int>> getReservationsByStatus() async {
    try {
      final result = {'confirmed': 0, 'cancelled': 0, 'pending': 0};

      for (final status in result.keys) {
        final snapshot = await _db
            .collection('reservations')
            .where('status', isEqualTo: status)
            .count()
            .get();
        result[status] = snapshot.count ?? 0;
      }

      return result;
    } catch (e) {
      debugPrint('Error getting reservations by status: $e');
      rethrow;
    }
  }

  // ------------------ PAGINATION HELPERS ------------------

  /// Get hotels paged. Returns items plus lastDocument to continue.
  Future<PaginatedResult<Hotel>> getHotelsPaged({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query q = _db
          .collection('hotels')
          .orderBy('createdAt', descending: true)
          .limit(limit);
      if (startAfter != null) q = q.startAfterDocument(startAfter);

      final snap = await q.get();
      final items = snap.docs.map((d) {
        final data = d.data() as Map<String, dynamic>? ?? {};
        data['id'] = d.id;
        return Hotel.fromMap(data);
      }).toList();
      final lastDoc = snap.docs.isNotEmpty ? snap.docs.last : null;
      return PaginatedResult(
        items: items,
        lastDocument: lastDoc,
        hasMore: (snap.docs.length == limit),
      );
    } catch (e) {
      debugPrint('Error getting hotels paged: $e');
      rethrow;
    }
  }

  /// Get rooms paged for a hotel (supports optional availability filter)
  Future<PaginatedResult<Room>> getRoomsPaged({
    required String hotelId,
    int limit = 20,
    DocumentSnapshot? startAfter,
    bool? onlyAvailable,
  }) async {
    try {
      Query q = _db
          .collection('rooms')
          .where('hotelId', isEqualTo: hotelId)
          .orderBy('createdAt', descending: true)
          .limit(limit);
      if (onlyAvailable != null) {
        q = q.where('isAvailable', isEqualTo: onlyAvailable);
      }
      if (startAfter != null) q = q.startAfterDocument(startAfter);

      final snap = await q.get();
      final items = snap.docs.map((d) {
        final data = d.data() as Map<String, dynamic>? ?? {};
        data['id'] = d.id;
        return Room.fromMap(data);
      }).toList();
      final lastDoc = snap.docs.isNotEmpty ? snap.docs.last : null;
      return PaginatedResult(
        items: items,
        lastDocument: lastDoc,
        hasMore: (snap.docs.length == limit),
      );
    } catch (e) {
      debugPrint('Error getting rooms paged: $e');
      rethrow;
    }
  }

  /// Get reservations paged for a user (or all if userId is null)
  Future<PaginatedResult<Reservation>> getReservationsPaged({
    String? userId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query q = _db
          .collection('reservations')
          .orderBy('createdAt', descending: true)
          .limit(limit);
      if (userId != null) q = q.where('userId', isEqualTo: userId);
      if (startAfter != null) q = q.startAfterDocument(startAfter);

      final snap = await q.get();
      final items = snap.docs.map((d) {
        final data = d.data() as Map<String, dynamic>? ?? {};
        data['id'] = d.id;
        return Reservation.fromMap(data);
      }).toList();
      final lastDoc = snap.docs.isNotEmpty ? snap.docs.last : null;
      return PaginatedResult(
        items: items,
        lastDocument: lastDoc,
        hasMore: (snap.docs.length == limit),
      );
    } catch (e) {
      debugPrint('Error getting reservations paged: $e');
      rethrow;
    }
  }

  /// Calculate estimated revenue from confirmed reservations
  /// Sum of (room price * duration) for all confirmed reservations
  /// Returns revenue in decimal format (e.g., 45250.50)
  Future<double> calculateEstimatedRevenue() async {
    try {
      final reservations = await _db
          .collection('reservations')
          .where('status', isEqualTo: 'confirmed')
          .get();

      double totalRevenue = 0.0;

      for (final resDoc in reservations.docs) {
        final data = resDoc.data();
        final roomId = data['roomId'] as String?;
        final startDate = data['startDate'];
        final endDate = data['endDate'];

        if (roomId == null) continue;

        // Parse dates
        DateTime start = startDate is Timestamp
            ? startDate.toDate()
            : DateTime.now();
        DateTime end = endDate is Timestamp ? endDate.toDate() : DateTime.now();

        // Get room price
        final roomDoc = await _db.collection('rooms').doc(roomId).get();
        if (!roomDoc.exists) continue;

        final roomData = roomDoc.data();
        final price = (roomData?['price'] as num?)?.toDouble() ?? 0.0;

        // Calculate duration in days
        final duration = end.difference(start).inDays;
        if (duration > 0) {
          totalRevenue += (price * duration);
        }
      }

      return totalRevenue;
    } catch (e) {
      debugPrint('Error calculating estimated revenue: $e');
      rethrow;
    }
  }

  /// Get top N most booked hotels
  /// Returns list sorted by reservation count descending
  Future<List<Map<String, dynamic>>> getTopBookedHotels({int limit = 5}) async {
    try {
      // Get all hotels
      final hotelsSnap = await _db.collection('hotels').get();
      final hotels = <String, String>{}; // hotelId -> hotelName
      for (final doc in hotelsSnap.docs) {
        final data = doc.data();
        hotels[doc.id] = (data['name'] as String?) ?? 'Unknown';
      }

      // Count reservations per hotel
      final reservationCounts = <String, int>{};
      for (final hotelId in hotels.keys) {
        final count = await _db
            .collection('reservations')
            .where('hotelId', isEqualTo: hotelId)
            .count()
            .get();
        reservationCounts[hotelId] = count.count ?? 0;
      }

      // Sort and convert to list
      final sorted = reservationCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sorted.take(limit).map((entry) {
        return {
          'hotelId': entry.key,
          'hotelName': hotels[entry.key] ?? 'Unknown',
          'reservationCount': entry.value,
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting top booked hotels: $e');
      rethrow;
    }
  }

  /// Dashboard: top hotels alias (delegates to getTopBookedHotels)
  Future<List<Map<String, dynamic>>> getTopHotels({int limit = 5}) {
    return getTopBookedHotels(limit: limit);
  }

  /// Get occupancy rate for each hotel
  /// Returns list of HotelOccupancyData sorted by occupancy rate descending
  Future<List<Map<String, dynamic>>> getOccupancyByHotel() async {
    try {
      // Get all hotels
      final hotelsSnap = await _db.collection('hotels').get();
      final result = <Map<String, dynamic>>[];

      for (final hotelDoc in hotelsSnap.docs) {
        final hotelData = hotelDoc.data();
        final hotelId = hotelDoc.id;
        final hotelName = hotelData['name'] as String? ?? 'Unknown';

        // Count total and occupied rooms
        final totalSnap = await _db
            .collection('rooms')
            .where('hotelId', isEqualTo: hotelId)
            .count()
            .get();
        final totalRooms = totalSnap.count ?? 0;

        final occupiedSnap = await _db
            .collection('rooms')
            .where('hotelId', isEqualTo: hotelId)
            .where('isAvailable', isEqualTo: false)
            .count()
            .get();
        final occupiedRooms = occupiedSnap.count ?? 0;

        final occupancyRate = totalRooms > 0
            ? (occupiedRooms / totalRooms) * 100.0
            : 0.0;

        result.add({
          'hotelId': hotelId,
          'hotelName': hotelName,
          'occupancyRate': occupancyRate,
          'totalRooms': totalRooms,
          'occupiedRooms': occupiedRooms,
        });
      }

      // Sort by occupancy rate descending
      result.sort(
        (a, b) => (b['occupancyRate'] as double).compareTo(
          a['occupancyRate'] as double,
        ),
      );
      return result;
    } catch (e) {
      debugPrint('Error getting occupancy by hotel: $e');
      rethrow;
    }
  }

  /// Get reservations count per day for the last N days
  /// Returns map: {date: count}
  Future<Map<String, int>> getReservationsPerDay({int days = 30}) async {
    try {
      final result = <String, int>{};
      final now = DateTime.now();

      // Initialize all dates with 0
      for (int i = 0; i < days; i++) {
        final date = now.subtract(Duration(days: i));
        final dateStr =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        result[dateStr] = 0;
      }

      // Get reservations from last N days
      final startDate = now.subtract(Duration(days: days));
      final snapshot = await _db
          .collection('reservations')
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .get();

      // Count by date
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final createdAt = data['createdAt'];
        if (createdAt is Timestamp) {
          final date = createdAt.toDate();
          final dateStr =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          result[dateStr] = (result[dateStr] ?? 0) + 1;
        }
      }

      return result;
    } catch (e) {
      debugPrint('Error getting reservations per day: $e');
      rethrow;
    }
  }

  /// Dashboard: reservations by day alias (default 7 days)
  Future<Map<String, int>> getReservationsByDay({int days = 7}) {
    return getReservationsPerDay(days: days);
  }

  /// Get occupancy rate for a specific hotel
  /// Returns percentage (0-100)
  Future<double> getHotelOccupancyRate(String hotelId) async {
    try {
      final totalSnap = await _db
          .collection('rooms')
          .where('hotelId', isEqualTo: hotelId)
          .count()
          .get();
      final totalRooms = totalSnap.count ?? 0;

      if (totalRooms == 0) return 0.0;

      final occupiedSnap = await _db
          .collection('rooms')
          .where('hotelId', isEqualTo: hotelId)
          .where('isAvailable', isEqualTo: false)
          .count()
          .get();
      final occupiedRooms = occupiedSnap.count ?? 0;

      return (occupiedRooms / totalRooms) * 100.0;
    } catch (e) {
      debugPrint('Error getting hotel occupancy rate: $e');
      rethrow;
    }
  }

  /// Get hotel details (for admin hotel detail screen)
  /// Returns hotel with room count and occupancy
  Future<Map<String, dynamic>?> getHotelDetails(String hotelId) async {
    try {
      final doc = await _db.collection('hotels').doc(hotelId).get();
      if (!doc.exists) return null;

      final data = doc.data() ?? {};
      data['id'] = hotelId;

      // Add room counts
      final roomsSnap = await _db
          .collection('rooms')
          .where('hotelId', isEqualTo: hotelId)
          .get();
      data['totalRooms'] = roomsSnap.size;

      final occupiedSnap = await _db
          .collection('rooms')
          .where('hotelId', isEqualTo: hotelId)
          .where('isAvailable', isEqualTo: false)
          .count()
          .get();
      data['occupiedRooms'] = occupiedSnap.count ?? 0;

      // Add reservation count
      final reservSnap = await _db
          .collection('reservations')
          .where('hotelId', isEqualTo: hotelId)
          .count()
          .get();
      data['totalReservations'] = reservSnap.count ?? 0;

      return data;
    } catch (e) {
      debugPrint('Error getting hotel details: $e');
      rethrow;
    }
  }

  /// Delete hotel with cleanup (admin only)
  Future<void> deleteHotel(String hotelId) async {
    try {
      await _db.runTransaction((tx) async {
        // Delete all rooms for this hotel
        final roomsSnap = await _db
            .collection('rooms')
            .where('hotelId', isEqualTo: hotelId)
            .get();
        for (final doc in roomsSnap.docs) {
          tx.delete(doc.reference);
        }

        // Delete all reservations for this hotel
        final resSnap = await _db
            .collection('reservations')
            .where('hotelId', isEqualTo: hotelId)
            .get();
        for (final doc in resSnap.docs) {
          tx.delete(doc.reference);
        }

        // Delete hotel
        tx.delete(_db.collection('hotels').doc(hotelId));
      });
    } catch (e) {
      debugPrint('Error deleting hotel: $e');
      rethrow;
    }
  }

  /// Get all rooms
  Future<List<Room>> getRooms() async {
    try {
      final snapshot = await _db.collection('rooms').get();
      return snapshot.docs.map((d) {
        final data = d.data() as Map<String, dynamic>? ?? {};
        data['id'] = d.id;
        return Room.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting rooms: $e');
      rethrow;
    }
  }

  /// Update hotel details
  Future<void> updateHotel(String hotelId, Map<String, dynamic> data) async {
    try {
      await _db.collection('hotels').doc(hotelId).update(data);
    } catch (e) {
      debugPrint('Error updating hotel: $e');
      rethrow;
    }
  }
}
