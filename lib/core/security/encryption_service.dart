import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for managing encryption keys securely
class EncryptionService {
  static const _passwordKey = 'trnmnt_db_password';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  /// Gets or creates the database encryption password
  Future<String> getDatabasePassword() async {
    String? password = await _storage.read(key: _passwordKey);
    
    if (password == null) {
      // Generate a strong random password
      password = _generateSecurePassword(32);
      await _storage.write(key: _passwordKey, value: password);
    }
    
    return password;
  }

  /// Generates a cryptographically secure random password
  String _generateSecurePassword(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Deletes the stored password (use with caution - will make database inaccessible)
  Future<void> deletePassword() async {
    await _storage.delete(key: _passwordKey);
  }

  /// Checks if a password exists
  Future<bool> hasPassword() async {
    final password = await _storage.read(key: _passwordKey);
    return password != null;
  }
}
