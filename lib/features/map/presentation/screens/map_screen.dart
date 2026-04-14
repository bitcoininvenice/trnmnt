import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/database/app_database.dart';
import '../../data/courts_repository.dart';
import '../../data/pickroll_repository.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  final LatLng _defaultCenter = const LatLng(45.4408, 12.3155); // Venice
  bool _isAddingMode = false;
  bool _isSatellite = false;
  
  int _dataSourceIndex = 0; // 0: TRNMNT, 1: Pick&Roll
  Set<int> _selectedSources = {0}; 
  LatLng _searchCenter = const LatLng(45.4408, 12.3155);
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadSavedCenter();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSavedCenter() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('map_lat');
    final lng = prefs.getDouble('map_lng');
    final zoom = prefs.getDouble('map_zoom');
    
    if (lat != null && lng != null && zoom != null) {
       _mapController.move(LatLng(lat, lng), zoom);
       if (mounted) setState(() => _searchCenter = LatLng(lat, lng));
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
        SnackBar(content: Text(AppLocalizations.of(context)!.positionSaved)),
      );
    }
  }

  void _zoomIn() {
    _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
  }

  void _zoomOut() {
    _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1);
  }

  void _showAddCourtForm(LatLng position) {
    if (!_isAddingMode) return;
    
    setState(() => _isAddingMode = false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddCourtForm(
          position: position,
          onSave: (name, description, hoops, nets, courtStatus, linesStatus, hasLights, stars) async {
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
            ));
            ref.invalidate(courtsProvider);
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showCourtDetails(Court court) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(court.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (court.description != null && court.description!.isNotEmpty) ...[
              Text(court.description!, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                const Icon(Icons.sports_basketball, color: Colors.orange),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.hoopsCount(court.hoops)),
              ],
            ),
            const SizedBox(height: 8),
            Text('${AppLocalizations.of(context)!.netsTitle}: ${_translateNets(context, court.netsStatus)}'),
            const SizedBox(height: 8),
            Text('${AppLocalizations.of(context)!.courtTitle}: ${_translateCourt(context, court.courtStatus)}'),
            const SizedBox(height: 8),
            Text('${AppLocalizations.of(context)!.linesTitle}: ${_translateLines(context, court.linesStatus)}'),
            const SizedBox(height: 8),
            Text('${AppLocalizations.of(context)!.lightsTitle}: ${court.hasLights ? AppLocalizations.of(context)!.yes : AppLocalizations.of(context)!.no}'),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.starsCount(court.stars)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  index < court.stars ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
              ),
            ),
            const SizedBox(height: 32),
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

  String _translateCourt(BuildContext context, String value) {
    switch (value) {
      case 'ben mantenuto': return AppLocalizations.of(context)!.wellMaintained;
      case 'giocabile': return AppLocalizations.of(context)!.playable;
      case 'preso male': return AppLocalizations.of(context)!.poorCondition;
      default: return value;
    }
  }

  String _translateLines(BuildContext context, String value) {
    switch (value) {
      case 'ben definite': return AppLocalizations.of(context)!.wellDefined;
      case 'visibili': return AppLocalizations.of(context)!.visible;
      case 'rovinate': return AppLocalizations.of(context)!.damaged;
      default: return value;
    }
  }

  void _showPickrollDetails(PickrollCourt court) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.public, color: Colors.blue),
                const SizedBox(width: 8),
                Text('Pick&Roll Street Court', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Text(court.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (court.address != null) ...[
              Text(court.address!, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _onMapPositionChanged(MapCamera camera, bool hasGesture) {
    if (!hasGesture || !_selectedSources.contains(1)) return;
    
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _searchCenter = camera.center);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final courtsAsync = ref.watch(courtsProvider);
    final pickrollAsync = ref.watch(pickrollCourtsProvider(_searchCenter));
    
    ref.listen(pickrollCourtsProvider(_searchCenter), (prev, next) {
      if (next.hasError && _selectedSources.contains(1)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore connessione API Pick&Roll: ${next.error}'), backgroundColor: Colors.red),
          );
        }
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.courtsMap),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 0, label: Text(AppLocalizations.of(context)!.mapDataSourceLocal), icon: const Icon(Icons.people)),
                ButtonSegment(value: 1, label: Text(AppLocalizations.of(context)!.mapDataSourcePickRoll), icon: const Icon(Icons.public)),
              ],
              selected: _selectedSources,
              multiSelectionEnabled: true,
              onSelectionChanged: (set) {
                if (set.isEmpty) return; // Must select at least one
                setState(() {
                  _selectedSources = set;
                  if (_selectedSources.contains(1)) {
                    _searchCenter = _mapController.camera.center;
                  }
                });
              },
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(color: Theme.of(context).colorScheme.surface), // Background for offline
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 13.0,
              onTap: (tapPosition, point) => _showAddCourtForm(point),
              onPositionChanged: _onMapPositionChanged,
            ),
            children: [
              TileLayer(
                urlTemplate: _isSatellite
                  ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                  : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.trnmnt.app',
              ),
              if (_selectedSources.contains(0))
                courtsAsync.when(
                  data: (courts) => MarkerLayer(
                    markers: courts.map((c) => Marker(
                      point: LatLng(c.latitude, c.longitude),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => _showCourtDetails(c),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.orange,
                          size: 40,
                        ),
                      ),
                    )).toList(),
                  ),
                  loading: () => const MarkerLayer(markers: []),
                  error: (e, s) => const MarkerLayer(markers: []),
                ),
              if (_selectedSources.contains(1))
                pickrollAsync.when(
                  data: (courts) => MarkerLayer(
                    markers: courts.map((c) => Marker(
                      point: LatLng(c.lat, c.lng),
                      width: 50,
                      height: 50,
                      child: GestureDetector(
                        onTap: () => _showPickrollDetails(c),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.orange,
                          size: 40,
                        ),
                      ),
                    )).toList(),
                  ),
                  loading: () => const MarkerLayer(markers: []),
                  error: (e, s) => const MarkerLayer(markers: []),
                ),
            ],
          ),
          if (_selectedSources.contains(1) && pickrollAsync.isLoading)
            const Positioned(
              bottom: 100,
              left: 40,
              right: 40,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 16),
                      Text('Sincronizzazione Pick&Roll...', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          if (_isAddingMode)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.orange,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.tapMapInstruction,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => setState(() => _isAddingMode = false),
                      )
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: !_isAddingMode
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'saveCenter',
                  mini: true,
                  backgroundColor: Theme.of(context).cardColor,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  onPressed: _saveMapCenter,
                  child: const Icon(Icons.bookmark),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'layerToggle',
                  mini: true,
                  backgroundColor: Theme.of(context).cardColor,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  onPressed: () => setState(() => _isSatellite = !_isSatellite),
                  child: Icon(_isSatellite ? Icons.map : Icons.satellite),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoomIn',
                  mini: true,
                  backgroundColor: Theme.of(context).cardColor,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  onPressed: _zoomIn,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoomOut',
                  mini: true,
                  backgroundColor: Theme.of(context).cardColor,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  onPressed: _zoomOut,
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(height: 16),
                FloatingActionButton.extended(
                  heroTag: 'addCourt',
                  onPressed: () => setState(() => _isAddingMode = true),
                  icon: const Icon(Icons.add_location),
                  label: Text(AppLocalizations.of(context)!.addAction),
                ),
              ],
            )
          : null,
    );
  }
}

class AddCourtForm extends StatefulWidget {
  final LatLng position;
  final Function(String name, String description, int hoops, String nets, String court, String lines, bool lights, int stars) onSave;

  const AddCourtForm({super.key, required this.position, required this.onSave});

  @override
  State<AddCourtForm> createState() => _AddCourtFormState();
}

class _AddCourtFormState extends State<AddCourtForm> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  int _hoops = 2;
  String _nets = 'stoffa';
  String _court = 'giocabile';
  String _lines = 'visibili';
  bool _lights = true;
  int _stars = 3;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppLocalizations.of(context)!.newCourtTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: _nameController, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.nameLabel)),
            TextField(controller: _descController, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.descLabel)),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('${AppLocalizations.of(context)!.hoops}:'),
                const Spacer(),
                IconButton(icon: const Icon(Icons.remove), onPressed: () => setState(() => _hoops = _hoops > 1 ? _hoops - 1 : 1)),
                Text(_hoops.toString()),
                IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => _hoops++)),
              ],
            ),
            DropdownButtonFormField<String>(
              value: _nets,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.netsTitle),
              items: [
                DropdownMenuItem(value: 'ferro', child: Text(AppLocalizations.of(context)!.metal)),
                DropdownMenuItem(value: 'stoffa', child: Text(AppLocalizations.of(context)!.cloth)),
                DropdownMenuItem(value: 'rotte', child: Text(AppLocalizations.of(context)!.broken)),
                DropdownMenuItem(value: 'non presenti', child: Text(AppLocalizations.of(context)!.notPresent)),
              ],
              onChanged: (v) => setState(() => _nets = v!),
            ),
            DropdownButtonFormField<String>(
              value: _court,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.courtTitle),
              items: [
                DropdownMenuItem(value: 'ben mantenuto', child: Text(AppLocalizations.of(context)!.wellMaintained)),
                DropdownMenuItem(value: 'giocabile', child: Text(AppLocalizations.of(context)!.playable)),
                DropdownMenuItem(value: 'preso male', child: Text(AppLocalizations.of(context)!.poorCondition)),
              ],
              onChanged: (v) => setState(() => _court = v!),
            ),
            DropdownButtonFormField<String>(
              value: _lines,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.linesTitle),
              items: [
                DropdownMenuItem(value: 'ben definite', child: Text(AppLocalizations.of(context)!.wellDefined)),
                DropdownMenuItem(value: 'visibili', child: Text(AppLocalizations.of(context)!.visible)),
                DropdownMenuItem(value: 'rovinate', child: Text(AppLocalizations.of(context)!.damaged)),
              ],
              onChanged: (v) => setState(() => _lines = v!),
            ),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.lightsTitle),
              value: _lights,
              onChanged: (v) => setState(() => _lights = v),
              contentPadding: EdgeInsets.zero,
            ),
            Row(
              children: [
                Text('${AppLocalizations.of(context)!.rating}:'),
                const Spacer(),
                ...List.generate(5, (index) => IconButton(
                  icon: Icon(index < _stars ? Icons.star : Icons.star_border, color: Colors.amber),
                  onPressed: () => setState(() => _stars = index + 1),
                ))
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.trim().isEmpty) return;
                widget.onSave(
                  _nameController.text.trim(),
                  _descController.text.trim(),
                  _hoops,
                  _nets,
                  _court,
                  _lines,
                  _lights,
                  _stars,
                );
              },
              child: Text(AppLocalizations.of(context)!.saveAction),
            )
          ],
        ),
      ),
    );
  }
}
