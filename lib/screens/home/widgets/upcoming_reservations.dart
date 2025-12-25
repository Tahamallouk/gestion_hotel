import 'package:flutter/material.dart';
import 'package:gestion_hotel/models/reservation.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import '../../hotels/list_hotels_screen.dart';

class UpcomingReservations extends StatelessWidget {
  final List<Reservation> reservations;

  const UpcomingReservations({super.key, required this.reservations});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mes prochaines reservations', style: AppTextStyles.headline4),
        const SizedBox(height: AppSpacing.md),
        if (reservations.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppBorderRadius.allLg,
              border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Aucune reservation a venir. Reservez une chambre pour commencer.',
                    style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ListHotelsScreen()),
                  ),
                  child: const Text('Reserver'),
                ),
              ],
            ),
          )
        else
          Column(
            children: reservations.map((r) => _ReservationTile(reservation: r)).toList(),
          ),
      ],
    );
  }
}

class _ReservationTile extends StatelessWidget {
  final Reservation reservation;

  const _ReservationTile({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final formatter = MaterialLocalizations.of(context);
    final start = formatter.formatMediumDate(reservation.startDate);
    final end = formatter.formatMediumDate(reservation.endDate);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allLg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: AppBorderRadius.allMd,
              ),
              child: const Icon(Icons.bed, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reservation.roomType.isNotEmpty ? reservation.roomType : 'Reservation', style: AppTextStyles.subtitle1),
                  const SizedBox(height: AppSpacing.xs),
                  Text('$start -> $end', style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            _StatusPill(status: reservation.status),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  Color _statusColor() {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'checkedin':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: _statusColor().withValues(alpha: 0.12),
        borderRadius: AppBorderRadius.allMd,
      ),
      child: Text(status, style: AppTextStyles.caption.copyWith(color: _statusColor())),
    );
  }
}
