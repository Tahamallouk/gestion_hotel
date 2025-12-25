import 'package:flutter/material.dart';
import 'package:gestion_hotel/screens/reservations/reservation_management_screen.dart';
import 'package:gestion_hotel/screens/reservations/quick_checkin_screen.dart';
import 'package:gestion_hotel/screens/reservations/admin_reservations_screen.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/app_card.dart';
import 'package:gestion_hotel/widgets/reservation_stats_widget.dart';

class ReservationAdminDashboard extends StatefulWidget {
  const ReservationAdminDashboard({super.key});

  @override
  State<ReservationAdminDashboard> createState() => _ReservationAdminDashboardState();
}

class _ReservationAdminDashboardState extends State<ReservationAdminDashboard> {
  int _selectedIndex = 0;

  final List<_AdminPage> _pages = [
    _AdminPage(
      title: 'Aperçu',
      icon: Icons.dashboard,
      widget: const _OverviewTab(),
    ),
    _AdminPage(
      title: 'Check-In/Out',
      icon: Icons.login,
      widget: const QuickCheckInScreen(),
    ),
    _AdminPage(
      title: 'Gestion QR',
      icon: Icons.qr_code_scanner,
      widget: const ReservationManagementScreen(),
    ),
    _AdminPage(
      title: 'Toutes les réservations',
      icon: Icons.list,
      widget: const AdminReservationsScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration Réservations'),
        elevation: 0,
      ),
      body: Row(
        children: [
          // Navigation rail for larger screens
          if (MediaQuery.of(context).size.width > 800)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: _pages
                  .map((page) => NavigationRailDestination(
                        icon: Icon(page.icon),
                        label: Text(page.title),
                      ))
                  .toList(),
            ),
          
          // Main content
          Expanded(
            child: _pages[_selectedIndex].widget,
          ),
        ],
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width <= 800
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              items: _pages
                  .map((page) => BottomNavigationBarItem(
                        icon: Icon(page.icon),
                        label: page.title,
                      ))
                  .toList(),
            )
          : null,
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics section
          const ReservationStatsWidget(),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Quick actions section
          Text(
            'Actions Rapides',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.2,
            children: [
              _QuickActionCard(
                title: 'Check-In/Out',
                subtitle: 'Gérer les arrivées et départs',
                icon: Icons.login,
                color: Colors.blue,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const QuickCheckInScreen(),
                    ),
                  );
                },
              ),
              _QuickActionCard(
                title: 'Scanner QR',
                subtitle: 'Rechercher par QR code',
                icon: Icons.qr_code_scanner,
                color: Colors.green,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ReservationManagementScreen(),
                    ),
                  );
                },
              ),
              _QuickActionCard(
                title: 'Toutes les réservations',
                subtitle: 'Vue d\'ensemble complète',
                icon: Icons.list,
                color: Colors.purple,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AdminReservationsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Tips and help section
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Conseils d\'utilisation',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _buildTip(
                  context,
                  'Check-In rapide',
                  'Utilisez l\'onglet "Check-In/Out" pour gérer rapidement les arrivées et départs du jour.',
                ),
                _buildTip(
                  context,
                  'Recherche QR',
                  'Scannez ou saisissez un code QR de réservation pour accéder instantanément aux détails.',
                ),
                _buildTip(
                  context,
                  'Statuts de réservation',
                  'Les statuts évoluent : Pending → Confirmed → CheckedIn → CheckedOut',
                ),
                _buildTip(
                  context,
                  'Gestion des chambres',
                  'Le changement de statut met automatiquement à jour la disponibilité des chambres.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AdminPage {
  final String title;
  final IconData icon;
  final Widget widget;

  _AdminPage({
    required this.title,
    required this.icon,
    required this.widget,
  });
}