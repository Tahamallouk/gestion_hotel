import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestion_hotel/models/hotel.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:latlong2/latlong.dart' as ll;

class HotelsService {
  static final _instance = HotelsService._internal();
  factory HotelsService() => _instance;
  HotelsService._internal();

  final _firestore = FirestoreService();

  /// Load hotels with pagination
  Future<HotelsPageResult> loadHotels({
    int limit = 12,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      final result = await _firestore.getHotelsPaged(
        limit: limit,
        startAfter: startAfter,
      );
      return HotelsPageResult(
        items: result.items,
        lastDocument: result.lastDocument,
        hasMore: result.hasMore,
        error: null,
      );
    } catch (e) {
      return HotelsPageResult(
        items: [],
        lastDocument: null,
        hasMore: false,
        error: 'Impossible de charger les hôtels: $e',
      );
    }
  }

  /// Filter hotels based on search criteria
  List<Hotel> filterHotels(
    List<Hotel> hotels, {
    String? searchQuery,
    String? selectedCity,
    String? selectedCountry,
  }) {
    return hotels.where((hotel) {
      final query = searchQuery?.toLowerCase().trim() ?? '';
      final cityFilter = selectedCity?.toLowerCase() ?? '';
      final countryFilter = selectedCountry?.toLowerCase() ?? '';

      final matchesSearch = query.isEmpty ||
          hotel.name.toLowerCase().contains(query) ||
          hotel.city.toLowerCase().contains(query) ||
          hotel.address.toLowerCase().contains(query);

      final matchesCity = cityFilter.isEmpty || 
          hotel.city.toLowerCase() == cityFilter;
      
      final matchesCountry = countryFilter.isEmpty || 
          hotel.country.toLowerCase() == countryFilter;

      return matchesSearch && matchesCity && matchesCountry;
    }).toList();
  }

  /// Sort hotels by the specified criteria
  void sortHotels(List<Hotel> hotels, String sortBy) {
    switch (sortBy) {
      case 'Valeur':
        hotels.sort((a, b) {
          final aRating = a.rating ?? 0.0;
          final bRating = b.rating ?? 0.0;
          final aScore = aRating / math.max(a.price, 1);
          final bScore = bRating / math.max(b.price, 1);
          return bScore.compareTo(aScore);
        });
        break;
      case 'Prix ↑':
        hotels.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Prix ↓':
        hotels.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Nom':
        hotels.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Note':
      default:
        hotels.sort((a, b) {
          final aRating = a.rating ?? 0.0;
          final bRating = b.rating ?? 0.0;
          return bRating.compareTo(aRating);
        });
        break;
    }
  }

  /// Extract unique cities from hotels list
  List<String> extractCities(List<Hotel> hotels) {
    final cities = hotels
        .map((h) => h.city)
        .where((city) => city.isNotEmpty)
        .toSet()
        .toList();
    cities.sort();
    return cities;
  }

  /// Extract unique countries from hotels list
  List<String> extractCountries(List<Hotel> hotels) {
    final countries = hotels
        .map((h) => h.country)
        .where((country) => country.isNotEmpty)
        .toSet()
        .toList();
    countries.sort();
    return countries;
  }

  /// Parse coordinates from location string
  ll.LatLng? parseCoordinates(String? location) {
    if (location == null || location.isEmpty) return null;
    
    final parts = location.split(',');
    if (parts.length != 2) return null;
    
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    
    if (lat == null || lng == null) return null;
    
    return ll.LatLng(lat, lng);
  }

  /// Index hotel locations from their data
  Map<String, ll.LatLng> indexHotelLocations(List<Hotel> hotels) {
    final coordsByHotel = <String, ll.LatLng>{};
    
    for (final hotel in hotels) {
      final coords = parseCoordinates(hotel.location);
      if (coords != null) {
        final key = hotel.id ?? hotel.name;
        coordsByHotel[key] = coords;
      }
    }
    
    return coordsByHotel;
  }

  /// Get default fallback center coordinates
  ll.LatLng get defaultCenter => const ll.LatLng(33.5731, -7.5898); // Casablanca

  /// Get available sort options
  List<String> get sortOptions => [
        'Note',
        'Prix ↑',
        'Prix ↓',
        'Valeur',
        'Nom',
      ];
}

class HotelsPageResult {
  final List<Hotel> items;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;
  final String? error;

  const HotelsPageResult({
    required this.items,
    required this.lastDocument,
    required this.hasMore,
    required this.error,
  });

  bool get isSuccess => error == null;
}