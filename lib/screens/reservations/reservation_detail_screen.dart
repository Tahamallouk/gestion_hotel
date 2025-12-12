import 'package:flutter/material.dart';
import 'package:gestion_hotel/models/reservation.dart';
import 'package:gestion_hotel/widgets/reservation_card.dart';
import 'package:gestion_hotel/services/firestore_service.dart';

class ReservationDetailScreen extends StatefulWidget {
  final Reservation reservation;
  const ReservationDetailScreen({super.key, required this.reservation});

  @override
  State<ReservationDetailScreen> createState() => _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  final FirestoreService firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final reservation = widget.reservation;

    return Scaffold(
      appBar: AppBar(title: const Text('Détail réservation')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReservationCard(reservation: reservation, showActions: false),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Détails', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('ID: ${reservation.id ?? ''}'),
                    const SizedBox(height: 4),
                    Text('Statut: ${reservation.status}'),
                    const SizedBox(height: 12),
                    // QR placeholder
                    Center(
                      child: Container(
                        width: 160,
                        height: 160,
                        color: Colors.grey.shade200,
                        child: const Center(child: Text('QR CODE')),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: reservation.status == 'cancelled'
                              ? null
                              : () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (c) => AlertDialog(
                                      title: const Text('Annuler la réservation ?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Non')),
                                        ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Oui')),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    try {
                                      await firestore.cancelReservation(reservation.id ?? '');
                                      if (!mounted) return;
                                      final messenger = ScaffoldMessenger.of(context);
                                      messenger.showSnackBar(const SnackBar(content: Text('Réservation annulée'), backgroundColor: Colors.green));
                                      Navigator.pop(context, true);
                                    } catch (e) {
                                      if (!mounted) return;
                                      final messenger = ScaffoldMessenger.of(context);
                                      messenger.showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.redAccent));
                                    }
                                  }
                                },
                          child: const Text('Annuler la réservation'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
