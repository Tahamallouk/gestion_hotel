import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Pie Chart Widget for displaying reservation status distribution
class ReservationPieChart extends StatelessWidget {
  final int confirmed;
  final int cancelled;
  final int pending;
  final VoidCallback? onRefresh;

  const ReservationPieChart({
    super.key,
    required this.confirmed,
    required this.cancelled,
    required this.pending,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final total = confirmed + cancelled + pending;
    if (total == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Aucune réservation',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 280,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: confirmed.toDouble(),
                  title: confirmed.toString(),
                  color: Colors.green,
                  radius: 80,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PieChartSectionData(
                  value: cancelled.toDouble(),
                  title: cancelled.toString(),
                  color: Colors.red,
                  radius: 80,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PieChartSectionData(
                  value: pending.toDouble(),
                  title: pending.toString(),
                  color: Colors.orange,
                  radius: 80,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              centerSpaceRadius: 0,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _LegendItem(
              color: Colors.green,
              label: 'Confirmées',
              value: confirmed,
            ),
            _LegendItem(
              color: Colors.orange,
              label: 'En attente',
              value: pending,
            ),
            _LegendItem(
              color: Colors.red,
              label: 'Annulées',
              value: cancelled,
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
