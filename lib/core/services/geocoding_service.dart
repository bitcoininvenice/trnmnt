import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocationSuggestion {
  final String displayName;
  final double lat;
  final double lon;

  LocationSuggestion({
    required this.displayName,
    required this.lat,
    required this.lon,
  });

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      displayName: json['display_name'] ?? '',
      lat: double.parse(json['lat'] ?? '0.0'),
      lon: double.parse(json['lon'] ?? '0.0'),
    );
  }
}

final geocodingServiceProvider = Provider((ref) => GeocodingService());

class GeocodingService {
  Future<List<LocationSuggestion>> searchAddress(String query) async {
    if (query.isEmpty) return [];
    
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5'
      );
      
      final response = await http.get(url, headers: {
        'User-Agent': 'trnmnt_app_basketball_manager'
      });
      
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((item) => LocationSuggestion.fromJson(item)).toList();
      }
    } catch (_) {
      // Silently handle geocoding errors
    }
    return [];
  }
}
