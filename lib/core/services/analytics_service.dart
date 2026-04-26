import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../env/env.dart';
import 'package:uuid/uuid.dart';

class AnalyticsService {
  static const String _userIdKey = 'anonymous_user_id';
  static String get _hmacSecret => Env.hmacSecret;
  static String? _currentSessionId;
  static DateTime? _sessionStartTime;

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString(_userIdKey);

      if (userId == null) {
        userId = const Uuid().v4();
        await prefs.setString(_userIdKey, userId);
      }

      await _syncUserMetadata(userId);
      await startSession();
    } catch (e) {
      // Silently fail in production
    }
  }

  static String _generateSignature(String payloadText, int timestamp) {
    final message = payloadText + timestamp.toString();
    final key = utf8.encode(_hmacSecret);
    final bytes = utf8.encode(message);

    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return digest.toString();
  }

  static Future<dynamic> _callSecureRpc(Map<String, dynamic> payload) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final payloadText = jsonEncode(payload);
    final signature = _generateSignature(payloadText, timestamp);

    return await Supabase.instance.client.rpc('sync_secure_analytics', params: {
      'p_payload': payloadText,
      'p_timestamp': timestamp,
      'p_signature': signature,
    });
  }

  static Future<void> _syncUserMetadata(String userId) async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();
    
    String model = 'Unknown';
    String osVersion = 'Unknown';
    String platform = Platform.isIOS ? 'ios' : 'android';

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      model = androidInfo.model;
      osVersion = 'Android ${androidInfo.version.release}';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      model = iosInfo.model;
      osVersion = 'iOS ${iosInfo.systemVersion}';
    }

    final supabaseId = Supabase.instance.client.auth.currentUser?.id;

    try {
      await _callSecureRpc({
        'id': userId,
        'device_model': model,
        'os_version': osVersion,
        'app_version': packageInfo.version,
        'platform': platform,
        if (supabaseId != null) 'supabase_id': supabaseId,
      });
    } catch (e) {
      // Ignore
    }
  }

  static Future<void> startSession() async {
    try {
      if (_currentSessionId != null) return; 

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_userIdKey);
      if (userId == null) return;

      final packageInfo = await PackageInfo.fromPlatform();
      final supabaseId = Supabase.instance.client.auth.currentUser?.id;
      _sessionStartTime = DateTime.now();

      final response = await _callSecureRpc({
        'user_id': userId,
        'start_time': _sessionStartTime!.toIso8601String(),
        'app_version': packageInfo.version,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'session_type': 'foreground',
        if (supabaseId != null) 'supabase_id': supabaseId,
      });

      if (response != null && response['id'] != null) {
        _currentSessionId = response['id'].toString();
      }
    } catch (e) {
      // Ignore
    }
  }

  static Future<void> endSession() async {
    try {
      if (_currentSessionId == null || _sessionStartTime == null) return;

      final endTime = DateTime.now();
      final duration = endTime.difference(_sessionStartTime!).inSeconds;

      await _callSecureRpc({
        'id': _currentSessionId,
        'user_id': 'ignore', 
        'start_time': _sessionStartTime!.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'duration_seconds': duration,
      });
      
      _currentSessionId = null;
      _sessionStartTime = null;
    } catch (e) {
      // Ignore
    }
  }
}
