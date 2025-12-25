import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestion_hotel/models/hotel.dart';
import 'package:gestion_hotel/screens/admin/admin_dashboard_screen.dart';
import 'package:gestion_hotel/screens/reservations/admin_reservations_screen.dart';
import 'package:gestion_hotel/screens/rooms/list_rooms_screen.dart';
import 'package:gestion_hotel/screens/hotels/list_hotels_screen.dart';
import 'package:gestion_hotel/screens/admin/hotels/add_hotel_screen.dart';
import 'package:gestion_hotel/services/auth_service.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/utils/app_theme.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Espace Administration'),
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            onPressed: _checkAdminRole,
            tooltip: 'Vérifier les droits',
            icon: const Icon(Icons.verified_user_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.all(AppBorderRadius.lg),
                  boxShadow: AppShadows.medium,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: const BorderRadius.all(AppBorderRadius.md),
                      ),
                      child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bienvenue, administrateur', style: AppTextStyles.subtitle1.copyWith(color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(
                            'Gérez les hôtels, chambres et réservations depuis un hub clair.',
                            style: AppTextStyles.body2.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: GridView.count(
                  crossAxisCount: ResponsiveHelper.isTablet(context) ? 2 : 1,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: ResponsiveHelper.isTablet(context) ? 2.4 : 2.1,
                  children: [
                    _AdminMenuItem(
                      icon: Icons.dashboard_outlined,
                      title: 'Tableau de bord',
                      description: 'Vue globale des KPI, top hôtels et tendances',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                      ),
                    ),
                    _AdminMenuItem(
                      icon: Icons.hotel,
                      title: 'Hôtels',
                      description: 'Lister, ajouter et consulter les hôtels',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ListHotelsScreen()),
                      ),
                      trailing: TextButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddHotelScreen()),
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Ajouter'),
                      ),
                    ),
                    _AdminMenuItem(
                      icon: Icons.door_front_door_outlined,
                      title: 'Chambres',
                      description: 'Surveiller la disponibilité et les tarifs',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ListRoomsScreen(
                            hotel: Hotel(name: 'N/A', city: '', address: ''),
                          ),
                        ),
                      ),
                    ),
                    _AdminMenuItem(
                      icon: Icons.calendar_month,
                      title: 'Réservations',
                      description: 'Filtrer, annuler et exporter les réservations',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminReservationsScreen()),
                      ),
                    ),
                    _AdminMenuItem(
                      icon: Icons.currency_exchange_outlined,
                      title: 'Convertisseur de devises',
                      description: 'Support international et conversion',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Scaffold(
                            appBar: AppBar(title: const Text('Convertisseur de Devises')),
                            body: const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: Text('Fonctionnalité en cours de développement'),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _AdminMenuItem(
                      icon: Icons.euro_outlined,
                      title: 'Éditeur de Prix',
                      description: 'Testez et convertissez les tarifs en temps réel',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Scaffold(
                            appBar: AppBar(title: const Text('Éditeur de Prix Interactif')),
                            body: const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: Text('Éditeur de prix en cours de développement'),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _AdminMenuItem(
                      icon: Icons.settings_outlined,
                      title: 'Paramètres',
                      description: 'Rôles, notifications et règles métiers',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Paramètres admin à venir')),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Déconnexion'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(AppBorderRadius.md),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
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
  final Widget? trailing;

  const _AdminMenuItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.quick,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(AppBorderRadius.lg),
        boxShadow: AppShadows.standard,
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(AppBorderRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryLight, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.subtitle1.copyWith(color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
              const Icon(Icons.arrow_forward_ios, color: AppColors.textTertiary, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
