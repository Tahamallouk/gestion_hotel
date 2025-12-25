import 'package:flutter/material.dart';
import 'package:gestion_hotel/utils/app_theme.dart';

/// Card showing a hotel photo, rating badge, address, and nightly price.
class HotelCard extends StatefulWidget {
	final String hotelId;
	final String name;
	final String address;
	final String imageUrl;
	final double rating;
	final double pricePerNight;
	final VoidCallback onTap;
	final bool isFavorite;
	final ValueChanged<bool>? onFavoriteTap;

	const HotelCard({
		super.key,
		required this.hotelId,
		required this.name,
		required this.address,
		required this.imageUrl,
		required this.rating,
		required this.pricePerNight,
		required this.onTap,
		this.isFavorite = false,
		this.onFavoriteTap,
	});

	@override
	State<HotelCard> createState() => _HotelCardState();
}

class _HotelCardState extends State<HotelCard> with SingleTickerProviderStateMixin {
	late final AnimationController _animationController;
	late final Animation<double> _scaleAnimation;

	@override
	void initState() {
		super.initState();
		_animationController = AnimationController(
			duration: const Duration(milliseconds: 180),
			vsync: this,
		);
		_scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
			CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
		);
	}

	@override
	void dispose() {
		_animationController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return GestureDetector(
			onTapDown: (_) => _animationController.forward(),
			onTapUp: (_) {
				_animationController.reverse();
				widget.onTap();
			},
			onTapCancel: () => _animationController.reverse(),
			child: ScaleTransition(
				scale: _scaleAnimation,
				child: Card(
					elevation: 2,
					margin: EdgeInsets.zero,
					shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.all12),
					clipBehavior: Clip.antiAlias,
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Stack(
								children: [
									SizedBox(
										height: 150,
										width: double.infinity,
										child: widget.imageUrl.isNotEmpty
												? Image.network(
														widget.imageUrl,
														fit: BoxFit.cover,
												errorBuilder: (context, error, stack) => const _HotelImagePlaceholder(),
													)
												: const _HotelImagePlaceholder(),
									),
									Positioned(
										top: AppSpacing.md,
										right: AppSpacing.md,
										child: Container(
											padding: const EdgeInsets.symmetric(
												horizontal: AppSpacing.sm,
												vertical: AppSpacing.xs,
											),
											decoration: BoxDecoration(
												color: Colors.black54,
												borderRadius: AppBorderRadius.all8,
											),
											child: Row(
												mainAxisSize: MainAxisSize.min,
												children: [
													const Icon(Icons.star, color: Colors.amber, size: 16),
													const SizedBox(width: 4),
													Text(
														widget.rating.toStringAsFixed(1),
														style: AppTextStyles.captionSmall.copyWith(
															color: Colors.white,
															fontWeight: FontWeight.w600,
														),
													),
												],
											),
										),
									),
									if (widget.onFavoriteTap != null)
										Positioned(
											top: AppSpacing.md,
											left: AppSpacing.md,
											child: GestureDetector(
												onTap: () => widget.onFavoriteTap!(!widget.isFavorite),
												child: Container(
													padding: const EdgeInsets.all(6),
													decoration: const BoxDecoration(
														color: Colors.black54,
														shape: BoxShape.circle,
													),
													child: Icon(
														widget.isFavorite ? Icons.favorite : Icons.favorite_border,
														color: Colors.red,
														size: 20,
													),
												),
											),
										),
								],
							),
							Padding(
								padding: const EdgeInsets.all(AppSpacing.lg),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text(
											widget.name,
											style: AppTextStyles.subtitle1.copyWith(
												color: Theme.of(context).textTheme.titleMedium?.color,
											),
											maxLines: 1,
											overflow: TextOverflow.ellipsis,
										),
										const SizedBox(height: AppSpacing.sm),
										Row(
											children: [
												const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
												const SizedBox(width: 4),
												Expanded(
													child: Text(
														widget.address,
														style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
														maxLines: 1,
														overflow: TextOverflow.ellipsis,
													),
												),
											],
										),
										const SizedBox(height: AppSpacing.md),
										Text(
											'${widget.pricePerNight.toStringAsFixed(0)} DH / nuit',
											style: AppTextStyles.subtitle2.copyWith(
												color: AppColors.primary,
												fontWeight: FontWeight.bold,
											),
										),
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

class _HotelImagePlaceholder extends StatelessWidget {
	const _HotelImagePlaceholder();

	@override
	Widget build(BuildContext context) {
		return Container(
			color: AppColors.background,
			child: const Center(
				child: Icon(Icons.hotel, size: 48, color: AppColors.textTertiary),
			),
		);
	}
}
