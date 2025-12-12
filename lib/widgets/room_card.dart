import 'package:flutter/material.dart';
import '../models/room.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback? onTap;
  final VoidCallback? onBook;

  const RoomCard({
    super.key,
    required this.room,
    this.onTap,
    this.onBook,
  });

  int get _totalPrice => room.basePrice + room.viewExtra;

  @override
  Widget build(BuildContext context) {
    

    return GestureDetector(
      key: Key('roomCard_${room.number}'),
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Room icon / placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue.shade50,
                ),
                child: Icon(
                  Icons.hotel,
                  size: 40,
                  color: Colors.blue.shade300,
                ),
              ),

              const SizedBox(width: 14),

              /// Room details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Title: Chambre 102
                    Text(
                      'Chambre ${room.number}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    /// Type & View
                    Text(
                      '${room.type.toUpperCase()} — Vue ${room.view}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// Price breakdown
                    Text(
                      '${room.basePrice}€ + ${room.viewExtra}€/nuit',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              /// Status + Book Button
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Availability badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: room.isAvailable
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      room.isAvailable ? 'Libre' : 'Occupée',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: room.isAvailable
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// Book button
                  if (room.isAvailable && onBook != null)
                    SizedBox(
                      height: 34,
                      child: ElevatedButton(
                        key: Key('bookButton_${room.number}'),
                        onPressed: onBook,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Réserver',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
