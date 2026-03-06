/// Test configuration for the app
/// Set isTestMode to true to use mock data without backend calls
library;

class TestConfig {
  /// Enable test mode to bypass real auth and use mock data
  static const bool isTestMode = true; // Set to false for production

  /// Test email credentials: email -> password
  static const Map<String, String> testCredentials = {
    'test@autogram.uz': 'Test1234!',
    'sardor@example.com': 'Test1234!',
    'aziza@example.com': 'Test1234!',
  };

  /// Test emails that bypass OTP verification (legacy)
  static const Map<String, String> testEmails = {
    'test@autogram.uz': '123456',
    'sardor@example.com': '123456',
    'aziza@example.com': '123456',
  };

  /// Test phone numbers (legacy, kept for reference)
  static const Map<String, String> testPhones = {
    '+998901234567': '1234',
    '+998909876543': '1234',
    '+998971234567': '1234',
    '+998881234567': '1234',
    '+998891234567': '1234',
  };

  /// Check if an email is a test email
  static bool isTestEmail(String email) {
    return testCredentials.containsKey(email);
  }

  /// Get the password for a test email
  static String? getTestPassword(String email) {
    return testCredentials[email];
  }

  /// Get the OTP code for a test email (legacy)
  static String? getTestOTP(String email) {
    return testEmails[email];
  }

  /// Check if a phone number is a test phone
  static bool isTestPhone(String phone) {
    return testPhones.containsKey(phone);
  }

  /// Get all test emails as a list
  static List<String> get testEmailList => testCredentials.keys.toList();

  /// Get all test phone numbers as a list
  static List<String> get testPhoneList => testPhones.keys.toList();
}
