import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final osmRepositoryProvider = Provider((ref) => OsmRepository());

final osmCourtsProvider = FutureProvider.family<List<OsmCourt>, LatLng>((ref, center) async {
  final repo = ref.watch(osmRepositoryProvider);
  return repo.fetchNearbyCourts(center.latitude, center.longitude);
});

class OsmCourt {
  final String id;
  final String name;
  final double lat;
  final double lon;
  final String? address;
  final String? surface;
  final String? access;
  final String? hoops;
  final String? lit;
  final String? sport;
  final String? leisure;
  final String? checkDate;

  OsmCourt({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
    this.address,
    this.surface,
    this.access,
    this.hoops,
    this.lit,
    this.sport,
    this.leisure,
    this.checkDate,
  });

  factory OsmCourt.fromOsm(Map<String, dynamic> element) {
    final tags = element['tags'] ?? {};
    String name = tags['name'] ?? 'Campetto da Basket';
    
    // Fallback names if generic
    if (name == 'Basketball' || name == 'Basketball Court' || name == 'basket') {
      name = 'Campetto Municipale';
    }

    final double? rawLat = (element['lat'] != null) 
        ? (element['lat'] as num).toDouble() 
        : (element['center'] != null && element['center']['lat'] != null)
            ? (element['center']['lat'] as num).toDouble()
            : null;

    final double? rawLon = (element['lon'] != null)
        ? (element['lon'] as num).toDouble()
        : (element['center'] != null && element['center']['lon'] != null)
            ? (element['center']['lon'] as num).toDouble()
            : null;

    if (rawLat == null || rawLon == null) {
      throw Exception('Dati geografici non validi per l\'elemento ${element['id']}');
    }

    String? address;
    if (tags['addr:full'] != null) {
      address = tags['addr:full'];
    } else if (tags['addr:street'] != null) {
      final street = tags['addr:street'];
      final number = tags['addr:housenumber'] ?? '';
      final city = tags['addr:city'] ?? '';
      address = '$street $number'.trim();
      if (city.isNotEmpty) address += ', $city';
    } else if (tags['addr:city'] != null) {
      address = tags['addr:city'];
    }

    return OsmCourt(
      id: element['id'].toString(),
      name: name,
      lat: rawLat,
      lon: rawLon,
      address: address,
      surface: tags['surface'],
      access: tags['access'],
      hoops: tags['hoops']?.toString(),
      lit: tags['lit'],
      sport: tags['sport'],
      leisure: tags['leisure'],
      checkDate: tags['check_date'] ?? tags['lastcheck'] ?? tags['survey:date'],
    );
  }
}

class OsmRepository {
  Future<List<OsmCourt>> fetchNearbyCourts(double lat, double lon, {double radius = 3000}) async {
    final query = '''
      [out:json][timeout:25];
      (
        node["leisure"="pitch"]["sport"="basketball"](around:$radius,$lat,$lon);
        way["leisure"="pitch"]["sport"="basketball"](around:$radius,$lat,$lon);
        relation["leisure"="pitch"]["sport"="basketball"](around:$radius,$lat,$lon);
      );
      out center;
    ''';

    try {
      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        headers: {
          'User-Agent': 'TRNMNT_App/1.0',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'data': query},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List elements = data['elements'] ?? [];
        return elements.map((e) => OsmCourt.fromOsm(e)).toList();
      } else {
        throw Exception('Errore carica OSM: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connessione OSM fallita: $e');
    }
  }
}
