import 'package:flutter/material.dart';
import 'package:gestion_hotel/models/hotel.dart';
import 'package:gestion_hotel/models/room.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/services/auth_service.dart';
import 'package:gestion_hotel/widgets/room_card.dart';
import 'package:gestion_hotel/widgets/paginated_list.dart';
import 'package:gestion_hotel/screens/rooms/add_room_screen.dart';
import 'package:gestion_hotel/screens/rooms/edit_room_screen.dart';
import 'package:gestion_hotel/screens/reservations/book_room_screen.dart';

class ListRoomsScreen extends StatefulWidget {
  final Hotel hotel;

  const ListRoomsScreen({super.key, required this.hotel});

  @override
  State<ListRoomsScreen> createState() => _ListRoomsScreenState();
}

class _ListRoomsScreenState extends State<ListRoomsScreen> {
  final FirestoreService _firestore = FirestoreService();
  final AuthService _auth = AuthService();

  String? _userRole;
  String _typeFilter = 'Tous';
  RangeValues _priceRange = const RangeValues(0, 500);
  bool? _availabilityFilter; // null = all, true=available, false=unavailable

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      final role = await _firestore.getUserRole(uid);
      if (!mounted) return;
      setState(() => _userRole = role);
    } catch (e) {
      debugPrint('Error fetching role: $e');
    }
  }

  bool get _isAdmin => _userRole == 'admin';

  void _openAddRoom() async {
    if (!_isAdmin) return;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final res = await navigator.push<bool?>(
      MaterialPageRoute(builder: (_) => AddRoomScreen(hotel: widget.hotel)),
    );

    if (!mounted) return;
    if (res == true) {
      messenger.showSnackBar(const SnackBar(content: Text('Chambre ajoutée'), backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chambres - ${widget.hotel.name}'),
        actions: [
          if (_isAdmin)
            IconButton(
              key: const Key('addRoomButton'),
              icon: const Icon(Icons.add),
              tooltip: 'Ajouter une chambre',
              onPressed: _openAddRoom,
            )
        ],
      ),
      body: Column(
        children: [
          /// Filters area
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _typeFilter,
                        items: const [
                          DropdownMenuItem(value: 'Tous', child: Text('Tous')),
                          DropdownMenuItem(value: 'Simple', child: Text('Simple')),
                          DropdownMenuItem(value: 'Double', child: Text('Double')),
                          DropdownMenuItem(value: 'Suite', child: Text('Suite')),
                        ],
                        onChanged: (v) => setState(() => _typeFilter = v ?? 'Tous'),
                        decoration: const InputDecoration(labelText: 'Type'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<bool?>(
                        initialValue: _availabilityFilter,
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Toutes')),
                          DropdownMenuItem(value: true, child: Text('Disponibles')),
                          DropdownMenuItem(value: false, child: Text('Indisponibles')),
                        ],
                        onChanged: (v) => setState(() => _availabilityFilter = v),
                        decoration: const InputDecoration(labelText: 'Disponibilité'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Prix'),
                    Expanded(
                      child: RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: 1000,
                        divisions: 20,
                        labels: RangeLabels('${_priceRange.start.toInt()}€', '${_priceRange.end.toInt()}€'),
                        onChanged: (v) => setState(() => _priceRange = v),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// Rooms list (paginated)
          Expanded(
            child: PaginatedList<Room>(
              fetchPage: ({startAfter, limit = 20}) => _firestore.getRoomsPaged(hotelId: widget.hotel.id ?? '', startAfter: startAfter, limit: limit, onlyAvailable: _availabilityFilter),
              itemBuilder: (context, room, index) {
                // apply client-side filters for type and price
                final matchesType = _typeFilter == 'Tous' || room.type == _typeFilter;
                final matchesPrice = (room.basePrice + room.viewExtra) >= _priceRange.start && (room.basePrice + room.viewExtra) <= _priceRange.end;
                if (!matchesType || !matchesPrice) return const SizedBox.shrink();

                return RoomCard(
                  room: room,
                  onTap: _isAdmin
                      ? () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => EditRoomScreen(room: room)));
                        }
                      : null,
                  onBook: room.isAvailable
                      ? () async {
                          final navigator = Navigator.of(this.context);
                          final messenger = ScaffoldMessenger.of(this.context);
                          final result = await navigator.push<bool?>(
                            MaterialPageRoute(builder: (_) => BookRoomScreen(room: room, hotelId: widget.hotel.id)),
                          );
                          if (!mounted) return;
                          if (result == true) {
                            messenger.showSnackBar(const SnackBar(content: Text('Réservation créée'), backgroundColor: Colors.green));
                          }
                        }
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
