import 'package:flutter/material.dart';
import 'package:gestion_hotel/utils/app_theme.dart';

enum AppButtonVariant { primary, secondary, danger, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool fullWidth;
  final bool loading;
  final Widget? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.fullWidth = false,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final color = _resolveColor();
    final fg = _resolveForeground();
    final side = _resolveBorder();

    final child = loading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : _buildLabel(fg);

    final button = switch (variant) {
      AppButtonVariant.ghost => OutlinedButton(
          onPressed: loading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: fg,
            side: side,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.mdValue),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
          child: child,
        ),
      _ => ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: fg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.mdValue),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            textStyle: AppTypography.label?.copyWith(),
          ),
          child: child,
        ),
    };

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  Widget _buildLabel(Color fg) {
    if (icon == null) return Text(label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon!,
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: AppTypography.label?.copyWith(color: fg) ?? TextStyle(color: fg)),
      ],
    );
  }

  Color _resolveColor() {
    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.primary;
      case AppButtonVariant.secondary:
        return AppColors.secondary;
      case AppButtonVariant.danger:
        return AppColors.danger;
      case AppButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color _resolveForeground() {
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.secondary:
      case AppButtonVariant.danger:
        return AppColors.onPrimary;
      case AppButtonVariant.ghost:
        return AppColors.textPrimary;
    }
  }

  BorderSide? _resolveBorder() {
    if (variant == AppButtonVariant.ghost) {
      return const BorderSide(color: AppColors.outline);
    }
    return null;
  }
}
