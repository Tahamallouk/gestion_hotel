import 'package:flutter/material.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/services/auth_service.dart';
import 'package:gestion_hotel/models/reservation.dart';
import 'package:gestion_hotel/widgets/reservation_card.dart';
import 'package:gestion_hotel/widgets/paginated_list.dart';
import 'reservation_detail_screen.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  final FirestoreService _firestore = FirestoreService();
  final AuthService _auth = AuthService();
  Key _pagKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Scaffold(body: Center(child: Text('Veuillez vous connecter')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mes réservations')),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _pagKey = UniqueKey());
        },
        child: PaginatedList<Reservation>(
          key: _pagKey,
          fetchPage: ({startAfter, limit = 20}) => _firestore.getReservationsPaged(userId: uid, startAfter: startAfter, limit: limit),
          itemBuilder: (context, r, index) {
            return ReservationCard(
              reservation: r,
              onTap: () async {
                final ctx = context;
                final res = await Navigator.push<bool?>(
                  ctx,
                  MaterialPageRoute(
                    builder: (context) => ReservationDetailScreen(reservation: r),
                  ),
                );
                if (res == true && mounted) {
                  setState(() => _pagKey = UniqueKey());
                }
              },
              onCancel: () async {
                final ctx = context;
                try {
                  await _firestore.cancelReservation(r.id ?? '');
                  if (!mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Réservation annulée'), backgroundColor: Colors.green),
                  );
                  if (mounted) {
                    setState(() => _pagKey = UniqueKey());
                  }
                } catch (e) {
                  if (!mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.redAccent),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
