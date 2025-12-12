import 'package:flutter/material.dart';
import 'package:gestion_hotel/models/room.dart';
import 'package:gestion_hotel/models/reservation.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/services/auth_service.dart';

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
  bool _loading = false;
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

  int get _nights => _range == null ? 0 : _range!.end.difference(_range!.start).inDays;
  int get _nightPrice => widget.room.basePrice + widget.room.viewExtra + (boardPrices[_boardType] ?? 0);
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

    setState(() => _loading = true);

    final uid = _auth.currentUser?.uid ?? '';
    final reservation = Reservation(
      roomId: widget.room.id ?? '',
      userId: uid,
      hotelId: widget.hotelId ?? '',
      roomType: widget.room.type,
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

    try {
      await _firestore.createReservation(reservation);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Réservation créée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réserver une chambre')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Chambre ${widget.room.number}', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('Type: ${widget.room.type}'),
                    Text('Vue: ${widget.room.view}'),
                    Text('Prix de base: ${widget.room.basePrice}€ / nuit'),
                    Text('Supplément vue: ${widget.room.viewExtra}€'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dates de séjour', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (_range != null)
                      Text('${_range!.start.day}/${_range!.start.month}/${_range!.start.year} → ${_range!.end.day}/${_range!.end.month}/${_range!.end.year}')
                    else
                      const Text('Aucune plage sélectionnée', style: TextStyle(fontStyle: FontStyle.italic)),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(onPressed: _pickRange, icon: const Icon(Icons.calendar_today), label: const Text('Sélectionner les dates')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_range != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Type de pension', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _boardType,
                        items: const [
                          DropdownMenuItem(value: 'sans', child: Text('Sans pension')),
                          DropdownMenuItem(value: 'demi_pension', child: Text('Demi-pension (+150€/nuit)')),
                          DropdownMenuItem(value: 'pension_complete', child: Text('Pension complète (+250€/nuit)')),
                          DropdownMenuItem(value: 'all_inclusive', child: Text('All-inclusive (+350€/nuit)')),
                        ],
                        onChanged: (v) => setState(() => _boardType = v ?? 'sans'),
                        decoration: const InputDecoration(labelText: 'Pension', border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (_range != null && _checkingAvailability)
              const Center(child: CircularProgressIndicator())
            else if (_range != null && !_isAvailable)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.shade100, border: Border.all(color: Colors.red), borderRadius: BorderRadius.circular(8)),
                child: const Text('❌ Chambre non disponible pour ces dates', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              )
            else if (_range != null && _isAvailable)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.green.shade100, border: Border.all(color: Colors.green), borderRadius: BorderRadius.circular(8)),
                child: const Text('✓ Chambre disponible', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            const SizedBox(height: 16),
            if (_range != null)
              Card(
                color: Colors.blueGrey.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Récapitulatif des prix', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Prix de base / nuit:'), Text('${widget.room.basePrice}€')]),
                      if (widget.room.viewExtra > 0)
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Supplément vue:'), Text('${widget.room.viewExtra}€')]),
                      if (boardPrices[_boardType]! > 0)
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Supplément pension:'), Text('${boardPrices[_boardType]!}€')]),
                      const Divider(),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Prix par nuit:'), Text('$_nightPrice€', style: const TextStyle(fontWeight: FontWeight.bold))]),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Nombre de nuits: $_nights'), const SizedBox.shrink()]),
                      const Divider(thickness: 2),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('TOTAL:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('$_totalPrice€', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue))
                      ]),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_loading || !_isAvailable || _range == null || _checkingAvailability) ? null : _book,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Confirmer la réservation', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
