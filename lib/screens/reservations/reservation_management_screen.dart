import 'package:flutter/material.dart';
import 'package:gestion_hotel/widgets/status_badge.dart';
import 'package:gestion_hotel/models/reservation.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/app_button.dart';
import 'package:gestion_hotel/widgets/app_card.dart';
import 'package:intl/intl.dart';

class ReservationManagementScreen extends StatefulWidget {
  const ReservationManagementScreen({super.key});

  @override
  State<ReservationManagementScreen> createState() => _ReservationManagementScreenState();
}

class _ReservationManagementScreenState extends State<ReservationManagementScreen> {
  final _firestore = FirestoreService();
  final _qrController = TextEditingController();
  
  Reservation? _foundReservation;
  bool _loading = false;
  String? _error;

  Future<void> _searchByQR(String qrToken) async {
    if (qrToken.trim().isEmpty) return;
    
    setState(() {
      _loading = true;
      _error = null;
      _foundReservation = null;
    });

    try {
      final reservation = await _firestore.getReservationByQrToken(qrToken.trim());
      setState(() {
        _foundReservation = reservation;
        if (reservation == null) {
          _error = 'Aucune réservation trouvée avec ce QR code';
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de la recherche: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _updateStatus(String reservationId, String newStatus) async {
    try {
      await _firestore.updateReservationStatus(reservationId, newStatus);
      
      // Refresh the reservation data
      if (_foundReservation != null) {
        _searchByQR(_qrController.text);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Statut mis à jour: $newStatus'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Widget _buildStatusAction(String status, String label, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () => _updateStatus(_foundReservation!.id!, status),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion Réservations'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // QR Code Search Section
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recherche par QR Code',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _qrController,
                          decoration: const InputDecoration(
                            hintText: 'Entrez le code QR de la réservation',
                            prefixIcon: Icon(Icons.qr_code_scanner),
                            border: OutlineInputBorder(),
                          ),
                          onFieldSubmitted: _searchByQR,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      AppButton(
                        onPressed: _loading ? null : () => _searchByQR(_qrController.text),
                        label: 'Chercher',
                        loading: _loading,
                      ),
                    ],
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                _error!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Reservation Details Section
            if (_foundReservation != null) ...[
              Text(
                'Détails de la Réservation',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Réservation #${_foundReservation!.id?.substring(0, 8) ?? 'N/A'}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        StatusBadge(
                          label: _foundReservation!.status.toUpperCase(),
                          type: _getStatusType(_foundReservation!.status),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Reservation Information
                    _buildInfoRow(
                      'Chambre',
                      _foundReservation!.roomType.isNotEmpty 
                          ? _foundReservation!.roomType
                          : _foundReservation!.roomId,
                      Icons.hotel,
                    ),
                    _buildInfoRow(
                      'Dates',
                      '${DateFormat('dd/MM/yyyy').format(_foundReservation!.startDate)} - ${DateFormat('dd/MM/yyyy').format(_foundReservation!.endDate)}',
                      Icons.calendar_today,
                    ),
                    _buildInfoRow(
                      'Durée',
                      '${_foundReservation!.nights} nuit${_foundReservation!.nights > 1 ? 's' : ''}',
                      Icons.nights_stay,
                    ),
                    _buildInfoRow(
                      'Prix Total',
                      '${_foundReservation!.totalPriceSnapshot ?? _foundReservation!.totalPrice} €',
                      Icons.euro,
                    ),
                    _buildInfoRow(
                      'Créée le',
                      DateFormat('dd/MM/yyyy à HH:mm').format(_foundReservation!.createdAt),
                      Icons.access_time,
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    
                    // Quick Actions
                    Text(
                      'Actions Rapides',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    Row(
                      children: [
                        _buildStatusAction('confirmed', 'Confirmer', Colors.green),
                        _buildStatusAction('checkedIn', 'Check-In', Colors.blue),
                        _buildStatusAction('checkedOut', 'Check-Out', Colors.orange),
                        _buildStatusAction('cancelled', 'Annuler', Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  StatusBadgeType _getStatusType(String status) {
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

  @override
  void dispose() {
    _qrController.dispose();
    super.dispose();
  }
}