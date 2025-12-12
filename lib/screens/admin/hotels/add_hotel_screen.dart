import 'package:flutter/material.dart';
import '../../../models/hotel.dart';
import '../../../services/firestore_service.dart';

class AddHotelScreen extends StatefulWidget {
  const AddHotelScreen({super.key});

  @override
  State<AddHotelScreen> createState() => _AddHotelScreenState();
}

class _AddHotelScreenState extends State<AddHotelScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final FirestoreService _firestore = FirestoreService();
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final hotel = Hotel(
      name: _nameCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
    );

    try {
      final id = await _firestore.addHotel(hotel);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hôtel ajouté (ID: $id)'), backgroundColor: Colors.green),
      );
      _formKey.currentState!.reset();
      _nameCtrl.clear();
      _cityCtrl.clear();
      _addressCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un hôtel')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nom de l\'hôtel'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Entrez le nom' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _cityCtrl,
                    decoration: const InputDecoration(labelText: 'Ville'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Entrez la ville' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _addressCtrl,
                    decoration: const InputDecoration(labelText: 'Adresse'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Entrez l\'adresse' : null,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Ajouter'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
