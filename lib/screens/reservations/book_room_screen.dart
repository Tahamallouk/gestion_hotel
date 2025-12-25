import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestion_hotel/models/reservation.dart';
import 'package:gestion_hotel/models/room.dart';

import 'package:gestion_hotel/providers/booking_provider_legacy.dart';
import 'package:gestion_hotel/services/auth_service.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/utils/app_theme.dart';

class BookRoomScreen extends StatefulWidget {
  final Room room;
  final String? hotelId;
  const BookRoomScreen({super.key, required this.room, this.hotelId});

  @override
  State<BookRoomScreen> createState() => _BookRoomScreenState();
}

class _BookRoomScreenState extends State<BookRoomScreen> {
  DateTimeRange? _range;
  String _boardType = 'sans';
  String _roomVariant = 'standard';
  int _guests = 1;
  bool _checkingAvailability = false;
  bool _isAvailable = true;
  final FirestoreService _firestore = FirestoreService();
  final AuthService _auth = AuthService();

  static const Map<String, int> boardPrices = {
    'sans': 0,
    'demi_pension': 150,
    'pension_complete': 250,
    'all_inclusive': 350,
  };

  static const Map<String, Map<String, dynamic>> roomVariants = {
    'standard': {'label': 'Standard', 'multiplier': 1.0},
    'deluxe': {'label': 'Deluxe (+20%)', 'multiplier': 1.2},
    'suite': {'label': 'Suite (+40%)', 'multiplier': 1.4},
  };

  static const int guestSurchargePerExtra = 80; // DH per nuit et par invité supplémentaire

  int get _nights => _range == null ? 0 : _range!.end.difference(_range!.start).inDays;
  double get _variantMultiplier => (roomVariants[_roomVariant]?['multiplier'] as double?) ?? 1.0;
  String get _variantLabel => (roomVariants[_roomVariant]?['label'] as String?) ?? 'Standard';

  int get _extraGuests => ((_guests - 1).clamp(0, _maxGuests - 1)).toInt();
  int get _maxGuests => (widget.room.capacity ?? 0) > 0 ? widget.room.capacity ?? 1 : 1;

  int get _baseWithBoard => widget.room.basePrice + widget.room.viewExtra + (boardPrices[_boardType] ?? 0);

  int get _guestSurchargePerNight => _extraGuests * guestSurchargePerExtra;

  int get _nightPrice {
    final variantApplied = (_baseWithBoard * _variantMultiplier).round();
    return variantApplied + _guestSurchargePerNight;
  }

  int get _totalPrice => _nightPrice * _nights;

  Future<void> _pickRange() async {
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
      _checkAvailability();
    }
  }

  Future<void> _checkAvailability() async {
    if (_range == null) return;
    setState(() => _checkingAvailability = true);
    try {
      final available = await _firestore.isRoomAvailableForDates(
        widget.room.id ?? '',
        _range!.start,
        _range!.end,
      );
      if (mounted) {
        setState(() {
          _isAvailable = available;
          _checkingAvailability = false;
        });
        if (!available) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('La chambre n\'est pas disponible pour ces dates'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _checkingAvailability = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _book() async {
    if (_range == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez des dates')),
      );
      return;
    }
    if (!_isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La chambre n\'est pas disponible'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_nights < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimum 1 nuit requis')),
      );
      return;
    }

    final uid = _auth.currentUser?.uid ?? '';
    final reservation = Reservation(
      roomId: widget.room.id ?? '',
      userId: uid,
      hotelId: widget.hotelId ?? '',
      roomType: widget.room.type.isEmpty ? _variantLabel : '${widget.room.type} · $_variantLabel',
      viewType: widget.room.view,
      boardType: _boardType,
      basePrice: widget.room.basePrice,
      viewExtra: widget.room.viewExtra,
      boardPrice: boardPrices[_boardType] ?? 0,
      nights: _nights,
      totalPrice: _totalPrice,
      startDate: _range!.start,
      endDate: _range!.end,
    );

    // Utiliser le provider de réservation pour la gestion d'état
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    bookingProvider.createReservation(reservation);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        // Écouter les changements d'état de réservation
        if (bookingProvider.isSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Réservation créée avec succès'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
            // Réinitialiser l'état de réservation
            bookingProvider.reset();
          });
        } else if (bookingProvider.error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(bookingProvider.error!),
                backgroundColor: Colors.redAccent,
              ),
            );
            // Effacer l'erreur après l'avoir affichée
            bookingProvider.clearError();
          });
        }

        return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Réserver une chambre'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                borderRadius: const BorderRadius.all(AppBorderRadius.xl),
                boxShadow: AppShadows.medium,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.all(AppBorderRadius.lg),
                    ),
                    child: const Icon(Icons.king_bed, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Chambre ${widget.room.number}', style: AppTextStyles.headline3.copyWith(color: Colors.white)),
                        const SizedBox(height: AppSpacing.xs),
                        Text('Type ${widget.room.type} · Vue ${widget.room.view}', style: AppTextStyles.body2.copyWith(color: Colors.white70)),
                        const SizedBox(height: AppSpacing.xs),
                        Text('${widget.room.basePrice} DH / nuit (+${widget.room.viewExtra} DH vue)', style: AppTextStyles.body3.copyWith(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _CardSection(
              title: 'Configuration',
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _roomVariant,
                    items: roomVariants.entries
                        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value['label'] as String)))
                        .toList(),
                    onChanged: (v) => setState(() => _roomVariant = v ?? 'standard'),
                    decoration: const InputDecoration(labelText: 'Type de chambre'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Nombre de clients (max $_maxGuests)', style: AppTextStyles.subtitle2),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _guests > 1 ? () => setState(() => _guests -= 1) : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text('$_guests', style: AppTextStyles.subtitle1),
                          IconButton(
                            onPressed: _guests < _maxGuests ? () => setState(() => _guests += 1) : null,
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _CardSection(
              title: 'Dates de séjour',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_range != null)
                    Text(
                      '${_range!.start.day}/${_range!.start.month}/${_range!.start.year} → ${_range!.end.day}/${_range!.end.month}/${_range!.end.year}',
                      style: AppTextStyles.subtitle2,
                    )
                  else
                    Text('Aucune plage sélectionnée', style: AppTextStyles.body3.copyWith(fontStyle: FontStyle.italic)),
                  const SizedBox(height: AppSpacing.sm),
                  ElevatedButton.icon(
                    onPressed: _pickRange,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Sélectionner les dates'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_range != null)
              _CardSection(
                title: 'Type de pension',
                child: DropdownButtonFormField<String>(
                  initialValue: _boardType,
                  items: const [
                    DropdownMenuItem(value: 'sans', child: Text('Sans pension')),
                    DropdownMenuItem(value: 'demi_pension', child: Text('Demi-pension (+150 DH/nuit)')),
                    DropdownMenuItem(value: 'pension_complete', child: Text('Pension complète (+250 DH/nuit)')),
                    DropdownMenuItem(value: 'all_inclusive', child: Text('All-inclusive (+350 DH/nuit)')),
                  ],
                  onChanged: (v) => setState(() => _boardType = v ?? 'sans'),
                  decoration: const InputDecoration(labelText: 'Pension'),
                ),
              ),
            if (_range != null) const SizedBox(height: AppSpacing.md),
            if (_range != null && _checkingAvailability)
              const Center(child: CircularProgressIndicator())
            else if (_range != null && !_isAvailable)
              _StatusBanner(
                text: 'Chambre non disponible pour ces dates',
                color: AppColors.error,
                icon: Icons.block,
              )
            else if (_range != null && _isAvailable)
              _StatusBanner(
                text: 'Chambre disponible',
                color: AppColors.success,
                icon: Icons.check_circle,
              ),
            if (_range != null) const SizedBox(height: AppSpacing.md),
            if (_range != null)
              _CardSection(
                title: 'Récapitulatif des prix',
                background: AppColors.primaryVeryLight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PriceRow(label: 'Prix de base / nuit', value: '${widget.room.basePrice} DH'),
                    if (widget.room.viewExtra > 0)
                      _PriceRow(label: 'Supplément vue', value: '${widget.room.viewExtra} DH'),
                    if (boardPrices[_boardType]! > 0)
                      _PriceRow(label: 'Supplément pension', value: '${boardPrices[_boardType]!} DH'),
                    if (_variantMultiplier > 1)
                      _PriceRow(
                        label: 'Ajustement type ($_variantLabel)',
                        value: '+${((_baseWithBoard * _variantMultiplier).round() - _baseWithBoard).clamp(0, 100000)} DH',
                      ),
                    if (_guestSurchargePerNight > 0)
                      _PriceRow(
                        label: 'Supplément clients ($_guests pers)',
                        value: '+$_guestSurchargePerNight DH',
                      ),
                    const Divider(),
                    _PriceRow(label: 'Prix par nuit', value: '$_nightPrice DH', bold: true),
                    _PriceRow(label: 'Nombre de clients', value: '$_guests'),
                    _PriceRow(label: 'Nombre de nuits', value: '$_nights'),
                    const Divider(thickness: 2),
                    _PriceRow(label: 'TOTAL', value: '$_totalPrice DH', bold: true, highlight: true),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.xl),
            
            // Total pricing info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'Prix total: ${_totalPrice.toStringAsFixed(2)} MAD',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (bookingProvider.isLoading || !_isAvailable || _range == null || _checkingAvailability) ? null : _book,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(AppBorderRadius.lg)),
                ),
                child: bookingProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Confirmer la réservation', style: AppTextStyles.buttonLarge),
              ),
            ),
          ],
        ),
      ),
        );
      },
    );
  }
}

class _CardSection extends StatelessWidget {
  final String title;
  final Widget child;
  final Color? background;

  const _CardSection({required this.title, required this.child, this.background});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: background ?? Colors.white,
        borderRadius: const BorderRadius.all(AppBorderRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.subtitle1),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;

  const _StatusBanner({required this.text, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPaddingSmall),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: const BorderRadius.all(AppBorderRadius.lg),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTextStyles.subtitle2.copyWith(color: color))),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final bool highlight;

  const _PriceRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: (bold ? AppTextStyles.subtitle2 : AppTextStyles.body2).copyWith(color: AppColors.textSecondary)),
          Text(
            value,
            style: (bold ? AppTextStyles.subtitle1 : AppTextStyles.body2).copyWith(
              color: highlight ? AppColors.primary : AppColors.textPrimary,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
