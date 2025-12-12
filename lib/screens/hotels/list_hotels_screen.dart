import 'package:flutter/material.dart';
import 'package:gestion_hotel/models/hotel.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/widgets/hotel_card.dart';
import 'package:gestion_hotel/widgets/paginated_list.dart';
import 'hotel_detail_screen.dart';

class ListHotelsScreen extends StatefulWidget {
  const ListHotelsScreen({super.key});

  @override
  State<ListHotelsScreen> createState() => _ListHotelsScreenState();
}

class _ListHotelsScreenState extends State<ListHotelsScreen> {
  final FirestoreService _firestore = FirestoreService();
  final TextEditingController _searchCtrl = TextEditingController();

  List<Hotel> _allHotels = [];
  List<Hotel> _filteredHotels = [];
  Set<String> _cities = {};
  String? _selectedCity;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHotels();
    _searchCtrl.addListener(_filterHotels);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadHotels() async {
    try {
      setState(() => _loading = true);
      final hotels = await _firestore.getHotels();
      setState(() {
        _allHotels = hotels;
        _filteredHotels = hotels;
        _cities = hotels.map((h) => h.city).toSet();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _filterHotels() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredHotels = _allHotels.where((hotel) {
        final matchesSearch = hotel.name.toLowerCase().contains(query) ||
            hotel.city.toLowerCase().contains(query) ||
            hotel.address.toLowerCase().contains(query);

        final matchesCity =
            _selectedCity == null || hotel.city == _selectedCity;

        return matchesSearch && matchesCity;
      }).toList();
    });
  }

  void _clearFilters() {
    _searchCtrl.clear();
    setState(() => _selectedCity = null);
    _filterHotels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hôtels'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /// Search bar
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un hôtel...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchCtrl.clear();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),

                /// City filter
                if (_cities.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          /// "All cities" chip
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: const Text('Toutes les villes'),
                              selected: _selectedCity == null,
                              onSelected: (selected) {
                                setState(() => _selectedCity = null);
                                _filterHotels();
                              },
                            ),
                          ),

                          /// City chips
                          ..._cities.map((city) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(city),
                                selected: _selectedCity == city,
                                onSelected: (selected) {
                                  setState(
                                    () => _selectedCity = selected ? city : null,
                                  );
                                  _filterHotels();
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                /// Hotels list or empty state
                Expanded(
                  child: (_searchCtrl.text.isNotEmpty || _selectedCity != null)
                      // If user is searching or filtering by city - use full fetch and client-side filter
                      ? (_filteredHotels.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.hotel_outlined, size: 64, color: Colors.grey),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Aucun hôtel trouvé',
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  if (_searchCtrl.text.isNotEmpty || _selectedCity != null)
                                    TextButton(
                                      onPressed: _clearFilters,
                                      child: const Text('Réinitialiser les filtres'),
                                    ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _filteredHotels.length,
                              itemBuilder: (context, index) {
                                final hotel = _filteredHotels[index];
                                return HotelCard(
                                  hotel: hotel,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HotelDetailScreen(hotel: hotel),
                                      ),
                                    );
                                  },
                                );
                              },
                            ))
                      // Otherwise use paginated list for better performance
                      : PaginatedList<Hotel>(
                          fetchPage: ({startAfter, limit = 20}) => _firestore.getHotelsPaged(limit: limit, startAfter: startAfter),
                          itemBuilder: (context, hotel, index) {
                            return HotelCard(
                              hotel: hotel,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HotelDetailScreen(hotel: hotel))),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
