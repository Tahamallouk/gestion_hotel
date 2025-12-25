import 'package:flutter/material.dart';
import 'package:gestion_hotel/services/world_time_service.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:intl/intl.dart';

class WorldTimeWidget extends StatefulWidget {
  final bool isCompact;

  const WorldTimeWidget({
    super.key,
    this.isCompact = false,
  });

  @override
  State<WorldTimeWidget> createState() => _WorldTimeWidgetState();
}

class _WorldTimeWidgetState extends State<WorldTimeWidget> {
  final WorldTimeService _timeService = WorldTimeService();
  List<Map<String, dynamic>> _timeZones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTimeZones();
  }

  Future<void> _loadTimeZones() async {
    setState(() {
      _isLoading = true;
    });

    final popularTimezones = _timeService.getPopularTimezones();
    final timeData = await _timeService.getMultipleTimezones(
      widget.isCompact ? popularTimezones.take(3).toList() : popularTimezones,
    );
    
    if (mounted) {
      setState(() {
        _timeZones = timeData;
        _isLoading = false;
      });
    }
  }

  String _formatCityName(String timezone) {
    final parts = timezone.split('/');
    if (parts.length > 1) {
      return parts.last.replaceAll('_', ' ');
    }
    return timezone;
  }

  String _formatTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return DateTime.now().toString().substring(11, 16);
    }
  }

  String _formatDate(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd/MM').format(dateTime);
    } catch (e) {
      return DateFormat('dd/MM').format(DateTime.now());
    }
  }

  String _getTimeIcon(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final hour = dateTime.hour;
      
      if (hour >= 6 && hour < 12) return '🌅'; // Morning
      if (hour >= 12 && hour < 18) return '☀️'; // Afternoon  
      if (hour >= 18 && hour < 22) return '🌆'; // Evening
      return '🌙'; // Night
    } catch (e) {
      return '🕐';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 8),
              Text(
                'Chargement horaires...',
                style: AppTypography.body1,
              ),
            ],
          ),
        ),
      );
    }

    if (_timeZones.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time,
                color: AppColors.error,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Horaires indisponibles',
                style: AppTypography.body1,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.public,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Horaires Mondiaux',
                  style: AppTypography.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...(_timeZones.map((timeData) => _buildTimeZoneRow(timeData))),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _loadTimeZones,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text(
                    'Actualiser',
                    style: AppTypography.caption,
                  ),
                ),
                Text(
                  'Mise à jour: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                  style: AppTypography.caption?.copyWith(
                    color: AppColors.textSecondary.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeZoneRow(Map<String, dynamic> timeData) {
    final timezone = timeData['timezone'] ?? '';
    final datetime = timeData['datetime'] ?? '';
    final cityName = _formatCityName(timezone);
    final time = _formatTime(datetime);
    final date = _formatDate(datetime);
    final icon = _getTimeIcon(datetime);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              cityName,
              style: AppTypography.body1?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              time,
              style: AppTypography.body1?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (!widget.isCompact)
            Expanded(
              child: Text(
                date,
                style: AppTypography.caption,
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }
}