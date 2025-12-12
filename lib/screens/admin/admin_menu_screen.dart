import 'package:flutter/material.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_dashboard_screen.dart';

/// Admin Menu Screen - Hub de navigation pour les fonctionnalités admin
class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  final FirestoreService _firestore = FirestoreService();
  final AuthService _auth = AuthService();
  bool _isAdmin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAdminRole();
  }

  Future<void> _checkAdminRole() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        if (!mounted) return;
        Navigator.pop(context);
        return;
      }

      final role = await _firestore.getUserRole(uid);
      if (!mounted) return;

      if (role != 'admin') {
        Navigator.pop(context);
      } else {
        setState(() => _isAdmin = true);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAdmin) {
      return const Scaffold(
        body: Center(child: Text('Accès refusé')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Administration'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header avec bienvenue
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenue Admin',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gérez votre système depuis ici',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Menu items
            Expanded(
              child: ListView(
                children: [
                  _AdminMenuItem(
                    icon: Icons.dashboard,
                    title: 'Tableau de bord',
                    description: 'Voir les statistiques et métriques',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => const AdminDashboardScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _AdminMenuItem(
                    icon: Icons.hotel,
                    title: 'Gestion des hôtels',
                    description: 'Ajouter, modifier, supprimer des hôtels',
                    onTap: () {
                      // TODO: Navigate to HotelsManagementScreen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('À venir...')),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _AdminMenuItem(
                    icon: Icons.door_sliding,
                    title: 'Gestion des chambres',
                    description: 'Ajouter, modifier, supprimer des chambres',
                    onTap: () {
                      // TODO: Navigate to RoomsManagementScreen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('À venir...')),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _AdminMenuItem(
                    icon: Icons.calendar_month,
                    title: 'Gestion des réservations',
                    description: 'Voir et gérer toutes les réservations',
                    onTap: () {
                      // TODO: Navigate to AdminReservationsScreen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('À venir...')),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _AdminMenuItem(
                    icon: Icons.people,
                    title: 'Gestion des utilisateurs',
                    description: 'Gérer les rôles et permissions',
                    onTap: () {
                      // TODO: Navigate to UsersManagementScreen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('À venir...')),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _AdminMenuItem(
                    icon: Icons.settings,
                    title: 'Paramètres admin',
                    description: 'Configurer les paramètres du système',
                    onTap: () {
                      // TODO: Navigate to AdminSettingsScreen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('À venir...')),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout button
            ElevatedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Déconnexion'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget pour un item du menu admin
class _AdminMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _AdminMenuItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue[50],
                ),
                child: Icon(icon, color: Colors.blue, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
