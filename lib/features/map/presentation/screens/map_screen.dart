import 'dart:async';
import 'package:flutter/material.dart';
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

enum MapDataSource { local, osm }

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  final LatLng _defaultCenter = const LatLng(45.4408, 12.3155); // Venice
  bool _isAddingMode = false;
  bool _isSatellite = true;
  LatLng _searchCenter = const LatLng(45.4408, 12.3155);
  
  MapDataSource _selectedSource = MapDataSource.local;
  List<OsmCourt> _osmCourts = [];
  bool _isFetchingOsm = false;
  Timer? _osmDebounce;
  LatLng? _lastSearchCenter;

  @override
  void initState() {
    super.initState();
    _loadSavedCenter();
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
      if (!mounted || _selectedSource != MapDataSource.osm) return;

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

  void _showAddCourtForm(LatLng position, {String? name, String? description, int? hoops, bool? lights, String? osmId, String source = 'trnmnt'}) {
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
          initialOsmId: osmId,
          onSave: (name, description, hoops, nets, courtStatus, linesStatus, hasLights, stars, source, osmId) async {
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
              osmId: drift.Value(osmId),
            ));
            if (mounted) {
              setState(() => _selectedSource = MapDataSource.local);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.courtSaved)),
              );
            }
          },
        ),
      ),
    );
  }

  void _showCourtDetails(Court court) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetailsSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(court.name.toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
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
            const SizedBox(height: 24),
          ],
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
                        osmId: court.id,
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
    final courtsAsync = ref.watch(courtsProvider);
    final osmEnabled = ref.watch(osmSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.courtsMap, style: const TextStyle(fontWeight: FontWeight.w900)),
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
                if (hasGesture && _selectedSource == MapDataSource.osm) {
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
              if (_selectedSource == MapDataSource.local)
                courtsAsync.when(
                  data: (courts) => MarkerLayer(
                    markers: courts.map((court) => Marker(
                      point: LatLng(court.latitude, court.longitude),
                      width: 40,
                      height: 40,
                      child: _CourtMarker(
                        color: Colors.orange,
                        icon: Icons.sports_basketball,
                        onTap: () => _showCourtDetails(court),
                      ),
                    )).toList(),
                  ),
                  loading: () => const MarkerLayer(markers: []),
                  error: (_, __) => const MarkerLayer(markers: []),
                ),
              if (_selectedSource == MapDataSource.osm && osmEnabled)
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
                  child: SegmentedButton<MapDataSource>(
                    style: SegmentedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      selectedBackgroundColor: Colors.white24,
                      side: BorderSide.none,
                    ),
                    segments: [
                      ButtonSegment(value: MapDataSource.local, label: Text(l10n.mapDataSourceLocal, style: const TextStyle(fontSize: 11)), icon: const Icon(Icons.person_pin, size: 16)),
                      ButtonSegment(value: MapDataSource.osm, label: Text(l10n.mapDataSourceOsm, style: const TextStyle(fontSize: 11)), icon: const Icon(Icons.public, size: 16)),
                    ],
                    selected: {_selectedSource},
                    onSelectionChanged: (set) {
                      setState(() {
                        _selectedSource = set.first;
                        _isAddingMode = false; // Reset adding mode when changing source
                      });
                      if (_selectedSource == MapDataSource.osm) {
                        _fetchOsmCourts(immediate: true);
                      }
                    },
                  ),
                ),
              ),
            ),

          if (osmEnabled && _selectedSource == MapDataSource.osm)
            Builder(
              builder: (context) {
                final currentCenter = _mapController.camera.center;
                final dist = _lastSearchCenter == null ? 1.0 : 
                    (currentCenter.latitude - _lastSearchCenter!.latitude).abs() + 
                    (currentCenter.longitude - _lastSearchCenter!.longitude).abs();
                
                // Show button if we are fetching OR if we moved enough
                if (_isFetchingOsm || dist > 0.002) {
                  return Positioned(
                    bottom: 110,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _isFetchingOsm 
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                                const SizedBox(width: 10),
                                Text(l10n.syncOsm, style: const TextStyle(color: Colors.white, fontSize: 12)),
                              ],
                            ),
                          )
                        : ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                            onPressed: () => _fetchOsmCourts(immediate: true),
                            icon: const Icon(Icons.refresh, color: Colors.white),
                            label: Text(l10n.searchInArea, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ).animate().fadeIn().scale(),
                    ),
                  );
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
                _MapFab(icon: Icons.save, onTap: _saveMapCenter),
                const SizedBox(height: 8),
                _MapFab(icon: _isSatellite ? Icons.map : Icons.satellite, onTap: () => setState(() => _isSatellite = !_isSatellite)),
                const SizedBox(height: 8),
                _MapFab(icon: Icons.add, onTap: _zoomIn),
                const SizedBox(height: 8),
                _MapFab(icon: Icons.remove, onTap: _zoomOut),
                if (_selectedSource == MapDataSource.local) ...[
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
  const _MapFab({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      onPressed: onTap,
      backgroundColor: Colors.black54,
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

class AddCourtForm extends StatefulWidget {
  final LatLng position;
  final String? initialName;
  final String? initialDescription;
  final int? initialHoops;
  final bool? initialLights;
  final String? initialSource;
  final String? initialOsmId;
  final void Function(String name, String description, int hoops, String nets, String court, String lines, bool lights, int stars, String source, String? osmId) onSave;

  const AddCourtForm({
    Key? key,
    required this.position,
    required this.onSave,
    this.initialName,
    this.initialDescription,
    this.initialHoops,
    this.initialLights,
    this.initialSource,
    this.initialOsmId,
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
                  widget.initialOsmId,
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
