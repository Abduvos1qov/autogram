/// Test configuration for the app
/// Set isTestMode to true to use mock data without backend calls
library;

class TestConfig {
  /// Enable test mode to bypass OTP and use mock data
  static const bool isTestMode = true; // Set to false for production

  /// Test phone numbers that bypass OTP verification
  /// Format: phone number -> OTP code
  static const Map<String, String> testPhones = {
    '+998901234567': '1234',
    '+998909876543': '1234',
    '+998971234567': '1234',
    '+998881234567': '1234',
    '+998891234567': '1234',
  };

  /// Check if a phone number is a test phone
  static bool isTestPhone(String phone) {
    return testPhones.containsKey(phone);
  }

  /// Get the OTP code for a test phone
  static String? getTestOTP(String phone) {
    return testPhones[phone];
  }

  /// Get all test phone numbers as a list
  static List<String> get testPhoneList => testPhones.keys.toList();
}
