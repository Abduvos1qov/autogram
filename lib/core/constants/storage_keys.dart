/// Keys for local storage (SharedPreferences and SecureStorage)

class StorageKeys {
  StorageKeys._();

  // Secure Storage Keys (for sensitive data)
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';

  // Shared Preferences Keys
  static const String isFirstLaunch = 'is_first_launch';
  static const String isOnboardingComplete = 'is_onboarding_complete';
  static const String selectedLanguage = 'selected_language';
  static const String themeMode = 'theme_mode';
  static const String userRole = 'user_role';

  // Cache Keys
  static const String cachedUser = 'cached_user';
  static const String cachedSellerProfile = 'cached_seller_profile';
  static const String cachedCategories = 'cached_categories';
  static const String cachedBrands = 'cached_brands';
  static const String searchHistory = 'search_history';
  static const String recentSearches = 'recent_searches';

  // Settings Keys
  static const String notificationsEnabled = 'notifications_enabled';
  static const String autoPlayVideos = 'auto_play_videos';
  static const String dataUsageMode = 'data_usage_mode';
  static const String pushNotificationsEnabled = 'push_notifications_enabled';

  // FCM
  static const String fcmToken = 'fcm_token';
  static const String fcmTokenLastUpdated = 'fcm_token_last_updated';
}
