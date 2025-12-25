import 'package:flutter/material.dart';
import 'package:gestion_hotel/widgets/status_badge.dart';
import 'package:gestion_hotel/models/reservation.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/app_button.dart';
import 'package:gestion_hotel/widgets/app_card.dart';
import 'package:intl/intl.dart';

class QuickCheckInScreen extends StatefulWidget {
  const QuickCheckInScreen({super.key});

  @override
  State<QuickCheckInScreen> createState() => _QuickCheckInScreenState();
}

class _QuickCheckInScreenState extends State<QuickCheckInScreen> {
  final _firestore = FirestoreService();
  final _searchController = TextEditingController();
  
  List<Reservation> _todayReservations = [];
  List<Reservation> _filteredReservations = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTodayReservations();
    _searchController.addListener(_filterReservations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadTodayReservations() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Get all reservations and filter for today
      final allReservations = await _firestore.getAllReservations().first;
      final today = DateTime.now();
      
      final todayReservations = allReservations.where((reservation) {
        // Check if today is within the reservation period or is the check-in date
        return _isDateInRange(today, reservation.startDate, reservation.endDate) ||
               _isSameDay(today, reservation.startDate) ||
               _isSameDay(today, reservation.endDate);
      }).toList();

      // Sort by check-in status priority and then by time
      todayReservations.sort((a, b) {
        final aPriority = _getStatusPriority(a.status);
        final bPriority = _getStatusPriority(b.status);
        if (aPriority != bPriority) {
          return aPriority.compareTo(bPriority);
        }
        return a.startDate.compareTo(b.startDate);
      });

      setState(() {
        _todayReservations = todayReservations;
        _filteredReservations = todayReservations;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _filterReservations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredReservations = _todayReservations.where((reservation) {
        return reservation.roomType.toLowerCase().contains(query) ||
               reservation.roomId.toLowerCase().contains(query) ||
               (reservation.id?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  int _getStatusPriority(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 1; // Highest priority for check-in
      case 'checkedin':
        return 2; // Can check-out
      case 'pending':
        return 3;
      case 'checkedout':
        return 4;
      case 'cancelled':
        return 5; // Lowest priority
      default:
        return 3;
    }
  }

  bool _isDateInRange(DateTime date, DateTime start, DateTime end) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(start.year, start.month, start.day);
    final endOnly = DateTime(end.year, end.month, end.day);
    
    return dateOnly.isAfter(startOnly.subtract(const Duration(days: 1))) &&
           dateOnly.isBefore(endOnly.add(const Duration(days: 1)));
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  Future<void> _performCheckIn(Reservation reservation) async {
    try {
      await _firestore.updateReservationStatus(reservation.id!, 'checkedIn');
      _showSuccessMessage('Check-in effectué avec succès');
      _loadTodayReservations(); // Reload data
    } catch (e) {
      _showErrorMessage('Erreur lors du check-in: $e');
    }
  }

  Future<void> _performCheckOut(Reservation reservation) async {
    try {
      await _firestore.updateReservationStatus(reservation.id!, 'checkedOut');
      _showSuccessMessage('Check-out effectué avec succès');
      _loadTodayReservations(); // Reload data
    } catch (e) {
      _showErrorMessage('Erreur lors du check-out: $e');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-In / Check-Out'),
        actions: [
          IconButton(
            onPressed: _loadTodayReservations,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search section
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Réservations d\'aujourd\'hui',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Rechercher par chambre ou ID...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (!_loading)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Text(
                        '${_filteredReservations.length} réservation${_filteredReservations.length != 1 ? 's' : ''} trouvée${_filteredReservations.length != 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Reservations list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(_error!),
                            const SizedBox(height: AppSpacing.md),
                            AppButton(
                              onPressed: _loadTodayReservations,
                              label: 'Réessayer',
                            ),
                          ],
                        ),
                      )
                    : _filteredReservations.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.hotel_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: AppSpacing.md),
                                Text('Aucune réservation pour aujourd\'hui'),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            itemCount: _filteredReservations.length,
                            itemBuilder: (context, index) {
                              final reservation = _filteredReservations[index];
                              return _buildReservationCard(reservation);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(Reservation reservation) {
    final today = DateTime.now();
    final isCheckInDay = _isSameDay(today, reservation.startDate);
    final isCheckOutDay = _isSameDay(today, reservation.endDate);
    final canCheckIn = isCheckInDay && reservation.status.toLowerCase() == 'confirmed';
    final canCheckOut = reservation.status.toLowerCase() == 'checkedin';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chambre ${reservation.roomType.isNotEmpty ? reservation.roomType : reservation.roomId}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Réservation #${reservation.id?.substring(0, 8) ?? 'N/A'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  label: reservation.status.toUpperCase(),
                  type: _getStatusBadgeType(reservation.status),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Date information
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${DateFormat('dd/MM').format(reservation.startDate)} - ${DateFormat('dd/MM').format(reservation.endDate)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                if (isCheckInDay)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Check-in aujourd\'hui',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (isCheckOutDay)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Check-out aujourd\'hui',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Action buttons
            Row(
              children: [
                if (canCheckIn)
                  Expanded(
                    child: AppButton(
                      onPressed: () => _performCheckIn(reservation),
                      label: 'Check-In',
                    ),
                  ),
                if (canCheckIn && canCheckOut) const SizedBox(width: AppSpacing.sm),
                if (canCheckOut)
                  Expanded(
                    child: AppButton(
                      onPressed: () => _performCheckOut(reservation),
                      label: 'Check-Out',
                    ),
                  ),
                if (!canCheckIn && !canCheckOut)
                  Expanded(
                    child: Text(
                      _getActionMessage(reservation),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getActionMessage(Reservation reservation) {
    switch (reservation.status.toLowerCase()) {
      case 'pending':
        return 'En attente de confirmation';
      case 'checkedout':
        return 'Check-out effectué';
      case 'cancelled':
        return 'Réservation annulée';
      default:
        return 'Aucune action disponible';
    }
  }

  StatusBadgeType _getStatusBadgeType(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return StatusBadgeType.confirmed;
      case 'checkedin':
        return StatusBadgeType.confirmed;
      case 'checkedout':
        return StatusBadgeType.info;
      case 'cancelled':
        return StatusBadgeType.cancelled;
      case 'pending':
        return StatusBadgeType.pending;
      default:
        return StatusBadgeType.info;
    }
  }
}