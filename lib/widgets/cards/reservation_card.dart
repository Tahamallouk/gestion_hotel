import 'package:flutter/material.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:intl/intl.dart';

/// Polished ReservationCard widget for displaying reservation information
/// Features: Hotel, dates, status with color coding, action buttons
class ReservationCard extends StatefulWidget {
  final String reservationId;
  final String hotelName;
  final String roomType;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final double totalPrice;
  final String status;
  final int guestCount;
  final VoidCallback? onViewDetails;
  final VoidCallback? onCancel;

  const ReservationCard({
    super.key,
    required this.reservationId,
    required this.hotelName,
    required this.roomType,
    required this.checkInDate,
    required this.checkOutDate,
    required this.totalPrice,
    required this.status,
    required this.guestCount,
    this.onViewDetails,
    this.onCancel,
  });

  @override
  State<ReservationCard> createState() => _ReservationCardState();
}

class _ReservationCardState extends State<ReservationCard> {
  Color _getStatusColor() {
    switch (widget.status.toLowerCase()) {
      case 'confirmed':
        return AppColors.statusConfirmed;
      case 'pending':
        return AppColors.statusPending;
      case 'cancelled':
        return AppColors.statusCancelled;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusLabel() {
    switch (widget.status.toLowerCase()) {
      case 'confirmed':
        return 'Confirmée';
      case 'pending':
        return 'En attente';
      case 'cancelled':
        return 'Annulée';
      default:
        return widget.status;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  int _getNights() {
    return widget.checkOutDate.difference(widget.checkInDate).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'fr_FR');
    final nights = _getNights();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.all12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header: Hotel name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.hotelName,
                        style: AppTextStyles.subtitle1.copyWith(
                          color: Theme.of(context).textTheme.titleMedium?.color,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        widget.roomType,
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.2),
                    borderRadius: AppBorderRadius.all8,
                    border: Border.all(
                      color: _getStatusColor(),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(),
                        size: 16,
                        color: _getStatusColor(),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getStatusLabel(),
                        style: AppTextStyles.caption.copyWith(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            /// Dates section
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: AppBorderRadius.all8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Arrivée',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(widget.checkInDate),
                          style: AppTextStyles.body2.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Départ',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(widget.checkOutDate),
                          style: AppTextStyles.body2.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            /// Info row: Guests and nights
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.guestCount} ${widget.guestCount > 1 ? 'invités' : 'invité'}',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.nights_stay,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$nights ${nights > 1 ? 'nuits' : 'nuit'}',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            /// Total price
            Text(
              'Montant total',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.totalPrice.toStringAsFixed(2)} DH',
              style: AppTextStyles.headline4.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),

            /// Action buttons
            if (widget.onViewDetails != null || widget.onCancel != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  if (widget.onViewDetails != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.onViewDetails,
                        icon: const Icon(Icons.visibility),
                        label: const Text('Détails'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                  if (widget.onViewDetails != null && widget.onCancel != null)
                    const SizedBox(width: AppSpacing.md),
                  if (widget.onCancel != null &&
                      widget.status.toLowerCase() != 'cancelled')
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: widget.onCancel,
                        icon: const Icon(Icons.close),
                        label: const Text('Annuler'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
