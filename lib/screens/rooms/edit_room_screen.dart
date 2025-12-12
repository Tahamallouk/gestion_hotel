import 'package:flutter/material.dart';
import 'package:gestion_hotel/models/room.dart';
import 'package:gestion_hotel/services/firestore_service.dart';

class EditRoomScreen extends StatefulWidget {
  final Room room;
  const EditRoomScreen({super.key, required this.room});

  @override
  State<EditRoomScreen> createState() => _EditRoomScreenState();
}

class _EditRoomScreenState extends State<EditRoomScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _numberCtrl;
  late TextEditingController _capacityCtrl;
  late TextEditingController _basePriceCtrl;
  late TextEditingController _viewExtraCtrl;

  String _type = 'double';
  String _view = 'jardin';
  bool _isAvailable = true;
  bool _loading = false;

  final FirestoreService _firestore = FirestoreService();

  @override
  void initState() {
    super.initState();

    _numberCtrl = TextEditingController(text: widget.room.number.toString());
    _capacityCtrl = TextEditingController(text: widget.room.capacity.toString());
    _basePriceCtrl = TextEditingController(text: widget.room.basePrice.toString());
    _viewExtraCtrl = TextEditingController(text: widget.room.viewExtra.toString());

    _type = widget.room.type;
    _view = widget.room.view;
    _isAvailable = widget.room.isAvailable;
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _capacityCtrl.dispose();
    _basePriceCtrl.dispose();
    _viewExtraCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final data = {
      'number': int.tryParse(_numberCtrl.text.trim()) ?? 0,
      'type': _type,
      'view': _view,
      'basePrice': int.tryParse(_basePriceCtrl.text.trim()) ?? 0,
      'viewExtra': int.tryParse(_viewExtraCtrl.text.trim()) ?? 0,
      'capacity': int.tryParse(_capacityCtrl.text.trim()) ?? 1,
      'isAvailable': _isAvailable,
    };

    try {
      await _firestore.updateRoom(widget.room.id!, data);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chambre mise à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Supprimer la chambre ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loading = true);

    try {
      await _firestore.deleteRoom(widget.room.id!);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chambre supprimée'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // UI FIELD BUILDER
  Widget _buildField(Widget field) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: field,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier la chambre'),
        actions: [
          IconButton(
            key: const Key('deleteRoomButton'),
            onPressed: _loading ? null : _delete,
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField(
                TextFormField(
                  key: const Key('editRoomNumberField'),
                  controller: _numberCtrl,
                  decoration: const InputDecoration(labelText: 'Numéro'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Entrez le numéro' : null,
                ),
              ),

              // TYPE
              _buildField(
                DropdownButtonFormField<String>(
                  key: const Key('editRoomTypeDropdown'),
                  initialValue: _type,
                  items: const [
                    DropdownMenuItem(value: 'double', child: Text('Double')),
                    DropdownMenuItem(value: 'triple', child: Text('Triple')),
                    DropdownMenuItem(value: 'suite', child: Text('Suite')),
                  ],
                  onChanged: (v) => setState(() => _type = v ?? 'double'),
                  decoration: const InputDecoration(labelText: 'Type de chambre'),
                ),
              ),

              // VIEW
              _buildField(
                DropdownButtonFormField<String>(
                  key: const Key('editRoomViewDropdown'),
                  initialValue: _view,
                  items: const [
                    DropdownMenuItem(value: 'jardin', child: Text('Vue Jardin')),
                    DropdownMenuItem(value: 'piscine', child: Text('Vue Piscine')),
                    DropdownMenuItem(value: 'mer', child: Text('Vue Mer')),
                  ],
                  onChanged: (v) => setState(() => _view = v ?? 'jardin'),
                  decoration: const InputDecoration(labelText: 'Vue'),
                ),
              ),

              // BASE PRICE
              _buildField(
                TextFormField(
                  key: const Key('editRoomBasePriceField'),
                  controller: _basePriceCtrl,
                  decoration: const InputDecoration(labelText: 'Prix de base (€)'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Entrez le prix de base' : null,
                ),
              ),

              // VIEW EXTRA
              _buildField(
                TextFormField(
                  key: const Key('editRoomViewExtraField'),
                  controller: _viewExtraCtrl,
                  decoration: const InputDecoration(labelText: 'Supplément vue (€)'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Entrez le supplément vue' : null,
                ),
              ),

              // CAPACITY
              _buildField(
                TextFormField(
                  key: const Key('editRoomCapacityField'),
                  controller: _capacityCtrl,
                  decoration: const InputDecoration(labelText: 'Capacité'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Entrez la capacité' : null,
                ),
              ),

              // AVAILABLE SWITCH
              SwitchListTile(
                title: const Text('Disponible'),
                value: _isAvailable,
                onChanged: (v) => setState(() => _isAvailable = v),
              ),

              // SAVE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('saveRoomButton'),
                  onPressed: _loading ? null : _save,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
