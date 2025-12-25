import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gestion_hotel/models/hotel.dart';
import 'package:gestion_hotel/models/room.dart';

import 'package:gestion_hotel/screens/rooms/add_room_screen.dart';
import 'package:gestion_hotel/screens/rooms/room_details_screen.dart';
import 'package:gestion_hotel/services/auth_service.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/app_card.dart';
import 'package:gestion_hotel/widgets/common/app_loader.dart';
import 'package:gestion_hotel/widgets/common/empty_state.dart';
import 'package:gestion_hotel/widgets/error_state.dart';
import 'package:gestion_hotel/widgets/cards/room_card.dart';
import 'package:gestion_hotel/widgets/section_header.dart';

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
  int? _capacityFilter;
  RangeValues _priceRange = const RangeValues(0, 500);
  bool? _availabilityFilter; // null = all, true=available, false=unavailable
  RangeValues _priceBounds = const RangeValues(0, 500);
  bool _initializedBounds = false;
  late Stream<List<Room>> _roomsStream;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
    _roomsStream = _firestore.getRoomsByHotel(widget.hotel.id ?? '');
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
    final horizontalPadding = AppSpacing.screenPaddingHorizontal;
    return Scaffold(
      appBar: AppBar(
        title: Text('Chambres — ${widget.hotel.name}'),
        actions: [
          if (_isAdmin)
            IconButton(
              key: const Key('addRoomButton'),
              icon: const Icon(Icons.add),
              tooltip: 'Ajouter une chambre',
              onPressed: _openAddRoom,
            ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<Room>>(
          stream: _roomsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: AppLoader(message: 'Chargement des chambres...'));
            }
            if (snapshot.hasError) {
              return ErrorState(
                title: 'Impossible de charger les chambres',
                subtitle: snapshot.error?.toString(),
                onRetry: () => setState(() {}),
              );
            }

            final rooms = snapshot.data ?? [];
            if (!_initializedBounds && rooms.isNotEmpty) {
              final prices = rooms.map((r) => r.basePrice + r.viewExtra).where((p) => p > 0).toList();
              final min = prices.isEmpty ? 0.0 : prices.reduce(math.min).toDouble();
              final maxRaw = prices.isEmpty ? 500.0 : prices.reduce(math.max).toDouble();
              final max = maxRaw <= min ? min + 50 : maxRaw;
              _priceBounds = RangeValues(min, max);
              _priceRange = RangeValues(_priceBounds.start, _priceBounds.end);
              _initializedBounds = true;
            }

            final filtered = rooms.where((room) {
              final price = room.basePrice + room.viewExtra;
              final matchesType = _typeFilter == 'Tous' || room.type == _typeFilter;
              final matchesCapacity = _capacityFilter == null || (room.capacity ?? 0) >= _capacityFilter!;
              final matchesAvailability = _availabilityFilter == null || room.isAvailable == _availabilityFilter;
              final matchesPrice = price >= _priceRange.start - 0.01 && price <= _priceRange.end + 0.01;
              return matchesType && matchesCapacity && matchesAvailability && matchesPrice;
            }).toList();

            final isMobile = ResponsiveHelper.isMobile(context);
            final gridCount = isMobile ? 1 : math.min(ResponsiveHelper.getGridColumns(context), 3);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: 'Chambres',
                          subtitle: '${rooms.length} résultat${rooms.length > 1 ? 's' : ''}',
                          action: _isAdmin
                              ? ElevatedButton.icon(
                                  onPressed: _openAddRoom,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Ajouter'),
                                )
                              : null,
                        ),
                        _FiltersBar(
                          type: _typeFilter,
                          capacity: _capacityFilter,
                          availability: _availabilityFilter,
                          priceRange: _priceRange,
                          priceBounds: _priceBounds,
                          onTypeChanged: (v) => setState(() => _typeFilter = v ?? 'Tous'),
                          onCapacityChanged: (v) => setState(() => _capacityFilter = v),
                          onAvailabilityChanged: (v) => setState(() => _availabilityFilter = v),
                          onPriceChanged: (v) => setState(() => _priceRange = v),
                          onReset: () {
                            setState(() {
                              _typeFilter = 'Tous';
                              _capacityFilter = null;
                              _availabilityFilter = null;
                              _priceRange = _priceBounds;
                            });
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: EmptyStates.noRooms(() {
                        setState(() {
                          _typeFilter = 'Tous';
                          _availabilityFilter = null;
                          _priceRange = _priceBounds;
                        });
                      }),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: AppSpacing.lg),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridCount,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: gridCount == 1 ? 1.8 : 1.4,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final room = filtered[index];
                          return RoomCard(
                            roomId: room.id ?? '',
                            roomType: room.type ?? 'Standard',
                            capacity: room.capacity ?? 2,
                            pricePerNight: room.pricePerNight ?? room.basePrice.toDouble(),
                            isAvailable: room.isAvailable,
                            imageUrl: room.imageUrl ?? '',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => RoomDetailsScreen(room: room)),
                              );
                            },
                          );
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FiltersBar extends StatelessWidget {
  final String type;
  final int? capacity;
  final bool? availability;
  final RangeValues priceRange;
  final RangeValues priceBounds;
  final void Function(String?) onTypeChanged;
  final void Function(int?) onCapacityChanged;
  final void Function(bool?) onAvailabilityChanged;
  final void Function(RangeValues) onPriceChanged;
  final VoidCallback onReset;

  const _FiltersBar({
    required this.type,
    required this.capacity,
    required this.availability,
    required this.priceRange,
    required this.priceBounds,
    required this.onTypeChanged,
    required this.onCapacityChanged,
    required this.onAvailabilityChanged,
    required this.onPriceChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final fields = <Widget>[
      Expanded(
        child: DropdownButtonFormField<String>(
          key: ValueKey(type),
          initialValue: type,
          decoration: const InputDecoration(labelText: 'Type'),
          items: const [
            DropdownMenuItem(value: 'Tous', child: Text('Tous')),
            DropdownMenuItem(value: 'Simple', child: Text('Simple')),
            DropdownMenuItem(value: 'Double', child: Text('Double')),
            DropdownMenuItem(value: 'Suite', child: Text('Suite')),
          ],
          onChanged: onTypeChanged,
        ),
      ),
      SizedBox(width: isMobile ? 0 : AppSpacing.md, height: isMobile ? AppSpacing.md : 0),
      Expanded(
        child: DropdownButtonFormField<int?>(
          key: ValueKey(capacity),
          initialValue: capacity,
          decoration: const InputDecoration(labelText: 'Capacité'),
          items: const [
            DropdownMenuItem(value: null, child: Text('Toutes')),
            DropdownMenuItem(value: 1, child: Text('1+ pers')),
            DropdownMenuItem(value: 2, child: Text('2+ pers')),
            DropdownMenuItem(value: 3, child: Text('3+ pers')),
            DropdownMenuItem(value: 4, child: Text('4+ pers')),
          ],
          onChanged: onCapacityChanged,
        ),
      ),
      SizedBox(width: isMobile ? 0 : AppSpacing.md, height: isMobile ? AppSpacing.md : 0),
      Expanded(
        child: DropdownButtonFormField<bool?>(
          key: ValueKey(availability),
          initialValue: availability,
          decoration: const InputDecoration(labelText: 'Disponibilité'),
          items: const [
            DropdownMenuItem(value: null, child: Text('Toutes')),
            DropdownMenuItem(value: true, child: Text('Disponibles')),
            DropdownMenuItem(value: false, child: Text('Indisponibles')),
          ],
          onChanged: onAvailabilityChanged,
        ),
      ),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filtres', style: AppTextStyles.headline4),
          const SizedBox(height: AppSpacing.md),
          isMobile ? Column(children: fields) : Row(children: fields),
          const SizedBox(height: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Budget par nuit', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              RangeSlider(
                values: priceRange,
                min: priceBounds.start,
                max: priceBounds.end,
                divisions: 10,
                labels: RangeLabels('${priceRange.start.toStringAsFixed(0)} DH', '${priceRange.end.toStringAsFixed(0)} DH'),
                onChanged: onPriceChanged,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh),
              label: const Text('Réinitialiser'),
            ),
          ),
        ],
      ),
    );
  }
}
