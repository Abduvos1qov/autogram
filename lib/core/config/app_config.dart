/// App-wide configuration constants

class AppConfig {
  AppConfig._();

  // API Configuration
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;
  static const int reelsPageSize = 10;
  static const int searchPageSize = 20;

  // Video Configuration
  static const int maxVideoDurationSeconds = 60;
  static const int maxVideoSizeMB = 100;
  static const List<String> allowedVideoFormats = ['mp4', 'mov', 'webm'];
  static const int minVideoResolution = 720;

  // Image Configuration
  static const int maxImageSizeMB = 10;
  static const int maxImagesPerListing = 10;
  static const int thumbnailQuality = 80;

  // Cache Configuration
  static const Duration cacheDuration = Duration(hours: 24);
  static const int maxCacheSize = 100; // MB

  // OTP Configuration
  static const int otpLength = 6;
  static const Duration otpResendDelay = Duration(seconds: 60);
  static const Duration otpExpiryDuration = Duration(minutes: 5);

  // Session Configuration
  static const Duration sessionTimeout = Duration(days: 30);

  // Search Configuration
  static const int searchDebounceMs = 500;
  static const int minSearchLength = 2;
  static const int maxSearchHistory = 10;

  // Listing Limits (Free Plan)
  static const int freeListingLimit = 3;
  static const int basicListingLimit = 15;
  static const int proListingLimit = -1; // Unlimited

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
