import 'package:flutter/material.dart';
import 'package:gestion_hotel/services/admin_service.dart';
import 'package:gestion_hotel/models/hotel.dart';
import 'package:gestion_hotel/models/room.dart';

class AdminRoomsManagementPageSimple extends StatefulWidget {
  const AdminRoomsManagementPageSimple({super.key});

  @override
  State<AdminRoomsManagementPageSimple> createState() => _AdminRoomsManagementPageSimpleState();
}

class _AdminRoomsManagementPageSimpleState extends State<AdminRoomsManagementPageSimple> {
  final _adminService = AdminService();
  List<Hotel> _hotels = [];
  List<Room> _rooms = [];
  String? _selectedHotelId;
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
      
      setState(() {
        _hotels = hotels;
        _loading = false;
        
        // Sélectionner automatiquement le premier hôtel
        if (hotels.isNotEmpty && _selectedHotelId == null) {
          _selectedHotelId = hotels.first.id;
          _loadRooms(_selectedHotelId!);
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadRooms(String hotelId) async {
    if (hotelId.startsWith('mock-')) {
      debugPrint('⚠️ Tentative de chargement de chambres pour hôtel mock: $hotelId');
      setState(() {
        _rooms = [];
        _loading = false;
      });
      return;
    }
    
    setState(() => _loading = true);
    debugPrint('📖 Chargement chambres pour hotelId: $hotelId');
    
    try {
      _adminService.getRoomsByHotel(hotelId).listen(
        (rooms) {
          if (mounted) {
            debugPrint('✅ Chambres chargées: ${rooms.length} pour hotelId: $hotelId');
            setState(() {
              _rooms = rooms;
              _loading = false;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _error = error.toString();
              _loading = false;
              _rooms = [];
            });
          }
        },
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
        _rooms = [];
      });
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
        title: const Text('Gestion des Chambres'),
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
            // Header avec sélection d'hôtel
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chambres par Hôtel',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _selectedHotelId == null || _loading ? null : _showAddRoomDialog,
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

            // Sélecteur d'hôtel amélioré
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedHotelId,
                  hint: const Row(
                    children: [
                      Icon(Icons.hotel, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Sélectionner un hôtel pour gérer ses chambres'),
                    ],
                  ),
                  items: _hotels.map((hotel) {
                    return DropdownMenuItem<String>(
                      value: hotel.id,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.hotel, size: 20),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  hotel.name,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${hotel.city} - ${hotel.price.toInt()} MAD',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: _loading ? null : (value) {
                    if (value != null) {
                      setState(() {
                        _selectedHotelId = value;
                        _rooms = [];
                      });
                      _loadRooms(value);
                    }
                  },
                ),
              ),
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
                      : _selectedHotelId == null
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.hotel, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'Sélectionnez un hôtel pour voir ses chambres',
                                    style: TextStyle(fontSize: 18, color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : _rooms.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.bed, size: 64, color: Colors.grey),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Aucune chambre trouvée',
                                        style: TextStyle(fontSize: 18, color: Colors.grey),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        onPressed: _showAddRoomDialog,
                                        icon: const Icon(Icons.add),
                                        label: const Text('Ajouter la première chambre'),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _rooms.length,
                                  itemBuilder: (context, index) {
                                    final room = _rooms[index];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: room.isAvailable ? Colors.green : Colors.red,
                                          child: const Icon(
                                            Icons.bed,
                                            color: Colors.white,
                                          ),
                                        ),
                                        title: Text(
                                          '${room.type} ${room.number}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          '${room.isAvailable ? "Disponible" : "Occupée"} • ${room.capacity} personnes',
                                        ),
                                        trailing: Text(
                                          '${room.basePrice} MAD',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                        onTap: () => _showRoomDetails(room),
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

  void _showAddRoomDialog() {
    // Validation stricte du hotelId
    if (_selectedHotelId == null || _selectedHotelId!.isEmpty) {
      _showMessage('Erreur: Aucun hôtel sélectionné', Colors.red);
      return;
    }
    
    // Bloquer les hôtels mock
    if (_selectedHotelId!.startsWith('mock-')) {
      _showMessage('Impossible d\'ajouter des chambres aux hôtels de démo', Colors.orange);
      return;
    }

    // Trouver l'hôtel sélectionné pour afficher son nom
    final selectedHotel = _hotels.firstWhere(
      (hotel) => hotel.id == _selectedHotelId,
      orElse: () => Hotel(
        name: 'Hôtel sélectionné',
        city: '',
        country: '',
        address: '',
        rating: 0,
        price: 0,
      ),
    );
    
    // Double vérification que l'hôtel existe
    if (selectedHotel.name == 'Hôtel sélectionné') {
      _showMessage('Erreur: Hôtel introuvable dans la liste', Colors.red);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _AddRoomDialog(
        hotelId: _selectedHotelId!,
        hotelName: selectedHotel.name,
        onRoomAdded: () {
          _loadRooms(_selectedHotelId!); // Rafraîchir la liste
        },
      ),
    );
  }

  void _showRoomDetails(Room room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${room.type} ${room.number}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('👥 Capacité: ${room.capacity} personnes'),
            Text('💰 Prix: ${room.basePrice} MAD/nuit'),
            Text('📋 Statut: ${room.isAvailable ? "Disponible" : "Occupée"}'),
            Text('👁️ Vue: ${room.view.isNotEmpty ? room.view : "Standard"}'),
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

class _AddRoomDialog extends StatefulWidget {
  final String hotelId;
  final String hotelName;
  final VoidCallback onRoomAdded;

  const _AddRoomDialog({
    required this.hotelId,
    required this.hotelName,
    required this.onRoomAdded,
  });

  @override
  State<_AddRoomDialog> createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends State<_AddRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _adminService = AdminService();
  final _numberController = TextEditingController();
  final _basePriceController = TextEditingController();
  String _selectedType = 'Simple';
  String _selectedView = 'Standard';
  int _capacity = 1;
  bool _isLoading = false;

  final List<String> _roomTypes = ['Simple', 'Double', 'Triple', 'Suite', 'Deluxe'];
  final List<String> _viewTypes = ['Standard', 'Jardin', 'Piscine', 'Mer', 'Ville'];
  final List<int> _capacityOptions = [1, 2, 3, 4, 5, 6];

  @override
  void dispose() {
    _numberController.dispose();
    _basePriceController.dispose();
    super.dispose();
  }

  Future<void> _saveRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Vérifier que l'utilisateur est admin
      final isAdmin = await _adminService.isCurrentUserAdmin();
      if (!isAdmin) {
        throw Exception('Accès refusé - Seuls les administrateurs peuvent ajouter des chambres');
      }
      
      // VALIDATION CRITIQUE: Vérifier que hotelId n'est pas null
      if (widget.hotelId.isEmpty) {
        throw Exception('Erreur système: hotelId manquant');
      }
      
      // VALIDATION CRITIQUE: Bloquer les hotelId mock
      if (widget.hotelId.startsWith('mock-')) {
        throw Exception('Impossible d\'ajouter des chambres aux hôtels de démonstration');
      }

      // Créer l'objet chambre avec hotelId explicite et sécurisé
      final room = Room(
        hotelId: widget.hotelId, // hotelId explicitement validé
        number: int.parse(_numberController.text.trim()),
        type: _selectedType,
        view: _selectedView,
        basePrice: int.parse(_basePriceController.text.trim()),
        viewExtra: 0,
        capacity: _capacity,
        isAvailable: true,
      );
      
      // DEBUG: Afficher les détails avant sauvegarde
      debugPrint('🛏️ Création chambre: hotelId=${room.hotelId}, number=${room.number}');

      // Sauvegarder dans Firestore avec le hotelId validé
      await _adminService.createRoom(room);

      // Succès avec détails de confirmation
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chambre n°${room.number} créée avec succès pour "${widget.hotelName}" (ID: ${room.hotelId})'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
        
        // DEBUG: Confirmer l'association
        debugPrint('✅ Chambre ${room.number} ajoutée à l\'hôtel ${room.hotelId}');
        
        widget.onRoomAdded(); // Rafraîchir la liste des chambres filtrées par hotelId
      }
    } catch (e) {
      // Erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🛏️ Ajouter une chambre',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.hotel,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  'Pour: ${widget.hotelName}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 450,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Numéro de chambre
                TextFormField(
                  controller: _numberController,
                  decoration: const InputDecoration(
                    labelText: 'Numéro de chambre *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.door_front_door),
                    helperText: 'Numéro unique pour cette chambre',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le numéro est obligatoire';
                    }
                    final number = int.tryParse(value.trim());
                    if (number == null || number <= 0) {
                      return 'Numéro invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Type de chambre
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type de chambre',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.bed),
                  ),
                  items: _roomTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                      // Ajuster automatiquement la capacité selon le type
                      switch (value) {
                        case 'Simple':
                          _capacity = 1;
                          break;
                        case 'Double':
                          _capacity = 2;
                          break;
                        case 'Triple':
                          _capacity = 3;
                          break;
                        case 'Suite':
                        case 'Deluxe':
                          _capacity = 4;
                          break;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Vue
                DropdownButtonFormField<String>(
                  initialValue: _selectedView,
                  decoration: const InputDecoration(
                    labelText: 'Vue',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.visibility),
                  ),
                  items: _viewTypes.map((view) {
                    return DropdownMenuItem(
                      value: view,
                      child: Text(view),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedView = value!);
                  },
                ),
                const SizedBox(height: 16),

                // Capacité
                DropdownButtonFormField<int>(
                  initialValue: _capacity,
                  decoration: const InputDecoration(
                    labelText: 'Capacité (personnes)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.people),
                  ),
                  items: _capacityOptions.map((capacity) {
                    return DropdownMenuItem(
                      value: capacity,
                      child: Text('$capacity ${capacity == 1 ? "personne" : "personnes"}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _capacity = value!);
                  },
                ),
                const SizedBox(height: 16),

                // Prix de base
                TextFormField(
                  controller: _basePriceController,
                  decoration: const InputDecoration(
                    labelText: 'Prix par nuit (MAD) *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                    suffixText: 'MAD',
                    helperText: 'Prix de base par nuit',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le prix est obligatoire';
                    }
                    final price = int.tryParse(value.trim());
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
          onPressed: _isLoading ? null : _saveRoom,
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