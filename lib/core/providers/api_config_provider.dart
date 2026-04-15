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
  static const String _defaultUrl = 'https://trnmnt.vercel.app';

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
      // Test the base URL. If we can reach it, the web dashboard is likely up.
      final response = await http.get(Uri.parse(state.baseUrl)).timeout(const Duration(seconds: 5));
      
      // Any response code below 500 (even 404 if the server is up but root is missing) 
      // typically means the server is reachable and alive.
      final isAlive = response.statusCode < 500;
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
