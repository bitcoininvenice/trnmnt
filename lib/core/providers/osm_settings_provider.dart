import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final osmSettingsProvider = StateNotifierProvider<OsmSettingsNotifier, bool>((ref) {
  return OsmSettingsNotifier();
});

class OsmSettingsNotifier extends StateNotifier<bool> {
  OsmSettingsNotifier() : super(true) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('osm_enabled') ?? true;
  }

  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('osm_enabled', value);
    state = value;
  }
}
