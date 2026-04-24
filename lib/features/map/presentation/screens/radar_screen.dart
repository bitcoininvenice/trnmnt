import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' as drift;
import 'package:trnmnt/core/database/app_database.dart';
import 'package:trnmnt/features/map/data/courts_repository.dart';
import 'package:trnmnt/features/map/data/osm_repository.dart';
import 'package:trnmnt/core/providers/osm_settings_provider.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../tournaments/data/tournaments_repository.dart';
import '../../../tournaments/presentation/widgets/tournament_status_badge.dart';
import 'package:trnmnt/features/explorer/presentation/screens/hub_screen.dart';

enum RadarDataSource { local, osm }

class RadarScreen extends ConsumerStatefulWidget {
  const RadarScreen({super.key});

  @override
  ConsumerState<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends ConsumerState<RadarScreen> {
  final MapController _mapController = MapController();
  final LatLng _defaultCenter = const LatLng(45.4408, 12.3155); // Venice
  bool _isAddingMode = false;
  bool _isSatellite = true;
  LatLng _searchCenter = const LatLng(45.4408, 12.3155);
  
  RadarDataSource _selectedSource = RadarDataSource.local;
  List<OsmCourt> _osmCourts = [];
  bool _isFetchingOsm = false;
  Timer? _osmDebounce;
  LatLng? _lastSearchCenter;
  bool _showRadar = true;
  bool _showMatches = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCenter();
    // Background sync of pending courts
    Future.microtask(() => ref.read(courtsRepositoryProvider).syncPendingCourts());
  }

  @override
  void dispose() {
    _osmDebounce?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCenter() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('map_lat');
    final lng = prefs.getDouble('map_lng');
    final zoom = prefs.getDouble('map_zoom');
    
    if (lat != null && lng != null && zoom != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _mapController.move(LatLng(lat, lng), zoom);
      });
    }
  }

  Future<void> _saveMapCenter() async {
    final prefs = await SharedPreferences.getInstance();
    final center = _mapController.camera.center;
    final zoom = _mapController.camera.zoom;
    await prefs.setDouble('map_lat', center.latitude);
    await prefs.setDouble('map_lng', center.longitude);
    await prefs.setDouble('map_zoom', zoom);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.positionSaved),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _fetchOsmCourts({bool immediate = false}) {
    if (_osmDebounce?.isActive ?? false) _osmDebounce!.cancel();
    
    final fetchAction = () async {
      if (!mounted || _selectedSource != RadarDataSource.osm) return;

      final currentCenter = _mapController.camera.center;
      setState(() {
        _isFetchingOsm = true;
        _lastSearchCenter = currentCenter;
      });

      try {
        final courts = await ref.read(osmRepositoryProvider).fetchNearbyCourts(
          currentCenter.latitude, 
          currentCenter.longitude,
          radius: 10000,
        );
        if (mounted) {
          setState(() => _osmCourts = courts);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.osmFoundCount(courts.length)),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.blueAccent,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isFetchingOsm = false);
      }
    };

    if (immediate) {
      fetchAction();
    } else {
      _osmDebounce = Timer(const Duration(milliseconds: 1000), fetchAction);
    }
  }

  void _zoomIn() {
    _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
  }

  void _zoomOut() {
    _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1);
  }

  void _showAddCourtForm(LatLng position, {String? name, String? description, int? hoops, bool? lights, String? sourceId, String source = 'trnmnt'}) {
    if (!_isAddingMode && name == null) return;
    
    setState(() => _isAddingMode = false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddCourtForm(
          position: position,
          initialName: name,
          initialDescription: description,
          initialHoops: hoops,
          initialLights: lights,
          initialSource: source,
          initialSourceId: sourceId,
          onSave: (name, description, hoops, nets, courtStatus, linesStatus, hasLights, stars, source, sourceId) async {
            final repo = ref.read(courtsRepositoryProvider);
            await repo.insertCourt(CourtsCompanion.insert(
              name: name,
              description: drift.Value(description),
              latitude: position.latitude,
              longitude: position.longitude,
              hoops: drift.Value(hoops),
              netsStatus: drift.Value(nets),
              courtStatus: drift.Value(courtStatus),
              linesStatus: drift.Value(linesStatus),
              hasLights: drift.Value(hasLights),
              stars: drift.Value(stars),
              source: drift.Value(source),
              sourceId: drift.Value(sourceId),
            ));
            if (mounted) {
              setState(() => _selectedSource = RadarDataSource.local);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.courtSaved)),
              );
              // Trigger sync and refresh cloud data
              ref.invalidate(cloudCourtsProvider);
            }
          },
        ),
      ),
    );
  }

  void _showCourtDetails(Court court) {
    // Find associated tournaments and live matches
    final tournaments = ref.read(radarTournamentsProvider).value ?? [];
    final liveMatches = ref.read(liveMatchesProvider).value ?? [];
    
    final List<Map<String, dynamic>> associatedItems = [];
    
    // 1. Find Tournaments
    for (final t in tournaments) {
      try {
        final data = t['data'] as Map<String, dynamic>?;
        final tourney = (data?['tournament'] ?? data) as Map<String, dynamic>?;
        if (tourney == null) continue;

        final vcid = t['venue_court_id'] ?? t['venueCourtId'] ?? tourney['venue_court_id'] ?? tourney['venueCourtId'];
        bool matches = false;
        if (vcid != null) {
          matches = vcid.toString() == court.cloudId || 
                    vcid.toString() == court.sourceId || 
                    vcid.toString() == court.id.toString();
        }
        
        if (matches) {
          associatedItems.add({
            ...t,
            'type': 'tournament',
            'courtName': court.name,
          });
        }
      } catch (_) {}
    }

    // 2. Find Standalone Live Matches
    for (final lm in liveMatches) {
      try {
        final vcid = lm['venue_court_id'] ?? lm['venueCourtId'];
        if (vcid != null && (vcid.toString() == court.cloudId || vcid.toString() == court.sourceId || vcid.toString() == court.id.toString())) {
          associatedItems.add({
            ...lm,
            'type': 'match',
            'courtName': court.name,
          });
        }
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _DetailsSheet(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(court.name.toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
                  if (court.cloudId != null) 
                    const Tooltip(message: 'Verified Court', child: Icon(Icons.verified, color: Colors.blue, size: 20)),
                ],
              ),
              const SizedBox(height: 8),
              if (court.description != null && court.description!.isNotEmpty)
                Text(court.description!, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 16),
              _DetailGrid(
                items: [
                  _DetailItem(icon: Icons.sports_basketball, label: AppLocalizations.of(context)!.hoops, value: court.hoops.toString(), color: Colors.orange),
                  _DetailItem(icon: Icons.grid_on, label: AppLocalizations.of(context)!.netsLabel, value: _translateNets(context, court.netsStatus ?? 'N/D'), color: Colors.blue),
                  _DetailItem(icon: Icons.lightbulb, label: AppLocalizations.of(context)!.litLabel, value: court.hasLights == true ? AppLocalizations.of(context)!.yes : AppLocalizations.of(context)!.no, color: Colors.yellow),
                  _DetailItem(icon: Icons.star, label: AppLocalizations.of(context)!.rating, value: "${court.stars}/5", color: Colors.amber),
                  _DetailItem(icon: Icons.square_foot, label: AppLocalizations.of(context)!.courtTitle, value: (court.courtStatus ?? 'giocabile').toUpperCase(), color: Colors.green),
                  _DetailItem(icon: Icons.linear_scale, label: AppLocalizations.of(context)!.linesTitle, value: (court.linesStatus ?? 'visibili').toUpperCase(), color: Colors.white70),
                ],
              ),
              if (associatedItems.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Divider(color: Colors.white10),
                const SizedBox(height: 16),
                Text(
                  '${associatedItems.length} EVENTI IN CORSO O PROGRAMMATI',
                  style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                ),
                const SizedBox(height: 16),
                _RadarCourtEventsList(items: associatedItems, liveMatches: liveMatches),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showOsmCourtDetails(OsmCourt court) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetailsSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.public, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Expanded(child: Text(court.name.toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
              ],
            ),
            const SizedBox(height: 16),
            if (court.address != null) ...[
              Text(AppLocalizations.of(context)!.addressLabel, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
              Text(court.address!, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 12),
            ],
            _DetailGrid(
              items: [
                if (court.surface != null) _DetailItem(icon: Icons.layers, label: AppLocalizations.of(context)!.surfaceLabel, value: court.surface!.toUpperCase(), color: Colors.cyan),
                if (court.hoops != null) _DetailItem(icon: Icons.sports_basketball, label: AppLocalizations.of(context)!.hoopsLabel, value: court.hoops!, color: Colors.orange),
                if (court.lit != null) _DetailItem(icon: Icons.wb_sunny, label: AppLocalizations.of(context)!.litLabel, value: court.lit == 'yes' ? AppLocalizations.of(context)!.yes : AppLocalizations.of(context)!.no, color: Colors.yellow),
                if (court.access != null) _DetailItem(icon: Icons.door_front_door, label: AppLocalizations.of(context)!.accessLabel, value: court.access!.toUpperCase(), color: Colors.greenAccent),
              ],
            ),
            const SizedBox(height: 16),
            if (court.checkDate != null)
              Text("${AppLocalizations.of(context)!.lastCheckLabel} ${court.checkDate}", style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.close))),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                    onPressed: () {
                      Navigator.pop(context);
                      _showAddCourtForm(
                        LatLng(court.lat, court.lon),
                        name: court.name,
                        description: 'OSM: ${court.address ?? ''}\nSurface: ${court.surface ?? ''}',
                        hoops: int.tryParse(court.hoops ?? '2'),
                        lights: court.lit == 'yes',
                        sourceId: court.id,
                        source: 'osm',
                      );
                    },
                    child: Text(AppLocalizations.of(context)!.addToMyCourts, style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTournamentDetails(List<Map<String, dynamic>> items, List<dynamic> liveMatches) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _DetailsSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (items.length > 1) ...[
              Text(
                '${items.length} EVENTI IN QUESTA LOCATION',
                style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
            ],
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 32),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isMatch = item['type'] == 'match';

                  if (isMatch) {
                    // ── PARTITA SINGOLA ──────────────────────────────────
                    final title = item['match_title']?.toString() ?? item['matchTitle']?.toString();
                    final home = item['home_team_name']?.toString() ?? item['homeTeamName']?.toString() ?? '?';
                    final away = item['away_team_name']?.toString() ?? item['awayTeamName']?.toString() ?? '?';
                    final homeScore = item['home_score']?.toString() ?? item['homeScore']?.toString() ?? '0';
                    final awayScore = item['away_score']?.toString() ?? item['awayScore']?.toString() ?? '0';
                    final timer = item['timer']?.toString() ?? '';
                    final courtName = item['courtName']?.toString();
                    final matchId = item['id']?.toString();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.sports_basketball, color: Colors.orange, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                title ?? '$home vs $away'.toUpperCase(),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (courtName != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.grey, size: 12),
                              const SizedBox(width: 4),
                              Text(courtName, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        // Score board
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(child: Text(home, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis)),
                              Text(homeScore, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text('–', style: TextStyle(fontSize: 18, color: Colors.grey)),
                              ),
                              Text(awayScore, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                              Expanded(child: Text(away, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ),
                        if (timer.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Center(
                            child: Text(timer, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: matchId == null ? null : () async {
                              Navigator.pop(context);
                              // Set the initial tab to Live Matches (index 1)
                              ref.read(hubInitialTabIndexProvider.notifier).state = 1;
                              // Set the selected match ID to highlight/reorder it
                              ref.read(hubSelectedMatchIdProvider.notifier).state = matchId;
                              // Navigate to Hub
                              context.go('/hub');
                            },
                            child: const Text('SEGUI LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                          ),
                        ),
                      ],
                    );
                  }

                  // ── TORNEO ──────────────────────────────────────────────
                  final t = item;
                  final data = t['data'] as Map<String, dynamic>?;
                  final tourney = data?['tournament'] as Map<String, dynamic>?;
                  final hasLiveMatchEntry = liveMatches.any((lm) => 
                    lm['tournament_id'].toString() == t['id'].toString() || 
                    (lm['id'] != null && lm['id'].toString().startsWith('${t['id']}_'))
                  );
                  final hasRunningMatchInSnapshot = (data?['matches'] as List?)?.any((m) => m['isRunning'] == true || m['is_running'] == true) ?? false;
                  final isLive = hasLiveMatchEntry || hasRunningMatchInSnapshot;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          TournamentStatusBadge(data: data ?? {}, isLiveOverride: isLive),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              (tourney?['name'] ?? 'Tournament').toUpperCase(),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.grey, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              t['courtName'] ?? tourney?['location'] ?? 'N/D', 
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          TournamentModeBadge(mode: tourney?['mode']?.toString() ?? 'group_only'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isLive ? Colors.green : Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                             Navigator.pop(context);
                             final cloudId = t['id']?.toString();
                             if (cloudId != null) {
                               context.go('/hub/tournament/$cloudId');
                             }
                          },
                          child: const Text('VEDI DETTAGLI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }


  String _translateNets(BuildContext context, String value) {
    switch (value) {
      case 'ferro': return AppLocalizations.of(context)!.metal;
      case 'stoffa': return AppLocalizations.of(context)!.cloth;
      case 'rotte': return AppLocalizations.of(context)!.broken;
      case 'non presenti': return AppLocalizations.of(context)!.notPresent;
      default: return value;
    }
  }



  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final courtsAsync = ref.watch(mergedCourtsProvider);
    final osmEnabled = ref.watch(osmSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.radar.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _searchCenter,
              initialZoom: 13.0,
              onTap: (tapPosition, point) => _showAddCourtForm(point),
              onPositionChanged: (position, hasGesture) {
                if (hasGesture && _selectedSource == RadarDataSource.osm) {
                  setState(() {}); // Force rebuild to evaluate if button should show
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _isSatellite
                  ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                  : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.trnmnt.app',
              ),
              
              if (_selectedSource == RadarDataSource.local)
                courtsAsync.when(
                  data: (courts) => MarkerLayer(
                    markers: courts.map((court) => Marker(
                      point: LatLng(court.latitude, court.longitude),
                      width: 40,
                      height: 40,
                      child: _CourtMarker(
                        color: court.cloudId != null ? Colors.deepOrange : Colors.orange,
                        icon: court.cloudId != null ? Icons.verified : Icons.sports_basketball,
                        onTap: () => _showCourtDetails(court),
                      ),
                    )).toList(),
                  ),
                  loading: () => const MarkerLayer(markers: []),
                  error: (_, __) => const MarkerLayer(markers: []),
                ),

              if (_selectedSource == RadarDataSource.osm && osmEnabled)
                MarkerLayer(
                  markers: _osmCourts.map((court) => Marker(
                    point: LatLng(court.lat, court.lon),
                    width: 40,
                    height: 40,
                    child: _CourtMarker(
                      color: Colors.blueAccent,
                      icon: Icons.public,
                      onTap: () => _showOsmCourtDetails(court),
                    ),
                  )).toList(),
                ),
              
              // Radar Tournaments & Live Matches Layer
              () {
                final tournaments = ref.watch(radarTournamentsProvider).value ?? [];
                final liveMatches = ref.watch(liveMatchesProvider).value ?? [];
                final courts = courtsAsync.value ?? [];
                
                if (!_showRadar && !_showMatches) return const MarkerLayer(markers: []);

                // Group items by coordinate
                final Map<String, List<Map<String, dynamic>>> groups = {};
                
                // 1. Process Tournaments
                for (final t in tournaments) {
                  try {
                    final data = t['data'] as Map<String, dynamic>?;
                    final tourney = (data?['tournament'] ?? data) as Map<String, dynamic>?;
                    if (tourney == null) continue;

                    // Visibility checks for tournaments
                    final winnerId = tourney['winner_team_id'] ?? tourney['winnerTeamId'];
                    final isCompleted = tourney['isCompleted'] == true || tourney['is_completed'] == true;
                    final statusStr = tourney['status']?.toString().toLowerCase();
                    
                    if (winnerId != null && winnerId.toString().trim().isNotEmpty) continue;
                    if (isCompleted) continue;
                    if (statusStr == 'concluded' || statusStr == 'completed' || statusStr == 'finished') continue;

                    // Date check
                    final startDateVal = tourney['startDate'];
                    if (startDateVal != null) {
                      final now = DateTime.now();
                      DateTime? start;
                      if (startDateVal is String) start = DateTime.tryParse(startDateVal);
                      else if (startDateVal is int) start = DateTime.fromMillisecondsSinceEpoch(startDateVal);

                      if (start != null) {
                        DateTime? end;
                        final endDateVal = tourney['endDate'];
                        if (endDateVal is String) end = DateTime.tryParse(endDateVal);
                        else if (endDateVal is int) end = DateTime.fromMillisecondsSinceEpoch(endDateVal);
                        end ??= start.add(const Duration(hours: 8));
                        if (now.isAfter(end)) continue;
                      }
                    }

                    double? lat;
                    double? lon;
                    Court? matchingCourt;
                    final vcid = t['venue_court_id'] ?? t['venueCourtId'] ?? tourney['venue_court_id'] ?? tourney['venueCourtId'];
                    if (vcid != null) {
                      matchingCourt = courts.where((c) => 
                        c.cloudId == vcid.toString() || c.sourceId == vcid.toString() || c.id.toString() == vcid.toString()
                      ).firstOrNull;
                      if (matchingCourt != null) {
                        lat = matchingCourt.latitude;
                        lon = matchingCourt.longitude;
                      }
                    }
                    if (lat == null || lon == null) {
                      lat = (tourney['latitude'] as num?)?.toDouble();
                      lon = (tourney['longitude'] as num?)?.toDouble();
                    }
                    
                    if (lat != null && lon != null) {
                      final key = '${lat.toStringAsFixed(6)}_${lon.toStringAsFixed(6)}';
                      if (!groups.containsKey(key)) groups[key] = [];
                      groups[key]!.add({
                        ...t, 
                        'type': 'tournament',
                        'finalLat': lat, 
                        'finalLon': lon,
                        'courtName': matchingCourt?.name,
                      });
                    }
                  } catch (_) {}
                }

                // 2. Process Standalone Live Matches
                for (final lm in liveMatches) {
                  try {
                    if (lm['tournament_id'] != null && lm['tournament_id'] != 'standalone') continue;
                    
                    final vcid = lm['venue_court_id'] ?? lm['venueCourtId'];
                    if (vcid == null) continue;

                    final matchingCourt = courts.where((c) => 
                      c.cloudId == vcid.toString() || c.sourceId == vcid.toString() || c.id.toString() == vcid.toString()
                    ).firstOrNull;

                    if (matchingCourt != null) {
                      final lat = matchingCourt.latitude;
                      final lon = matchingCourt.longitude;
                      final key = '${lat.toStringAsFixed(6)}_${lon.toStringAsFixed(6)}';
                      
                      if (!groups.containsKey(key)) groups[key] = [];
                      groups[key]!.add({
                        ...lm,
                        'type': 'match',
                        'finalLat': lat,
                        'finalLon': lon,
                        'courtName': matchingCourt.name,
                      });
                    }
                  } catch (_) {}
                }

                // 3. Filter groups based on visibility toggles
                final filteredGroups = groups.entries.where((entry) {
                  final items = entry.value;
                  final visibleItems = items.where((it) {
                    if (it['type'] == 'tournament' && !_showRadar) return false;
                    if (it['type'] == 'match' && !_showMatches) return false;
                    return true;
                  }).toList();
                  
                  if (visibleItems.isEmpty) return false;
                  
                  for (final item in items) {
                    if (item['type'] == 'match') return true;
                    final data = item['data'] as Map<String, dynamic>?;
                    final tourney = (data?['tournament'] ?? data) as Map<String, dynamic>?;
                    if (tourney == null) continue;

                    final startDateVal = tourney['startDate'] ?? tourney['start_date'];
                    final endDateVal = tourney['endDate'] ?? tourney['end_date'];
                    DateTime? startDate = startDateVal is String ? DateTime.tryParse(startDateVal) : (startDateVal is int ? DateTime.fromMillisecondsSinceEpoch(startDateVal) : null);
                    DateTime? endDate = endDateVal is String ? DateTime.tryParse(endDateVal) : (endDateVal is int ? DateTime.fromMillisecondsSinceEpoch(endDateVal) : null);
                    final now = DateTime.now();
                    
                    if (startDate == null) return true;
                    final isFuture = now.isBefore(startDate);
                    final isPast = endDate != null ? now.isAfter(endDate) : now.isAfter(startDate.add(const Duration(hours: 24)));
                    
                    if (isFuture || !isPast) return true;
                  }
                  return false;
                }).toList();

                return MarkerLayer(
                  markers: filteredGroups.map((entry) {
                    final allItems = entry.value;
                    final items = allItems.where((it) {
                      if (it['type'] == 'tournament' && !_showRadar) return false;
                      if (it['type'] == 'match' && !_showMatches) return false;
                      return true;
                    }).toList();
                    
                    if (items.isEmpty) return const Marker(point: LatLng(0,0), child: SizedBox.shrink());

                    final first = items[0];
                    Color markerColor = Colors.blue;
                    bool anyLive = false;
                    bool anyUpcoming = false;

                    for (final item in items) {
                      if (item['type'] == 'match') {
                        anyLive = true;
                        continue;
                      }
                      final tourney = Map<String, dynamic>.from(item['data']?['tournament'] ?? item);
                      final startDateVal = tourney['startDate'] ?? tourney['start_date'];
                      final endDateVal = tourney['endDate'] ?? tourney['end_date'];
                      
                      DateTime? startDate = startDateVal is String ? DateTime.tryParse(startDateVal) : (startDateVal is int ? DateTime.fromMillisecondsSinceEpoch(startDateVal) : null);
                      DateTime? endDate = endDateVal is String ? DateTime.tryParse(endDateVal) : (endDateVal is int ? DateTime.fromMillisecondsSinceEpoch(endDateVal) : null);
                      final now = DateTime.now();
                      
                      if (startDate == null || now.isBefore(startDate)) {
                        anyUpcoming = true;
                      } else {
                        bool isConcluded = endDate != null ? now.isAfter(endDate) : now.isAfter(startDate.add(const Duration(hours: 24)));
                        if (!isConcluded) anyLive = true;
                      }
                    }

                    if (anyLive) {
                      final isMatchOnly = items.every((it) => it['type'] == 'match');
                      markerColor = isMatchOnly ? Colors.orange : Colors.green;
                    } else if (anyUpcoming) {
                      markerColor = Colors.blue;
                    } else {
                      markerColor = Colors.grey;
                    }
                    
                    final isTournament = items.any((it) => it['type'] == 'tournament');
                    final displayName = first['courtName'] ?? (isTournament ? Map<String, dynamic>.from(items.firstWhere((it) => it['type'] == 'tournament')['data']?['tournament'] ?? items.firstWhere((it) => it['type'] == 'tournament'))['name'] : first['match_title'] ?? 'Match');

                    return Marker(
                      point: LatLng(first['finalLat'], first['finalLon']),
                      width: 100,
                      height: 100,
                      child: _TournamentMarker(
                        color: markerColor,
                        count: items.length,
                        label: displayName,
                        isMatch: !isTournament,
                        onTap: () => _showTournamentDetails(items, liveMatches),
                      ),
                    );
                  }).toList(),
                );
              }(),
            ],
          ),

          // Source Selector
          if (osmEnabled)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                  child: SegmentedButton<RadarDataSource>(
                    style: SegmentedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      selectedBackgroundColor: Colors.white24,
                      side: BorderSide.none,
                    ),
                    segments: [
                      ButtonSegment(value: RadarDataSource.local, label: Text(l10n.radarDataSourceLocal, style: const TextStyle(fontSize: 11)), icon: const Icon(Icons.person_pin, size: 16)),
                      ButtonSegment(value: RadarDataSource.osm, label: Text(l10n.radarDataSourceOsm, style: const TextStyle(fontSize: 11)), icon: const Icon(Icons.public, size: 16)),
                    ],
                    selected: {_selectedSource},
                    onSelectionChanged: (set) {
                      setState(() {
                        _selectedSource = set.first;
                        _isAddingMode = false; // Reset adding mode when changing source
                      });
                      if (_selectedSource == RadarDataSource.osm) {
                        _fetchOsmCourts(immediate: true);
                      }
                    },
                  ),
                ),
              ),
            ),

          // Global Loading Indicator (Sync Status)
          Builder(
            builder: (context) {
              final cloudAsync = ref.watch(cloudCourtsProvider);
              final isSyncingTRNMNT = cloudAsync.isLoading;
              
              if (isSyncingTRNMNT || _isFetchingOsm) {
                return Positioned(
                  bottom: 110,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                          const SizedBox(width: 10),
                          Text(
                            isSyncingTRNMNT ? 'Sincronizzazione Radar...' : l10n.syncOsm, 
                            style: const TextStyle(color: Colors.white, fontSize: 12)
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              
              // Only show Search in Area button if we are in OSM mode and moved enough
              if (osmEnabled && _selectedSource == RadarDataSource.osm) {
                final currentCenter = _mapController.camera.center;
                final dist = _lastSearchCenter == null ? 1.0 : 
                    (currentCenter.latitude - _lastSearchCenter!.latitude).abs() + 
                    (currentCenter.longitude - _lastSearchCenter!.longitude).abs();
                
                if (dist > 0.002) {
                   return Positioned(
                    bottom: 110,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                        onPressed: () => _fetchOsmCourts(immediate: true),
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: Text(l10n.searchInArea, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ).animate().fadeIn().scale(),
                    ),
                  );
                }
              }
              return const SizedBox.shrink();
            }
          ),

          if (_isAddingMode)
            Positioned(
              top: 80,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)),
                child: Text(l10n.tapMapToAdd, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),

          Positioned(
            bottom: 24,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _MapFab(
                  icon: _showMatches ? Icons.sports_basketball : Icons.sports_basketball_outlined,
                  onTap: () => setState(() => _showMatches = !_showMatches),
                  color: _showMatches ? Colors.orange : null,
                ),
                const SizedBox(height: 8),
                _MapFab(
                  icon: _showRadar ? Icons.emoji_events : Icons.emoji_events_outlined,
                  onTap: () => setState(() => _showRadar = !_showRadar),
                  color: _showRadar ? Colors.blue : null,
                ),
                const SizedBox(height: 8),
                _MapFab(icon: Icons.save, onTap: _saveMapCenter),
                const SizedBox(height: 8),
                _MapFab(icon: _isSatellite ? Icons.map : Icons.satellite, onTap: () => setState(() => _isSatellite = !_isSatellite)),
                const SizedBox(height: 8),
                _MapFab(icon: Icons.add, onTap: _zoomIn),
                const SizedBox(height: 8),
                _MapFab(icon: Icons.remove, onTap: _zoomOut),
                if (_selectedSource == RadarDataSource.local) ...[
                  const SizedBox(height: 16),
                  FloatingActionButton.extended(
                    heroTag: 'add_court_fab',
                    backgroundColor: Colors.orange,
                    onPressed: () => setState(() => _isAddingMode = true),
                    icon: const Icon(Icons.add_location_alt, color: Colors.white),
                    label: Text(l10n.addAction, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic value) {
    if (value == null) return '';
    DateTime? dt;
    if (value is String) dt = DateTime.tryParse(value);
    if (value is int) dt = DateTime.fromMillisecondsSinceEpoch(value);
    if (dt == null) return value.toString();
    return "${dt.day}/${dt.month}/${dt.year}";
  }
}

class _CourtMarker extends StatelessWidget {
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const _CourtMarker({required this.color, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _DetailsSheet extends StatelessWidget {
  final Widget child;
  const _DetailsSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: child,
    );
  }
}

class _MapFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  const _MapFab({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: null,
      onPressed: onTap,
      backgroundColor: color ?? Colors.black54,
      child: Icon(icon, color: Colors.white),
    );
  }
}

class _DetailGrid extends StatelessWidget {
  final List<_DetailItem> items;
  const _DetailGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.8,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: items,
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailItem({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label.toUpperCase(), style: const TextStyle(fontSize: 7, color: Colors.grey, fontWeight: FontWeight.bold)),
                Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarCourtEventsList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final List<dynamic> liveMatches;

  const _RadarCourtEventsList({required this.items, required this.liveMatches});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isTournament = item['type'] == 'tournament';
        final data = item['data'] as Map<String, dynamic>?;
        final tourney = (data?['tournament'] ?? data) as Map<String, dynamic>?;
        
        final String title = isTournament 
            ? (tourney?['name'] ?? 'Tournament') 
            : 'Match';
        final String subtitle = isTournament 
            ? '${(data?['teams'] as List?)?.length ?? 0} SQUADRE • ${tourney?['mode']?.toString().toUpperCase() ?? ''}'
            : 'Partita Singola';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isTournament ? Colors.orange.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isTournament ? Icons.emoji_events : Icons.sports_basketball,
                color: isTournament ? Colors.orange : Colors.blue,
                size: 20,
              ),
            ),
            title: Text(
              title.toUpperCase(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white24),
            onTap: () {
              if (isTournament) {
                final id = item['id']?.toString();
                if (id != null) context.push('/cloud/tournaments/$id');
              }
            },
          ),
        );
      },
    );
  }
}

class AddCourtForm extends StatefulWidget {
  final LatLng position;
  final String? initialName;
  final String? initialDescription;
  final int? initialHoops;
  final bool? initialLights;
  final String? initialSource;
  final String? initialSourceId;
  final void Function(String name, String description, int hoops, String nets, String court, String lines, bool lights, int stars, String source, String? sourceId) onSave;

  const AddCourtForm({
    Key? key,
    required this.position,
    required this.onSave,
    this.initialName,
    this.initialDescription,
    this.initialHoops,
    this.initialLights,
    this.initialSource,
    this.initialSourceId,
  }) : super(key: key);

  @override
  State<AddCourtForm> createState() => _AddCourtFormState();
}

class _AddCourtFormState extends State<AddCourtForm> {
  late final _nameController = TextEditingController(text: widget.initialName);
  late final _descController = TextEditingController(text: widget.initialDescription);
  late int _hoops = widget.initialHoops ?? 2;
  String _nets = 'stoffa';
  String _court = 'giocabile';
  String _lines = 'visibili';
  late bool _lights = widget.initialLights ?? true;
  int _stars = 3;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.newCourtTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController, 
              decoration: InputDecoration(
                labelText: l10n.nameLabel, 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.location_on_outlined),
              )
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController, 
              maxLines: 2, 
              decoration: InputDecoration(
                labelText: l10n.descLabel, 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.description_outlined),
              )
            ),
            const SizedBox(height: 20),
            
            // Hoops and Lights Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.sports_basketball, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(l10n.hoops),
                        const Spacer(),
                        IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => setState(() => _hoops = _hoops > 1 ? _hoops - 1 : 1)),
                        Text(_hoops.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => setState(() => _hoops = _hoops + 1)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            SwitchListTile(
              secondary: Icon(Icons.lightbulb, color: _lights ? Colors.yellow : Colors.grey),
              title: Text(l10n.lightsTitle),
              subtitle: Text(l10n.litLabel),
              value: _lights,
              onChanged: (v) => setState(() => _lights = v),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: Colors.white.withOpacity(0.05),
            ),
            const SizedBox(height: 12),

            // Dropdowns row
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _nets,
                    items: [
                      DropdownMenuItem(value: 'stoffa', child: Text(l10n.cloth)),
                      DropdownMenuItem(value: 'ferro', child: Text(l10n.metal)),
                      DropdownMenuItem(value: 'rotte', child: Text(l10n.broken)),
                      DropdownMenuItem(value: 'non presenti', child: Text(l10n.notPresent)),
                    ],
                    onChanged: (v) => setState(() => _nets = v!),
                    decoration: InputDecoration(
                      labelText: l10n.netsTitle,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _court,
                    items: [
                      DropdownMenuItem(value: 'ben mantenuto', child: Text(l10n.wellMaintained)),
                      DropdownMenuItem(value: 'giocabile', child: Text(l10n.playable)),
                      DropdownMenuItem(value: 'preso male', child: Text(l10n.poorCondition)),
                    ],
                    onChanged: (v) => setState(() => _court = v!),
                    decoration: InputDecoration(
                      labelText: l10n.courtTitle,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _lines,
              items: [
                DropdownMenuItem(value: 'ben definite', child: Text(l10n.wellDefined)),
                DropdownMenuItem(value: 'visibili', child: Text(l10n.visible)),
                DropdownMenuItem(value: 'rovinate', child: Text(l10n.damaged)),
              ],
              onChanged: (v) => setState(() => _lines = v!),
              decoration: InputDecoration(
                labelText: l10n.linesTitle,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 20),
            Text(l10n.rating, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => IconButton(
                onPressed: () => setState(() => _stars = index + 1),
                icon: Icon(index < _stars ? Icons.star : Icons.star_border, color: Colors.amber, size: 28),
              )),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, 
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                widget.onSave(
                  _nameController.text, 
                  _descController.text, 
                  _hoops, 
                  _nets, 
                  _court, 
                  _lines, 
                  _lights, 
                  _stars,
                  widget.initialSource ?? 'trnmnt',
                  widget.initialSourceId,
                );
              },
              child: Text(l10n.saveAction, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}

class _TournamentMarker extends StatelessWidget {
  final Color color;
  final int count;
  final String? label;
  final VoidCallback onTap;
  final bool isMatch;
  
  const _TournamentMarker({
    required this.color, 
    required this.onTap, 
    this.count = 1, 
    this.label,
    this.isMatch = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ).animate(onPlay: (c) => c.repeat()).scale(duration: 1.seconds, begin: const Offset(1, 1), end: const Offset(1.3, 1.3)).fadeOut(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(color: color.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)
                  ],
                ),
                child: Icon(
                  isMatch ? Icons.sports_basketball : Icons.emoji_events,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              if (count > 1)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
            ],
          ),
          if (label != null)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                label!.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}

