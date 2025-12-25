import 'package:flutter/material.dart';
import 'package:gestion_hotel/models/hotel.dart';
import 'package:gestion_hotel/models/reservation.dart';
import 'package:gestion_hotel/models/room.dart';
import 'package:gestion_hotel/services/auth_service.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/app_card.dart';

class ReservationPage extends StatefulWidget {
  final Room room;
  final Hotel hotel;

  const ReservationPage({super.key, required this.room, required this.hotel});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final _firestore = FirestoreService();
  final _auth = AuthService();

  DateTimeRange? _range;
  bool _submitting = false;

  int get _nights {
    if (_range == null) return 0;
    final raw = _range!.end.difference(_range!.start).inDays;
    return raw <= 0 ? 1 : raw;
  }

  int get _nightlyRate => widget.room.basePrice + widget.room.viewExtra;

  int get _totalPrice => _nightlyRate * (_nights == 0 ? 1 : _nights);

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final initial = DateTimeRange(start: now, end: now.add(const Duration(days: 1)));
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      initialDateRange: _range ?? initial,
    );
    if (picked != null) {
      setState(() => _range = picked);
    }
  }

  Future<void> _submit() async {
    if (_range == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sélectionnez vos dates.')));
      return;
    }
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connectez-vous pour réserver.')));
      return;
    }

    final resolvedHotelId = (widget.hotel.id != null && widget.hotel.id!.isNotEmpty)
        ? widget.hotel.id!
        : widget.hotel.name; // fallback to displayable name
    final resolvedRoomId = (widget.room.id != null && widget.room.id!.isNotEmpty)
        ? widget.room.id!
        : 'mock-room-${widget.room.number}';
    final reservation = Reservation(
      userId: uid,
      hotelId: resolvedHotelId,
      roomId: resolvedRoomId,
      roomType: widget.room.type,
      viewType: widget.room.view,
      boardType: 'sans',
      basePrice: widget.room.basePrice,
      viewExtra: widget.room.viewExtra,
      boardPrice: 0,
      nights: _nights,
      totalPrice: _totalPrice,
      startDate: _range!.start,
      endDate: _range!.end,
    );

    final hasRealRoomDoc = widget.room.id != null && widget.room.id!.isNotEmpty && !widget.room.id!.startsWith('mock-');

    setState(() => _submitting = true);
    try {
      if (hasRealRoomDoc) {
        await _firestore.createReservation(reservation);
      } else {
        await _firestore.createReservationSimple(reservation);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Réservation confirmée'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final hotel = widget.hotel;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Réserver')), 
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: AppBorderRadius.allMd,
                      ),
                      child: const Icon(Icons.king_bed, color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${hotel.name} · Chambre ${room.number}', style: AppTextStyles.subtitle1),
                          const SizedBox(height: AppSpacing.xs),
                          Text('${room.type} · ${room.capacity} pers · Vue ${room.view.isEmpty ? 'standard' : room.view}', style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Text('$_nightlyRate DH / nuit', style: AppTextStyles.subtitle2.copyWith(color: AppColors.success)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dates', style: AppTextStyles.subtitle1),
                const SizedBox(height: AppSpacing.sm),
                if (_range != null)
                  Text('${_range!.start.day}/${_range!.start.month}/${_range!.start.year} → ${_range!.end.day}/${_range!.end.month}/${_range!.end.year}', style: AppTextStyles.body2)
                else
                  Text('Choisissez vos dates de séjour', style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.sm),
                ElevatedButton.icon(
                  onPressed: _pickDates,
                  icon: const Icon(Icons.date_range),
                  label: const Text('Sélectionner'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Récapitulatif', style: AppTextStyles.subtitle1),
                const SizedBox(height: AppSpacing.sm),
                _PriceRow(label: 'Prix par nuit', value: '$_nightlyRate DH'),
                _PriceRow(label: 'Nuits', value: _nights == 0 ? '—' : '$_nights'),
                const Divider(),
                _PriceRow(label: 'Total prévisionnel', value: '$_totalPrice DH', bold: true),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: AppSpacing.md)),
              child: _submitting
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Confirmer la réservation', style: AppTextStyles.buttonLarge),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _PriceRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: bold ? AppTextStyles.subtitle2 : AppTextStyles.body3.copyWith(color: AppColors.textSecondary)),
          Text(value, style: bold ? AppTextStyles.subtitle2.copyWith(color: AppColors.primary) : AppTextStyles.body2),
        ],
      ),
    );
  }
}