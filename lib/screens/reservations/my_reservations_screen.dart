import 'package:flutter/material.dart';
import 'package:gestion_hotel/models/reservation.dart';
import 'package:gestion_hotel/screens/hotels/list_hotels_screen.dart';
import 'package:gestion_hotel/screens/reservations/reservation_detail_screen.dart';
import 'package:gestion_hotel/services/auth_service.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/app_card.dart';
import 'package:gestion_hotel/widgets/common/empty_state.dart';
import 'package:gestion_hotel/widgets/status_badge.dart';
import 'package:intl/intl.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  final FirestoreService _firestore = FirestoreService();
  final AuthService _auth = AuthService();
  final DateFormat _df = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.lock_outline, size: 48, color: AppColors.textTertiary),
              SizedBox(height: AppSpacing.sm),
              Text('Veuillez vous connecter', style: AppTextStyles.subtitle2),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Mes réservations'),
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'À venir'),
              Tab(text: 'Passées'),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(AppSpacing.screenPadding),
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppBorderRadius.allXl,
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.subtle,
              ),
              child: Row(
                children: const [
                  Icon(Icons.calendar_today, color: AppColors.primary),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Consultez vos réservations, annulez en un tap et suivez les détails.',
                      style: AppTextStyles.body2,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Reservation>>(
                stream: _firestore.getReservationsByUserStream(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.screenPadding),
                      child: EmptyStates.error(message: snapshot.error.toString(), onRetry: () {}),
                    );
                  }

                  final all = snapshot.data ?? [];
                  final now = DateTime.now();
                  final upcoming = all
                      .where((r) => !r.endDate.isBefore(now))
                      .toList()
                    ..sort((a, b) => a.startDate.compareTo(b.startDate));
                  final past = all
                      .where((r) => r.endDate.isBefore(now))
                      .toList()
                    ..sort((a, b) => b.startDate.compareTo(a.startDate));

                  return RefreshIndicator(
                    onRefresh: () async {},
                    child: TabBarView(
                      children: [
                        _ReservationList(
                          reservations: upcoming,
                          empty: EmptyStates.noReservations(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ListHotelsScreen()),
                            );
                          }),
                          onCancel: _cancelReservation,
                          onOpen: _openReservation,
                          onQr: _showQr,
                          df: _df,
                        ),
                        _ReservationList(
                          reservations: past,
                          empty: EmptyState(
                            icon: Icons.history,
                            title: 'Pas de réservations passées',
                            subtitle: 'Vous retrouverez ici l\'historique de vos séjours.',
                            actionLabel: 'Explorer des hôtels',
                            onAction: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ListHotelsScreen()),
                              );
                            },
                          ),
                          onCancel: null,
                          onOpen: _openReservation,
                          onQr: _showQr,
                          df: _df,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelReservation(Reservation r) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _firestore.cancelReservation(r.id ?? '');
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
  }

  void _openReservation(Reservation r) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReservationDetailScreen(reservation: r)),
    );
  }

  void _showQr(Reservation r) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: AppBorderRadius.lg)),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('QR réservation', style: AppTextStyles.subtitle1),
              const SizedBox(height: AppSpacing.sm),
              Text(
                r.qrToken?.isNotEmpty == true
                    ? 'Token: ${r.qrToken}'
                    : 'Le QR sera généré à la confirmation.',
                style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: const [
                    Icon(Icons.qr_code_2, size: 96, color: AppColors.textSecondary),
                    SizedBox(height: AppSpacing.sm),
                    Text('QR en préparation'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.download),
                  label: const Text('Télécharger'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReservationList extends StatelessWidget {
  final List<Reservation> reservations;
  final Widget empty;
  final Future<void> Function(Reservation)? onCancel;
  final void Function(Reservation) onOpen;
  final void Function(Reservation) onQr;
  final DateFormat df;

  const _ReservationList({
    required this.reservations,
    required this.empty,
    required this.onCancel,
    required this.onOpen,
    required this.onQr,
    required this.df,
  });

  @override
  Widget build(BuildContext context) {
    if (reservations.isEmpty) return empty;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.sm),
      itemBuilder: (context, index) {
        final r = reservations[index];
        final nights = r.endDate.difference(r.startDate).inDays;
        return _ReservationTile(
          reservation: r,
          nights: nights > 0 ? nights : 1,
          df: df,
          onOpen: () => onOpen(r),
          onQr: () => onQr(r),
          onCancel: (onCancel != null && r.status != 'cancelled')
              ? () async { await onCancel!(r); }
              : null,
        );
      },
      separatorBuilder: (context, _) => const SizedBox(height: AppSpacing.sm),
      itemCount: reservations.length,
    );
  }
}

class _ReservationTile extends StatelessWidget {
  final Reservation reservation;
  final int nights;
  final DateFormat df;
  final VoidCallback onOpen;
  final VoidCallback onQr;
  final VoidCallback? onCancel;

  const _ReservationTile({
    required this.reservation,
    required this.nights,
    required this.df,
    required this.onOpen,
    required this.onQr,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final start = df.format(reservation.startDate.toLocal());
    final end = df.format(reservation.endDate.toLocal());

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  reservation.roomType.isNotEmpty ? reservation.roomType : 'Réservation ${reservation.id ?? ''}',
                  style: AppTextStyles.subtitle2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusBadge(
                label: reservation.status.toUpperCase(),
                type: _statusFor(reservation.status),
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TimelineVertical(start: start, end: end),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${nights.toString()} nuit(s) · Chambre ${reservation.roomId}',
                      style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Montant: ${reservation.totalPriceSnapshot?.toStringAsFixed(2) ?? reservation.totalPrice.toStringAsFixed(2)} DH',
                      style: AppTextStyles.body3,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: [
                        _Chip(icon: Icons.hotel, label: reservation.hotelId.isNotEmpty ? reservation.hotelId : 'Hôtel'),
                        if (reservation.viewType.isNotEmpty) _Chip(icon: Icons.landscape, label: reservation.viewType),
                        if (reservation.boardType.isNotEmpty) _Chip(icon: Icons.restaurant, label: reservation.boardType),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Voir détails'),
              ),
              const SizedBox(width: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: onQr,
                icon: const Icon(Icons.qr_code_2),
                label: const Text('Télécharger QR'),
              ),
              const Spacer(),
              if (onCancel != null)
                TextButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Annuler'),
                ),
            ],
          ),
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

class _TimelineVertical extends StatelessWidget {
  final String start;
  final String end;

  const _TimelineVertical({required this.start, required this.end});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Dot(label: start, highlight: false),
        Container(
          width: 2,
          height: 32,
          color: AppColors.border,
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        ),
        _Dot(label: end, highlight: true),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final String label;
  final bool highlight;

  const _Dot({required this.label, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: highlight ? AppColors.primary : AppColors.border,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: highlight ? AppColors.primary : AppColors.textSecondary,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
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
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
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
