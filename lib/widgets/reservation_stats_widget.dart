import 'package:flutter/material.dart';
import 'package:gestion_hotel/utils/app_theme.dart';

class ReservationStatsWidget extends StatelessWidget {
  const ReservationStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Statistiques des réservations', style: AppTextStyles.subtitle1),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total: '),
                Text('0', style: AppTextStyles.subtitle2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}