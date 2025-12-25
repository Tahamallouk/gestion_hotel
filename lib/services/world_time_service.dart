import 'dart:convert';
import 'package:http/http.dart' as http;

class WorldTimeService {
  static const String _baseUrl = 'http://worldtimeapi.org/api';

  Future<Map<String, dynamic>?> getTimeForTimezone(String timezone) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/timezone/$timezone'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching time: $e');
      // Return mock data if API fails
      return {
        'timezone': timezone,
        'datetime': DateTime.now().toIso8601String(),
        'utc_offset': '+01:00',
        'abbreviation': 'CET',
      };
    }
  }

  Future<List<Map<String, dynamic>>> getMultipleTimezones(List<String> timezones) async {
    final List<Map<String, dynamic>> results = [];
    
    for (String timezone in timezones) {
      final timeData = await getTimeForTimezone(timezone);
      if (timeData != null) {
        results.add(timeData);
      }
    }
    
    return results;
  }

  List<String> getPopularTimezones() {
    return [
      'Europe/Paris',
      'America/New_York',
      'Asia/Tokyo',
      'Australia/Sydney',
      'Europe/London',
      'America/Los_Angeles',
    ];
  }
}