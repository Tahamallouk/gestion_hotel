import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Line Chart Widget for reservations over time
class ReservationsLineChart extends StatelessWidget {
  final List<DailyReservationData> data;
  final VoidCallback? onRefresh;

  const ReservationsLineChart({
    super.key,
    required this.data,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Aucune donnée disponible',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final maxY = data.isEmpty ? 10.0 : data.map((e) => e.count.toDouble()).reduce((a, b) => a > b ? a : b) + 2;

    return SizedBox(
      height: 280,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            horizontalInterval: maxY / 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[200]!,
                strokeWidth: 0.5,
              );
            },
            drawVerticalLine: true,
            verticalInterval: 1,
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey[200]!,
                strokeWidth: 0.5,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox.shrink();
                  }

                  return Text(
                    data[index].formattedDate,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                },
                interval: data.length > 10 ? 2 : 1,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                },
                reservedSize: 30,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!, width: 1),
              left: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.count.toDouble());
              }).toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.blue,
                    strokeWidth: 1,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withValues(alpha: 0.1),
              ),
            ),
          ],
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
        ),
      ),
    );
  }
}

/// Data class for daily reservation data
class DailyReservationData {
  final DateTime date;
  final int count;

  String get formattedDate {
    return '${date.day}/${date.month}';
  }

  DailyReservationData({
    required this.date,
    required this.count,
  });

  factory DailyReservationData.fromMap(Map<String, dynamic> map) {
    return DailyReservationData(
      date: map['date'] is DateTime ? map['date'] as DateTime : DateTime.now(),
      count: map['count'] ?? 0,
    );
  }
}
