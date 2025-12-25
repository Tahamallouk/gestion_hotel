import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gestion_hotel/models/hotel.dart';
import 'package:gestion_hotel/models/room.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/app_card.dart';
import 'package:gestion_hotel/widgets/error_state.dart';

import 'package:gestion_hotel/screens/rooms/room_details_screen.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../reservations/reservation_page.dart';

class HotelDetailsPage extends StatefulWidget {
  final Hotel hotel;
  const HotelDetailsPage({super.key, required this.hotel});

  @override
  State<HotelDetailsPage> createState() => _HotelDetailsPageState();
}

class _HotelDetailsPageState extends State<HotelDetailsPage> {
  final _firestore = FirestoreService();
  late final Stream<List<Room>> _roomsStream;
  ll.LatLng? _coords;
  final _rand = Random();

  @override
  void initState() {
    super.initState();
    _roomsStream = widget.hotel.id == null ? const Stream.empty() : _firestore.getRoomsByHotel(widget.hotel.id!);
    _coords = _parseLatLng(widget.hotel.location);
  }

  @override
  void dispose() {
    super.dispose();
  }

  ll.LatLng? _parseLatLng(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split(',');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return null;
    return ll.LatLng(lat, lng);
  }

  void _openReservation(Room room) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReservationPage(
          room: room,
          hotel: widget.hotel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(hotel.name),
          bottom: const TabBar(tabs: [Tab(text: 'Chambres'), Tab(text: 'Infos')]),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingHorizontal,
                vertical: AppSpacing.md,
              ),
              child: _HotelHeaderCompact(hotel: hotel),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _RoomsTab(
                    stream: _roomsStream,
                    onBook: _openReservation,
                    fallbackRooms: _mockRooms(hotel),
                  ),
                  _InfoTab(hotel: hotel, coords: _coords),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HotelHeaderCompact extends StatelessWidget {
  final Hotel hotel;

  const _HotelHeaderCompact({required this.hotel});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final thumbSize = isMobile ? 72.0 : 88.0;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: AppBorderRadius.allMd,
            child: (hotel.imageUrl?.isEmpty ?? true)
                ? Container(
                    width: thumbSize,
                    height: thumbSize,
                    color: AppColors.surface,
                    child: const Icon(Icons.apartment, color: AppColors.textSecondary, size: 28),
                  )
                : Image.network(
                    hotel.imageUrl ?? '',
                    width: thumbSize,
                    height: thumbSize,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: thumbSize,
                      height: thumbSize,
                      color: AppColors.surface,
                      child: const Icon(Icons.apartment, color: AppColors.textSecondary, size: 28),
                    ),
                  ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(hotel.name, style: AppTextStyles.headline3),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hotel.city.isNotEmpty ? hotel.city : 'Ville à préciser',
                        style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _RatingBadge(rating: hotel.rating ?? 0.0),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomsTab extends StatelessWidget {
  final Stream<List<Room>> stream;
  final ValueChanged<Room> onBook;
  final List<Room> fallbackRooms;

  const _RoomsTab({required this.stream, required this.onBook, required this.fallbackRooms});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingHorizontal,
        vertical: AppSpacing.sm,
      ),
      child: StreamBuilder<List<Room>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorState(title: 'Chambres', subtitle: snapshot.error?.toString());
          }

          final rooms = snapshot.data ?? [];
          final items = rooms.isEmpty ? fallbackRooms : rooms;

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final room = items[index];
              final onBookTap = () {
                if (!room.isAvailable) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chambre indisponible pour le moment.')),
                  );
                  return;
                }
                onBook(room);
              };
              return _RoomCard(
                room: room,
                onDetails: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RoomDetailsScreen(room: room)),
                ),
                onBook: onBookTap,
              );
            },
          );
        },
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  final Hotel hotel;
  final ll.LatLng? coords;

  const _InfoTab({required this.hotel, required this.coords});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingHorizontal, vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('À propos', style: AppTextStyles.subtitle1),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  hotel.address.isEmpty ? 'Adresse à compléter' : hotel.address,
                  style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary),
                ),
                if (coords != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text('Coordonnées: ${coords!.latitude.toStringAsFixed(4)}, ${coords!.longitude.toStringAsFixed(4)}',
                      style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary)),
                ],
                const SizedBox(height: AppSpacing.sm),
                Text(
                    hotel.price > 0
                      ? 'Tarif indicatif : ${hotel.price.toStringAsFixed(0)} DH/nuit'
                      : 'Tarif disponible lors de la réservation',
                  style: AppTextStyles.body3,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Avis', style: AppTextStyles.subtitle1),
                SizedBox(height: AppSpacing.sm),
                Text('Les avis clients seront affichés ici.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension on _HotelDetailsPageState {
  List<Room> _mockRooms(Hotel hotel) {
    const placeholders = [
      'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=1400&q=80',
      'https://images.unsplash.com/photo-1501117716987-c8e1ecb210af?auto=format&fit=crop&w=1400&q=80',
      'https://images.unsplash.com/photo-1505761671935-60b3a7427bad?auto=format&fit=crop&w=1400&q=80',
      'https://images.unsplash.com/photo-1505691938895-1758d7feb511?auto=format&fit=crop&w=1400&q=80',
    ];

    Room makeRoom(int number) {
      final base = 60 + _rand.nextInt(100);
      final extra = [0, 10, 20][_rand.nextInt(3)];
      final views = ['mer', 'jardin', 'piscine', 'ville'];
      final types = ['double', 'triple', 'suite'];
      return Room(
        id: 'mock-$number',
        hotelId: hotel.id ?? 'mock-hotel',
        number: number,
        type: types[_rand.nextInt(types.length)],
        view: views[_rand.nextInt(views.length)],
        basePrice: base,
        viewExtra: extra,
        capacity: 2 + _rand.nextInt(3),
        isAvailable: _rand.nextBool(),
        imageUrl: placeholders[_rand.nextInt(placeholders.length)],
      );
    }

    return List<Room>.generate(4, (i) => makeRoom(200 + i));
  }
}

class _RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback? onBook;
  final VoidCallback onDetails;

  const _RoomCard({required this.room, required this.onBook, required this.onDetails});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final imageWidth = isMobile ? 120.0 : 150.0;
    final imageHeight = isMobile ? 80.0 : 94.0;
    final nightlyPrice = (room.basePrice + room.viewExtra).toDouble();
    final hasImage = room.imageUrl?.isNotEmpty ?? false;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage)
            ClipRRect(
              borderRadius: AppBorderRadius.allMd,
              child: Image.network(
                room.imageUrl ?? '',
                width: imageWidth,
                height: imageHeight,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _ImagePlaceholder(width: imageWidth, height: imageHeight),
              ),
            )
          else
            _ImagePlaceholder(width: imageWidth, height: imageHeight),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(room.type.isNotEmpty ? room.type : 'Type non renseigné', style: AppTextStyles.subtitle1),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _capacityAndView(room),
                  style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${nightlyPrice.toStringAsFixed(0)}€ / nuit',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _AvailabilityBadge(isAvailable: room.isAvailable),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    FilledButton(onPressed: onBook, child: const Text('Réserver')),
                    const SizedBox(width: AppSpacing.sm),
                    OutlinedButton(onPressed: onDetails, child: const Text('Détails')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _capacityAndView(Room room) {
    final capacity = (room.capacity ?? 0) > 0 ? '${room.capacity} pers.' : 'Capacité inconnue';
    final view = room.view.isNotEmpty ? ' · Vue ${room.view}' : '';
    return '$capacity$view';
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final double width;
  final double height;

  const _ImagePlaceholder({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.allMd,
        border: Border.all(color: AppColors.border),
      ),
      child: const Icon(Icons.image_not_supported_outlined, color: AppColors.textSecondary),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  final bool isAvailable;

  const _AvailabilityBadge({required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    final color = isAvailable ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppBorderRadius.allMd,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        isAvailable ? 'Libre' : 'Occupée',
        style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;

  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: AppBorderRadius.allMd,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 16, color: Colors.amber),
          const SizedBox(width: 4),
          Text(rating > 0 ? rating.toStringAsFixed(1) : 'N/C', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}