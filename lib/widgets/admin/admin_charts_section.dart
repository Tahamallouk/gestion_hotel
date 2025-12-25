import 'package:flutter/material.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/chart_container.dart';
import 'package:gestion_hotel/widgets/common/empty_state.dart';
import 'package:gestion_hotel/widgets/reservation_pie_chart.dart';
import 'package:gestion_hotel/widgets/reservations_line_chart.dart';
import 'package:gestion_hotel/widgets/top_hotels_bar_chart.dart';

/// Charts section widget for admin dashboard
class AdminChartsSection extends StatelessWidget {
  final int confirmedCount;
  final int cancelledCount;
  final int pendingCount;
  final List<DailyReservationData> reservationsSeries;
  final List<HotelBarData> topHotels;
  final int selectedDays;

  const AdminChartsSection({
    super.key,
    required this.confirmedCount,
    required this.cancelledCount,
    required this.pendingCount,
    required this.reservationsSeries,
    required this.topHotels,
    required this.selectedDays,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasStatusData = (confirmedCount + cancelledCount + pendingCount) > 0;
    final bool hasTimeSeries = reservationsSeries.isNotEmpty;
    final bool hasTopHotels = topHotels.isNotEmpty;

    return Column(
      children: [
        ChartContainer(
          title: 'Distribution par statut',
          description: 'Proportion des réservations',
          chart: hasStatusData
              ? ReservationPieChart(
                  confirmed: confirmedCount,
                  cancelled: cancelledCount,
                  pending: pendingCount,
                )
              : _chartEmptyState(
                  icon: Icons.donut_large_outlined,
                  title: 'Aucune donnée',
                  subtitle: 'Aucune réservation enregistrée pour afficher la répartition.',
                ),
          height: 350,
        ),
        const SizedBox(height: AppSpacing.md),
        ChartContainer(
          title: 'Réservations par jour',
          description: 'Tendance sur $selectedDays jours',
          chart: hasTimeSeries
              ? ReservationsLineChart(data: reservationsSeries)
              : _chartEmptyState(
                  icon: Icons.show_chart,
                  title: 'Pas encore de tendance',
                  subtitle: 'Aucune réservation sur les $selectedDays derniers jours.',
                ),
          height: 320,
        ),
        const SizedBox(height: AppSpacing.md),
        ChartContainer(
          title: 'Hôtels les plus réservés',
          description: 'Top 5 par nombre de réservations',
          chart: hasTopHotels
              ? TopHotelsBarChart(
                  hotels: topHotels,
                  maxReservations: topHotels.fold(0, (max, h) => h.reservations > max ? h.reservations : max),
                )
              : _chartEmptyState(
                  icon: Icons.hotel_class_outlined,
                  title: 'Aucun hôtel classé',
                  subtitle: 'Il faut davantage de réservations pour afficher un top 5.',
                ),
          height: 320,
        ),
      ],
    );
  }

  Widget _chartEmptyState({required IconData icon, required String title, required String subtitle}) {
    return EmptyState(
      icon: icon,
      title: title,
      subtitle: subtitle,
    );
  }
}
