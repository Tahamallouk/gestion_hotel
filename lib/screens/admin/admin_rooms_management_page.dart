import 'package:flutter/material.dart';
import 'package:gestion_hotel/services/admin_service.dart';
import 'package:gestion_hotel/models/hotel.dart';
import 'package:gestion_hotel/models/room.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/app_card.dart';
import 'package:gestion_hotel/widgets/section_header.dart';

class AdminRoomsManagementPage extends StatefulWidget {
  const AdminRoomsManagementPage({super.key});

  @override
  State<AdminRoomsManagementPage> createState() => _AdminRoomsManagementPageState();
}

class _AdminRoomsManagementPageState extends State<AdminRoomsManagementPage> {
  final _adminService = AdminService();
  List<Hotel> _hotels = [];
  String? _selectedHotelId;
  List<Room> _rooms = [];
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
        throw Exception('Vous n\'êtes pas connecté en tant qu\'administrateur');
      }
      
      final hotels = await _adminService.getHotels();
      print('🏨 Hôtels trouvés pour les chambres: ${hotels.length}');
      
      if (mounted) {
        setState(() {
          _hotels = hotels;
          _loading = false;
          // Sélectionner automatiquement le premier hôtel s'il y en a
          if (hotels.isNotEmpty && _selectedHotelId == null) {
            _selectedHotelId = hotels.first.id;
            if (_selectedHotelId != null) {
              _loadRooms(_selectedHotelId!);
            }
          }
        });
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des hôtels: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
        _showError(e.toString());
      }
    }
  }

  void _onHotelSelected(String? hotelId) {
    setState(() {
      _selectedHotelId = hotelId;
      _rooms = [];
    });
    
    if (hotelId != null && !hotelId.startsWith('mock-')) {
      _loadRooms(hotelId);
    }
  }

  void _loadRooms(String hotelId) {
    if (hotelId.startsWith('mock-')) {
      print('⚠️ Hôtel mock ignoré: $hotelId');
      setState(() {
        _rooms = [];
        _loading = false;
      });
      return;
    }
    
    setState(() => _loading = true);
    
    try {
      _adminService.getRoomsByHotel(hotelId).listen(
        (rooms) {
          print('🛏️ Chambres trouvées pour $hotelId: ${rooms.length}');
          if (mounted) {
            setState(() {
              _rooms = rooms;
              _loading = false;
            });
          }
        },
        onError: (error) {
          print('❌ Erreur chambres pour $hotelId: $error');
          if (mounted) {
            setState(() {
              _error = error.toString();
              _loading = false;
              _rooms = []; // Vider la liste en cas d'erreur
            });
            _showError('Erreur lors du chargement des chambres: $error');
          }
        },
      );
    } catch (e) {
      print('❌ Erreur inattendue: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
          _rooms = [];
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _createRoom() async {
    if (_selectedHotelId == null) {
      _showError('Veuillez sélectionner un hôtel d\'abord');
      return;
    }

    final result = await showDialog<Room>(
      context: context,
      builder: (context) => _RoomFormDialog(hotelId: _selectedHotelId!),
    );

    if (result != null) {
      setState(() => _loading = true);
      try {
        await _adminService.createRoom(result);
        _showSuccess('Chambre ${result.number} créée avec succès');
        // Rooms will reload automatically via stream
      } catch (e) {
        _showError('Erreur lors de la création: ${e.toString()}');
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _editRoom(Room room) async {
    final result = await showDialog<Room>(
      context: context,
      builder: (context) => _RoomFormDialog(room: room),
    );

    if (result != null && room.id != null) {
      setState(() => _loading = true);
      try {
        await _adminService.updateRoom(room.id!, {
          'number': result.number,
          'type': result.type,
          'view': result.view,
          'basePrice': result.basePrice,
          'viewExtra': result.viewExtra,
          'capacity': result.capacity,
          'isAvailable': result.isAvailable,
        });
        _showSuccess('Chambre ${result.number} mise à jour');
        // Rooms will reload automatically via stream
      } catch (e) {
        _showError('Erreur lors de la modification: ${e.toString()}');
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _deleteRoom(Room room) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer la chambre ${room.number} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && room.id != null) {
      setState(() => _loading = true);
      try {
        await _adminService.deleteRoom(room.id!);
        _showSuccess('Chambre ${room.number} supprimée');
        // Rooms will reload automatically via stream
      } catch (e) {
        _showError('Erreur lors de la suppression: ${e.toString()}');
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Chambres (Admin)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadHotels();
              if (_selectedHotelId != null) {
                _loadRooms(_selectedHotelId!);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel selection
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sélectionner un hôtel',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedHotelId,
                    decoration: const InputDecoration(
                      labelText: 'Hôtel',
                      border: OutlineInputBorder(),
                    ),
                    items: _hotels.map((hotel) {
                      return DropdownMenuItem(
                        value: hotel.id,
                        child: Text('${hotel.name} - ${hotel.city}'),
                      );
                    }).toList(),
                    onChanged: _onHotelSelected,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Rooms section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionHeader(title: 'Chambres'),
                ElevatedButton.icon(
                  onPressed: (_loading || _selectedHotelId == null) ? null : _createRoom,
                  icon: const Icon(Icons.add),
                  label: const Text('Créer une chambre'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            
            if (_error != null) ...[
              AppCard(
                child: ListTile(
                  leading: const Icon(Icons.error, color: Colors.red),
                  title: const Text('Erreur'),
                  subtitle: Text(_error!),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            if (_selectedHotelId == null) ...[
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hotel, size: 64, color: Colors.grey),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'Sélectionnez un hôtel',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        'Choisissez un hôtel pour voir ses chambres',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (_loading) ...[
              const Expanded(child: Center(child: CircularProgressIndicator())),
            ] else ...[
              Expanded(
                child: _rooms.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bed, size: 64, color: Colors.grey),
                            SizedBox(height: AppSpacing.md),
                            Text(
                              'Aucune chambre trouvée',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              'Créez la première chambre pour cet hôtel',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _rooms.length,
                        itemBuilder: (context, index) {
                          final room = _rooms[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: AppCard(
                            child: ListTile(
                              title: Text(
                                'Chambre ${room.number}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Type: ${room.type}'),
                                  if (room.view.isNotEmpty) Text('Vue: ${room.view}'),
                                  Text('Capacité: ${room.capacity} personnes'),
                                  Text('Prix de base: ${room.basePrice}€'),
                                  if (room.viewExtra > 0) Text('Supplément vue: ${room.viewExtra}€'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: room.isAvailable ? Colors.green : Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      room.isAvailable ? 'Disponible' : 'Occupée',
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                  PopupMenuButton(
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: ListTile(
                                          leading: Icon(Icons.edit),
                                          title: Text('Modifier'),
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: ListTile(
                                          leading: Icon(Icons.delete, color: Colors.red),
                                          title: Text('Supprimer', style: TextStyle(color: Colors.red)),
                                        ),
                                      ),
                                    ],
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'edit':
                                          _editRoom(room);
                                          break;
                                        case 'delete':
                                          _deleteRoom(room);
                                          break;
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                        },
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RoomFormDialog extends StatefulWidget {
  final Room? room;
  final String? hotelId;
  
  const _RoomFormDialog({this.room, this.hotelId});

  @override
  State<_RoomFormDialog> createState() => _RoomFormDialogState();
}

class _RoomFormDialogState extends State<_RoomFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _numberCtrl;
  late final TextEditingController _typeCtrl;
  late final TextEditingController _viewCtrl;
  late final TextEditingController _basePriceCtrl;
  late final TextEditingController _viewExtraCtrl;
  late final TextEditingController _capacityCtrl;
  late bool _isAvailable;

  @override
  void initState() {
    super.initState();
    final room = widget.room;
    _numberCtrl = TextEditingController(text: room?.number.toString() ?? '');
    _typeCtrl = TextEditingController(text: room?.type ?? '');
    _viewCtrl = TextEditingController(text: room?.view ?? '');
    _basePriceCtrl = TextEditingController(text: room?.basePrice.toString() ?? '');
    _viewExtraCtrl = TextEditingController(text: room?.viewExtra.toString() ?? '0');
    _capacityCtrl = TextEditingController(text: room?.capacity.toString() ?? '2');
    _isAvailable = room?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _typeCtrl.dispose();
    _viewCtrl.dispose();
    _basePriceCtrl.dispose();
    _viewExtraCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.room != null;
    
    return AlertDialog(
      title: Text(isEdit ? 'Modifier la chambre' : 'Créer une chambre'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _numberCtrl,
                  decoration: const InputDecoration(labelText: 'Numéro de chambre *'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.trim().isEmpty == true) return 'Numéro requis';
                    if (int.tryParse(value!) == null) return 'Numéro valide requis';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _typeCtrl,
                  decoration: const InputDecoration(labelText: 'Type de chambre *'),
                  validator: (value) => value?.trim().isEmpty == true ? 'Type requis' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _viewCtrl,
                  decoration: const InputDecoration(labelText: 'Vue (optionnel)'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _basePriceCtrl,
                  decoration: const InputDecoration(labelText: 'Prix de base (€) *'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.trim().isEmpty == true) return 'Prix requis';
                    if (int.tryParse(value!) == null) return 'Prix valide requis';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _viewExtraCtrl,
                  decoration: const InputDecoration(labelText: 'Supplément vue (€)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.trim().isNotEmpty == true && int.tryParse(value!) == null) {
                      return 'Montant valide requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _capacityCtrl,
                  decoration: const InputDecoration(labelText: 'Capacité (personnes) *'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.trim().isEmpty == true) return 'Capacité requise';
                    final capacity = int.tryParse(value!);
                    if (capacity == null || capacity < 1) return 'Capacité valide requise';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                SwitchListTile(
                  title: const Text('Disponible'),
                  value: _isAvailable,
                  onChanged: (value) => setState(() => _isAvailable = value),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final room = Room(
                id: widget.room?.id,
                hotelId: widget.hotelId ?? widget.room!.hotelId,
                number: int.parse(_numberCtrl.text.trim()),
                type: _typeCtrl.text.trim(),
                view: _viewCtrl.text.trim(),
                basePrice: int.parse(_basePriceCtrl.text.trim()),
                viewExtra: int.tryParse(_viewExtraCtrl.text.trim()) ?? 0,
                capacity: int.parse(_capacityCtrl.text.trim()),
                isAvailable: _isAvailable,
              );
              Navigator.pop(context, room);
            }
          },
          child: Text(isEdit ? 'Modifier' : 'Créer'),
        ),
      ],
    );
  }
}