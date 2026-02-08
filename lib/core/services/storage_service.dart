import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';

/// SharedPreferences wrapper for non-sensitive data storage

class StorageService {
  late SharedPreferences _prefs;

  StorageService();

  /// Initialize the storage service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Factory constructor with SharedPreferences instance (for testing)
  StorageService.withPrefs({required SharedPreferences prefs}) : _prefs = prefs;

  // String operations
  Future<bool> setString(String key, String value) async {
    return _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  // Bool operations
  Future<bool> setBool(String key, bool value) async {
    return _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  // Int operations
  Future<bool> setInt(String key, int value) async {
    return _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  // Double operations
  Future<bool> setDouble(String key, double value) async {
    return _prefs.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  // String list operations
  Future<bool> setStringList(String key, List<String> value) async {
    return _prefs.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  // JSON operations
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    return _prefs.setString(key, jsonEncode(value));
  }

  Map<String, dynamic>? getJson(String key) {
    final value = _prefs.getString(key);
    if (value == null) return null;
    return jsonDecode(value) as Map<String, dynamic>;
  }

  // Remove and clear
  Future<bool> remove(String key) async {
    return _prefs.remove(key);
  }

  Future<bool> clear() async {
    return _prefs.clear();
  }

  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  // App-specific convenience methods
  bool get isFirstLaunch {
    return getBool(StorageKeys.isFirstLaunch) ?? true;
  }

  Future<void> setFirstLaunchComplete() async {
    await setBool(StorageKeys.isFirstLaunch, false);
  }

  bool get isOnboardingComplete {
    return getBool(StorageKeys.isOnboardingComplete) ?? false;
  }

  Future<void> setOnboardingComplete() async {
    await setBool(StorageKeys.isOnboardingComplete, true);
  }

  String get selectedLanguage {
    return getString(StorageKeys.selectedLanguage) ?? 'uz';
  }

  Future<void> setSelectedLanguage(String language) async {
    await setString(StorageKeys.selectedLanguage, language);
  }

  String? get themeMode {
    return getString(StorageKeys.themeMode);
  }

  Future<void> setThemeMode(String mode) async {
    await setString(StorageKeys.themeMode, mode);
  }

  String? get userRole {
    return getString(StorageKeys.userRole);
  }

  Future<void> setUserRole(String role) async {
    await setString(StorageKeys.userRole, role);
  }

  bool get notificationsEnabled {
    return getBool(StorageKeys.notificationsEnabled) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await setBool(StorageKeys.notificationsEnabled, enabled);
  }

  bool get autoPlayVideos {
    return getBool(StorageKeys.autoPlayVideos) ?? true;
  }

  Future<void> setAutoPlayVideos(bool enabled) async {
    await setBool(StorageKeys.autoPlayVideos, enabled);
  }
}
