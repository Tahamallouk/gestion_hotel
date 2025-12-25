import 'package:flutter/material.dart';
import 'package:gestion_hotel/models/reservation.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/app_card.dart';
import 'package:gestion_hotel/widgets/common/empty_state.dart';
import 'package:gestion_hotel/widgets/paginated_list.dart';
import 'package:gestion_hotel/widgets/status_badge.dart';
import 'package:intl/intl.dart';

class AdminReservationsScreen extends StatefulWidget {
  const AdminReservationsScreen({super.key});

  @override
  State<AdminReservationsScreen> createState() => _AdminReservationsScreenState();
}

class _AdminReservationsScreenState extends State<AdminReservationsScreen> {
  final FirestoreService _firestore = FirestoreService();
  String? _hotelFilter;
  String? _statusFilter;
  int _visibleCount = 0;
  bool _evaluatedVisibility = false;
  final List<Map<String, dynamic>> _statusOptions = const [
    {'label': 'Tous', 'value': null, 'color': AppColors.textSecondary},
    {'label': 'En attente', 'value': 'pending', 'color': AppColors.warning},
    {'label': 'Confirmées', 'value': 'confirmed', 'color': AppColors.success},
    {'label': 'Annulées', 'value': 'cancelled', 'color': AppColors.error},
  ];

  @override
  Widget build(BuildContext context) {
    final bool filtersActive = _hotelFilter != null || _statusFilter != null;
    int frameVisibleCount = 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bool shouldUpdate = _visibleCount != frameVisibleCount || !_evaluatedVisibility;
      if (shouldUpdate) {
        setState(() {
          _visibleCount = frameVisibleCount;
          _evaluatedVisibility = true;
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Réservations (Admin)'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.manage_search, color: AppColors.primary),
                      SizedBox(width: AppSpacing.sm),
                      Text('Filtrer les réservations', style: AppTextStyles.subtitle1),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Filtrer par hôtel (ID)',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    onChanged: (v) => setState(() {
                      _hotelFilter = v.trim().isEmpty ? null : v.trim();
                      _evaluatedVisibility = false;
                    }),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _statusOptions.map((option) {
                      final bool selected = _statusFilter == option['value'];
                      return ChoiceChip(
                        label: Text(option['label'] as String),
                        selected: selected,
                        labelStyle: AppTextStyles.body3.copyWith(
                          color: selected ? Colors.white : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                        selectedColor: (option['color'] as Color).withValues(alpha: 0.9),
                        backgroundColor: AppColors.surface,
                        side: const BorderSide(color: AppColors.border),
                        onSelected: (_) => setState(() {
                          _statusFilter = option['value'] as String?;
                          _evaluatedVisibility = false;
                        }),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                PaginatedList<Reservation>(
                  pageSize: 15,
                  fetchPage: ({startAfter, limit = 15}) => _firestore.getReservationsPaged(startAfter: startAfter, limit: limit),
                  itemBuilder: (context, reservation, index) {
                    final bool hidden = (_hotelFilter != null && reservation.hotelId != _hotelFilter) ||
                        (_statusFilter != null && reservation.status != _statusFilter);
                    if (!hidden) frameVisibleCount++;
                    if (hidden) return const SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.xs),
                      child: _ReservationRow(
                        reservation: reservation,
                        onCancel: reservation.status == 'cancelled'
                            ? null
                            : () async {
                                final messenger = ScaffoldMessenger.of(this.context);
                                try {
                                  await _firestore.cancelReservation(reservation.id ?? '');
                                  if (!mounted) return;
                                  messenger.showSnackBar(
                                    const SnackBar(content: Text('Réservation annulée'), backgroundColor: Colors.green),
                                  );
                                } catch (e) {
                                  if (!mounted) return;
                                  messenger.showSnackBar(
                                    SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.redAccent),
                                  );
                                }
                              },
                      ),
                    );
                  },
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: filtersActive && _evaluatedVisibility && _visibleCount == 0
                          ? Center(
                              child: EmptyState(
                                icon: Icons.filter_alt_off,
                                title: 'Aucune réservation ne correspond aux filtres sélectionnés',
                                subtitle: 'Réinitialisez les filtres pour voir toutes les réservations.',
                                actionLabel: 'Réinitialiser les filtres',
                                onAction: () {
                                  setState(() {
                                    _hotelFilter = null;
                                    _statusFilter = null;
                                    _evaluatedVisibility = false;
                                  });
                                },
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReservationRow extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback? onCancel;

  const _ReservationRow({required this.reservation, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM');
    final start = df.format(reservation.startDate.toLocal());
    final end = df.format(reservation.endDate.toLocal());
    final nights = reservation.endDate.difference(reservation.startDate).inDays;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Hotel: ${reservation.hotelId}', style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary)),
              StatusBadge(
                label: reservation.status.toUpperCase(),
                type: _statusFor(reservation.status),
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Réservation ${reservation.id ?? ''}', style: AppTextStyles.subtitle2),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _Chip(icon: Icons.event, label: '$start → $end'),
              const SizedBox(width: AppSpacing.sm),
              _Chip(icon: Icons.bed_outlined, label: reservation.roomType.isEmpty ? reservation.roomId : reservation.roomType),
              const SizedBox(width: AppSpacing.sm),
              _Chip(icon: Icons.nights_stay_outlined, label: '${nights > 0 ? nights : 1} nuit(s)'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Montant: ${reservation.totalPriceSnapshot?.toStringAsFixed(2) ?? reservation.totalPrice.toStringAsFixed(2)} DH',
            style: AppTextStyles.body3,
          ),
          if (onCancel != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.cancel_schedule_send),
                label: const Text('Annuler'),
              ),
            ),
          ],
        ],
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

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.allMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
