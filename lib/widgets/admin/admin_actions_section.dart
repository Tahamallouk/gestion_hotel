import 'package:flutter/material.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/app_card.dart';
import 'package:gestion_hotel/widgets/export_button.dart';
import 'package:gestion_hotel/screens/admin/admin_hotel_detail_screen.dart';

/// Actions section widget for admin dashboard
class AdminActionsSection extends StatelessWidget {
  final int totalHotels;
  final int totalRooms;
  final int totalReservations;
  final int confirmedCount;
  final int cancelledCount;
  final int pendingCount;
  final double occupancyRate;
  final double estimatedRevenue;
  final List<Map<String, dynamic>> allHotels;

  const AdminActionsSection({
    super.key,
    required this.totalHotels,
    required this.totalRooms,
    required this.totalReservations,
    required this.confirmedCount,
    required this.cancelledCount,
    required this.pendingCount,
    required this.occupancyRate,
    required this.estimatedRevenue,
    required this.allHotels,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showExportDialog(context),
              icon: const Icon(Icons.download),
              label: const Text('Exporter'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allMd),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showHotelsDialog(context),
              icon: const Icon(Icons.hotel),
              label: const Text('Hôtels'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allMd),
                side: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    final exportData = [
      {
        'Métrique': 'Total Hôtels',
        'Valeur': totalHotels,
      },
      {
        'Métrique': 'Total Chambres',
        'Valeur': totalRooms,
      },
      {
        'Métrique': 'Total Réservations',
        'Valeur': totalReservations,
      },
      {
        'Métrique': 'Confirmées',
        'Valeur': confirmedCount,
      },
      {
        'Métrique': 'Annulées',
        'Valeur': cancelledCount,
      },
      {
        'Métrique': 'En Attente',
        'Valeur': pendingCount,
      },
      {
        'Métrique': 'Taux Occupation',
        'Valeur': '${occupancyRate.toStringAsFixed(1)}%',
      },
      {
        'Métrique': 'Revenus Estimés',
        'Valeur': '${estimatedRevenue.toStringAsFixed(2)} DH',
      },
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exporter les données'),
        content: ExportButton(
          title: 'Statistiques',
          data: exportData,
          filename: 'dashboard_${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}.csv',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showHotelsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sélectionner un hôtel'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: allHotels.length,
            itemBuilder: (context, index) {
              final hotel = allHotels[index];
              return ListTile(
                title: Text(hotel['name'] as String? ?? 'Unknown'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminHotelDetailScreen(
                        hotelId: hotel['id'] as String? ?? '',
                        hotelName: hotel['name'] as String? ?? 'Unknown',
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
