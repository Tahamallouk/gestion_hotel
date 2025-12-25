import 'package:flutter/material.dart';
import 'package:gestion_hotel/models/room.dart';
import 'package:gestion_hotel/utils/app_theme.dart';

class RoomDetailsScreen extends StatefulWidget {
  final Room room;

  const RoomDetailsScreen({super.key, required this.room});

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  DateTimeRange? _range;

  List<String> get _gallery => [
        widget.room.imageUrl,
        'https://images.unsplash.com/photo-1505761671935-60b3a7427bad?auto=format&fit=crop&w=900&q=80',
        'https://images.unsplash.com/photo-1501117716987-c8e1ecb210af?auto=format&fit=crop&w=900&q=80',
      ].where((e) => e?.isNotEmpty ?? false).map((e) => e!).toList();

  double get _pricePerNight => (widget.room.basePrice + widget.room.viewExtra).toDouble();

  int get _nights {
    if (_range == null) return 1;
    final diff = _range!.end.difference(_range!.start).inDays;
    return diff <= 0 ? 1 : diff;
  }

  double get _total => _nights * _pricePerNight;

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    return Scaffold(
      appBar: AppBar(title: Text(room.type.isEmpty ? 'Chambre ${room.number}' : room.type)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Gallery(images: _gallery),
            const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(room.type.isEmpty ? 'Chambre ${room.number}' : room.type, style: AppTextStyles.headline4),
                      const SizedBox(height: AppSpacing.xs),
                      Text('Capacité ${room.capacity} · Vue ${room.view.isEmpty ? 'standard' : room.view}',
                          style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                _AvailabilityPill(isAvailable: room.isAvailable),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text('${_pricePerNight.toStringAsFixed(0)} DH/nuit',
                style: AppTextStyles.headline3.copyWith(color: AppColors.success, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.lg),
            _Section(label: 'Équipements', child: _AmenitiesGrid()),
            const SizedBox(height: AppSpacing.lg),
            _Section(
              label: 'Séjour',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickDates,
                    icon: const Icon(Icons.date_range),
                    label: Text(_range == null
                        ? 'Choisir des dates'
                        : '${_formatDate(_range!.start)} → ${_formatDate(_range!.end)}'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Total estimé: ${_total.toStringAsFixed(0)} DH pour $_nights nuit(s)',
                      style: AppTextStyles.subtitle2.copyWith(color: AppColors.textPrimary)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.meeting_room_outlined),
                label: const Text('Réserver'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _range ?? DateTimeRange(start: now, end: nextWeek),
    );
    if (picked != null) {
      setState(() => _range = picked);
    }
  }

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _Section extends StatelessWidget {
  final String label;
  final Widget child;
  const _Section({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.subtitle1),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

class _Gallery extends StatelessWidget {
  final List<String> images;
  const _Gallery({required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppBorderRadius.allLg,
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(child: Icon(Icons.image_not_supported_outlined, color: AppColors.textSecondary)),
      );
    }
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (context, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final url = images[index];
          return ClipRRect(
            borderRadius: AppBorderRadius.allLg,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => const _GalleryPlaceholder(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GalleryPlaceholder extends StatelessWidget {
  const _GalleryPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: const Center(child: Icon(Icons.image, color: AppColors.textSecondary)),
    );
  }
}

class _AmenitiesGrid extends StatelessWidget {
  final List<_Amenity> amenities = const [
    _Amenity(Icons.wifi, 'Wifi'),
    _Amenity(Icons.breakfast_dining, 'Petit-déj'),
    _Amenity(Icons.tv, 'TV'),
    _Amenity(Icons.ac_unit, 'Clim'),
    _Amenity(Icons.pool, 'Piscine'),
    _Amenity(Icons.local_parking, 'Parking'),
  ];

  const _AmenitiesGrid();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: amenities
          .map((a) => Chip(
                avatar: Icon(a.icon, size: 16, color: AppColors.textSecondary),
                label: Text(a.label),
                backgroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: AppBorderRadius.allMd,
                  side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
                ),
              ))
          .toList(),
    );
  }
}

class _Amenity {
  final IconData icon;
  final String label;
  const _Amenity(this.icon, this.label);
}

class _AvailabilityPill extends StatelessWidget {
  final bool isAvailable;
  const _AvailabilityPill({required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    final color = isAvailable ? AppColors.success : AppColors.error;
    final label = isAvailable ? 'Disponible' : 'Indisponible';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: AppBorderRadius.allMd,
      ),
      child: Text(label, style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w700)),
    );
  }
}
