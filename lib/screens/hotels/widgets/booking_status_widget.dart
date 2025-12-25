import 'package:flutter/material.dart';
import 'package:gestion_hotel/utils/app_theme.dart';

class BookingStatusWidget extends StatelessWidget {
  const BookingStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle_outline, color: AppColors.success),
                const SizedBox(width: AppSpacing.sm),
                Text('Statut des réservations', style: AppTextStyles.subtitle1),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('Toutes les réservations sont confirmées'),
          ],
        ),
      ),
    );
  }
}