import 'package:flutter/material.dart';
import 'package:gestion_hotel/models/reservation.dart';
import 'package:gestion_hotel/services/auth_service.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/app_card.dart';
import 'package:gestion_hotel/widgets/common/empty_state.dart';
import 'package:gestion_hotel/widgets/section_header.dart';
import 'package:gestion_hotel/widgets/status_badge.dart';
import 'package:intl/intl.dart';

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({super.key});

  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  final _firestore = FirestoreService();
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;
    final horizontalPadding = AppSpacing.screenPaddingHorizontal;

    if (uid == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.lock_outline, size: 48, color: AppColors.textTertiary),
              SizedBox(height: AppSpacing.sm),
              Text('Connectez-vous pour voir vos réservations.', style: AppTextStyles.subtitle2),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<List<Reservation>>(
      stream: _firestore.getReservationsByUserStream(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final reservations = snapshot.data ?? [];

        if (reservations.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Mes réservations'),
                const SizedBox(height: AppSpacing.lg),
                EmptyStates.noReservations(() {}),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: AppSpacing.xl),
          itemCount: reservations.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: SectionHeader(title: 'Mes réservations'),
              );
            }
            final reservation = reservations[index - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _ReservationTile(reservation: reservation),
            );
          },
        );
      },
    );
  }
}

class _ReservationTile extends StatelessWidget {
  final Reservation reservation;

  const _ReservationTile({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');
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
              Text(reservation.roomType.isEmpty ? 'Chambre ${reservation.roomId}' : reservation.roomType, style: AppTextStyles.subtitle1),
              StatusBadge(label: reservation.status.toUpperCase(), type: _statusFor(reservation.status), dense: true),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _Timeline(start: start, end: end),
          const SizedBox(height: AppSpacing.sm),
          Text('${nights > 0 ? nights : 1} nuit(s) · Hôtel ${reservation.hotelId.isEmpty ? '—' : reservation.hotelId}', style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xs),
          Text('Montant: ${reservation.totalPriceSnapshot?.toStringAsFixed(2) ?? reservation.totalPrice.toStringAsFixed(2)} DH', style: AppTextStyles.body3),
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

class _Timeline extends StatelessWidget {
  final String start;
  final String end;

  const _Timeline({required this.start, required this.end});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Dot(label: start),
        Expanded(
          child: Container(height: 1, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm)),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: highlight ? AppColors.primary : AppColors.border),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: AppTextStyles.caption.copyWith(color: highlight ? AppColors.primary : AppColors.textSecondary, fontWeight: highlight ? FontWeight.w700 : FontWeight.w500)),
      ],
    );
  }
}
