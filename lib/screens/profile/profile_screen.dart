import 'package:flutter/material.dart';
import 'package:gestion_hotel/utils/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profil utilisateur', style: AppTextStyles.headline3),
            const SizedBox(height: AppSpacing.md),
            Text('Ajoutez ici les informations, preferences et securite.', style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xl),
            Card(
              shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allLg),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _RowItem(label: 'Email', value: 'exemple@domaine.com'),
                    SizedBox(height: AppSpacing.sm),
                    _RowItem(label: 'Role', value: 'Utilisateur'),
                    SizedBox(height: AppSpacing.sm),
                    _RowItem(label: 'Langue', value: 'Francais'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  final String label;
  final String value;

  const _RowItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary))),
        Text(value, style: AppTextStyles.subtitle1),
      ],
    );
  }
}
