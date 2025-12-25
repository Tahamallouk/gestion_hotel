import 'package:flutter/material.dart';
import 'package:gestion_hotel/services/admin_service.dart';
import 'package:gestion_hotel/models/hotel.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/app_card.dart';
import 'package:gestion_hotel/widgets/section_header.dart';

class AdminHotelsManagementPage extends StatefulWidget {
  const AdminHotelsManagementPage({super.key});

  @override
  State<AdminHotelsManagementPage> createState() => _AdminHotelsManagementPageState();
}

class _AdminHotelsManagementPageState extends State<AdminHotelsManagementPage> {
  final _adminService = AdminService();
  List<Hotel> _hotels = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    print('🚀 Initialisation AdminHotelsManagementPage');
    _loadHotels();
  }

  Future<void> _loadHotels() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      print('🔍 Vérification du statut admin...');
      final isAdmin = await _adminService.isCurrentUserAdmin();
      print('✅ Statut admin: $isAdmin');
      
      if (!isAdmin) {
        throw Exception('Vous n\'êtes pas connecté en tant qu\'administrateur');
      }
      
      print('📡 Récupération des hôtels depuis Firestore...');
      final hotels = await _adminService.getHotels();
      print('📊 Hôtels trouvés: ${hotels.length}');
      
      // Si aucun hôtel, créer automatiquement des données de test
      if (hotels.isEmpty) {
        print('🏨 Aucun hôtel trouvé, création automatique de données de test...');
        await _createSampleData();
        // Recharger après création
        final newHotels = await _adminService.getHotels();
        print('🎆 Nouveaux hôtels créés: ${newHotels.length}');
        
        if (mounted) {
          setState(() {
            _hotels = newHotels;
            _loading = false;
          });
          _showSuccess('${newHotels.length} hôtels de test créés automatiquement');
        }
      } else {
        if (mounted) {
          setState(() {
            _hotels = hotels;
            _loading = false;
          });
        }
      }
    } catch (e) {
      print('❌ Erreur lors du chargement: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
        _showError(e.toString());
      }
    }
  }

  Future<void> _createSampleData() async {
    try {
      // Créer des hôtels d'exemple
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

      final hotel1Id = await _adminService.createHotel(hotel1);
      final hotel2Id = await _adminService.createHotel(hotel2);
      
      print('✅ Hôtels créés: $hotel1Id, $hotel2Id');
    } catch (e) {
      print('❌ Erreur lors de la création des données: $e');
      rethrow;
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

  Future<void> _createHotel() async {
    final result = await showDialog<Hotel>(
      context: context,
      builder: (context) => const _HotelFormDialog(),
    );

    if (result != null) {
      setState(() => _loading = true);
      try {
        await _adminService.createHotel(result);
        _showSuccess('Hôtel "${result.name}" créé avec succès');
        await _loadHotels(); // Reload list
      } catch (e) {
        _showError('Erreur lors de la création: ${e.toString()}');
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _editHotel(Hotel hotel) async {
    final result = await showDialog<Hotel>(
      context: context,
      builder: (context) => _HotelFormDialog(hotel: hotel),
    );

    if (result != null && hotel.id != null) {
      setState(() => _loading = true);
      try {
        await _adminService.updateHotel(hotel.id!, {
          'name': result.name,
          'city': result.city,
          'country': result.country,
          'address': result.address,
          'rating': result.rating,
          'price': result.price,
        });
        _showSuccess('Hôtel "${result.name}" mis à jour');
        await _loadHotels();
      } catch (e) {
        _showError('Erreur lors de la modification: ${e.toString()}');
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _deleteHotel(Hotel hotel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer l\'hôtel "${hotel.name}" ?\\n'
          '\\nCette action supprimera également :\\n'
          '• Toutes les chambres de cet hôtel\\n'
          '• Toutes les réservations associées\\n'
          '\\nCette action est irréversible.',
        ),
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

    if (confirmed == true && hotel.id != null) {
      setState(() => _loading = true);
      try {
        await _adminService.deleteHotel(hotel.id!);
        _showSuccess('Hôtel "${hotel.name}" supprimé');
        await _loadHotels();
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
        title: const Text('Gestion des Hôtels (Admin)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHotels,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionHeader(title: 'Hôtels'),
                ElevatedButton.icon(
                  onPressed: _loading ? null : _createHotel,
                  icon: const Icon(Icons.add),
                  label: const Text('Créer un hôtel'),
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
            
            if (_loading) ...[
              const Center(child: CircularProgressIndicator()),
            ] else ...[
              Expanded(
                child: _hotels.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.hotel, size: 64, color: Colors.grey),
                            SizedBox(height: AppSpacing.md),
                            Text(
                              'Aucun hôtel trouvé',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              'Créez votre premier hôtel pour commencer',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _hotels.length,
                        itemBuilder: (context, index) {
                          final hotel = _hotels[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: AppCard(
                            child: ListTile(
                              title: Text(
                                hotel.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${hotel.city}, ${hotel.country}'),
                                  Text(hotel.address),
                                  if ((hotel.rating ?? 0) > 0) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 16),
                                        const SizedBox(width: 4),
                                        Text('${hotel.rating}/5'),
                                        const SizedBox(width: 16),
                                        const Icon(Icons.attach_money, size: 16),
                                        Text('${hotel.price.toStringAsFixed(0)}€/nuit'),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                              trailing: PopupMenuButton(
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
                                      _editHotel(hotel);
                                      break;
                                    case 'delete':
                                      _deleteHotel(hotel);
                                      break;
                                  }
                                },
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

class _HotelFormDialog extends StatefulWidget {
  final Hotel? hotel;
  
  const _HotelFormDialog({this.hotel});

  @override
  State<_HotelFormDialog> createState() => _HotelFormDialogState();
}

class _HotelFormDialogState extends State<_HotelFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _ratingCtrl;
  late final TextEditingController _priceCtrl;

  @override
  void initState() {
    super.initState();
    final hotel = widget.hotel;
    _nameCtrl = TextEditingController(text: hotel?.name ?? '');
    _cityCtrl = TextEditingController(text: hotel?.city ?? '');
    _countryCtrl = TextEditingController(text: hotel?.country ?? '');
    _addressCtrl = TextEditingController(text: hotel?.address ?? '');
    _ratingCtrl = TextEditingController(text: hotel?.rating.toString() ?? '');
    _priceCtrl = TextEditingController(text: hotel?.price.toString() ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    _addressCtrl.dispose();
    _ratingCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.hotel != null;
    
    return AlertDialog(
      title: Text(isEdit ? 'Modifier l\'hôtel' : 'Créer un hôtel'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nom de l\'hôtel *'),
                  validator: (value) => value?.trim().isEmpty == true ? 'Nom requis' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _cityCtrl,
                  decoration: const InputDecoration(labelText: 'Ville *'),
                  validator: (value) => value?.trim().isEmpty == true ? 'Ville requise' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _countryCtrl,
                  decoration: const InputDecoration(labelText: 'Pays'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _addressCtrl,
                  decoration: const InputDecoration(labelText: 'Adresse *'),
                  validator: (value) => value?.trim().isEmpty == true ? 'Adresse requise' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _ratingCtrl,
                  decoration: const InputDecoration(labelText: 'Note (0-5)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.trim().isNotEmpty == true) {
                      final rating = double.tryParse(value!);
                      if (rating == null || rating < 0 || rating > 5) {
                        return 'Note entre 0 et 5';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _priceCtrl,
                  decoration: const InputDecoration(labelText: 'Prix par nuit (€)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.trim().isNotEmpty == true) {
                      final price = double.tryParse(value!);
                      if (price == null || price < 0) {
                        return 'Prix valide requis';
                      }
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
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final hotel = Hotel(
                id: widget.hotel?.id,
                name: _nameCtrl.text.trim(),
                city: _cityCtrl.text.trim(),
                country: _countryCtrl.text.trim(),
                address: _addressCtrl.text.trim(),
                rating: double.tryParse(_ratingCtrl.text.trim()) ?? 0,
                price: double.tryParse(_priceCtrl.text.trim()) ?? 0,
              );
              Navigator.pop(context, hotel);
            }
          },
          child: Text(isEdit ? 'Modifier' : 'Créer'),
        ),
      ],
    );
  }
}