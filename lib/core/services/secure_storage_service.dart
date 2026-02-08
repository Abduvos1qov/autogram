import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';

/// Secure storage for sensitive data like tokens

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  // Basic operations
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  Future<bool> containsKey(String key) async {
    return _storage.containsKey(key: key);
  }

  Future<Map<String, String>> readAll() async {
    return _storage.readAll();
  }

  // Token operations
  Future<void> saveAccessToken(String token) async {
    await write(StorageKeys.accessToken, token);
  }

  Future<String?> getAccessToken() async {
    return read(StorageKeys.accessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await write(StorageKeys.refreshToken, token);
  }

  Future<String?> getRefreshToken() async {
    return read(StorageKeys.refreshToken);
  }

  Future<void> saveUserId(String userId) async {
    await write(StorageKeys.userId, userId);
  }

  Future<String?> getUserId() async {
    return read(StorageKeys.userId);
  }

  Future<void> clearAuthData() async {
    await delete(StorageKeys.accessToken);
    await delete(StorageKeys.refreshToken);
    await delete(StorageKeys.userId);
  }

  // FCM token
  Future<void> saveFcmToken(String token) async {
    await write(StorageKeys.fcmToken, token);
  }

  Future<String?> getFcmToken() async {
    return read(StorageKeys.fcmToken);
  }
}
