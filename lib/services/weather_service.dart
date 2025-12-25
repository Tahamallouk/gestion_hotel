import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiKey = 'YOUR_FREE_API_KEY'; // Replace with your OpenWeatherMap API key
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<Map<String, dynamic>?> getCurrentWeather(String city) async {
    if (_apiKey == 'YOUR_FREE_API_KEY') {
      // Return mock data if API key not configured
      return {
        'name': city,
        'main': {
          'temp': 22.5,
          'humidity': 65,
        },
        'weather': [
          {
            'main': 'Clear',
            'description': 'clear sky',
            'icon': '01d',
          }
        ],
        'wind': {
          'speed': 3.5,
        }
      };
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/weather?q=$city&appid=$_apiKey&units=metric'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching weather: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getForecast(String city) async {
    if (_apiKey == 'YOUR_FREE_API_KEY') {
      // Return mock forecast data
      return {
        'list': List.generate(5, (index) => {
          'dt_txt': DateTime.now().add(Duration(days: index)).toString(),
          'main': {
            'temp': 20.0 + (index * 2),
            'humidity': 60 + index,
          },
          'weather': [
            {
              'main': index.isEven ? 'Clear' : 'Clouds',
              'description': index.isEven ? 'clear sky' : 'few clouds',
              'icon': index.isEven ? '01d' : '02d',
            }
          ],
        }),
      };
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/forecast?q=$city&appid=$_apiKey&units=metric'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching forecast: $e');
      return null;
    }
  }
}