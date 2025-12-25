import 'package:flutter/material.dart';
import 'package:gestion_hotel/models/hotel.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import '../../hotels/hotel_detail_screen.dart';
import '../../hotels/list_hotels_screen.dart';

class FeaturedHotels extends StatelessWidget {
  final List<Hotel> hotels;

  const FeaturedHotels({super.key, required this.hotels});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Hotels en avant', style: AppTextStyles.headline4),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ListHotelsScreen()),
              ),
              child: const Text('Tout voir'),
            )
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (hotels.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppBorderRadius.allLg,
              border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
            ),
            child: Column(
              children: [
                Icon(Icons.hotel_outlined, color: AppColors.textSecondary, size: 32),
                const SizedBox(height: AppSpacing.sm),
                Text('Aucun hotel disponible pour le moment', style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: hotels.length,
              separatorBuilder: (context, _) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                final hotel = hotels[index];
                return SizedBox(
                  width: ResponsiveHelper.isMobile(context) ? 260 : 300,
                  child: _HotelTile(hotel: hotel),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _HotelTile extends StatelessWidget {
  final Hotel hotel;

  const _HotelTile({required this.hotel});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppBorderRadius.allLg,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HotelDetailScreen(hotel: hotel)),
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary.withValues(alpha: 0.9), AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppBorderRadius.allLg,
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.16),
                    borderRadius: AppBorderRadius.allMd,
                  ),
                  child: const Icon(Icons.hotel, color: AppColors.textOnPrimary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hotel.name, style: AppTextStyles.subtitle1.copyWith(color: AppColors.textOnPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: AppColors.textOnPrimary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              hotel.city,
                              style: AppTextStyles.caption.copyWith(color: AppColors.textOnPrimary.withValues(alpha: 0.85)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('4.5', style: AppTextStyles.body3.copyWith(color: AppColors.textOnPrimary)),
                  ],
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textOnPrimary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
