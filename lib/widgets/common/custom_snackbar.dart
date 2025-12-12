import 'package:flutter/material.dart';
import 'package:gestion_hotel/utils/app_theme.dart';

/// Custom SnackBar with styled appearance
/// Supports success, error, info, and warning types
class CustomSnackBar {
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      type: SnackBarType.success,
      duration: duration,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      message: message,
      type: SnackBarType.error,
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      type: SnackBarType.info,
      duration: duration,
    );
  }

  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      type: SnackBarType.warning,
      duration: duration,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required SnackBarType type,
    required Duration duration,
  }) {
    final colors = _getColors(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getIcon(type),
              color: colors.textColor,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.body2.copyWith(
                  color: colors.textColor,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colors.backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.lg),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.all12,
        ),
        elevation: 6,
      ),
    );
  }

  static IconData _getIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle;
      case SnackBarType.error:
        return Icons.error;
      case SnackBarType.info:
        return Icons.info;
      case SnackBarType.warning:
        return Icons.warning;
    }
  }

  static SnackBarColors _getColors(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return SnackBarColors(
          backgroundColor: AppColors.success.withValues(alpha: 0.9),
          textColor: Colors.white,
        );
      case SnackBarType.error:
        return SnackBarColors(
          backgroundColor: AppColors.error.withValues(alpha: 0.9),
          textColor: Colors.white,
        );
      case SnackBarType.info:
        return SnackBarColors(
          backgroundColor: AppColors.info.withValues(alpha: 0.9),
          textColor: Colors.white,
        );
      case SnackBarType.warning:
        return SnackBarColors(
          backgroundColor: AppColors.warning.withValues(alpha: 0.9),
          textColor: Colors.white,
        );
    }
  }
}

enum SnackBarType { success, error, info, warning }

class SnackBarColors {
  final Color backgroundColor;
  final Color textColor;

  SnackBarColors({
    required this.backgroundColor,
    required this.textColor,
  });
}
