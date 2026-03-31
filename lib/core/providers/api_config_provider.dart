import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ApiConfig {
  final String baseUrl;
  final bool isConnected;

  ApiConfig({
    required this.baseUrl,
    this.isConnected = false,
  });

  ApiConfig copyWith({
    String? baseUrl,
    bool? isConnected,
  }) {
    return ApiConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

class ApiConfigNotifier extends StateNotifier<ApiConfig> {
  static const String _key = 'api_base_url';
  static const String _defaultUrl = 'https://vesb.vercel.app';

  ApiConfigNotifier() : super(ApiConfig(baseUrl: _defaultUrl)) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString(_key) ?? _defaultUrl;
    state = ApiConfig(baseUrl: savedUrl);
    // Auto test on load
    testConnection();
  }

  Future<void> setUrl(String url) async {
    // Normalize URL
    var normalizedUrl = url.trim();
    if (normalizedUrl.endsWith('/')) {
      normalizedUrl = normalizedUrl.substring(0, normalizedUrl.length - 1);
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, normalizedUrl);
    state = state.copyWith(baseUrl: normalizedUrl, isConnected: false);
    await testConnection();
  }

  Future<bool> testConnection() async {
    try {
      // Test the /health endpoint or similar. 
      // If we don't have one, just try a GET to the base or api/publish (might 405 but still reachable)
      final response = await http.get(Uri.parse('${state.baseUrl}/api/publish')).timeout(const Duration(seconds: 5));
      // Even if 405 Method Not Allowed, it means server is alive
      final isAlive = response.statusCode != 404 && response.statusCode < 500;
      state = state.copyWith(isConnected: isAlive);
      return isAlive;
    } catch (e) {
      state = state.copyWith(isConnected: false);
      return false;
    }
  }
}

final apiConfigProvider = StateNotifierProvider<ApiConfigNotifier, ApiConfig>((ref) {
  return ApiConfigNotifier();
});
