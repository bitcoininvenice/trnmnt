import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/database/app_database.dart';
import '../../data/courts_repository.dart';

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

  @override
  void initState() {
    super.initState();
    _loadSavedCenter();
  }

  Future<void> _loadSavedCenter() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('map_lat');
    final lng = prefs.getDouble('map_lng');
    final zoom = prefs.getDouble('map_zoom');
    
    if (lat != null && lng != null && zoom != null) {
       _mapController.move(LatLng(lat, lng), zoom);
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
        const SnackBar(content: Text('Posizione mappa salvata!')),
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
                Text('Canestri: ${court.hoops}'),
              ],
            ),
            const SizedBox(height: 8),
            Text('Retine: ${court.netsStatus}'),
            const SizedBox(height: 8),
            Text('Campo: ${court.courtStatus}'),
            const SizedBox(height: 8),
            Text('Linee: ${court.linesStatus}'),
            const SizedBox(height: 8),
            Text('Luci: ${court.hasLights ? "Sì" : "No"}'),
            const SizedBox(height: 16),
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

  @override
  Widget build(BuildContext context) {
    final courtsAsync = ref.watch(courtsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mappa Campetti'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 13.0,
              onTap: (tapPosition, point) => _showAddCourtForm(point),
            ),
            children: [
              TileLayer(
                urlTemplate: _isSatellite
                  ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                  : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.trnmnt.app',
              ),
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
            ],
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
                      const Text(
                        'Tocca la mappa per\naggiungere un campetto',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
                  label: const Text('Aggiungi'),
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
            const Text('Nuovo Campetto', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nome')),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Descrizione')),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Canestri:'),
                const Spacer(),
                IconButton(icon: const Icon(Icons.remove), onPressed: () => setState(() => _hoops = _hoops > 1 ? _hoops - 1 : 1)),
                Text(_hoops.toString()),
                IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => _hoops++)),
              ],
            ),
            DropdownButtonFormField<String>(
              value: _nets,
              decoration: const InputDecoration(labelText: 'Retine'),
              items: ['ferro', 'stoffa', 'rotte', 'non presenti'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _nets = v!),
            ),
            DropdownButtonFormField<String>(
              value: _court,
              decoration: const InputDecoration(labelText: 'Campo'),
              items: ['ben mantenuto', 'giocabile', 'preso male'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _court = v!),
            ),
            DropdownButtonFormField<String>(
              value: _lines,
              decoration: const InputDecoration(labelText: 'Linee'),
              items: ['ben definite', 'visibili', 'rovinate'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _lines = v!),
            ),
            SwitchListTile(
              title: const Text('Luci'),
              value: _lights,
              onChanged: (v) => setState(() => _lights = v),
              contentPadding: EdgeInsets.zero,
            ),
            Row(
              children: [
                const Text('Valutazione:'),
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
              child: const Text('SALVA'),
            )
          ],
        ),
      ),
    );
  }
}
