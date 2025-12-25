import 'package:flutter/material.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import '../../hotels/list_hotels_screen.dart';

class WelcomeCard extends StatelessWidget {
  final String userEmail;

  const WelcomeCard({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppBorderRadius.allXl,
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.textOnPrimary.withValues(alpha: 0.12),
            child: const Icon(Icons.hotel_class, color: AppColors.textOnPrimary, size: 32),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bonjour,', style: AppTextStyles.body2.copyWith(color: AppColors.textOnPrimary.withValues(alpha: 0.85))),
                const SizedBox(height: AppSpacing.xs),
                Text(userEmail, style: AppTextStyles.headline3.copyWith(color: AppColors.textOnPrimary)),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Gerez vos hotels, chambres et reservations depuis un hub unique.',
                  style: AppTextStyles.body3.copyWith(color: AppColors.textOnPrimary.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
          if (!ResponsiveHelper.isMobile(context))
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.textOnPrimary, foregroundColor: AppColors.primary),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ListHotelsScreen()),
                );
              },
              icon: const Icon(Icons.explore),
              label: const Text('Explorer'),
            ),
        ],
      ),
    );
  }
}
