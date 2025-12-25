import 'package:flutter/material.dart';
import 'package:gestion_hotel/features/dashboard/dashboard_page.dart';
import 'package:gestion_hotel/features/profile/profile_page.dart';
import 'package:gestion_hotel/features/reservations/reservations_page.dart';
import 'package:gestion_hotel/screens/hotels/user_hotels_list_screen.dart';
import 'package:gestion_hotel/screens/reservations/reservation_admin_dashboard.dart';
import 'package:gestion_hotel/screens/admin/admin_hotels_management_page_simple.dart';
import 'package:gestion_hotel/screens/admin/admin_rooms_management_page_simple.dart';
import 'package:gestion_hotel/screens/dev/dev_admin_tools_page.dart';
import 'package:gestion_hotel/services/auth_service.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/utils/app_theme.dart';

class AppShell extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const AppShell({
    super.key,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _auth = AuthService();
  final _firestore = FirestoreService();
  int _selectedIndex = 0;
  String _role = 'client';
  bool _loadingRole = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      setState(() => _loadingRole = false);
      return;
    }

    try {
      final role = await _firestore.getUserRole(uid);
      if (!mounted) return;
      setState(() {
        _role = role ?? 'client';
        _loadingRole = false;
        if (_selectedIndex >= _items.length) _selectedIndex = 0;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingRole = false);
    }
  }

  List<_NavItem> get _clientItems => [
        _NavItem(label: 'Dashboard', icon: Icons.space_dashboard_outlined, builder: (context, goTo) => DashboardPage(onNavigate: goTo)),
        _NavItem(label: 'Hôtels', icon: Icons.apartment, builder: (context, _) => const UserHotelsListScreen()),
        _NavItem(label: 'Mes réservations', icon: Icons.calendar_month_outlined, builder: (context, _) => const ReservationsPage()),
        _NavItem(label: 'Profil', icon: Icons.person_outline, builder: (context, _) => const ProfilePage()),
      ];

  List<_NavItem> get _adminItems => [
        _NavItem(label: 'Dashboard', icon: Icons.space_dashboard_outlined, builder: (context, goTo) => DashboardPage(onNavigate: goTo)),
        _NavItem(label: 'Gestion Hôtels', icon: Icons.apartment, builder: (context, _) => const AdminHotelsManagementPageSimple()),
        _NavItem(label: 'Gestion Chambres', icon: Icons.king_bed_outlined, builder: (context, _) => const AdminRoomsManagementPageSimple()),
        _NavItem(label: 'Reservations', icon: Icons.calendar_month_outlined, builder: (context, _) => const ReservationAdminDashboard()),
        _NavItem(label: 'Profil', icon: Icons.person_outline, builder: (context, _) => const ProfilePage()),
      ];

  List<_NavItem> get _items => _role == 'admin' ? _adminItems : _clientItems;

  void _onSelect(int index) {
    setState(() => _selectedIndex = index);
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1000;
        final items = _items;
        if (items.isEmpty || _loadingRole) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final safeIndex = _selectedIndex.clamp(0, items.length - 1);
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            titleSpacing: isWide ? AppSpacing.lg : null,
            title: Row(
              children: [
                const Icon(Icons.hotel_class_outlined),
                const SizedBox(width: AppSpacing.sm),
                const Text('Gestion Hotel'),
                const SizedBox(width: AppSpacing.md),
                if (!isWide) const SizedBox(),
              ],
            ),
            actions: [
              // DEV: Bouton d'accès rapide aux outils de développement
              IconButton(
                icon: const Icon(Icons.build, color: Colors.orange),
                tooltip: '🔧 Outils de développement',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DevAdminToolsPage()),
                  );
                },
              ),
              IconButton(
                icon: Icon(widget.currentThemeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
                tooltip: 'Changer de theme',
                onPressed: () {
                  final next = widget.currentThemeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                  widget.onThemeModeChanged(next);
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Se deconnecter',
                onPressed: () async => _auth.signOut(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: const Icon(Icons.person, color: AppColors.primary, size: 18),
                ),
              ),
            ],
          ),
          bottomNavigationBar: isWide
              ? null
              : NavigationBar(
                  selectedIndex: safeIndex,
                  onDestinationSelected: _onSelect,
                  destinations: [
                    for (final item in items)
                      NavigationDestination(
                        icon: Icon(item.icon),
                        label: item.label,
                      ),
                  ],
                ),
          body: Row(
            children: [
              if (isWide)
                Container(
                  width: 240,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(right: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
                  ),
                  child: _NavigationList(items: items, selectedIndex: safeIndex, onSelect: _onSelect),
                ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: items[safeIndex].builder(context, _onSelect),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavigationList extends StatelessWidget {
  final List<_NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _NavigationList({
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemBuilder: (context, index) {
        final item = items[index];
        final selected = index == selectedIndex;
        return ListTile(
          leading: Icon(item.icon, color: selected ? AppColors.primary : AppColors.textSecondary),
          title: Text(item.label, style: AppTextStyles.body2.copyWith(color: selected ? AppColors.primary : null)),
          selected: selected,
          selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allMd),
          onTap: () => onSelect(index),
        );
      },
      separatorBuilder: (context, _) => const SizedBox(height: AppSpacing.xs),
      itemCount: items.length,
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final Widget Function(BuildContext, void Function(int)) builder;
  const _NavItem({required this.label, required this.icon, required this.builder});
}
