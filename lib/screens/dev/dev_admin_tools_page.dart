import 'package:flutter/material.dart';
import 'package:gestion_hotel/services/auth_service.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/models/hotel.dart';
import 'package:gestion_hotel/models/room.dart';

class DevAdminToolsPage extends StatefulWidget {
  const DevAdminToolsPage({super.key});

  @override
  State<DevAdminToolsPage> createState() => _DevAdminToolsPageState();
}

class _DevAdminToolsPageState extends State<DevAdminToolsPage> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  bool _loading = false;

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 5 : 3),
      ),
    );
  }

  Future<void> _makeCurrentUserAdmin() async {
    setState(() => _loading = true);
    
    try {
      final user = _authService.currentUser;
      if (user == null) {
        _showMessage('Aucun utilisateur connecté', isError: true);
        return;
      }

      // Update user role to admin directly in Firestore
      await _firestoreService.updateUserRole(user.uid, 'admin');
      
      _showMessage('✅ Utilisateur ${user.email} est maintenant ADMIN');
      print('🔑 Utilisateur ${user.uid} (${user.email}) est maintenant admin');
    } catch (e) {
      _showMessage('Erreur: $e', isError: true);
      print('❌ Erreur lors de la mise à jour du rôle: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _createSampleData() async {
    setState(() => _loading = true);
    
    try {
      // Create sample hotels
      final hotel1 = Hotel(
        name: 'Hôtel Royal Casablanca',
        city: 'Casablanca',
        country: 'Maroc',
        address: '123 Boulevard Hassan II, Casablanca',
        rating: 4.5,
        price: 150.0,
      );

      final hotel2 = Hotel(
        name: 'Grand Hôtel Marrakech',
        city: 'Marrakech', 
        country: 'Maroc',
        address: '456 Avenue Mohammed V, Marrakech',
        rating: 4.8,
        price: 200.0,
      );

      print('🏨 Création des hôtels de test...');
      final hotel1Id = await _firestoreService.addHotel(hotel1);
      final hotel2Id = await _firestoreService.addHotel(hotel2);
      print('✅ Hôtels créés: $hotel1Id, $hotel2Id');

      // Create sample rooms for hotel1
      final rooms = [
        Room(
          hotelId: hotel1Id,
          number: 101,
          type: 'Standard',
          view: 'Ville',
          basePrice: 100,
          viewExtra: 20,
          capacity: 2,
        ),
        Room(
          hotelId: hotel1Id,
          number: 201,
          type: 'Deluxe',
          view: 'Mer',
          basePrice: 150,
          viewExtra: 50,
          capacity: 3,
        ),
        Room(
          hotelId: hotel2Id,
          number: 301,
          type: 'Suite',
          view: 'Montagne',
          basePrice: 200,
          viewExtra: 80,
          capacity: 4,
        ),
      ];

      print('🛏️ Création des chambres de test...');
      for (final room in rooms) {
        await _firestoreService.addRoom(room);
      }
      print('✅ ${rooms.length} chambres créées');

      _showMessage('✅ Données de test créées: 2 hôtels et ${rooms.length} chambres');
    } catch (e) {
      _showMessage('Erreur: $e', isError: true);
      print('❌ Erreur lors de la création des données: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _checkCurrentUserStatus() async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        _showMessage('Aucun utilisateur connecté', isError: true);
        return;
      }

      final role = await _firestoreService.getUserRole(user.uid);
      
      final message = '''
Utilisateur connecté:
• Email: ${user.email}
• UID: ${user.uid}
• Rôle: $role
      ''';
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Statut utilisateur'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      print('👤 Statut utilisateur: ${user.email} ($role)');
    } catch (e) {
      _showMessage('Erreur: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔧 Outils de développement Admin'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚠️ OUTILS DE DÉVELOPPEMENT',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    SizedBox(height: 8),
                    Text('Ces outils permettent de configurer rapidement l\'environnement de test.'),
                    Text('À utiliser uniquement en développement !'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            ElevatedButton.icon(
              onPressed: _loading ? null : _checkCurrentUserStatus,
              icon: const Icon(Icons.person_search),
              label: const Text('Vérifier le statut de l\'utilisateur actuel'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: _loading ? null : _makeCurrentUserAdmin,
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text('Faire de l\'utilisateur actuel un ADMIN'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: _loading ? null : _createSampleData,
              icon: const Icon(Icons.data_object),
              label: const Text('Créer des données de test (hôtels + chambres)'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            ),
            
            if (_loading) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}