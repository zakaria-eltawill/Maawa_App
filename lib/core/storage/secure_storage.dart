import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Token keys
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyTokenExpiresIn = 'token_expires_in';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserId = 'user_id';

  // Access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  Future<void> setAccessToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  // Refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  Future<void> setRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }

  // Token expiry
  Future<String?> getTokenExpiresIn() async {
    return await _storage.read(key: _keyTokenExpiresIn);
  }

  Future<void> setTokenExpiresIn(String expiresIn) async {
    await _storage.write(key: _keyTokenExpiresIn, value: expiresIn);
  }

  // User role
  Future<String?> getUserRole() async {
    return await _storage.read(key: _keyUserRole);
  }

  Future<void> setUserRole(String role) async {
    await _storage.write(key: _keyUserRole, value: role);
  }

  // User ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  Future<void> setUserId(String userId) async {
    await _storage.write(key: _keyUserId, value: userId);
  }

  // Clear all tokens (logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Clear tokens only (keep other data if needed)
  Future<void> clearTokens() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyTokenExpiresIn);
    await _storage.delete(key: _keyUserRole);
    await _storage.delete(key: _keyUserId);
  }
}

