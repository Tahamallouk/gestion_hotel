import 'package:flutter/material.dart';
import 'package:gestion_hotel/models/hotel.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/app_card.dart';

class HotelCard extends StatelessWidget {
  final Hotel hotel;
  final VoidCallback onTap;
  final VoidCallback? onBookNow;
  final bool dense;

  const HotelCard({
    super.key,
    required this.hotel,
    required this.onTap,
    this.onBookNow,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final trustBadges = _buildTrustBadges(hotel);
    
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.md),
            ),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: (hotel.imageUrl?.isNotEmpty ?? false)
                      ? Image.network(
                          hotel.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => const _ImagePlaceholder(),
                        )
                      : const _ImagePlaceholder(),
                ),
                Positioned(
                  top: AppSpacing.md,
                  right: AppSpacing.md,
                  child: _RatingPill(rating: hotel.rating ?? 0.0),
                ),
              ],
            ),
          ),
          
          // Content section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hotel name
                  Text(
                    hotel.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: AppSpacing.xs),
                  
                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          '${hotel.city}, ${hotel.country}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  if (!dense) ...[
                    const SizedBox(height: AppSpacing.sm),
                    
                    // Trust badges
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: trustBadges.map((badge) => _TrustBadge(
                        icon: badge.icon,
                        label: badge.label,
                      )).toList(),
                    ),
                  ],
                  
                  const Spacer(),
                  
                  // Price and action section
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${hotel.price.toStringAsFixed(0)} DH',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              Text(
                                'par nuit',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          OutlinedButton(
                            onPressed: onTap,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 32),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                              ),
                            ),
                            child: const Text('Voir'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      // Prominent booking button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: onBookNow ?? onTap,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 36),
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(onBookNow != null ? 'Réserver maintenant' : 'Voir et réserver'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_TrustBadgeData> _buildTrustBadges(Hotel hotel) {
    final badges = <_TrustBadgeData>[];
    
    // Verification logic
    final rating = hotel.rating ?? 0.0;
    if (rating >= 4.5) {
      badges.add(const _TrustBadgeData(Icons.verified_outlined, 'Très bien noté'));
    } else if (rating >= 4.0) {
      badges.add(const _TrustBadgeData(Icons.thumb_up_outlined, 'Bien noté'));
    }
    
    if (hotel.address.length > 10) {
      badges.add(const _TrustBadgeData(Icons.location_city_outlined, 'Adresse vérifiée'));
    } else if (hotel.city.isNotEmpty) {
      badges.add(const _TrustBadgeData(Icons.map_outlined, 'Ville renseignée'));
    }
    
    if (badges.length < 3) {
      badges.add(const _TrustBadgeData(Icons.shield, 'Réservation sécurisée'));
    }
    
    return badges.take(3).toList();
  }
}

class _TrustBadgeData {
  final IconData icon;
  final String label;

  const _TrustBadgeData(this.icon, this.label);
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustBadge({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  final double rating;

  const _RatingPill({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 36,
        ),
      ),
    );
  }
}