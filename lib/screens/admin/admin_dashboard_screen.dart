import 'package:flutter/material.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/services/auth_service.dart';
import 'package:gestion_hotel/widgets/stat_card_advanced.dart';
import 'package:gestion_hotel/widgets/chart_container.dart';
import 'package:gestion_hotel/widgets/occupancy_gauge.dart';
import 'package:gestion_hotel/widgets/reservation_pie_chart.dart';
import 'package:gestion_hotel/widgets/top_hotels_bar_chart.dart';
import 'package:gestion_hotel/widgets/reservations_line_chart.dart';
import 'package:gestion_hotel/widgets/time_range_filter.dart';
import 'package:gestion_hotel/widgets/export_button.dart';
import 'package:gestion_hotel/screens/admin/admin_hotel_detail_screen.dart';

/// Admin Dashboard Screen - Affiche les statistiques et métriques clés du système
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirestoreService _firestore = FirestoreService();
  final AuthService _auth = AuthService();
  
  bool _isLoading = true;
  bool _isAdmin = false;
  String? _errorMessage;
  
  // Time range filter
  int _selectedDays = 30;
  
  // Statistiques
  int _totalHotels = 0;
  int _totalRooms = 0;
  int _totalReservations = 0;
  int _confirmedCount = 0;
  int _cancelledCount = 0;
  int _pendingCount = 0;
  double _occupancyRate = 0.0;
  double _estimatedRevenue = 0.0;
  
  // Charted data
  List<HotelBarData> _topHotels = [];
  Map<String, int> _reservationsPerDay = {};
  List<Map<String, dynamic>> _allHotels = [];

  @override
  void initState() {
    super.initState();
    _checkAdminAndLoadStats();
  }

  Future<void> _checkAdminAndLoadStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        if (!mounted) return;
        Navigator.pop(context);
        return;
      }

      // Check admin role
      final role = await _firestore.getUserRole(uid);
      if (role != 'admin') {
        if (!mounted) return;
        Navigator.pop(context);
        return;
      }

      if (!mounted) return;
      setState(() => _isAdmin = true);

      // Load all statistics
      await _loadAllStatistics();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erreur: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAllStatistics() async {
    try {
      final hotelsCount = await _firestore.getHotelsCount();
      final roomsCount = await _firestore.getRoomsCount();
      final reservationsCount = await _firestore.getReservationsCount();
      final statusCounts = await _firestore.getReservationsByStatus();
      final occupancy = await _firestore.getOccupancyRate();
      final revenue = await _firestore.calculateEstimatedRevenue();
      final topHotels = await _firestore.getTopBookedHotels(limit: 5);
      final reservationsPerDay = await _firestore.getReservationsPerDay(days: _selectedDays);
      final allHotels = await _firestore.getHotels();

      if (!mounted) return;

      // Convert reservation per day to chart data
      final List<DailyReservationData> chartData = [];
      final sortedDates = reservationsPerDay.keys.toList()..sort();
      for (final dateStr in sortedDates) {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          final date = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
          chartData.add(DailyReservationData(
            date: date,
            count: reservationsPerDay[dateStr] ?? 0,
          ));
        }
      }

      // Convert top hotels to chart data
      final hotelChartData = topHotels.map((h) => HotelBarData.fromMap(h)).toList();

      setState(() {
        _totalHotels = hotelsCount;
        _totalRooms = roomsCount;
        _totalReservations = reservationsCount;
        _confirmedCount = statusCounts['confirmed'] ?? 0;
        _cancelledCount = statusCounts['cancelled'] ?? 0;
        _pendingCount = statusCounts['pending'] ?? 0;
        _occupancyRate = occupancy;
        _estimatedRevenue = revenue;
        _topHotels = hotelChartData;
        _reservationsPerDay = reservationsPerDay;
        _allHotels = allHotels.map((h) => {'id': h.id, 'name': h.name}).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erreur lors du chargement des statistiques: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAdmin) {
      return const Scaffold(
        body: Center(child: Text('Accès refusé')),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tableau de bord')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkAdminAndLoadStats,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord admin'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkAdminAndLoadStats,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========== Section 1 : Chiffres clés ==========
              const Text(
                'Chiffres clés',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  StatCardAdvanced(
                    title: 'Total hôtels',
                    value: _totalHotels.toString(),
                    icon: Icons.hotel,
                    color: Colors.blue,
                    subtitle: 'Actifs',
                  ),
                  StatCardAdvanced(
                    title: 'Total chambres',
                    value: _totalRooms.toString(),
                    icon: Icons.door_sliding,
                    color: Colors.green,
                    subtitle: 'Disponibles',
                  ),
                  StatCardAdvanced(
                    title: 'Total réservations',
                    value: _totalReservations.toString(),
                    icon: Icons.calendar_month,
                    color: Colors.orange,
                    subtitle: 'Toutes périodes',
                  ),
                  StatCardAdvanced(
                    title: 'Taux d\'occupation',
                    value: '${_occupancyRate.toStringAsFixed(1)}%',
                    icon: Icons.percent,
                    color: Colors.purple,
                    subtitle: 'Moyen global',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ========== Section 2 : Réservations par statut ==========
              const Text(
                'Réservations par statut',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.0,
                children: [
                  StatCardAdvanced(
                    title: 'Confirmées',
                    value: _confirmedCount.toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                    height: 130,
                    showTrendArrow: false,
                  ),
                  StatCardAdvanced(
                    title: 'Annulées',
                    value: _cancelledCount.toString(),
                    icon: Icons.cancel,
                    color: Colors.red,
                    height: 130,
                    showTrendArrow: false,
                  ),
                  StatCardAdvanced(
                    title: 'En attente',
                    value: _pendingCount.toString(),
                    icon: Icons.hourglass_empty,
                    color: Colors.amber,
                    height: 130,
                    showTrendArrow: false,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ========== Section 3 : Revenus ==========
              const Text(
                'Revenus estimés',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Revenus (confirmées)',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_estimatedRevenue.toStringAsFixed(2)} €',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Basé sur $_confirmedCount réservations',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.trending_up,
                        size: 48,
                        color: Colors.green.withValues(alpha: 0.2),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ========== Section 4 : Jauge d'occupation ==========
              const Text(
                'Occupation globale',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Center(
                child: OccupancyGauge(
                  occupancyRate: _occupancyRate,
                  label: 'Taux global',
                  size: 180,
                ),
              ),

              const SizedBox(height: 24),

              // ========== Section 5 : Graphiques ==========
              const Text(
                'Graphiques et analyses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Time range filter
              TimeRangeFilter(
                selectedDays: _selectedDays,
                onChanged: (days) {
                  setState(() {
                    _selectedDays = days;
                  });
                  _loadAllStatistics();
                },
              ),

              const SizedBox(height: 16),

              // PieChart - Distribution par statut
              ChartContainer(
                title: 'Distribution par statut',
                description: 'Proportion des réservations',
                chart: ReservationPieChart(
                  confirmed: _confirmedCount,
                  cancelled: _cancelledCount,
                  pending: _pendingCount,
                ),
                height: 350,
              ),

              const SizedBox(height: 16),

              // LineChart - Réservations sur période
              ChartContainer(
                title: 'Réservations par jour',
                description: 'Tendance sur $_selectedDays jours',
                chart: _reservationsPerDay.isNotEmpty
                    ? ReservationsLineChart(
                        data: _reservationsPerDay.entries
                            .map((e) {
                              final parts = e.key.split('-');
                              return DailyReservationData(
                                date: DateTime(
                                  int.parse(parts[0]),
                                  int.parse(parts[1]),
                                  int.parse(parts[2]),
                                ),
                                count: e.value,
                              );
                            })
                            .toList()
                          ..sort((a, b) => a.date.compareTo(b.date)),
                      )
                    : const Center(child: Text('Aucune donnée')),
                height: 320,
              ),

              const SizedBox(height: 16),

              // BarChart - Top hôtels
              ChartContainer(
                title: 'Hôtels les plus réservés',
                description: 'Top 5 par nombre de réservations',
                chart: _topHotels.isNotEmpty
                    ? TopHotelsBarChart(
                        hotels: _topHotels,
                        maxReservations: _topHotels.fold(0, (max, h) => h.reservations > max ? h.reservations : max),
                      )
                    : const Center(child: Text('Aucune donnée')),
                height: 320,
              ),

              const SizedBox(height: 16),

              // Actions rapides
              const Text(
                'Actions rapides',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Export data
                        final exportData = [
                          {
                            'Métrique': 'Total Hôtels',
                            'Valeur': _totalHotels,
                          },
                          {
                            'Métrique': 'Total Chambres',
                            'Valeur': _totalRooms,
                          },
                          {
                            'Métrique': 'Total Réservations',
                            'Valeur': _totalReservations,
                          },
                          {
                            'Métrique': 'Confirmées',
                            'Valeur': _confirmedCount,
                          },
                          {
                            'Métrique': 'Annulées',
                            'Valeur': _cancelledCount,
                          },
                          {
                            'Métrique': 'En Attente',
                            'Valeur': _pendingCount,
                          },
                          {
                            'Métrique': 'Taux Occupation',
                            'Valeur': '${_occupancyRate.toStringAsFixed(1)}%',
                          },
                          {
                            'Métrique': 'Revenus Estimés',
                            'Valeur': '${_estimatedRevenue.toStringAsFixed(2)}€',
                          },
                        ];

                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Exporter les données'),
                            content: ExportButton(
                              title: 'Statistiques',
                              data: exportData,
                              filename: 'dashboard_${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}.csv',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Fermer'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Exporter'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Show hotels list
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Sélectionner un hôtel'),
                            content: SizedBox(
                              width: double.maxFinite,
                              child: ListView.builder(
                                itemCount: _allHotels.length,
                                itemBuilder: (context, index) {
                                  final hotel = _allHotels[index];
                                  return ListTile(
                                    title: Text(hotel['name'] as String? ?? 'Unknown'),
                                    trailing: const Icon(Icons.arrow_forward),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AdminHotelDetailScreen(
                                            hotelId: hotel['id'] as String? ?? '',
                                            hotelName: hotel['name'] as String? ?? 'Unknown',
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.hotel),
                      label: const Text('Hôtels'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
