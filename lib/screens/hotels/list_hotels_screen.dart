import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:gestion_hotel/models/hotel.dart';
import 'package:gestion_hotel/screens/hotels/hotel_detail_screen.dart';
import 'package:gestion_hotel/services/hotels_service.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/common/app_loader.dart';
import 'package:gestion_hotel/widgets/error_state.dart';
import 'package:gestion_hotel/screens/hotels/widgets/hotels_filters_card.dart';
import 'package:gestion_hotel/screens/hotels/widgets/hotels_page_header.dart';
import 'package:gestion_hotel/screens/hotels/widgets/hotels_map.dart';
import 'package:gestion_hotel/screens/hotels/widgets/hotels_grid.dart';
import 'package:gestion_hotel/screens/hotels/widgets/booking_guide_card.dart';
import 'package:gestion_hotel/screens/hotels/widgets/booking_status_widget.dart';

class ListHotelsScreen extends StatefulWidget {
  const ListHotelsScreen({super.key});

  @override
  State<ListHotelsScreen> createState() => _ListHotelsScreenState();
}

class _ListHotelsScreenState extends State<ListHotelsScreen> {
  final _hotelsService = HotelsService();
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  List<Hotel> _hotels = [];
  List<Hotel> _visibleHotels = [];
  List<String> _cities = [];
  List<String> _countries = [];
  String _selectedCity = '';
  String _selectedCountry = '';
  String _sort = 'Note';
  Map<String, ll.LatLng> _coordsByHotel = {};
  String? _selectedHotelOnMap;
  bool _showMap = false;

  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;
  bool _initialLoading = true;
  bool _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_applyFilters);
    _scrollCtrl.addListener(_maybeLoadMore);
    _loadFirstPage();
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_maybeLoadMore);
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _initialLoading = true;
      _error = null;
      _hasMore = true;
      _lastDoc = null;
    });

    final result = await _hotelsService.loadHotels(limit: 12);
    
    if (result.isSuccess) {
      _hotels = result.items;
      _lastDoc = result.lastDocument;
      _hasMore = result.hasMore;
      _coordsByHotel = _hotelsService.indexHotelLocations(_hotels);
      _updateFilterOptions();
      _applyFilters();
    } else {
      _error = result.error;
    }
    
    if (mounted) setState(() => _initialLoading = false);
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    
    setState(() => _loadingMore = true);
    
    final result = await _hotelsService.loadHotels(
      limit: 12,
      startAfter: _lastDoc,
    );
    
    if (result.isSuccess) {
      _hotels.addAll(result.items);
      _lastDoc = result.lastDocument ?? _lastDoc;
      _hasMore = result.hasMore;
      _coordsByHotel.addAll(_hotelsService.indexHotelLocations(result.items));
      _updateFilterOptions();
      _applyFilters();
    }
    
    if (mounted) setState(() => _loadingMore = false);
  }

  void _maybeLoadMore() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 320) {
      _loadMore();
    }
  }

  void _updateFilterOptions() {
    setState(() {
      _cities = _hotelsService.extractCities(_hotels);
      _countries = _hotelsService.extractCountries(_hotels);
      
      // Reset filters if they're no longer valid
      if (_selectedCity.isNotEmpty && !_cities.contains(_selectedCity)) {
        _selectedCity = '';
      }
      if (_selectedCountry.isNotEmpty && !_countries.contains(_selectedCountry)) {
        _selectedCountry = '';
      }
    });
  }

  void _applyFilters() {
    final filtered = _hotelsService.filterHotels(
      _hotels,
      searchQuery: _searchCtrl.text,
      selectedCity: _selectedCity.isEmpty ? null : _selectedCity,
      selectedCountry: _selectedCountry.isEmpty ? null : _selectedCountry,
    );

    _hotelsService.sortHotels(filtered, _sort);
    setState(() => _visibleHotels = filtered);
  }

  void _clearFilters() {
    _searchCtrl.clear();
    setState(() {
      _selectedCity = '';
      _selectedCountry = '';
    });
    _applyFilters();
  }

  bool get _hasFilters =>
      _searchCtrl.text.isNotEmpty ||
      _selectedCity.isNotEmpty ||
      _selectedCountry.isNotEmpty;

  void _navigateToHotel(Hotel hotel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HotelDetailScreen(hotel: hotel),
      ),
    );
  }

  void _navigateToBooking(Hotel hotel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HotelDetailScreen(
          hotel: hotel,
          initialTabIndex: 0, // Tab "Chambres"
        ),
      ),
    );
  }

  void _onMarkerTap(Hotel hotel) {
    setState(() {
      _selectedHotelOnMap = hotel.id ?? hotel.name;
    });
  }

  void _onHotelTap(Hotel hotel) {
    setState(() {
      _selectedHotelOnMap = hotel.id ?? hotel.name;
    });
    // Optionally scroll to hotel in list
  }

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = AppSpacing.lg;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hôtels'),
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: _initialLoading
          ? const AppLoader()
          : _error != null
              ? ErrorState(
                  title: 'Erreur de chargement',
                  subtitle: _error!,
                  onRetry: _loadFirstPage,
                )
              : RefreshIndicator(
                  onRefresh: _loadFirstPage,
                  child: CustomScrollView(
                    controller: _scrollCtrl,
                    slivers: [
                      // Header and filters
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: AppSpacing.lg,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              HotelsPageHeader(
                                totalCount: _hotels.length,
                                loadedMore: !_hasMore,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              HotelsFiltersCard(
                                searchCtrl: _searchCtrl,
                                cities: _cities,
                                countries: _countries,
                                selectedCity: _selectedCity,
                                selectedCountry: _selectedCountry,
                                sort: _sort,
                                onSortChanged: (value) {
                                  setState(() => _sort = value);
                                  _applyFilters();
                                },
                                onCityChanged: (value) {
                                  setState(() => _selectedCity = value ?? '');
                                  _applyFilters();
                                },
                                onCountryChanged: (value) {
                                  setState(() => _selectedCountry = value ?? '');
                                  _applyFilters();
                                },
                                onClear: _hasFilters ? _clearFilters : null,
                                showMap: _showMap,
                                onToggleMap: (value) => setState(() => _showMap = value),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Booking Guide Card
                      const SliverToBoxAdapter(
                        child: BookingGuideCard(),
                      ),

                      // Booking Status Widget
                      const SliverToBoxAdapter(
                        child: BookingStatusWidget(),
                      ),

                      // Map section
                      if (_showMap)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                            ),
                            child: Column(
                              children: [
                                HotelsMap(
                                  hotels: _visibleHotels,
                                  coordsByHotel: _coordsByHotel,
                                  selectedHotelId: _selectedHotelOnMap,
                                  fallbackCenter: _hotelsService.defaultCenter,
                                  onMarkerTap: _onMarkerTap,
                                  onHotelTap: _onHotelTap,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                              ],
                            ),
                          ),
                        ),

                      // Hotels grid/list
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        sliver: HotelsGrid(
                          hotels: _visibleHotels,
                          loading: _loadingMore,
                          onTap: _navigateToHotel,
                          onBookNow: _navigateToBooking,
                        ),
                      ),

                      // Bottom padding
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.xl),
                      ),
                    ],
                  ),
                ),
    );
  }
}