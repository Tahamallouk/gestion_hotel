import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:gestion_hotel/models/hotel.dart';

/// Minimal OSM/Nominatim hotel search for free-text queries.
class OsmSearchService {
  static const _base = 'nominatim.openstreetmap.org';
  static const _defaultHeaders = {
    // Nominatim requires a valid user agent; keep it simple but explicit.
    'User-Agent': 'gestion_hotel/1.0 (contact: support@example.com)',
    'Accept-Language': 'fr',
  };

  final _rand = Random();

  Future<List<Hotel>> searchHotels(String query, {int limit = 12}) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    final uri = Uri.https(_base, '/search', {
      'q': '$q hotel',
      'format': 'jsonv2',
      'addressdetails': '1',
      'limit': limit.toString(),
    });

    final resp = await http.get(uri, headers: _defaultHeaders);
    if (resp.statusCode != 200) {
      throw Exception('Recherche indisponible (${resp.statusCode})');
    }

    final dynamic data = jsonDecode(resp.body);
    if (data is! List) return [];

    return data.map<Hotel>((item) {
      final name = (item['name'] as String?)?.trim();
      final displayName = (item['display_name'] as String?)?.trim() ?? '';
      final latStr = item['lat']?.toString();
      final lonStr = item['lon']?.toString();
      final lat = double.tryParse(latStr ?? '');
      final lon = double.tryParse(lonStr ?? '');

      final address = item['address'] is Map ? (item['address'] as Map<String, dynamic>) : <String, dynamic>{};
      final city = (address['city'] ?? address['town'] ?? address['village'] ?? address['state'] ?? '').toString();
      final road = (address['road'] ?? '').toString();
      final house = (address['house_number'] ?? '').toString();
      final addressLine = [house, road, city].where((p) => p.trim().isNotEmpty).join(' ').trim();

      final imageUrl = _imageForHotel(name, city, latStr, lonStr);
      final price = 60 + _rand.nextInt(140); // 60-199 DH
      final rating = 3.5 + _rand.nextDouble() * 1.5; // 3.5-5.0

      return Hotel(
        id: item['place_id']?.toString(),
        name: name?.isNotEmpty == true ? name! : (displayName.isNotEmpty ? displayName.split(',').first : 'Hôtel'),
        city: city,
        address: addressLine.isNotEmpty ? addressLine : displayName,
        location: (lat != null && lon != null) ? '$lat,$lon' : '',
        price: price.toDouble(),
        rating: double.parse(rating.toStringAsFixed(1)),
        imageUrl: imageUrl,
      );
    }).where((h) => h.location.isNotEmpty).toList(growable: false);
  }

  String _imageForHotel(String? name, String city, String? lat, String? lon) {
    final seed = _stableHash('${name ?? ''}|$city|${lat ?? ''}|${lon ?? ''}');
    // Deterministic placeholder: same hotel -> same picture, different hotels -> different picture
    return 'https://picsum.photos/seed/$seed/800/500';
  }

  int _stableHash(String input) {
    int hash = 0;
    for (final codeUnit in input.codeUnits) {
      hash = 0x1fffffff & (hash + codeUnit);
      hash = 0x1fffffff & (hash + ((hash << 10)));
      hash ^= (hash >> 6);
    }
    hash = 0x1fffffff & (hash + (hash << 3));
    hash ^= (hash >> 11);
    hash = 0x1fffffff & (hash + (hash << 15));
    return hash.abs();
  }
}
