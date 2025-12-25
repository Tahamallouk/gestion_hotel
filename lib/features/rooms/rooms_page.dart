import 'package:flutter/material.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/app_card.dart';
import 'package:gestion_hotel/widgets/section_header.dart';

class RoomsPage extends StatelessWidget {
  const RoomsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final rooms = const [
      _RoomCardData('Deluxe', 'Vue mer • 45 disponibles', 180.0),
      _RoomCardData('Suite Junior', 'Salon + balcon • 22 disponibles', 250.0),
      _RoomCardData('Standard', 'Lit queen • 60 disponibles', 110.0),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingHorizontal, vertical: AppSpacing.xl),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeader(title: 'Chambres'),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: rooms
              .map(
                (room) => SizedBox(
                  width: ResponsiveHelper.isMobile(context) ? double.infinity : 320,
                  child: _RoomCard(data: room),
                ),
              )
              .toList(),
        ),
      ]),
    );
  }
}

class _RoomCardData {
  final String title;
  final String subtitle;
  final double price;
  const _RoomCardData(this.title, this.subtitle, this.price);
}

class _RoomCard extends StatelessWidget {
  final _RoomCardData data;
  const _RoomCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final checkIn = DateTime.now().add(const Duration(days: 7)); // Example check-in
    final checkOut = checkIn.add(const Duration(days: 3)); // Example 3-night stay
    
    return AppCard(
      onTap: () {
        _showRoomDetails(context, data, checkIn, checkOut);
      },
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: AppBorderRadius.allMd),
            child: const Icon(Icons.king_bed_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(data.title, style: AppTextStyles.subtitle1)),
        ]),
        const SizedBox(height: AppSpacing.sm),
        Text(data.subtitle, style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.md),
        Text(
          '${data.price.toStringAsFixed(0)}€ / nuit',
          style: AppTextStyles.subtitle1.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ]),
    );
  }

  void _showRoomDetails(BuildContext context, _RoomCardData room, DateTime checkIn, DateTime checkOut) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Détails de la chambre ${room.title}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  room.subtitle,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Prix de base:', style: AppTypography.bodyMedium),
                          Text('${room.price.toStringAsFixed(0)}€', 
                               style: AppTypography.titleMedium?.copyWith(
                                 color: AppColors.primary,
                                 fontWeight: FontWeight.bold
                               )),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Tarification dynamique disponible', 
                           style: AppTypography.bodySmall?.copyWith(
                             color: AppColors.secondary
                           )),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Testez vos prix personnalisés:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Prix: ${room.price.toStringAsFixed(2)} €',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Réservation pour ${room.title} initiée'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text('Réserver cette chambre'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
