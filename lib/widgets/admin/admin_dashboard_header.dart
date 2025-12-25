import 'package:flutter/material.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/app_card.dart';

/// Header widget for admin dashboard
class AdminDashboardHeader extends StatelessWidget {
  final VoidCallback onRefresh;

  const AdminDashboardHeader({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.insights, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dashboard Admin', style: AppTextStyles.headline2),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Surveillez les indicateurs clés, les réservations et les hôtels performants.',
                  style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.sync),
            label: const Text('Rafraîchir'),
          ),
        ],
      ),
    );
  }
}
