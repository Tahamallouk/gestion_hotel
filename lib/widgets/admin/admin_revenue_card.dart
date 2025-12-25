import 'package:flutter/material.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/app_card.dart';

/// Revenue card widget for admin dashboard
class AdminRevenueCard extends StatelessWidget {
  final double estimatedRevenue;
  final int confirmedCount;

  const AdminRevenueCard({
    super.key,
    required this.estimatedRevenue,
    required this.confirmedCount,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Revenus (confirmées)', style: AppTextStyles.subtitle1.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${estimatedRevenue.toStringAsFixed(2)} DH',
                  style: AppTextStyles.displaySmall.copyWith(color: AppColors.success, letterSpacing: -0.5),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Basé sur $confirmedCount réservations confirmées',
                  style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.all(AppBorderRadius.lg),
            ),
            child: const Icon(Icons.trending_up, size: 48, color: AppColors.success),
          ),
        ],
      ),
    );
  }
}
