import 'package:flutter/material.dart';
import 'package:gestion_hotel/services/admin_service.dart';
import 'package:gestion_hotel/models/hotel.dart';

class AdminHotelsManagementPageSimple extends StatefulWidget {
  const AdminHotelsManagementPageSimple({super.key});

  @override
  State<AdminHotelsManagementPageSimple> createState() => _AdminHotelsManagementPageSimpleState();
}

class _AdminHotelsManagementPageSimpleState extends State<AdminHotelsManagementPageSimple> {
  final _adminService = AdminService();
  List<Hotel> _hotels = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHotels();
  }

  Future<void> _loadHotels() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final isAdmin = await _adminService.isCurrentUserAdmin();
      if (!isAdmin) {
        throw Exception('Accès refusé - Admin requis');
      }
      
      final hotels = await _adminService.getHotels();
      
      // Si aucun hôtel, créer des données de test
      if (hotels.isEmpty) {
        await _createSampleHotels();
        final newHotels = await _adminService.getHotels();
        setState(() {
          _hotels = newHotels;
          _loading = false;
        });
        _showMessage('Données de test créées!', Colors.green);
      } else {
        setState(() {
          _hotels = hotels;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _createSampleHotels() async {
    try {
      final hotel1 = Hotel(
        name: 'Hôtel Royal Casablanca',
        city: 'Casablanca',
        country: 'Maroc',
        address: '123 Boulevard Hassan II',
        rating: 4.5,
        price: 150.0,
      );

      final hotel2 = Hotel(
        name: 'Grand Hôtel Marrakech',
        city: 'Marrakech',
        country: 'Maroc',
        address: '456 Avenue Mohammed V',
        rating: 4.8,
        price: 200.0,
      );

      await _adminService.createHotel(hotel1);
      await _adminService.createHotel(hotel2);
    } catch (e) {
      print('Erreur création sample: $e');
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Hôtels'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHotels,
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mes Hôtels',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _loading ? null : _showAddHotelDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Content
            Expanded(
              child: _loading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Chargement...'),
                        ],
                      ),
                    )
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error, size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                'Erreur: $_error',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadHotels,
                                child: const Text('Réessayer'),
                              ),
                            ],
                          ),
                        )
                      : _hotels.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.hotel, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'Aucun hôtel trouvé',
                                    style: TextStyle(fontSize: 18, color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _hotels.length,
                              itemBuilder: (context, index) {
                                final hotel = _hotels[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      child: const Icon(Icons.hotel, color: Colors.white),
                                    ),
                                    title: Text(
                                      hotel.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text('${hotel.city}, ${hotel.country}'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.star, color: Colors.amber, size: 16),
                                        Text(' ${hotel.rating}'),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${hotel.price.toInt()} MAD',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () => _showHotelDetails(hotel),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddHotelDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddHotelDialog(
        onHotelAdded: () {
          _loadHotels(); // Rafraîchir la liste
        },
      ),
    );
  }

  void _showHotelDetails(Hotel hotel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(hotel.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📍 ${hotel.address}'),
            Text('🌍 ${hotel.city}, ${hotel.country}'),
            Text('⭐ ${hotel.rating}/5'),
            Text('💰 ${hotel.price.toInt()} MAD/nuit'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

class _AddHotelDialog extends StatefulWidget {
  final VoidCallback onHotelAdded;

  const _AddHotelDialog({required this.onHotelAdded});

  @override
  State<_AddHotelDialog> createState() => _AddHotelDialogState();
}

class _AddHotelDialogState extends State<_AddHotelDialog> {
  final _formKey = GlobalKey<FormState>();
  final _adminService = AdminService();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveHotel() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Vérifier que l'utilisateur est admin
      final isAdmin = await _adminService.isCurrentUserAdmin();
      if (!isAdmin) {
        throw Exception('Accès refusé - Seuls les administrateurs peuvent ajouter des hôtels');
      }

      // Créer l'objet hôtel
      final hotel = Hotel(
        name: _nameController.text.trim(),
        city: _cityController.text.trim(),
        country: _countryController.text.trim().isEmpty 
            ? 'Maroc' 
            : _countryController.text.trim(),
        address: _addressController.text.trim(),
        rating: 4.0,
        price: double.tryParse(_priceController.text.trim()) ?? 100.0,
      );

      // Sauvegarder dans Firestore
      await _adminService.createHotel(hotel);

      // Succès
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hôtel "${hotel.name}" créé avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onHotelAdded(); // Rafraîchir la liste
      }
    } catch (e) {
      // Erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        '➕ Ajouter un hôtel',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nom de l'hôtel
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de l\'hôtel *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.hotel),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le nom est obligatoire';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Ville
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'Ville *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La ville est obligatoire';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Pays (optionnel, défaut = Maroc)
                TextFormField(
                  controller: _countryController,
                  decoration: const InputDecoration(
                    labelText: 'Pays (défaut: Maroc)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.flag),
                  ),
                ),
                const SizedBox(height: 16),

                // Adresse
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Adresse *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'L\'adresse est obligatoire';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Prix
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Prix par nuit (MAD) *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                    suffixText: 'MAD',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le prix est obligatoire';
                    }
                    final price = double.tryParse(value.trim());
                    if (price == null || price <= 0) {
                      return 'Prix invalide';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        // Bouton Annuler
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        
        // Bouton Enregistrer
        ElevatedButton(
          onPressed: _isLoading ? null : _saveHotel,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('💾 Enregistrer'),
        ),
      ],
    );
  }
}