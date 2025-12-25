import 'package:flutter/material.dart';
import 'package:gestion_hotel/services/weather_service.dart';
import 'package:gestion_hotel/utils/app_theme.dart';

class WeatherWidget extends StatefulWidget {
  final String city;
  final bool isCompact;

  const WeatherWidget({
    super.key,
    this.city = 'Paris',
    this.isCompact = false,
  });

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    setState(() {
      _isLoading = true;
    });

    final data = await _weatherService.getCurrentWeather(widget.city);
    
    if (mounted) {
      setState(() {
        _weatherData = data;
        _isLoading = false;
      });
    }
  }

  String _getWeatherIcon(String? iconCode) {
    if (iconCode == null) return '☀️';
    
    switch (iconCode.substring(0, 2)) {
      case '01': return '☀️';
      case '02': return '⛅';
      case '03':
      case '04': return '☁️';
      case '09':
      case '10': return '🌧️';
      case '11': return '⛈️';
      case '13': return '🌨️';
      case '50': return '🌫️';
      default: return '🌤️';
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
                'Chargement météo...',
                style: AppTypography.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    if (_weatherData == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Météo indisponible',
                style: AppTypography.bodyLarge,
              ),
              if (!widget.isCompact) ...[
                const SizedBox(height: 4),
                Text(
                  'Vérifiez votre clé API',
                  style: AppTypography.caption?.copyWith(
                    color: AppColors.textSecondary.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final temperature = _weatherData!['main']?['temp']?.round() ?? 0;
    final description = _weatherData!['weather']?[0]?['description'] ?? '';
    final humidity = _weatherData!['main']?['humidity'] ?? 0;
    final windSpeed = _weatherData!['wind']?['speed'] ?? 0.0;
    final iconCode = _weatherData!['weather']?[0]?['icon'];
    final cityName = _weatherData!['name'] ?? widget.city;

    if (widget.isCompact) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(
                _getWeatherIcon(iconCode),
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$cityName',
                      style: AppTypography.subtitle1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${temperature}°C',
                      style: AppTypography.subtitle1.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      description,
                      style: AppTypography.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
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
                  Icons.wb_sunny,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Météo - $cityName',
                  style: AppTypography.subtitle1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      _getWeatherIcon(iconCode),
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${temperature}°C',
                      style: AppTypography.title?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      description,
                      style: AppTypography.caption,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWeatherDetail('Humidité', '${humidity}%', Icons.water_drop),
                    const SizedBox(height: 8),
                    _buildWeatherDetail('Vent', '${windSpeed.toStringAsFixed(1)} m/s', Icons.air),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _loadWeatherData,
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

  Widget _buildWeatherDetail(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.caption?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: AppTypography.body1?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}