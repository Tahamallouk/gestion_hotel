import 'package:flutter/material.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/models/reservation.dart';
import 'package:gestion_hotel/widgets/reservation_card.dart';

class AdminReservationsScreen extends StatefulWidget {
  const AdminReservationsScreen({super.key});

  @override
  State<AdminReservationsScreen> createState() => _AdminReservationsScreenState();
}

class _AdminReservationsScreenState extends State<AdminReservationsScreen> {
  final FirestoreService _firestore = FirestoreService();
  String? _hotelFilter;
  String? _statusFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réservations (Admin)')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Filtrer par hôtel (id)'),
                    onChanged: (v) => setState(() => _hotelFilter = v.isEmpty ? null : v),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _statusFilter,
                  hint: const Text('Statut'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Tous')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                    DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                  ],
                  onChanged: (v) => setState(() => _statusFilter = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Reservation>>(
              stream: _firestore.getAllReservations(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) return Center(child: Text('Erreur: ${snapshot.error}'));
                var list = snapshot.data ?? [];
                if (_hotelFilter != null) list = list.where((r) => r.hotelId == _hotelFilter).toList();
                if (_statusFilter != null) list = list.where((r) => r.status == _statusFilter).toList();
                if (list.isEmpty) return Center(child: Text('Aucune réservation')); 
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final r = list[index];
                    return ReservationCard(
                      reservation: r,
                      onTap: () {},
                      showActions: true,
                      onCancel: () async {
                        try {
                          await _firestore.cancelReservation(r.id ?? '');
                          if (!mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Réservation annulée'), backgroundColor: Colors.green),
                          );
                        } catch (e) {
                          if (!mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.redAccent),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
