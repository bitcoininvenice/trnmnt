import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final defaultTabProvider = StateNotifierProvider<DefaultTabNotifier, int>((ref) {
  return DefaultTabNotifier();
});

class DefaultTabNotifier extends StateNotifier<int> {
  static const _defaultTabKey = 'default_home_tab';

  DefaultTabNotifier() : super(0) {
    _loadDefaultTab();
  }

  Future<void> _loadDefaultTab() async {
    final prefs = await SharedPreferences.getInstance();
    final tabIndex = prefs.getInt(_defaultTabKey);
    if (tabIndex != null) {
      state = tabIndex;
    }
  }

  Future<void> setDefaultTab(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_defaultTabKey, index);
    state = index;
  }
}
