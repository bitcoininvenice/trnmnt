import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong2/latlong.dart';

final pickrollRepositoryProvider = Provider((ref) => PickrollRepository());

final pickrollCourtsProvider = FutureProvider.family<List<PickrollCourt>, LatLng>((ref, center) async {
  final repo = ref.watch(pickrollRepositoryProvider);
  return repo.fetchNearbyCourts(center.latitude, center.longitude);
});

class PickrollCourt {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String? address;

  PickrollCourt({required this.id, required this.name, required this.lat, required this.lng, this.address});

  factory PickrollCourt.fromJson(Map<String, dynamic> json) {
    final coords = json['coord'] as List<dynamic>?;
    return PickrollCourt(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Campetto Pick&Roll',
      lat: coords != null && coords.isNotEmpty ? (coords[0] as num).toDouble() : 0.0,
      lng: coords != null && coords.length > 1 ? (coords[1] as num).toDouble() : 0.0,
      address: json['description'] ?? '',
    );
  }
}

class PickrollRepository {
  Future<List<PickrollCourt>> fetchNearbyCourts(double lat, double lng) async {
    final token = dotenv.env['PICK_ROLL_API_TOKEN'];
    if (token == null) throw Exception('API Token Pick&Roll mancante in .env');

    final url = Uri.https('apiv2.pick-roll.com', '/api/structures/near', {
      'lat': lat.toString(),
      'lng': lng.toString(),
      'token': token,
    });
    
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List structures = jsonResponse['structures'] ?? [];
        final mapped = structures
            .where((item) => item['type'] == 'street')
            .map((item) => PickrollCourt.fromJson(item))
            .toList();
        return mapped;
      } else {
        throw Exception('Errore API: Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Errore connessione Pick&Roll: $e');
    }
  }
}
