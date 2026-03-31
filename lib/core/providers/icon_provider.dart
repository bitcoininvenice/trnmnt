import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final customIconProvider = StateNotifierProvider<CustomIconNotifier, String?>((ref) {
  return CustomIconNotifier();
});

class CustomIconNotifier extends StateNotifier<String?> {
  CustomIconNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('custom_app_icon');
  }

  Future<void> setIcon(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_app_icon', path);
    state = path;
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('custom_app_icon');
    state = null;
  }
}
