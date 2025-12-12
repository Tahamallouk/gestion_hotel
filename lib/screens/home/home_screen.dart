import 'package:flutter/material.dart';
import 'package:gestion_hotel/services/auth_service.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/screens/reservations/my_reservations_screen.dart';
import 'package:gestion_hotel/screens/reservations/admin_reservations_screen.dart';
import 'package:gestion_hotel/screens/admin/admin_dashboard_screen.dart';
import '../hotels/list_hotels_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(ThemeMode)? onThemeModeChanged;
  final ThemeMode? currentThemeMode;

  const HomeScreen({
    super.key,
    this.onThemeModeChanged,
    this.currentThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final userEmail = auth.currentUser?.email ?? 'Utilisateur';
    final FirestoreService firestore = FirestoreService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (onThemeModeChanged != null)
            IconButton(
              icon: Icon(
                currentThemeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              tooltip: 'Changer de thème',
              onPressed: () {
                final newMode = currentThemeMode == ThemeMode.dark
                    ? ThemeMode.light
                    : ThemeMode.dark;
                onThemeModeChanged!(newMode);
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
            onPressed: () async {
              await auth.signOut();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Welcome card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bienvenue!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userEmail,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              /// Section Title
              const Text(
                'Explorez nos hôtels',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              /// Hotels button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ListHotelsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.hotel_outlined),
                  label: const Text('Voir tous les hôtels'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyReservationsScreen()),
                    );
                  },
                  icon: const Icon(Icons.book_online),
                  label: const Text('Mes réservations'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),

              const SizedBox(height: 12),
              FutureBuilder<String?>(
                future: firestore.getUserRole(auth.currentUser?.uid ?? ''),
                builder: (context, snap) {
                  if (!snap.hasData) return const SizedBox.shrink();
                  if (snap.data == 'admin') {
                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (c) => const AdminDashboardScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.dashboard),
                            label: const Text('Tableau de bord admin'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (c) => const AdminReservationsScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.admin_panel_settings),
                            label: const Text('Admin - Réservations'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 24),

              /// Quick stats (placeholder)
              const Text(
                'Statistiques rapides',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              /// Stats grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _StatCard(
                    icon: Icons.hotel,
                    title: 'Hôtels',
                    count: '15',
                  ),
                  _StatCard(
                    icon: Icons.bed,
                    title: 'Chambres',
                    count: '245',
                  ),
                  _StatCard(
                    icon: Icons.calendar_today,
                    title: 'Réservations',
                    count: '48',
                  ),
                  _StatCard(
                    icon: Icons.star,
                    title: 'Rating',
                    count: '4.5',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String count;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              count,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
