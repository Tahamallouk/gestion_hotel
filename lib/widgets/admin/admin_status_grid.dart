import 'package:flutter/material.dart';
import 'package:gestion_hotel/utils/app_theme.dart';

/// Status grid widget for admin dashboard
class AdminStatusGrid extends StatelessWidget {
  final int confirmedCount;
  final int cancelledCount;
  final int pendingCount;

  const AdminStatusGrid({
    super.key,
    required this.confirmedCount,
    required this.cancelledCount,
    required this.pendingCount,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 960;
        final double itemWidth = isWide 
            ? (constraints.maxWidth - (AppSpacing.md * 2)) / 3 
            : (constraints.maxWidth - AppSpacing.md) / 2;
        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            StatusTile(
              width: itemWidth,
              title: 'Confirmées',
              value: confirmedCount,
              color: AppColors.success,
              icon: Icons.check_circle,
            ),
            StatusTile(
              width: itemWidth,
              title: 'Annulées',
              value: cancelledCount,
              color: AppColors.error,
              icon: Icons.cancel,
            ),
            StatusTile(
              width: itemWidth,
              title: 'En attente',
              value: pendingCount,
              color: AppColors.warning,
              icon: Icons.hourglass_top,
            ),
          ],
        );
      },
    );
  }
}

class StatusTile extends StatelessWidget {
  final double width;
  final String title;
  final int value;
  final Color color;
  final IconData icon;

  const StatusTile({
    super.key,
    required this.width,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPaddingSmall),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: AppBorderRadius.allLg,
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: AppShadows.subtle,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const Spacer(),
                StatusChip(label: title, color: color),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value.toString(),
              style: AppTextStyles.headline2.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('Réservations', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const StatusChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.allMd,
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
