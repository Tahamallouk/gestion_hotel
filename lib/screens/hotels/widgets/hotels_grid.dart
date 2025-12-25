import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gestion_hotel/models/hotel.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/cards/hotel_card.dart';

class HotelsGrid extends StatelessWidget {
  final List<Hotel> hotels;
  final void Function(Hotel) onTap;
  final void Function(Hotel)? onBookNow;
  final bool loading;

  const HotelsGrid({
    super.key,
    required this.hotels,
    required this.onTap,
    this.onBookNow,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (hotels.isEmpty && !loading) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.hotel_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Aucun hôtel trouvé',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Essayez de modifier vos critères de recherche',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final columns = math.min(ResponsiveHelper.getGridColumns(context), 3);
    
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: columns == 1 ? 1.2 : 1.35,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index < hotels.length) {
            final hotel = hotels[index];
            return HotelCard(
              hotelId: hotel.id ?? '',
              name: hotel.name,
              address: hotel.address,
              imageUrl: hotel.imageUrl ?? '',
              rating: hotel.rating ?? 0.0,
              pricePerNight: hotel.pricePerNight ?? hotel.price,
              onTap: () => onTap(hotel),
            );
          }
          
          // Loading indicator for more items
          if (loading && index == hotels.length) {
            return const Card(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          return null;
        },
        childCount: hotels.length + (loading ? 1 : 0),
      ),
    );
  }
}

class HotelsList extends StatelessWidget {
  final List<Hotel> hotels;
  final void Function(Hotel) onTap;
  final void Function(Hotel)? onBookNow;
  final bool loading;

  const HotelsList({
    super.key,
    required this.hotels,
    required this.onTap,
    this.onBookNow,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (hotels.isEmpty && !loading) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.hotel_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Aucun hôtel trouvé',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index < hotels.length) {
            final hotel = hotels[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == hotels.length - 1 ? 0 : AppSpacing.md,
              ),
              child: HotelCard(
                hotelId: hotel.id ?? '',
                name: hotel.name,
                address: hotel.address,
                imageUrl: hotel.imageUrl ?? '',
                rating: hotel.rating ?? 0.0,
                pricePerNight: hotel.pricePerNight ?? hotel.price,
                onTap: () => onTap(hotel),
              ),
            );
          }
          
          // Loading indicator
          if (loading && index == hotels.length) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          return null;
        },
        childCount: hotels.length + (loading ? 1 : 0),
      ),
    );
  }
}