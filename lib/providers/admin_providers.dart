import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_hotel/services/admin_statistics_service.dart';

/// Provider for AdminStatisticsService
final adminStatisticsServiceProvider = Provider<AdminStatisticsService>((ref) {
  return AdminStatisticsService();
});

/// Provider for admin role check
final adminRoleProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(adminStatisticsServiceProvider);
  return service.checkAdminRole();
});

/// Provider for admin dashboard data with time range parameter
final adminDashboardDataProvider = FutureProvider.family<AdminDashboardData, int>((ref, selectedDays) async {
  final service = ref.read(adminStatisticsServiceProvider);
  return service.loadAllStatistics(selectedDays: selectedDays);
});

/// Provider for selected time range (state management)
final selectedDaysProvider = StateProvider<int>((ref) => 30);
