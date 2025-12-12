import 'package:flutter/material.dart';
import 'package:gestion_hotel/models/hotel.dart';
import 'package:gestion_hotel/models/room.dart';
import 'package:gestion_hotel/services/firestore_service.dart';

class AddRoomScreen extends StatefulWidget {
  final Hotel hotel;
  const AddRoomScreen({super.key, required this.hotel});

  @override
  State<AddRoomScreen> createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _numberCtrl = TextEditingController();
  final TextEditingController _capacityCtrl = TextEditingController(text: '2');
  final TextEditingController _basePriceCtrl = TextEditingController();
  final TextEditingController _viewExtraCtrl = TextEditingController();
  String _type = 'double';
  String _view = 'jardin';
  bool _isAvailable = true;
  bool _loading = false;
  final FirestoreService _firestore = FirestoreService();

  @override
  void dispose() {
    _numberCtrl.dispose();
    _capacityCtrl.dispose();
    _basePriceCtrl.dispose();
    _viewExtraCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final room = Room(
      hotelId: widget.hotel.id ?? '',
      number: int.tryParse(_numberCtrl.text.trim()) ?? 0,
      type: _type,
      view: _view,
      basePrice: int.tryParse(_basePriceCtrl.text.trim()) ?? 0,
      viewExtra: int.tryParse(_viewExtraCtrl.text.trim()) ?? 0,
      capacity: int.tryParse(_capacityCtrl.text.trim()) ?? 2,
      isAvailable: _isAvailable,
    );

    try {
      await _firestore.addRoom(room);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chambre ajoutée'), backgroundColor: Colors.green));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une chambre')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                key: const Key('roomNumberField'),
                controller: _numberCtrl,
                decoration: const InputDecoration(labelText: 'Numéro'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Entrez le numéro' : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                key: const Key('roomTypeDropdown'),
                initialValue: _type,
                items: const [
                  DropdownMenuItem(value: 'double', child: Text('Double')),
                  DropdownMenuItem(value: 'triple', child: Text('Triple')),
                  DropdownMenuItem(value: 'suite', child: Text('Suite')),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'double'),
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                key: const Key('roomViewDropdown'),
                initialValue: _view,
                items: const [
                  DropdownMenuItem(value: 'jardin', child: Text('Jardin')),
                  DropdownMenuItem(value: 'piscine', child: Text('Piscine')),
                  DropdownMenuItem(value: 'mer', child: Text('Mer')),
                ],
                onChanged: (v) => setState(() => _view = v ?? 'jardin'),
                decoration: const InputDecoration(labelText: 'Vue'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('roomBasePriceField'),
                controller: _basePriceCtrl,
                decoration: const InputDecoration(labelText: 'Prix de base (€)'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Entrez le prix de base' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('roomViewExtraField'),
                controller: _viewExtraCtrl,
                decoration: const InputDecoration(labelText: 'Supplément vue (€)'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Entrez le supplément vue' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('roomCapacityField'),
                controller: _capacityCtrl,
                decoration: const InputDecoration(labelText: 'Capacité'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Entrez la capacité' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Disponible'),
                  Switch(
                    value: _isAvailable,
                    onChanged: (v) => setState(() => _isAvailable = v),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('submitAddRoomButton'),
                  onPressed: _loading ? null : _submit,
                  child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Ajouter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
