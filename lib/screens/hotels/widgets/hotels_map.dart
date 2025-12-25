import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:gestion_hotel/models/hotel.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/app_card.dart';

class HotelsMap extends StatelessWidget {
  final List<Hotel> hotels;
  final Map<String, ll.LatLng> coordsByHotel;
  final String? selectedHotelId;
  final ll.LatLng fallbackCenter;
  final ValueChanged<Hotel> onMarkerTap;
  final ValueChanged<Hotel> onHotelTap;

  const HotelsMap({
    super.key,
    required this.hotels,
    required this.coordsByHotel,
    required this.selectedHotelId,
    required this.fallbackCenter,
    required this.onMarkerTap,
    required this.onHotelTap,
  });

  @override
  Widget build(BuildContext context) {
    final hotelsWithCoords = hotels
        .where((h) => coordsByHotel.containsKey(h.id ?? h.name))
        .toList();

    if (hotelsWithCoords.isEmpty) {
      return AppCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(
                Icons.map_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Ajoutez la latitude,longitude dans le champ location pour afficher les hôtels sur la carte.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final center = _getMapCenter(hotelsWithCoords);
    final markers = _buildMarkers(context, hotelsWithCoords);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Map controls section
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vue carte',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: hotelsWithCoords.map((hotel) {
                  final isSelected = hotel.id == selectedHotelId || hotel.name == selectedHotelId;
                  return ActionChip(
                    avatar: Icon(
                      Icons.location_on,
                      size: 18,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.primary,
                    ),
                    label: Text(hotel.name),
                    backgroundColor: isSelected 
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    labelStyle: TextStyle(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.onPrimary
                          : null,
                    ),
                    onPressed: () => onHotelTap(hotel),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Map
        AppCard(
          child: SizedBox(
            height: 400,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 8.0,
                minZoom: 3.0,
                maxZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.gestion_hotel',
                  tileProvider: CancellableNetworkTileProvider(),
                ),
                MarkerLayer(markers: markers),
              ],
            ),
          ),
        ),
      ],
    );
  }

  ll.LatLng _getMapCenter(List<Hotel> hotelsWithCoords) {
    if (selectedHotelId != null && coordsByHotel[selectedHotelId!] != null) {
      return coordsByHotel[selectedHotelId!]!;
    }
    
    if (hotelsWithCoords.isNotEmpty) {
      final key = hotelsWithCoords.first.id ?? hotelsWithCoords.first.name;
      return coordsByHotel[key] ?? fallbackCenter;
    }
    
    return fallbackCenter;
  }

  List<Marker> _buildMarkers(BuildContext context, List<Hotel> hotelsWithCoords) {
    return hotelsWithCoords.map((hotel) {
      final key = hotel.id ?? hotel.name;
      final coords = coordsByHotel[key]!;
      final selected = key == selectedHotelId;
      
      return Marker(
        point: coords,
        width: 58,
        height: 58,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () => onMarkerTap(hotel),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.location_on,
              color: selected 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: selected ? 34 : 30,
            ),
          ),
        ),
      );
    }).toList();
  }
}