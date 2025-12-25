import 'package:flutter/material.dart';
import 'package:gestion_hotel/models/reservation.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/app_card.dart';
import 'package:gestion_hotel/widgets/cards/reservation_card.dart';
import 'package:gestion_hotel/widgets/status_badge.dart';

class ReservationDetailScreen extends StatefulWidget {
  final Reservation reservation;
  const ReservationDetailScreen({super.key, required this.reservation});

  @override
  State<ReservationDetailScreen> createState() => _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  final FirestoreService firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final reservation = widget.reservation;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Détail réservation'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReservationCard(
              reservationId: reservation.id ?? '',
              hotelName: reservation.hotelName ?? 'Hôtel inconnu',
              roomType: reservation.roomType, 
              checkInDate: reservation.checkInDate ?? reservation.startDate,
              checkOutDate: reservation.checkOutDate ?? reservation.endDate,
              totalPrice: reservation.totalPrice.toDouble(),
              status: reservation.status,
              guestCount: reservation.guestCount ?? 1,
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Détails', style: AppTextStyles.subtitle1),
                      StatusBadge(
                        label: reservation.status.toUpperCase(),
                        type: _statusFor(reservation.status),
                        dense: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text('ID: ${reservation.id ?? ''}', style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Statut: ${reservation.status}', style: AppTextStyles.body3),
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppBorderRadius.allLg,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(child: Text('QR CODE')), // Placeholder
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: reservation.status == 'cancelled'
                          ? null
                          : () async {
                              final navigator = Navigator.of(this.context);
                              final messenger = ScaffoldMessenger.of(this.context);
                              final confirm = await showDialog<bool>(
                                context: this.context,
                                builder: (c) => AlertDialog(
                                  title: const Text('Annuler la réservation ?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Non')),
                                    FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Oui')),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                try {
                                  await firestore.cancelReservation(reservation.id ?? '');
                                  if (!mounted) return;
                                  messenger.showSnackBar(const SnackBar(content: Text('Réservation annulée'), backgroundColor: Colors.green));
                                  navigator.pop(true);
                                } catch (e) {
                                  if (!mounted) return;
                                  messenger.showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.redAccent));
                                }
                              }
                            },
                      icon: const Icon(Icons.cancel_schedule_send),
                      label: const Text('Annuler la réservation'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  StatusBadgeType _statusFor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'checkedin':
        return StatusBadgeType.confirmed;
      case 'pending':
        return StatusBadgeType.pending;
      case 'cancelled':
        return StatusBadgeType.cancelled;
      default:
        return StatusBadgeType.info;
    }
  }
}
