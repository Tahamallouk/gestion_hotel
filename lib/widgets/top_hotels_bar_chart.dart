import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Bar Chart Widget for top hotels by reservations
class TopHotelsBarChart extends StatelessWidget {
  final List<HotelBarData> hotels;
  final int maxReservations;
  final VoidCallback? onRefresh;

  const TopHotelsBarChart({
    super.key,
    required this.hotels,
    required this.maxReservations,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (hotels.isEmpty) {
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

    final max = maxReservations > 0 ? maxReservations.toDouble() : 10.0;

    return SizedBox(
      height: 280,
      child: BarChart(
        BarChartData(
          barGroups: hotels.asMap().entries.map((entry) {
            final index = entry.key;
            final hotel = entry.value;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: hotel.reservations.toDouble(),
                  color: Colors.blue.withValues(alpha: 0.7 + (index * 0.05)),
                  width: 24,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                )
              ],
            );
          }).toList(),
          maxY: max,
          titlesData: FlTitlesData(
            show: true,
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= hotels.length) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      hotels[index].hotelName.split(' ').first,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
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
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            horizontalInterval: (max / 5),
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[200]!,
                strokeWidth: 0.5,
              );
            },
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!, width: 1),
              left: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
          ),
        ),
      ),
    );
  }
}

/// Data class for hotel bar chart
class HotelBarData {
  final String hotelId;
  final String hotelName;
  final int reservations;

  HotelBarData({
    required this.hotelId,
    required this.hotelName,
    required this.reservations,
  });

  factory HotelBarData.fromMap(Map<String, dynamic> map) {
    return HotelBarData(
      hotelId: map['hotelId'] ?? '',
      hotelName: map['hotelName'] ?? 'Unknown Hotel',
      reservations: (map['reservations'] as num?)?.toInt() ?? 0,
    );
  }
}
