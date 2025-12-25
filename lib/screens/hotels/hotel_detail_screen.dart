import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestion_hotel/models/hotel.dart';
import 'package:gestion_hotel/models/reservation.dart';
import 'package:gestion_hotel/models/room.dart';
import 'package:gestion_hotel/providers/auth_provider.dart';
import 'package:gestion_hotel/providers/booking_provider_legacy.dart';
import 'package:gestion_hotel/screens/reservations/book_room_screen.dart';
import 'package:gestion_hotel/screens/rooms/room_details_screen.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/app_card.dart';
import 'package:gestion_hotel/widgets/common/app_loader.dart';
import 'package:gestion_hotel/widgets/common/empty_state.dart';
import 'package:gestion_hotel/widgets/error_state.dart';

class HotelDetailScreen extends StatefulWidget {
  final Hotel hotel;
  final int initialTabIndex;

  const HotelDetailScreen({
    super.key, 
    required this.hotel,
    this.initialTabIndex = 0,
  });

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  final _firestore = FirestoreService();
  late final Stream<List<Room>> _roomsStream;
  late final Stream<List<Reservation>> _reservationsStream;
  late final Future<Map<String, dynamic>?> _detailsFuture;

  static const _demoImages = [
    'https://images.unsplash.com/photo-1505691938895-1758d7feb511?auto=format&fit=crop&w=1400&q=80',
    'https://images.unsplash.com/photo-1496417263034-38ec4f0b665a?auto=format&fit=crop&w=1400&q=80',
    'https://images.unsplash.com/photo-1505691938895-1758d7feb511?auto=format&fit=crop&w=1200&q=80&sat=-10',
  ];

  @override
  void initState() {
    super.initState();
    final hotelId = widget.hotel.id ?? '';
    _roomsStream = _firestore.getRoomsByHotel(hotelId);
    _reservationsStream = _firestore.getReservationsByUserStream('');
    _detailsFuture = _firestore.getHotelDetails(hotelId);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: widget.initialTabIndex,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.hotel.name),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Chambres'),
              Tab(text: 'Réservations'),
              Tab(text: 'Statistiques'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingHorizontal,
                vertical: AppSpacing.md,
              ),
              child: _HotelHeaderCompact(hotel: widget.hotel, images: _demoImages),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingHorizontal,
                vertical: AppSpacing.sm,
              ),
              child: _MetaCard(hotel: widget.hotel),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _RoomsTab(roomsStream: _roomsStream, hotelId: widget.hotel.id ?? ''),
                  _ReservationsTab(reservationsStream: _reservationsStream),
                  _StatsTab(detailsFuture: _detailsFuture, hotel: widget.hotel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomsTab extends StatelessWidget {
  final Stream<List<Room>> roomsStream;
  final String hotelId;

  const _RoomsTab({required this.roomsStream, required this.hotelId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingHorizontal,
        vertical: AppSpacing.md,
      ),
      child: StreamBuilder<List<Room>>(
        stream: roomsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoader(message: 'Chargement des chambres...');
          }
          if (snapshot.hasError) {
            return const ErrorState(
              title: 'Erreur lors du chargement des chambres',
            );
          }

          final rooms = snapshot.data ?? [];
          if (rooms.isEmpty) {
            return const EmptyState(
              icon: Icons.king_bed_outlined,
              title: 'Aucune chambre',
              subtitle: 'Aucune chambre n\'est configurée pour cet hôtel.',
            );
          }

          final demoImages = [
            'https://images.unsplash.com/photo-1505691938895-1758d7feb511?auto=format&fit=crop&w=1400&q=80',
            'https://images.unsplash.com/photo-1496417263034-38ec4f0b665a?auto=format&fit=crop&w=1400&q=80',
            'https://images.unsplash.com/photo-1505691938895-1758d7feb511?auto=format&fit=crop&w=1400&q=80',
          ];

          return ListView.separated(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              final fallbackUrl = demoImages[index % demoImages.length];
              final imageUrl = (room.imageUrl?.isNotEmpty ?? false) ? room.imageUrl! : fallbackUrl;
              return _RoomCard(
                room: room,
                imageUrl: imageUrl,
                hotelId: hotelId,
              );
            },
            separatorBuilder: (context, _) => const SizedBox(height: AppSpacing.md),
          );
        },
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final Room room;
  final String? hotelId;
  final String imageUrl;

  const _RoomCard({required this.room, required this.hotelId, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isMobile = ResponsiveHelper.isMobile(context);
        final hasImage = (room.imageUrl?.isNotEmpty ?? false) || imageUrl.isNotEmpty;
        final nightlyPrice = (room.basePrice + room.viewExtra).toDouble();
        final canBook = room.isAvailable && authProvider.isAuthenticated;
        final isLoggedIn = authProvider.isAuthenticated;

        return AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasImage)
                ClipRRect(
                  borderRadius: AppBorderRadius.allMd,
                  child: Image.network(
                    imageUrl,
                    width: isMobile ? 110 : 140,
                    height: isMobile ? 80 : 96,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _ImagePlaceholder(isMobile: isMobile),
                  ),
                )
              else
                _ImagePlaceholder(isMobile: isMobile),
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
                        Text(
                          '${nightlyPrice.toStringAsFixed(0)} DH / nuit',
                          style: AppTextStyles.subtitle1.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        _AvailabilityBadge(isAvailable: room.isAvailable),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Bouton de réservation principal
                    SizedBox(
                      width: double.infinity,
                      child: Consumer<BookingProvider>(
                        builder: (context, bookingProvider, child) {
                          return FilledButton.icon(
                            onPressed: () async {
                              if (!isLoggedIn) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Veuillez vous connecter pour réserver'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              if (!room.isAvailable) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Chambre indisponible pour le moment.')),
                                );
                                return;
                              }
                              final result = await Navigator.push<bool?>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChangeNotifierProvider.value(
                                    value: bookingProvider,
                                    child: BookRoomScreen(
                                      room: room,
                                      hotelId: hotelId,
                                    ),
                                  ),
                                ),
                              );
                              if (!context.mounted) return;
                              if (result == true) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Réservation créée avec succès!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: canBook 
                                  ? AppColors.success 
                                  : (!isLoggedIn ? AppColors.warning : AppColors.textSecondary),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            icon: bookingProvider.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    !isLoggedIn
                                        ? Icons.login
                                        : (room.isAvailable ? Icons.calendar_today : Icons.block),
                                    size: 20,
                                  ),
                            label: Text(
                              bookingProvider.isLoading
                                  ? 'Réservation en cours...'
                                  : (!isLoggedIn
                                      ? 'Se connecter pour réserver'
                                      : (room.isAvailable ? 'RÉSERVER MAINTENANT' : 'INDISPONIBLE')),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Bouton détails plus petit
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RoomDetailsScreen(
                                    room: room,
                                  ),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Voir les détails'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _capacityAndView(Room room) {
    final capacity = (room.capacity ?? 0) > 0 ? '${room.capacity} pers.' : 'Capacité inconnue';
    final view = room.view.isNotEmpty ? ' · Vue ${room.view}' : '';
    return '$capacity$view';
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final bool isMobile;

  const _ImagePlaceholder({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isMobile ? 110 : 140,
      height: isMobile ? 80 : 96,
      decoration: BoxDecoration(
        color: AppColors.primaryVeryLight,
        borderRadius: AppBorderRadius.allMd,
      ),
      child: Icon(Icons.king_bed, color: AppColors.primary, size: isMobile ? 32 : 40),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        isAvailable ? 'Libre' : 'Occupée',
        style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// Placeholder classes for remaining tabs
class _ReservationsTab extends StatelessWidget {
  final Stream<List<Reservation>> reservationsStream;

  const _ReservationsTab({required this.reservationsStream});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Réservations - En construction'),
    );
  }
}

class _StatsTab extends StatelessWidget {
  final Future<Map<String, dynamic>?> detailsFuture;
  final Hotel hotel;

  const _StatsTab({required this.detailsFuture, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Statistiques - En construction'),
    );
  }
}

class _HotelHeaderCompact extends StatelessWidget {
  final Hotel hotel;
  final List<String> images;

  const _HotelHeaderCompact({required this.hotel, required this.images});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryVeryLight,
        borderRadius: AppBorderRadius.allLg,
      ),
      child: Row(
        children: [
          Icon(Icons.apartment, color: AppColors.primary, size: 32),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hotel.name, style: AppTextStyles.headline3),
                if (hotel.city.isNotEmpty)
                  Text(hotel.city, style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaCard extends StatelessWidget {
  final Hotel hotel;

  const _MetaCard({required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.allLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MetaItem(
            icon: Icons.star,
            label: 'Note',
            value: (hotel.rating ?? 0) > 0 ? '${hotel.rating}/5' : 'N/C',
          ),
          _MetaItem(
            icon: Icons.location_on,
            label: 'Ville',
            value: hotel.city.isNotEmpty ? hotel.city : 'N/C',
          ),
          _MetaItem(
            icon: Icons.euro,
            label: 'Prix',
            value: hotel.price > 0 ? '${hotel.price.toInt()}€' : 'Variable',
          ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        Text(value, style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}