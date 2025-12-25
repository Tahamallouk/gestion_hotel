import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/services/auth_service.dart';
import 'package:gestion_hotel/widgets/reservations_line_chart.dart';
import 'package:gestion_hotel/widgets/top_hotels_bar_chart.dart';

/// Service dedicated to admin dashboard statistics
/// This service ONLY moves existing API calls without changing any backend behavior
class AdminStatisticsService {
  final FirestoreService _firestore = FirestoreService();
  final AuthService _auth = AuthService();

  /// Check if current user is admin
  /// THIS CODE WAS INTENTIONALLY LEFT UNCHANGED TO AVOID BREAKING BACKEND BEHAVIOR
  Future<bool> checkAdminRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    
    final role = await _firestore.getUserRole(uid);
    return role == 'admin';
  }

  /// Load all dashboard statistics
  /// THIS CODE WAS INTENTIONALLY LEFT UNCHANGED TO AVOID BREAKING BACKEND BEHAVIOR
  Future<AdminDashboardData> loadAllStatistics({required int selectedDays}) async {
    final hotelsCount = await _firestore.getHotelsCount();
    final roomsCount = await _firestore.getRoomsCount();
    final reservationsCount = await _firestore.getReservationsCount();
    final statusCounts = await _firestore.getReservationsByStatus();
    final occupancy = await _firestore.getOccupancyRate();
    final revenue = await _firestore.calculateEstimatedRevenue();
    final topHotels = await _firestore.getTopBookedHotels(limit: 5);
    final reservationsPerDay = await _firestore.getReservationsPerDay(days: selectedDays);
    final allHotels = await _firestore.getHotels();

    // Convert reservation per day to chart data
    // THIS CODE WAS INTENTIONALLY LEFT UNCHANGED TO AVOID BREAKING BACKEND BEHAVIOR
    final List<DailyReservationData> chartData = [];
    final sortedDates = reservationsPerDay.keys.toList()..sort();
    for (final dateStr in sortedDates) {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final date = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        chartData.add(DailyReservationData(
          date: date,
          count: reservationsPerDay[dateStr] ?? 0,
        ));
      }
    }

    // Convert top hotels to chart data
    // THIS CODE WAS INTENTIONALLY LEFT UNCHANGED TO AVOID BREAKING BACKEND BEHAVIOR
    final hotelChartData = topHotels.map((h) => HotelBarData.fromMap(h)).toList();

    return AdminDashboardData(
      totalHotels: hotelsCount,
      totalRooms: roomsCount,
      totalReservations: reservationsCount,
      confirmedCount: statusCounts['confirmed'] ?? 0,
      cancelledCount: statusCounts['cancelled'] ?? 0,
      pendingCount: statusCounts['pending'] ?? 0,
      occupancyRate: occupancy,
      estimatedRevenue: revenue,
      topHotels: hotelChartData,
      reservationsSeries: chartData,
      allHotels: allHotels.map((h) => {'id': h.id, 'name': h.name}).toList(),
    );
  }
}

/// Data model for admin dashboard statistics
class AdminDashboardData {
  final int totalHotels;
  final int totalRooms;
  final int totalReservations;
  final int confirmedCount;
  final int cancelledCount;
  final int pendingCount;
  final double occupancyRate;
  final double estimatedRevenue;
  final List<HotelBarData> topHotels;
  final List<DailyReservationData> reservationsSeries;
  final List<Map<String, dynamic>> allHotels;

  const AdminDashboardData({
    required this.totalHotels,
    required this.totalRooms,
    required this.totalReservations,
    required this.confirmedCount,
    required this.cancelledCount,
    required this.pendingCount,
    required this.occupancyRate,
    required this.estimatedRevenue,
    required this.topHotels,
    required this.reservationsSeries,
    required this.allHotels,
  });

  bool get isEmptyData =>
      totalHotels == 0 &&
      totalRooms == 0 &&
      totalReservations == 0 &&
      confirmedCount == 0 &&
      cancelledCount == 0 &&
      pendingCount == 0;
}
