import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_hotel/providers/admin_providers.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/common/app_loader.dart';
import 'package:gestion_hotel/widgets/common/empty_state.dart';
import 'package:gestion_hotel/widgets/error_state.dart';
import 'package:gestion_hotel/widgets/section_header.dart';
import 'package:gestion_hotel/widgets/time_range_filter.dart';
import 'package:gestion_hotel/widgets/admin/admin_dashboard_header.dart';
import 'package:gestion_hotel/widgets/admin/admin_stats_grid.dart';
import 'package:gestion_hotel/widgets/admin/admin_status_grid.dart';
import 'package:gestion_hotel/widgets/admin/admin_revenue_card.dart';
import 'package:gestion_hotel/widgets/admin/admin_occupancy_card.dart';
import 'package:gestion_hotel/widgets/admin/admin_charts_section.dart';
import 'package:gestion_hotel/widgets/admin/admin_actions_section.dart';

/// Admin Dashboard Screen - Affiche les statistiques et métriques clés du système
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch admin role check
    final adminRoleAsync = ref.watch(adminRoleProvider);
    
    return adminRoleAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: AppLoader(message: 'Vérification des permissions...')),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: ErrorState(
            title: 'Erreur d\'authentification',
            subtitle: error.toString(),
            onRetry: () => ref.invalidate(adminRoleProvider),
          ),
        ),
      ),
      data: (isAdmin) {
        if (!isAdmin) {
          // Redirect non-admin users
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pop(context);
          });
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: ErrorState(title: 'Accès refusé')),
          );
        }
        
        return const _AdminDashboardContent();
      },
    );
  }
}

class _AdminDashboardContent extends ConsumerWidget {
  const _AdminDashboardContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch selected time range
    final selectedDays = ref.watch(selectedDaysProvider);
    
    // Watch dashboard data
    final dashboardAsync = ref.watch(adminDashboardDataProvider(selectedDays));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminDashboardDataProvider(selectedDays)),
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: dashboardAsync.when(
        loading: () => const Center(
          child: AppLoader(message: 'Chargement des statistiques...'),
        ),
        error: (error, stack) => Center(
          child: ErrorState(
            title: 'Erreur de chargement',
            subtitle: error.toString(),
            onRetry: () => ref.invalidate(adminDashboardDataProvider(selectedDays)),
          ),
        ),
        data: (data) {
          if (data.isEmptyData) {
            return Center(
              child: EmptyState(
                icon: Icons.analytics_outlined,
                title: 'Aucune donnée disponible',
                subtitle: 'Ajoutez des hôtels, chambres ou réservations pour voir les statistiques.',
                actionLabel: 'Rafraîchir',
                onAction: () => ref.invalidate(adminDashboardDataProvider(selectedDays)),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(adminDashboardDataProvider(selectedDays));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AdminDashboardHeader(
                    onRefresh: () => ref.invalidate(adminDashboardDataProvider(selectedDays)),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  const SectionHeader(
                    title: 'Chiffres clés',
                    subtitle: 'Vue rapide sur les indicateurs majeurs',
                  ),
                  AdminStatsGrid(
                    totalHotels: data.totalHotels,
                    totalRooms: data.totalRooms,
                    totalReservations: data.totalReservations,
                    occupancyRate: data.occupancyRate,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  const SectionHeader(
                    title: 'Réservations par statut',
                    subtitle: 'Répartition globale',
                  ),
                  AdminStatusGrid(
                    confirmedCount: data.confirmedCount,
                    cancelledCount: data.cancelledCount,
                    pendingCount: data.pendingCount,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  const SectionHeader(
                    title: 'Revenus estimés',
                    subtitle: 'Basé sur les réservations confirmées',
                  ),
                  AdminRevenueCard(
                    estimatedRevenue: data.estimatedRevenue,
                    confirmedCount: data.confirmedCount,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  const SectionHeader(
                    title: 'Occupation globale',
                    subtitle: 'Moyenne pondérée',
                  ),
                  AdminOccupancyCard(
                    occupancyRate: data.occupancyRate,
                    totalRooms: data.totalRooms,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  SectionHeader(
                    title: 'Graphiques et analyses',
                    subtitle: 'Tendance sur $selectedDays jours',
                    action: TimeRangeFilter(
                      selectedDays: selectedDays,
                      onChanged: (days) {
                        ref.read(selectedDaysProvider.notifier).state = days;
                      },
                    ),
                  ),
                  AdminChartsSection(
                    confirmedCount: data.confirmedCount,
                    cancelledCount: data.cancelledCount,
                    pendingCount: data.pendingCount,
                    reservationsSeries: data.reservationsSeries,
                    topHotels: data.topHotels,
                    selectedDays: selectedDays,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  const SectionHeader(
                    title: 'Actions rapides',
                    subtitle: 'Exporter et naviguer',
                  ),
                  AdminActionsSection(
                    totalHotels: data.totalHotels,
                    totalRooms: data.totalRooms,
                    totalReservations: data.totalReservations,
                    confirmedCount: data.confirmedCount,
                    cancelledCount: data.cancelledCount,
                    pendingCount: data.pendingCount,
                    occupancyRate: data.occupancyRate,
                    estimatedRevenue: data.estimatedRevenue,
                    allHotels: data.allHotels,
                  ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}