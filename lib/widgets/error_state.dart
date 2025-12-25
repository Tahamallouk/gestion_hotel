import 'package:flutter/material.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'app_button.dart';

class ErrorState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.title,
    this.subtitle,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger, size: 36),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: AppTypography.title?.copyWith(color: AppColors.danger)),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: AppTypography.bodyMuted,
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Réessayer',
                onPressed: onRetry,
                variant: AppButtonVariant.danger,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
