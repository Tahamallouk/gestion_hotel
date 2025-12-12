import 'package:flutter/material.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/services/auth_service.dart';
import 'package:gestion_hotel/widgets/stat_card_advanced.dart';

/// Admin Hotel Detail Screen - Detailed view of a single hotel
class AdminHotelDetailScreen extends StatefulWidget {
  final String hotelId;
  final String hotelName;

  const AdminHotelDetailScreen({
    super.key,
    required this.hotelId,
    required this.hotelName,
  });

  @override
  State<AdminHotelDetailScreen> createState() => _AdminHotelDetailScreenState();
}

class _AdminHotelDetailScreenState extends State<AdminHotelDetailScreen> {
  final FirestoreService _firestore = FirestoreService();
  final AuthService _auth = AuthService();

  bool _isLoading = true;
  String? _errorMessage;

  // Hotel data
  Map<String, dynamic>? _hotelData;
  int _totalRooms = 0;
  int _occupiedRooms = 0;
  int _totalReservations = 0;
  double _occupancyRate = 0.0;

  @override
  void initState() {
    super.initState();
    _checkAdminAndLoadData();
  }

  Future<void> _checkAdminAndLoadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        if (!mounted) return;
        Navigator.pop(context);
        return;
      }

      final role = await _firestore.getUserRole(uid);
      if (role != 'admin') {
        if (!mounted) return;
        Navigator.pop(context);
        return;
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      await _loadHotelData();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erreur: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadHotelData() async {
    try {
      final hotelData = await _firestore.getHotelDetails(widget.hotelId);
      if (!mounted) return;

      setState(() {
        _hotelData = hotelData;
        _totalRooms = hotelData?['totalRooms'] ?? 0;
        _occupiedRooms = hotelData?['occupiedRooms'] ?? 0;
        _totalReservations = hotelData?['totalReservations'] ?? 0;
        _occupancyRate = _totalRooms > 0 ? (_occupiedRooms / _totalRooms) * 100 : 0.0;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erreur: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteHotel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'hôtel'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${widget.hotelName}" ? Cette action supprimera toutes les chambres et réservations.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _firestore.deleteHotel(widget.hotelId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hôtel supprimé avec succès')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erreur lors de la suppression: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détail de l\'hôtel')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détail de l\'hôtel')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadHotelData,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hotelName),
        elevation: 0,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 12),
                    Text('Modifier'),
                  ],
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fonctionnalité non implémentée')),
                  );
                },
              ),
              PopupMenuItem(
                onTap: _deleteHotel,
                child: const Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Supprimer', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hôtel info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.hotelName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_hotelData?['address'] != null)
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _hotelData!['address'] as String? ?? '',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    if (_hotelData?['phone'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.phone, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              _hotelData!['phone'] as String? ?? '',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Key Metrics
            const Text(
              'Statistiques',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                StatCardAdvanced(
                  title: 'Chambres',
                  value: _totalRooms.toString(),
                  icon: Icons.hotel,
                  color: Colors.blue,
                  subtitle: 'Total',
                ),
                StatCardAdvanced(
                  title: 'Occupées',
                  value: _occupiedRooms.toString(),
                  icon: Icons.lock,
                  color: Colors.orange,
                  subtitle: 'En ce moment',
                ),
                StatCardAdvanced(
                  title: 'Taux d\'occupation',
                  value: '${_occupancyRate.toStringAsFixed(1)}%',
                  icon: Icons.percent,
                  color: Colors.green,
                  subtitle: 'Aujourd\'hui',
                ),
                StatCardAdvanced(
                  title: 'Réservations',
                  value: _totalReservations.toString(),
                  icon: Icons.calendar_today,
                  color: Colors.purple,
                  subtitle: 'Total',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Actions
            const Text(
              'Actions rapides',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Voir les réservations - À implémenter')),
                  );
                },
                icon: const Icon(Icons.calendar_month),
                label: const Text('Voir les réservations'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ajouter une chambre - À implémenter')),
                  );
                },
                icon: const Icon(Icons.add_location),
                label: const Text('Ajouter une chambre'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
