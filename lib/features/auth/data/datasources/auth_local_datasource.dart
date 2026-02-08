import 'dart:convert';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/logger.dart';
import '../models/user_model.dart';

/// Local data source for caching auth data

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearUserCache();
  Future<void> saveUserRole(String role);
  String? getUserRole();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final StorageService _storage;
  final SecureStorageService _secureStorage;

  AuthLocalDataSourceImpl({
    required StorageService storageService,
    required SecureStorageService secureStorageService,
  })  : _storage = storageService,
        _secureStorage = secureStorageService;

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _storage.setString(StorageKeys.cachedUser, userJson);
      await _storage.setUserRole(user.role.value);
      await _secureStorage.saveUserId(user.id);
      AppLogger.debug('User cached successfully');
    } catch (e) {
      AppLogger.error('Error caching user', e);
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userJson = _storage.getString(StorageKeys.cachedUser);
      if (userJson == null) {
        return null;
      }

      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      AppLogger.error('Error getting cached user', e);
      return null;
    }
  }

  @override
  Future<void> clearUserCache() async {
    try {
      await _storage.remove(StorageKeys.cachedUser);
      await _storage.remove(StorageKeys.userRole);
      await _secureStorage.clearAuthData();
      AppLogger.debug('User cache cleared');
    } catch (e) {
      AppLogger.error('Error clearing user cache', e);
    }
  }

  @override
  Future<void> saveUserRole(String role) async {
    await _storage.setUserRole(role);
  }

  @override
  String? getUserRole() {
    return _storage.userRole;
  }
}
