import 'package:flutter/material.dart';
import 'package:gestion_hotel/utils/app_theme.dart';

class StatsGrid extends StatelessWidget {
  final int hotels;
  final int rooms;
  final int reservations;
  final double occupancyRate;

  const StatsGrid({super.key, required this.hotels, required this.rooms, required this.reservations, required this.occupancyRate});

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveHelper.getGridColumns(context).clamp(2, 4);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Statistiques rapides', style: AppTextStyles.headline4),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.6,
          children: [
            _StatCard(icon: Icons.hotel, label: 'Hotels', value: hotels.toString()),
            _StatCard(icon: Icons.bed_outlined, label: 'Chambres', value: rooms.toString()),
            _StatCard(icon: Icons.calendar_month, label: 'Reservations', value: reservations.toString()),
            _StatCard(icon: Icons.pie_chart, label: 'Taux d occupation', value: '${occupancyRate.toStringAsFixed(1)}%'),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allLg),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: AppBorderRadius.allMd,
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(value, style: AppTextStyles.headline4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
