import 'package:flutter/material.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import '../../admin/admin_dashboard_screen.dart';
import '../../reservations/admin_reservations_screen.dart';
import '../../reservations/my_reservations_screen.dart';
import '../../hotels/list_hotels_screen.dart';

class QuickActions extends StatelessWidget {
  final String? role;

  const QuickActions({super.key, required this.role});

  bool get _isAdmin => role == 'admin';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Actions rapides', style: AppTextStyles.headline4),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _ActionChipButton(
              icon: Icons.hotel_outlined,
              label: 'Voir les hotels',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ListHotelsScreen()),
              ),
            ),
            _ActionChipButton(
              icon: Icons.book_online,
              label: 'Mes reservations',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyReservationsScreen()),
              ),
            ),
            if (_isAdmin)
              _ActionChipButton(
                icon: Icons.dashboard_customize_outlined,
                label: 'Dashboard admin',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                ),
              ),
            if (_isAdmin)
              _ActionChipButton(
                icon: Icons.admin_panel_settings,
                label: 'Reservations admin',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminReservationsScreen()),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ActionChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChipButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: AppColors.primary),
      label: Text(label, style: AppTextStyles.body3.copyWith(color: AppColors.textPrimary)),
      onPressed: onTap,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allMd, side: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
    );
  }
}
