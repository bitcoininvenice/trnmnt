import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trnmnt/features/map/data/courts_repository.dart';
import 'package:trnmnt/features/map/data/osm_repository.dart';
import 'package:trnmnt/core/providers/osm_settings_provider.dart';
import 'package:trnmnt/core/services/geocoding_service.dart';
import 'dart:async';

class CourtPickerSheet extends ConsumerStatefulWidget {
  const CourtPickerSheet({super.key});

  @override
  ConsumerState<CourtPickerSheet> createState() => _CourtPickerSheetState();
}

class _CourtPickerSheetState extends ConsumerState<CourtPickerSheet> {
  final _searchController = TextEditingController();
  List<OsmCourt> _osmResults = [];
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () async {
      if (query.length < 3) {
        setState(() => _osmResults = []);
        return;
      }

      setState(() => _isSearching = true);
      try {
        // First geocode the query to get a center
        final geocoding = ref.read(geocodingServiceProvider);
        final suggestions = await geocoding.searchAddress(query);
        
        if (suggestions.isNotEmpty) {
          final first = suggestions.first;
          final osmRepo = ref.read(osmRepositoryProvider);
          final courts = await osmRepo.fetchNearbyCourts(first.lat, first.lon, radius: 15000);
          if (mounted) setState(() => _osmResults = courts);
        } else {
          if (mounted) setState(() => _osmResults = []);
        }
      } catch (e) {
        // Error handled silently or via UI if needed
      } finally {
        if (mounted) setState(() => _isSearching = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final courtsAsync = ref.watch(courtsProvider);
    final osmEnabled = ref.watch(osmSettingsProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DefaultTabController(
        length: osmEnabled ? 2 : 1,
        child: Column(
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)),
            ),
            TabBar(
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.orange,
              tabs: [
                const Tab(icon: Icon(Icons.person_pin), text: 'I MIEI'),
                if (osmEnabled) const Tab(icon: Icon(Icons.public), text: 'OSM (Cerca)'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Local Courts
                  courtsAsync.when(
                    data: (courts) {
                      if (courts.isEmpty) {
                        return const Center(child: Text('Nessun campetto salvato.'));
                      }
                      return ListView.builder(
                        itemCount: courts.length,
                        itemBuilder: (context, index) {
                          final court = courts[index];
                          return ListTile(
                            leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.sports_basketball, size: 16, color: Colors.white)),
                            title: Text(court.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Valutazione: ${"⭐" * court.stars}', style: const TextStyle(fontSize: 12)),
                            onTap: () => Navigator.pop(context, court.name),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => const Center(child: Text('Errore')),
                  ),
                  
                  // Tab 2: OSM Search
                  if (osmEnabled)
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Cerca città o zona...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: _onSearchChanged,
                          ),
                        ),
                        if (_isSearching)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: LinearProgressIndicator(),
                          ),
                        Expanded(
                          child: _osmResults.isEmpty && !_isSearching
                              ? const Center(child: Text('Cerca una zona per trovare campetti pubblici'))
                              : ListView.builder(
                                  itemCount: _osmResults.length,
                                  itemBuilder: (context, index) {
                                    final court = _osmResults[index];
                                    return ListTile(
                                      leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.stars, size: 16, color: Colors.white)),
                                      title: Text(court.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text(court.address ?? 'Campetto Pubblico'),
                                      onTap: () => Navigator.pop(context, court.name),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
