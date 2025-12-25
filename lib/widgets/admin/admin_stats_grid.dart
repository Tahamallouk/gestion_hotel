import 'package:flutter/material.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/stat_card.dart';

/// Statistics grid widget for admin dashboard
class AdminStatsGrid extends StatelessWidget {
  final int totalHotels;
  final int totalRooms;
  final int totalReservations;
  final double occupancyRate;

  const AdminStatsGrid({
    super.key,
    required this.totalHotels,
    required this.totalRooms,
    required this.totalReservations,
    required this.occupancyRate,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final itemWidth = isWide
            ? (constraints.maxWidth - AppSpacing.md * 3) / 4
            : (constraints.maxWidth - AppSpacing.md) / 2;

        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            SizedBox(
              width: itemWidth,
              child: StatCard(
                title: 'Total hôtels',
                value: totalHotels.toString(),
                icon: Icons.hotel,
                color: AppColors.primary,
                subtitle: 'Actifs',
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: StatCard(
                title: 'Total chambres',
                value: totalRooms.toString(),
                icon: Icons.door_front_door_outlined,
                color: AppColors.secondary,
                subtitle: 'Catalogue',
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: StatCard(
                title: 'Total réservations',
                value: totalReservations.toString(),
                icon: Icons.calendar_month,
                color: AppColors.accent,
                subtitle: 'Toutes périodes',
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: StatCard(
                title: 'Taux d\'occupation',
                value: '${occupancyRate.toStringAsFixed(1)}%',
                icon: Icons.percent,
                color: AppColors.info,
                subtitle: 'Global',
              ),
            ),
          ],
        );
      },
    );
  }
}
