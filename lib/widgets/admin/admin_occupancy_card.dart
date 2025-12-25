import 'package:flutter/material.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/app_card.dart';
import 'package:gestion_hotel/widgets/occupancy_gauge.dart';

/// Occupancy card widget for admin dashboard
class AdminOccupancyCard extends StatelessWidget {
  final double occupancyRate;
  final int totalRooms;

  const AdminOccupancyCard({
    super.key,
    required this.occupancyRate,
    required this.totalRooms,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          OccupancyGauge(
            occupancyRate: occupancyRate,
            label: 'Taux global',
            size: 180,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _pill('${occupancyRate.toStringAsFixed(1)}% de remplissage', AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              _pill('$totalRooms chambres suivies', AppColors.secondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppBorderRadius.allLg,
      ),
      child: Text(text, style: AppTextStyles.caption.copyWith(color: color)),
    );
  }
}
