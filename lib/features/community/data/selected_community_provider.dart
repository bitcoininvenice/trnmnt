import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final selectedCommunityIdProvider = StateNotifierProvider<SelectedCommunityIdNotifier, String?>((ref) {
  return SelectedCommunityIdNotifier();
});

class SelectedCommunityIdNotifier extends StateNotifier<String?> {
  SelectedCommunityIdNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('selected_community_id');
  }

  Future<void> setSelected(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      prefs.remove('selected_community_id');
    } else {
      prefs.setString('selected_community_id', id);
    }
    state = id;
  }
}
