import 'package:flutter/material.dart';
import 'package:gestion_hotel/utils/app_theme.dart';

class BookingGuideCard extends StatelessWidget {
  const BookingGuideCard({super.key});

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
                const Icon(Icons.info_outline, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text('Guide de réservation', style: AppTextStyles.subtitle1),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('• Sélectionnez vos dates'),
            const Text('• Choisissez votre chambre'),
            const Text('• Confirmez votre réservation'),
          ],
        ),
      ),
    );
  }
}