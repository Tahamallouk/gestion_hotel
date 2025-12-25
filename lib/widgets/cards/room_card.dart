import 'package:flutter/material.dart';
import 'package:gestion_hotel/utils/app_theme.dart';

/// Polished RoomCard widget for displaying room information
/// Features: Type, capacity, price, availability status with visual indicators
class RoomCard extends StatefulWidget {
  final String roomId;
  final String roomType;
  final int capacity;
  final double pricePerNight;
  final bool isAvailable;
  final String? imageUrl;
  final VoidCallback onTap;
  final Map<String, dynamic>? amenities;

  const RoomCard({
    super.key,
    required this.roomId,
    required this.roomType,
    required this.capacity,
    required this.pricePerNight,
    required this.isAvailable,
    this.imageUrl,
    required this.onTap,
    this.amenities,
  });

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    if (!widget.isAvailable) {
      return AppColors.error;
    }
    return AppColors.success;
  }

  String _getStatusText() {
    return widget.isAvailable ? 'Disponible' : 'Occupée';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _animationController.forward();
      },
      onTapUp: (_) {
        _animationController.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        _animationController.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.all12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Room image with status badge
              Stack(
                children: [
                  /// Image
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      color: AppColors.background,
                    ),
                    child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                        ? Image.network(
                            widget.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, exception, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.bed,
                                  size: 48,
                                  color: AppColors.textTertiary,
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Icon(
                              Icons.bed,
                              size: 48,
                              color: AppColors.textTertiary,
                            ),
                          ),
                  ),

                  /// Status badge
                  Positioned(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(),
                        borderRadius: AppBorderRadius.all8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.isAvailable
                                ? Icons.check_circle
                                : Icons.block,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getStatusText(),
                            style: AppTextStyles.captionSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              /// Room info
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Type and capacity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.roomType,
                          style: AppTextStyles.subtitle2.copyWith(
                            color:
                                Theme.of(context).textTheme.titleMedium?.color,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: AppBorderRadius.all8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.people,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.capacity}',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    /// Price
                    Text(
                      '${widget.pricePerNight.toStringAsFixed(2)} DH / nuit',
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    /// Amenities if available
                    if (widget.amenities != null &&
                        (widget.amenities as Map).isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: (widget.amenities as Map)
                            .entries
                            .take(3)
                            .map((entry) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: AppBorderRadius.all8,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              entry.key,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
