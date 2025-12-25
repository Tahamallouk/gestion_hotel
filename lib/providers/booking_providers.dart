import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_hotel/models/room.dart';
import 'package:gestion_hotel/models/reservation.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/services/auth_service.dart';

/// Provider for FirestoreService singleton
final firestoreProvider = Provider<FirestoreService>((ref) => FirestoreService());

/// Provider for AuthService singleton
final authProvider = Provider<AuthService>((ref) => AuthService());

/// Provider to get available rooms for a hotel
final availableRoomsProvider = StreamProvider.family<List<Room>, String>((ref, hotelId) {
  final firestore = ref.read(firestoreProvider);
  return firestore.getRoomsByHotel(hotelId);
});

/// Provider to check if user is logged in
final currentUserProvider = StreamProvider((ref) {
  final auth = ref.read(authProvider);
  return auth.authStateChanges();
});

/// Provider for user's reservations
final userReservationsProvider = StreamProvider<List<Reservation>>((ref) {
  final firestore = ref.read(firestoreProvider);
  final auth = ref.read(authProvider);
  final uid = auth.currentUser?.uid;
  
  if (uid == null) return Stream.value([]);
  return firestore.getReservationsByUserStream(uid);
});

/// Provider to check room availability for specific dates
final roomAvailabilityProvider = FutureProvider.family<bool, RoomAvailabilityParams>((ref, params) async {
  final firestore = ref.read(firestoreProvider);
  return firestore.isRoomAvailableForDates(
    params.roomId,
    params.startDate,
    params.endDate,
  );
});

/// State for booking process
class BookingState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  
  const BookingState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });
  
  BookingState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return BookingState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// NotifierProvider for booking state management
class BookingNotifier extends StateNotifier<BookingState> {
  BookingNotifier(this._firestore) : super(const BookingState());
  
  final FirestoreService _firestore;
  
  /// Create a new reservation
  Future<void> createReservation(Reservation reservation) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    
    try {
      await _firestore.createReservation(reservation);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false, 
        error: 'Erreur lors de la création de la réservation: $e',
      );
    }
  }
  
  /// Reset booking state
  void reset() {
    state = const BookingState();
  }
  
  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for booking state management
final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  final firestore = ref.read(firestoreProvider);
  return BookingNotifier(firestore);
});

/// Parameters for room availability check
class RoomAvailabilityParams {
  final String roomId;
  final DateTime startDate;
  final DateTime endDate;
  
  const RoomAvailabilityParams({
    required this.roomId,
    required this.startDate,
    required this.endDate,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomAvailabilityParams &&
          runtimeType == other.runtimeType &&
          roomId == other.roomId &&
          startDate == other.startDate &&
          endDate == other.endDate;
  
  @override
  int get hashCode => roomId.hashCode ^ startDate.hashCode ^ endDate.hashCode;
}