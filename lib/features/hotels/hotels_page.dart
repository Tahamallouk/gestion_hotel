import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:gestion_hotel/models/hotel.dart';
import 'package:gestion_hotel/services/osm_search_service.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/app_card.dart';
import 'package:gestion_hotel/widgets/cards/hotel_card.dart' as cards;
import 'package:gestion_hotel/widgets/error_state.dart';
import 'package:gestion_hotel/widgets/section_header.dart';


import 'hotel_details_page.dart';

class HotelsPage extends StatefulWidget {
  const HotelsPage({super.key});

  @override
  State<HotelsPage> createState() => _HotelsPageState();
}

class _HotelsPageState extends State<HotelsPage> {
  final _searchService = OsmSearchService();
  final _queryController = TextEditingController();
  Timer? _debounce;
  final Map<String, ll.LatLng> _coordsByHotel = {};

  static const String _defaultSort = 'Note';

  static const Map<String, List<String>> _countryCities = {
    'Maroc': ['Casablanca', 'Marrakech', 'Rabat', 'Tanger', 'Fès', 'Agadir'],
    'France': ['Paris', 'Lyon', 'Marseille', 'Nice', 'Bordeaux', 'Lille'],
    'Espagne': ['Madrid', 'Barcelone', 'Valence', 'Séville', 'Malaga'],
    'Italie': ['Rome', 'Milan', 'Florence', 'Venise', 'Naples'],
    'USA': ['New York', 'Los Angeles', 'Miami', 'Chicago', 'San Francisco'],
    'Canada': ['Montréal', 'Toronto', 'Vancouver', 'Québec'],
    'Émirats arabes unis': ['Dubaï', 'Abou Dabi', 'Sharjah'],
    'Turquie': ['Istanbul', 'Ankara', 'Izmir', 'Antalya'],
    'Royaume-Uni': ['Londres', 'Manchester', 'Edimbourg', 'Birmingham'],
    'Allemagne': ['Berlin', 'Munich', 'Hambourg', 'Francfort'],
  };

  List<Hotel> _allHotels = [];
  List<Hotel> _hotels = [];
  final List<String> _countries = _countryCities.keys.toList();
  bool _loading = false;
  String? _error;
  String? _selectedHotelId;
  String _selectedCountry = '';
  String _selectedCity = '';
  String _sort = _defaultSort;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _performSearch([String? forcedQuery]) async {
    final fromInput = (forcedQuery ?? _queryController.text).trim();
    final fallbackQuery = _queryFromFilters();
    final query = fromInput.isNotEmpty ? fromInput : fallbackQuery;

    if (query.isEmpty) {
      setState(() {
        _allHotels = [];
        _hotels = [];
        _coordsByHotel.clear();
        _selectedHotelId = null;
        _error = null;
      });
      return;
    }

    // Keep the text field in sync when the query is derived from filters only.
    if (fromInput.isEmpty && query.isNotEmpty && _queryController.text.trim().isEmpty) {
      _queryController.text = query;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final hotels = await _searchService.searchHotels(query);
      if (!mounted) return;
      setState(() {
        _allHotels = hotels;
      });
      _applyFiltersAndSort();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Recherche impossible ($e)');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _hotelKey(Hotel hotel) => hotel.id ?? hotel.name;

  String _queryFromFilters() {
    final parts = <String>[];
    if (_selectedCity.isNotEmpty) parts.add(_selectedCity);
    if (_selectedCountry.isNotEmpty) parts.add(_selectedCountry);
    return parts.join(' ').trim();
  }

  ll.LatLng get _fallbackCenter => const ll.LatLng(5.348, -4.027); // Abidjan default

  ll.LatLng? _parseLatLng(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split(',');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return null;
    return ll.LatLng(lat, lng);
  }

  void _onSelectHotel(Hotel hotel) {
    final key = _hotelKey(hotel);
    setState(() => _selectedHotelId = key);
  }

  void _applyFiltersAndSort() {
    var list = _allHotels;

    if (_selectedCountry.isNotEmpty) {
      list = list.where(_matchesSelectedCountry).toList();
    }

    if (_selectedCity.isNotEmpty) {
      list = list.where(_matchesSelectedCity).toList();
    }

    switch (_sort) {
      case 'Valeur':
        list.sort((a, b) {
          final aScore = (a.rating ?? 0) / (a.price <= 0 ? 1 : a.price);
          final bScore = (b.rating ?? 0) / (b.price <= 0 ? 1 : b.price);
          return bScore.compareTo(aScore);
        });
        break;
      case 'Note':
        list.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      default:
        list = List<Hotel>.from(list);
    }

    _coordsByHotel
      ..clear()
      ..addEntries(
        list
            .map((h) => MapEntry(_hotelKey(h), _parseLatLng(h.location)))
            .where((entry) => entry.value != null)
            .map((entry) => MapEntry(entry.key, entry.value!)),
      );

    Hotel? firstWithCoords;
    if (list.isNotEmpty) {
      firstWithCoords = list.firstWhere(
        (h) => _coordsByHotel.containsKey(_hotelKey(h)),
        orElse: () => list.first,
      );
    }

    setState(() {
      _hotels = list;
      _selectedHotelId = firstWithCoords != null ? _hotelKey(firstWithCoords) : null;
    });
  }

  void _openDetails(Hotel hotel) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => HotelDetailsPage(hotel: hotel)),
    );
  }

  void _onCountryChanged(String? value) {
    setState(() {
      _selectedCountry = value?.trim() ?? '';
      _selectedCity = '';
    });
    final query = _queryFromFilters();
    if (_allHotels.isEmpty && query.isNotEmpty && _queryController.text.trim().isEmpty) {
      _performSearch(query);
    } else {
      _applyFiltersAndSort();
    }
  }

  void _onCityChanged(String? value) {
    setState(() {
      _selectedCity = value?.trim() ?? '';
    });
    final query = _queryFromFilters();
    if (_allHotels.isEmpty && query.isNotEmpty && _queryController.text.trim().isEmpty) {
      _performSearch(query);
    } else {
      _applyFiltersAndSort();
    }
  }

  bool _matchesSelectedCountry(Hotel hotel) {
    final selected = _selectedCountry.toLowerCase();
    final hotelCountry = (hotel.country).toLowerCase();
    if (hotelCountry == selected) return true;

    // Fallback: infer country via city list mapping when country is missing or different wording.
    if (hotelCountry.isEmpty || hotelCountry == 'unknown') {
      final cities = _countryCities[_selectedCountry] ?? const [];
      final hotelCity = hotel.city.toLowerCase();
      return cities.any((c) => hotelCity == c.toLowerCase());
    }

    // Soft match: contains to accommodate minor naming differences.
    return hotelCountry.contains(selected) || selected.contains(hotelCountry);
  }

  bool _matchesSelectedCity(Hotel hotel) {
    final cityNeedle = _selectedCity.toLowerCase();
    final hotelCity = hotel.city.toLowerCase();
    if (hotelCity == cityNeedle) return true;

    // Allow partial contains to be forgiving.
    return hotelCity.contains(cityNeedle) || cityNeedle.contains(hotelCity);
  }

  void _onSortChanged(String value) {
    setState(() {
      _sort = value;
    });
    _applyFiltersAndSort();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = AppSpacing.screenPaddingHorizontal;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: AppSpacing.xl),
        child: ErrorState(title: 'Hôtels', subtitle: _error, onRetry: _performSearch),
      );
    }
    // No initial results is allowed; user should search.

    final isMobile = ResponsiveHelper.isMobile(context);
    final gridCount = isMobile ? 1 : 3;
    final hotelsToShow = _hotels;
    final currentSelected = hotelsToShow.any((h) => _hotelKey(h) == _selectedHotelId)
      ? _selectedHotelId
      : (hotelsToShow.isNotEmpty ? _hotelKey(hotelsToShow.first) : null);

    return RefreshIndicator(
      onRefresh: _performSearch,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: 'Hôtels',
                    subtitle: hotelsToShow.isEmpty ? 'Choisissez un pays ou tapez pour chercher des hôtels' : '${hotelsToShow.length} résultat(s)',
                    action: TextButton.icon(
                      onPressed: () => _performSearch(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Actualiser'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Filtrer rapidement', style: AppTextStyles.subtitle2),
                        const SizedBox(height: AppSpacing.sm),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Pays',
                            prefixIcon: Icon(Icons.public),
                            border: OutlineInputBorder(),
                          ),
                          key: ValueKey('country-${_selectedCountry.isEmpty ? 'none' : _selectedCountry}'),
                          initialValue: _selectedCountry.isEmpty ? null : _selectedCountry,
                          items: _countries
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: _onCountryChanged,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Ville',
                            prefixIcon: Icon(Icons.location_city),
                            border: OutlineInputBorder(),
                          ),
                          key: ValueKey('city-${_selectedCity.isEmpty ? 'none' : _selectedCity}-${_selectedCountry.isEmpty ? 'all' : _selectedCountry}'),
                          initialValue: _selectedCity.isEmpty ? null : _selectedCity,
                          items: (_selectedCountry.isNotEmpty
                                  ? _countryCities[_selectedCountry] ?? const []
                                  : _countryCities.values.expand((e) => e).toSet().toList())
                              .map((city) => DropdownMenuItem(value: city, child: Text(city)))
                              .toList(),
                          onChanged: _onCityChanged,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            ChoiceChip(
                              label: const Text('Mieux notés'),
                              selected: _sort == 'Note',
                              onSelected: (_) => _onSortChanged('Note'),
                            ),
                            ChoiceChip(
                              label: const Text('Qualité/prix'),
                              selected: _sort == 'Valeur',
                              onSelected: (_) => _onSortChanged('Valeur'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      labelText: 'Chercher un hôtel ou une ville',
                      border: const OutlineInputBorder(),
                      hintText: 'Ex: Marriott Paris ou Abidjan hotel',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () => _performSearch(),
                      ),
                    ),
                    controller: _queryController,
                    onChanged: (value) {
                      _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 400), () => _performSearch(value));
                    },
                    onSubmitted: (value) => _performSearch(value),
                    textInputAction: TextInputAction.search,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              const Icon(Icons.map_outlined, color: AppColors.textSecondary),
                              const SizedBox(width: AppSpacing.sm),
                              Text('Carte des résultats', style: AppTextStyles.subtitle1),
                              const Spacer(),
                              if (hotelsToShow.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.08),
                                    borderRadius: AppBorderRadius.allMd,
                                  ),
                                  child: Text('${hotelsToShow.length} hôtels', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                                ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        if (hotelsToShow.isEmpty)
                          _MapPlaceholder(message: _loading ? 'Recherche en cours...' : 'Aucun résultat. Saisissez un pays ou un nom ci-dessus.')
                        else if (_coordsByHotel.isEmpty)
                          _MapPlaceholder(message: 'Aucune coordonnée disponible pour ces hôtels. Ajoutez latitude,longitude dans le champ location.')
                        else
                          _MapSection(
                            hotels: hotelsToShow,
                            coordsByHotel: _coordsByHotel,
                            selectedHotelId: currentSelected,
                            fallback: _fallbackCenter,
                            onHotelTap: (hotel) {
                              _onSelectHotel(hotel);
                              _openDetails(hotel);
                            },
                            onMarkerTap: _onSelectHotel,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: AppSpacing.lg),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridCount,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: gridCount == 1 ? 1.2 : 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final hotel = hotelsToShow[index];
                  final key = _hotelKey(hotel);
                  final selected = key == currentSelected;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: AppBorderRadius.allMd,
                      border: Border.all(color: selected ? AppColors.primary : Colors.transparent, width: selected ? 1.5 : 0.5),
                    ),
                    child: cards.HotelCard(
                      hotelId: hotel.id ?? hotel.name,
                      name: hotel.name,
                      address: hotel.city.isNotEmpty ? '${hotel.city} · ${hotel.address}' : hotel.address,
                      imageUrl: hotel.imageUrl ?? '',
                      rating: hotel.rating ?? 0.0,
                      pricePerNight: hotel.price,
                      onTap: () {
                        _onSelectHotel(hotel);
                        _openDetails(hotel);
                      },
                    ),
                  );
                },
                childCount: hotelsToShow.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        ],
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  final String message;

  const _MapPlaceholder({required this.message});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          const Icon(Icons.map_outlined, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapSection extends StatelessWidget {
  final List<Hotel> hotels;
  final Map<String, ll.LatLng> coordsByHotel;
  final String? selectedHotelId;
  final ll.LatLng fallback;
  final ValueChanged<Hotel> onMarkerTap;
  final ValueChanged<Hotel> onHotelTap;

  const _MapSection({
    required this.hotels,
    required this.coordsByHotel,
    required this.selectedHotelId,
    required this.fallback,
    required this.onMarkerTap,
    required this.onHotelTap,
  });

  @override
  Widget build(BuildContext context) {
    final markerEntries = hotels
        .map((hotel) {
          final key = hotel.id ?? hotel.name;
          final coords = coordsByHotel[key];
          if (coords == null) return null;
          final selected = key == selectedHotelId;
          final color = selected ? AppColors.primary : AppColors.textSecondary;
          return Marker(
            point: coords,
            width: 60,
            height: 60,
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () => onMarkerTap(hotel),
              onLongPress: () => onHotelTap(hotel),
              child: Icon(Icons.location_on, color: color, size: 32),
            ),
          );
        })
        .whereType<Marker>()
        .toList();

    final firstPosition = markerEntries.isNotEmpty ? markerEntries.first.point : fallback;
    final center = selectedHotelId != null && coordsByHotel[selectedHotelId!] != null ? coordsByHotel[selectedHotelId!]! : firstPosition;

    return AppCard(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: ResponsiveHelper.isMobile(context) ? 260 : 360,
        child: FlutterMap(
          key: ValueKey(selectedHotelId ?? 'map'),
          options: MapOptions(
            initialCenter: center,
            initialZoom: 12,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom | InteractiveFlag.doubleTapZoom,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.gestion.hotel',
              tileProvider: CancellableNetworkTileProvider(),
            ),
            MarkerLayer(markers: markerEntries),
          ],
        ),
      ),
    );
  }


}
