import 'package:flutter/material.dart';
import 'package:gestion_hotel/utils/app_theme.dart';

/// Empty state widget for displaying when no data is available
/// Shows icon, title, subtitle, and optional action button
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double iconSize;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconSize = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Icon
              Container(
                padding: const EdgeInsets.all(AppSpacing.xxxl),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              /// Title
              Text(
                title,
                style: AppTextStyles.headline3.copyWith(
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.lg),

              /// Subtitle
              Text(
                subtitle,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              /// Action button
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.xxxl),
                ElevatedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.refresh),
                  label: Text(actionLabel!),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxxl,
                      vertical: AppSpacing.lg,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state variations for common scenarios
class EmptyStates {
  /// No hotels found
  static Widget noHotels(VoidCallback? onRefresh) {
    return EmptyState(
      icon: Icons.hotel,
      title: 'Aucun hôtel trouvé',
      subtitle: 'Nous n\'avons trouvé aucun hôtel correspondant à votre recherche.',
      actionLabel: onRefresh != null ? 'Réessayer' : null,
      onAction: onRefresh,
    );
  }

  /// No rooms found
  static Widget noRooms(VoidCallback? onRefresh) {
    return EmptyState(
      icon: Icons.bed,
      title: 'Aucune chambre disponible',
      subtitle:
          'Aucune chambre n\'est disponible pour les dates sélectionnées.',
      actionLabel: onRefresh != null ? 'Réessayer' : null,
      onAction: onRefresh,
    );
  }

  /// No reservations
  static Widget noReservations(VoidCallback? onRefresh) {
    return EmptyState(
      icon: Icons.calendar_today,
      title: 'Aucune réservation',
      subtitle: 'Vous n\'avez pas encore effectué de réservation.',
      actionLabel: onRefresh != null ? 'Parcourir les hôtels' : null,
      onAction: onRefresh,
    );
  }

  /// No favorites
  static Widget noFavorites(VoidCallback? onRefresh) {
    return EmptyState(
      icon: Icons.favorite_border,
      title: 'Pas de favoris',
      subtitle: 'Ajoutez vos hôtels préférés à vos favoris.',
      actionLabel: onRefresh != null ? 'Découvrir' : null,
      onAction: onRefresh,
    );
  }

  /// Error occurred
  static Widget error({
    required String message,
    VoidCallback? onRetry,
  }) {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Une erreur s\'est produite',
      subtitle: message,
      actionLabel: onRetry != null ? 'Réessayer' : null,
      onAction: onRetry,
    );
  }

  /// No search results
  static Widget noSearchResults({
    required String query,
    VoidCallback? onClear,
  }) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'Aucun résultat',
      subtitle: 'Aucun résultat trouvé pour "$query".',
      actionLabel: onClear != null ? 'Effacer la recherche' : null,
      onAction: onClear,
    );
  }
}
