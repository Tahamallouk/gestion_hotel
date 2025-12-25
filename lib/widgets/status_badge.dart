import 'package:flutter/material.dart';
import 'package:gestion_hotel/utils/app_theme.dart';

enum StatusBadgeType { confirmed, pending, cancelled, info }

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeType type;
  final bool dense;

  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(type);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? AppSpacing.sm : AppSpacing.md,
        vertical: dense ? AppSpacing.xs : 6,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadius.pillValue),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        label,
        style: AppTypography.label?.copyWith(
          color: colors.foreground,
          fontSize: dense ? 11 : 12,
        ),
      ),
    );
  }

  _StatusBadgeColors _colorsFor(StatusBadgeType type) {
    switch (type) {
      case StatusBadgeType.confirmed:
        return _StatusBadgeColors(
          background: AppColors.success.withValues(alpha: 0.12),
          border: AppColors.success.withValues(alpha: 0.3),
          foreground: AppColors.success,
        );
      case StatusBadgeType.pending:
        return _StatusBadgeColors(
          background: AppColors.warning.withValues(alpha: 0.12),
          border: AppColors.warning.withValues(alpha: 0.3),
          foreground: AppColors.warning,
        );
      case StatusBadgeType.cancelled:
        return _StatusBadgeColors(
          background: AppColors.danger.withValues(alpha: 0.12),
          border: AppColors.danger.withValues(alpha: 0.3),
          foreground: AppColors.danger,
        );
      case StatusBadgeType.info:
        return _StatusBadgeColors(
          background: AppColors.info.withValues(alpha: 0.12),
          border: AppColors.info.withValues(alpha: 0.3),
          foreground: AppColors.info,
        );
    }
  }
}

class _StatusBadgeColors {
  final Color background;
  final Color border;
  final Color foreground;

  const _StatusBadgeColors({
    required this.background,
    required this.border,
    required this.foreground,
  });
}
