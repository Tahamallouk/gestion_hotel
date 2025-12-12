import 'package:flutter/material.dart';
import 'package:gestion_hotel/models/reservation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final bool showActions;

  const ReservationCard({super.key, required this.reservation, this.onTap, this.onCancel, this.showActions = true});

  String _formatDate(DateTime d) => DateFormat('dd MMM yyyy').format(d.toLocal());

  Future<Map<String, dynamic>?> _fetchRoomAndHotel() async {
    final db = FirebaseFirestore.instance;
    final roomSnap = await db.collection('rooms').doc(reservation.roomId).get();
    final hotelSnap = await db.collection('hotels').doc(reservation.hotelId).get();
    return {
      'room': roomSnap.exists ? roomSnap.data() : null,
      'hotel': hotelSnap.exists ? hotelSnap.data() : null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final nights = reservation.endDate.difference(reservation.startDate).inDays;

    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchRoomAndHotel(),
      builder: (context, snapshot) {
        final roomData = snapshot.data?['room'] as Map<String, dynamic>?;
        final hotelData = snapshot.data?['hotel'] as Map<String, dynamic>?;
        final roomNumber = roomData != null ? roomData['number']?.toString() ?? '' : '';
        final roomType = roomData != null ? roomData['type']?.toString() ?? '' : '';
        final pricePerNight = roomData != null ? (roomData['price'] is num ? (roomData['price'] as num).toDouble() : double.tryParse(roomData['price']?.toString() ?? '0') ?? 0.0) : 0.0;
        final total = (nights > 0 ? nights : 1) * pricePerNight;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hotelData != null ? hotelData['name'] ?? 'Hôtel' : 'Hôtel',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Chip(
                        label: Text(reservation.status.toUpperCase()),
                        backgroundColor: reservation.status == 'cancelled'
                            ? Colors.red.shade50
                            : reservation.status == 'confirmed'
                                ? Colors.green.shade50
                                : Colors.orange.shade50,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Chambre $roomNumber · $roomType', style: TextStyle(color: Colors.grey.shade700)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text('${_formatDate(reservation.startDate)} → ${_formatDate(reservation.endDate)}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Nuits: ${nights > 0 ? nights : 1}'),
                      Text('${total.toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  if (showActions && onCancel != null && reservation.status != 'cancelled') ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: onCancel, child: const Text('Annuler')),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
